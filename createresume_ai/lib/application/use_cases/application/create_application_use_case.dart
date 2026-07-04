import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/application.dart';
import '../../../domain/repositories/i_application_repository.dart';

/// Creates a new job application record.
class CreateApplicationUseCase {
  final IApplicationRepository _applicationRepository;

  const CreateApplicationUseCase(this._applicationRepository);

  Future<Either<Failure, Application>> call({required Application application}) {
    return _applicationRepository.createApplication(application);
  }
}
