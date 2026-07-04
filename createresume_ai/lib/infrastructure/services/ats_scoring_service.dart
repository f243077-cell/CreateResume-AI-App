import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/resume.dart';
import '../../domain/services/i_ats_scoring_service.dart';
import '../../domain/value_objects/ats_score.dart';
import '../../domain/value_objects/keyword_match.dart';
import 'supabase_database_service.dart';

/// Calls the `analyze-ats` Supabase Edge Function.
///
/// Uses the same 10 s timeout + exponential backoff retry pattern as [AiService].
class AtsScoringService implements IATSScoringService {
  final SupabaseDatabaseService _db;

  const AtsScoringService(this._db);

  @override
  Future<Either<Failure, ATSScore>> scoreResume(Resume resume) async {
    try {
      final response = await _invokeWithRetry(
        body: {
          'action': 'score',
          'resume_id': resume.id,
          'title': resume.title,
        },
      );

      final data = jsonDecode(response) as Map<String, dynamic>;
      final score = ATSScore(data['score'] as int);
      return Right(score);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('ATS scoring failed: $e'));
    }
  }

  @override
  Future<Either<Failure, KeywordMatch>> getKeywordMatch({
    required String resumeText,
    required String jobDescription,
  }) async {
    try {
      final response = await _invokeWithRetry(
        body: {
          'action': 'keyword_match',
          'resume_text': resumeText,
          'job_description': jobDescription,
        },
      );

      final data = jsonDecode(response) as Map<String, dynamic>;
      return Right(KeywordMatch(
        matchedKeywords: List<String>.from(data['matched_keywords'] as List),
        missingKeywords: List<String>.from(data['missing_keywords'] as List),
        matchPercentage: (data['match_percentage'] as num).toDouble(),
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Keyword matching failed: $e'));
    }
  }

  // ── Retry helper (same pattern as AiService) ─────────────────────

  Future<String> _invokeWithRetry({
    required Map<String, dynamic> body,
  }) async {
    const functionName = 'analyze-ats';
    const maxAttempts = 3;
    const backoffDelays = [Duration(seconds: 1), Duration(seconds: 2)];

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final response = await _db.functions
            .invoke(functionName, body: body)
            .timeout(const Duration(seconds: 10));

        if (response.status != 200) {
          throw ServerException(
            'Edge Function "$functionName" returned ${response.status}',
            response.status,
          );
        }

        return response.data as String;
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

    throw const ServerException('Unexpected retry loop exit');
  }
}
