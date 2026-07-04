import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/resume.dart';
import '../../../domain/repositories/i_resume_repository.dart';

/// Fetches a single resume by ID.
class GetResumeByIdUseCase {
  final IResumeRepository _resumeRepository;

  const GetResumeByIdUseCase(this._resumeRepository);

  Future<Either<Failure, Resume>> call({required String resumeId}) {
    return _resumeRepository.getResumeById(resumeId);
  }
}
