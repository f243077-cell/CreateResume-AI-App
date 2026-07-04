import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/resume.dart';
import '../../../domain/repositories/i_resume_repository.dart';

/// Persists updates to an existing resume.
class UpdateResumeUseCase {
  final IResumeRepository _resumeRepository;

  const UpdateResumeUseCase(this._resumeRepository);

  Future<Either<Failure, Resume>> call({required Resume resume}) {
    return _resumeRepository.updateResume(resume);
  }
}
