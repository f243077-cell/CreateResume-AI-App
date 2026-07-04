import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/resume.dart';

/// Resume CRUD and template repository contract.
abstract class IResumeRepository {
  /// Fetches all resumes belonging to [userId].
  Future<Either<Failure, List<Resume>>> getResumes(String userId);

  /// Fetches a single resume by its [id].
  Future<Either<Failure, Resume>> getResumeById(String id);

  /// Creates a new resume and returns the persisted entity.
  Future<Either<Failure, Resume>> createResume(Resume resume);

  /// Persists updates to an existing resume.
  Future<Either<Failure, Resume>> updateResume(Resume resume);

  /// Deletes a resume by its [id].
  Future<Either<Failure, void>> deleteResume(String id);

  /// Returns the list of available resume template identifiers.
  Future<Either<Failure, List<String>>> getTemplates();
}
