import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;
import 'package:uuid/uuid.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/services/i_ai_content_generator.dart';
import 'supabase_database_service.dart';

/// Calls Supabase Edge Functions for AI content generation.
///
/// Credits are charged by the functions, not here. Each user action sends
/// one Idempotency-Key, reused on retries, so a retry after a timeout is
/// answered from the server's stored result instead of being charged again.
/// Retries: timeouts, network errors, 5xx and 409 (still in flight), with
/// 2 s and 4 s back-off. Other 4xx responses are final.
class AiService implements IAIContentGenerator {
  final SupabaseDatabaseService _db;

  const AiService(this._db);

  // ── IAIContentGenerator ───────────────────────────────────────────

  @override
  Future<Either<Failure, String>> improveSection(String text) =>
      _runAiTool('improve_text', {'text': text});

  @override
  Future<Either<Failure, String>> rewriteBullet(String text) =>
      _runAiTool('rewrite_bullet', {'text': text});

  /// Generate a complete resume from a user description via AI.
  /// Calls the 'dynamic-api' Edge Function.
  Future<Either<Failure, Map<String, dynamic>>> generateResumeFromDescription({
    required String description,
    required String careerStage,
    required String jobTitle,
    required String userId,
    String? jobDescription,
    String? industry,
  }) async {
    try {
      final response = await _invokeWithRetry(
        functionName: 'dynamic-api',
        body: {
          'description': description,
          'careerStage': careerStage,
          'jobTitle': jobTitle,
          if (jobDescription != null && jobDescription.trim().isNotEmpty)
            'jobDescription': jobDescription.trim(),
          if (industry != null && industry.trim().isNotEmpty)
            'industry': industry.trim(),
        },
      );

      final data = _asMap(response);
      final success = data['success'] == true;
      final resume = data['resume'];

      if (success && resume is Map<String, dynamic>) {
        return Right(resume);
      }

      final errorMessage = data['error'] as String?;
      return Left(
        ServerFailure(
          errorMessage ??
              'Failed to generate resume: unexpected response shape: ${data.keys}',
        ),
      );
    } on InsufficientCreditsException catch (e) {
      return Left(InsufficientCreditsFailure(requested: e.requested, available: e.available));
    } on ServerException catch (e) {
      return Left(_serverFailure(e));
    } catch (e) {
      // Catches jsonDecode failures, type cast failures, etc. instead of
      // letting them crash silently or surface as an unhandled exception.
      return Left(ServerFailure('Failed to generate resume: $e'));
    }
  }

  /// Rewrite a bullet point for better impact.
  /// Alias for rewriteBullet to match the requested method name.
  Future<Either<Failure, String>> rewriteBulletPoint(String bulletPoint) async {
    return rewriteBullet(bulletPoint);
  }

  @override
  Future<Either<Failure, String>> generateCoverLetter({
    required String resumeSummary,
    required String companyName,
    required String jobTitle,
  }) =>
      _runAiTool('cover_letter', {
        'resumeSummary': resumeSummary,
        'companyName': companyName,
        'jobTitle': jobTitle,
      });

  @override
  Future<Either<Failure, String>> analyzeSkillGap({
    required String skills,
    required String jobDescription,
  }) =>
      _runAiTool('skill_gap', {
        'skills': skills,
        'jobDescription': jobDescription,
      });

  // ── Helpers ────────────────────────────────────────────────────────

  /// Error body of a failed function call as a map (empty if unreadable).
  Map<String, dynamic> _detailsMap(dynamic details) {
    try {
      if (details is Map<String, dynamic>) return details;
      if (details is String) return jsonDecode(details) as Map<String, dynamic>;
    } catch (_) {}
    return const {};
  }

  /// Runs one action of the 'ai-tools' Edge Function and returns its text.
  Future<Either<Failure, String>> _runAiTool(
    String action,
    Map<String, dynamic> fields,
  ) async {
    try {
      final response = await _invokeWithRetry(
        functionName: 'ai-tools',
        body: {'action': action, ...fields},
      );

      final data = _asMap(response);
      final result = data['result'];
      if (data['success'] == true && result is String && result.trim().isNotEmpty) {
        return Right(result.trim());
      }
      return Left(
        ServerFailure(
          data['error'] as String? ??
              'Unexpected response shape from ai-tools ($action): ${data.keys}',
        ),
      );
    } on InsufficientCreditsException catch (e) {
      return Left(InsufficientCreditsFailure(requested: e.requested, available: e.available));
    } on ServerException catch (e) {
      return Left(_serverFailure(e));
    } catch (e) {
      return Left(ServerFailure('AI request failed: $e'));
    }
  }

  /// Normalizes an Edge Function response into a `Map<String, dynamic>`,
  /// whether it arrives as a raw JSON string or already-decoded map.
  Map<String, dynamic> _asMap(dynamic response) {
    if (response is String) {
      return jsonDecode(response) as Map<String, dynamic>;
    }
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw ServerException(
      'Unexpected response type from Edge Function: ${response.runtimeType}',
    );
  }

  Failure _serverFailure(ServerException e) => e.statusCode == 401
      ? const AuthFailure('Your session has expired. Please sign in again.')
      : ServerFailure(e.message, e.statusCode);

  // ── Retry helper ──────────────────────────────────────────────────

  /// Invokes a Supabase Edge Function with one Idempotency-Key for all
  /// attempts. 402 becomes [InsufficientCreditsException]; other 4xx are
  /// thrown as [ServerException] without retrying.
  Future<dynamic> _invokeWithRetry({
    required String functionName,
    required Map<String, dynamic> body,
  }) async {
    const maxAttempts = 3;
    const backoffDelays = [Duration(seconds: 2), Duration(seconds: 4)];
    final idempotencyKey = const Uuid().v4();

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final isLastAttempt = attempt == maxAttempts - 1;
      try {
        final response = await _db.functions
            .invoke(
              functionName,
              body: body,
              headers: {'Idempotency-Key': idempotencyKey},
            )
            .timeout(const Duration(seconds: 60));
        return response.data;
      } on FunctionException catch (e) {
        final details = _detailsMap(e.details);
        if (e.status == 402) {
          throw InsufficientCreditsException(
            requested: (details['required'] as num?)?.toInt() ?? 0,
            available: (details['available'] as num?)?.toInt() ?? 0,
          );
        }
        final message =
            'Edge Function "$functionName" failed: ${details['error'] ?? 'status ${e.status}'}';
        final retryable = e.status >= 500 || e.status == 409;
        if (!retryable || isLastAttempt) {
          throw ServerException(message, e.status);
        }
      } catch (e) {
        if (e is ServerException || e is InsufficientCreditsException) rethrow;
        if (isLastAttempt) {
          throw ServerException(
            'Edge Function "$functionName" failed after $maxAttempts attempts: $e',
          );
        }
      }
      await Future<void>.delayed(backoffDelays[attempt]);
    }

    throw const ServerException('Unexpected retry loop exit');
  }
}
