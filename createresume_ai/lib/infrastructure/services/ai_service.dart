import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/services/i_ai_content_generator.dart';
import 'edge_function_client.dart';
import 'supabase_database_service.dart';

/// Calls Supabase Edge Functions for AI content generation.
///
/// Credits are charged by the functions, not here. Calls go through
/// [EdgeFunctionClient] with the AI timeout (45 s) and at most one retry;
/// see it for the idempotency and retry rules.
class AiService implements IAIContentGenerator {
  final EdgeFunctionClient _functions;

  AiService(SupabaseDatabaseService db, {EdgeFunctionClient? functions})
      : _functions = functions ?? EdgeFunctionClient(db);

  Future<dynamic> _invokeWithRetry({
    required String functionName,
    required Map<String, dynamic> body,
    Duration timeout = EdgeFunctionClient.aiTimeout,
  }) =>
      _functions.invoke(
        functionName,
        body,
        timeout: timeout,
        maxRetries: EdgeFunctionClient.aiMaxRetries,
      );

  // ── IAIContentGenerator ───────────────────────────────────────────

  @override
  Future<Either<Failure, String>> improveSection(String text) =>
      _runAiTool('improve_text', {'text': text});

  @override
  Future<Either<Failure, String>> rewriteBullet(String text) =>
      _runAiTool('rewrite_bullet', {'text': text});

  /// Generate a complete resume from a user description via AI.
  /// Calls the 'dynamic-api' Edge Function.
  @override
  Future<Either<Failure, Map<String, dynamic>>> generateResumeFromDescription({
    required String description,
    required String careerStage,
    required String jobTitle,
    String? jobDescription,
    String? industry,
  }) async {
    try {
      final response = await _invokeWithRetry(
        functionName: 'dynamic-api',
        timeout: EdgeFunctionClient.generationTimeout,
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
}
