import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/resume.dart';
import '../entities/user.dart';
import '../value_objects/ats_score.dart';
import '../value_objects/keyword_match.dart';

/// ATS (Applicant Tracking System) scoring service contract.
abstract class IATSScoringService {
  /// Scores a resume against ATS best practices, and against
  /// [jobDescription] when one is given. [profile] supplies contact details.
  Future<Either<Failure, ATSScore>> scoreResume(
    Resume resume, {
    String jobDescription = '',
    User? profile,
  });

  /// Analyzes keyword overlap between resume text and a job description.
  Future<Either<Failure, KeywordMatch>> getKeywordMatch({
    required String resumeText,
    required String jobDescription,
  });
}
