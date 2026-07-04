import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../value_objects/career_stage.dart';

/// AI-powered content generation service contract.
abstract class IAIContentGenerator {
  /// Generates resume content tailored to a job description and career stage.
  ///
  /// Returns a map of section names to generated content strings.
  Future<Either<Failure, Map<String, String>>> generateResumeContent({
    required String jobDescription,
    required CareerStage careerStage,
  });

  /// Improves the wording and impact of a resume section.
  Future<Either<Failure, String>> improveSection(String text);

  /// Rewrites a single bullet point for clarity and impact.
  Future<Either<Failure, String>> rewriteBullet(String text);
}
