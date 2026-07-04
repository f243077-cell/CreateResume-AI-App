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
  Future<Either<Failure, String>> improveSection(String text) async {
    try {
      final response = await _invokeWithRetry(
        functionName: 'improve-section',
        body: {'text': text},
      );

      final data = _asMap(response);
      final improved = data['improved_text'];
      if (improved is String) {
        return Right(improved);
      }
      return Left(
        ServerFailure(
          data['error'] as String? ??
              'Unexpected response shape from improve-section: ${data.keys}',
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to improve section: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> rewriteBullet(String text) async {
    try {
      final response = await _invokeWithRetry(
        functionName: 'rewrite-bullet',
        body: {'text': text},
      );

      final data = _asMap(response);
      final rewritten = data['rewritten_text'];
      if (rewritten is String) {
        return Right(rewritten);
      }
      return Left(
        ServerFailure(
          data['error'] as String? ??
              'Unexpected response shape from rewrite-bullet: ${data.keys}',
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to rewrite bullet: $e'));
    }
  }

  /// Generate a complete resume from a user description via AI.
  /// Calls the 'dynamic-api' Edge Function.
  Future<Either<Failure, Map<String, dynamic>>> generateResumeFromDescription({
    required String description,
    required String careerStage,
    required String jobTitle,
    required String userId,
  }) async {
    try {
      final response = await _invokeWithRetry(
        functionName: 'dynamic-api',
        body: {
          'description': description,
          'careerStage': careerStage,
          'jobTitle': jobTitle,
          'userId': userId,
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

  /// Generate a cover letter using AI.
  /// Calls the 'generate-cover-letter' Edge Function.
  Future<Either<Failure, String>> generateCoverLetter({
    required String resumeSummary,
    required String companyName,
    required String jobTitle,
  }) async {
    try {
      final response = await _invokeWithRetry(
        functionName: 'generate-cover-letter',
        body: {
          'resume_summary': resumeSummary,
          'company_name': companyName,
          'job_title': jobTitle,
        },
      );

      final data = _asMap(response);
      final coverLetter = data['cover_letter'];
      if (coverLetter is String) {
        return Right(coverLetter);
      }
      return Left(
        ServerFailure(
          data['error'] as String? ??
              'Unexpected response shape from generate-cover-letter: ${data.keys}',
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to generate cover letter: $e'));
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────

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
            .timeout(const Duration(seconds: 30));

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
