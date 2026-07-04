import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/resume.dart';
import '../../../domain/repositories/i_resume_repository.dart';

/// Fetches all resumes belonging to a user.
class GetResumesUseCase {
  final IResumeRepository _resumeRepository;

  const GetResumesUseCase(this._resumeRepository);

  Future<Either<Failure, List<Resume>>> call({required String userId}) {
    return _resumeRepository.getResumes(userId);
  }
}
