import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/resume.dart';
import '../value_objects/ats_score.dart';
import '../value_objects/keyword_match.dart';

/// ATS (Applicant Tracking System) scoring service contract.
abstract class IATSScoringService {
  /// Scores a resume against ATS best practices.
  Future<Either<Failure, ATSScore>> scoreResume(Resume resume);

  /// Analyzes keyword overlap between resume text and a job description.
  Future<Either<Failure, KeywordMatch>> getKeywordMatch({
    required String resumeText,
    required String jobDescription,
  });
}
