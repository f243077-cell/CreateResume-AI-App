import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/services/i_ai_content_generator.dart';
import '../../domain/value_objects/career_stage.dart';
import 'supabase_database_service.dart';

/// Calls Supabase Edge Functions for AI content generation.
///
/// Every call uses a 30 s timeout with exponential backoff retry:
/// attempt 1 → wait 2 s → attempt 2 → wait 4 s → attempt 3 → throw.
class AiService implements IAIContentGenerator {
  final SupabaseDatabaseService _db;

  const AiService(this._db);

  // ── IAIContentGenerator ───────────────────────────────────────────

  @override
  Future<Either<Failure, Map<String, String>>> generateResumeContent({
    required String jobDescription,
    required CareerStage careerStage,
  }) async {
    try {
      final response = await _invokeWithRetry(
        functionName: 'generate-resume',
        body: {
          'job_description': jobDescription,
          'career_stage': careerStage.name,
        },
      );

      final data = _asMap(response);
      final content = data.map((k, v) => MapEntry(k, v.toString()));
      return Right(content);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to generate resume content: $e'));
    }
  }

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
          'userId': userId,
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
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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

  // ── Retry helper ──────────────────────────────────────────────────

  /// Invokes a Supabase Edge Function with 30 s timeout and
  /// exponential backoff: 2 s → retry → 4 s → retry → throw.
  Future<dynamic> _invokeWithRetry({
    required String functionName,
    required Map<String, dynamic> body,
  }) async {
    const maxAttempts = 3;
    const backoffDelays = [Duration(seconds: 2), Duration(seconds: 4)];

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final response = await _db.functions
            .invoke(functionName, body: body)
            .timeout(const Duration(seconds: 60));

        if (response.status != 200) {
          // Try to surface the Edge Function's own error message from the
          // body, since a non-200 response often still carries useful JSON.
          String detail = 'status ${response.status}';
          final rawData = response.data;
          try {
            final map = rawData is String
                ? jsonDecode(rawData) as Map<String, dynamic>
                : rawData as Map<String, dynamic>;
            if (map['error'] != null) {
              detail = map['error'].toString();
            }
          } catch (_) {
            // Body wasn't parseable JSON; fall back to the status-only detail.
          }

          throw ServerException(
            'Edge Function "$functionName" failed: $detail',
            response.status,
          );
        }

        return response.data;
      } catch (e) {
        final isLastAttempt = attempt == maxAttempts - 1;
        if (isLastAttempt) {
          if (e is ServerException) rethrow;
          throw ServerException(
            'Edge Function "$functionName" failed after $maxAttempts attempts: $e',
          );
        }
        await Future<void>.delayed(backoffDelays[attempt]);
      }
    }

    // Unreachable, but satisfies the analyzer.
    throw const ServerException('Unexpected retry loop exit');
  }
}
