import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';

/// AI-powered content generation service contract.
abstract class IAIContentGenerator {
  /// Improves the wording and impact of a resume section.
  Future<Either<Failure, String>> improveSection(String text);

  /// Rewrites a single bullet point for clarity and impact.
  Future<Either<Failure, String>> rewriteBullet(String text);

  /// Writes a cover letter from the candidate's background.
  Future<Either<Failure, String>> generateCoverLetter({
    required String resumeSummary,
    required String companyName,
    required String jobTitle,
  });

  /// Compares the candidate's [skills] with a [jobDescription] and describes
  /// matching and missing skills.
  Future<Either<Failure, String>> analyzeSkillGap({
    required String skills,
    required String jobDescription,
  });
}
