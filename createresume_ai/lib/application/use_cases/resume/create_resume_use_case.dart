import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/resume.dart';
import '../../../domain/repositories/i_resume_repository.dart';

/// Creates a new resume record.
class CreateResumeUseCase {
  final IResumeRepository _resumeRepository;

  const CreateResumeUseCase(this._resumeRepository);

  Future<Either<Failure, Resume>> call({required Resume resume}) {
    return _resumeRepository.createResume(resume);
  }
}
