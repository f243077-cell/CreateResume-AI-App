import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/repositories/i_resume_repository.dart';

class DeleteResumeUseCase {
  final IResumeRepository _resumeRepository;

  DeleteResumeUseCase(this._resumeRepository);

  Future<Either<Failure, void>> call({required String resumeId}) async {
    return await _resumeRepository.deleteResume(resumeId);
  }
}
