import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/resume.dart';
import '../../../domain/services/i_ats_scoring_service.dart';
import '../../../domain/value_objects/ats_score.dart';
import '../../../domain/value_objects/keyword_match.dart';

/// Result containing both the ATS score and keyword match analysis.
class AtsAnalysisResult {
  final ATSScore score;
  final KeywordMatch keywordMatch;

  const AtsAnalysisResult({
    required this.score,
    required this.keywordMatch,
  });
}

/// Analyzes a resume's ATS compatibility by scoring it and
/// performing keyword matching against a job description.
class AnalyzeAtsCompatibilityUseCase {
  final IATSScoringService _atsScoringService;

  const AnalyzeAtsCompatibilityUseCase(this._atsScoringService);

  /// Scores the [resume] and matches keywords against [jobDescription].
  ///
  /// Returns an [AtsAnalysisResult] containing both the score and
  /// keyword match data, or a [Failure].
  Future<Either<Failure, AtsAnalysisResult>> call({
    required Resume resume,
    required String resumeText,
    required String jobDescription,
  }) async {
    // Score the resume
    final scoreResult = await _atsScoringService.scoreResume(resume);

    return scoreResult.fold(
      (failure) => Left(failure),
      (score) async {
        // Get keyword match analysis
        final matchResult = await _atsScoringService.getKeywordMatch(
          resumeText: resumeText,
          jobDescription: jobDescription,
        );

        return matchResult.fold(
          (failure) => Left(failure),
          (keywordMatch) => Right(AtsAnalysisResult(
            score: score,
            keywordMatch: keywordMatch,
          )),
        );
      },
    );
  }
}
