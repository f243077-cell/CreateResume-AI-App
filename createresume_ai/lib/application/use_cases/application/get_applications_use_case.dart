import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/application.dart';
import '../../../domain/repositories/i_application_repository.dart';

/// Fetches all job applications for a user.
class GetApplicationsUseCase {
  final IApplicationRepository _applicationRepository;

  const GetApplicationsUseCase(this._applicationRepository);

  Future<Either<Failure, List<Application>>> call({required String userId}) {
    return _applicationRepository.getApplications(userId);
  }
}
