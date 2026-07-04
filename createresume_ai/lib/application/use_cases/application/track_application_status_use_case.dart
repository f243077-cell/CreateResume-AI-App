import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/application.dart';
import '../../../domain/repositories/i_application_repository.dart';

/// Updates the status of a tracked job application.
class TrackApplicationStatusUseCase {
  final IApplicationRepository _applicationRepository;

  const TrackApplicationStatusUseCase(this._applicationRepository);

  /// Updates the [status] of the application identified by [applicationId].
  ///
  /// Returns the updated [Application] or a [Failure].
  Future<Either<Failure, Application>> call({
    required String applicationId,
    required ApplicationStatus status,
  }) {
    return _applicationRepository.updateApplicationStatus(
      id: applicationId,
      status: status,
    );
  }
}
