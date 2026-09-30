import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/resume.dart';

/// Resume CRUD and template repository contract.
abstract class IResumeRepository {
  /// Resumes for [userId], newest first, without child sections (for
  /// lists). Use [getResumeById] for the full resume.
  Future<Either<Failure, List<Resume>>> getResumeSummaries(String userId, {int? limit});

  /// Fetches a single resume by its [id].
  Future<Either<Failure, Resume>> getResumeById(String id);

  /// Creates a new resume and returns the persisted entity.
  Future<Either<Failure, Resume>> createResume(Resume resume);

  /// Persists updates to an existing resume.
  Future<Either<Failure, Resume>> updateResume(Resume resume);

  /// Deletes a resume by its [id].
  Future<Either<Failure, void>> deleteResume(String id);
}
