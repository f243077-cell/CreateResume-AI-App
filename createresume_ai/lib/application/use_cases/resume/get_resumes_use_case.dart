import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/resume.dart';
import '../../../domain/repositories/i_resume_repository.dart';

/// Fetches a user's resumes for lists: newest first, without child sections.
class GetResumesUseCase {
  final IResumeRepository _resumeRepository;

  const GetResumesUseCase(this._resumeRepository);

  Future<Either<Failure, List<Resume>>> call({required String userId, int? limit}) {
    return _resumeRepository.getResumeSummaries(userId, limit: limit);
  }
}
