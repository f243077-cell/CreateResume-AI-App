import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/application.dart';

/// Job application tracking repository contract.
abstract class IApplicationRepository {
  /// Fetches all applications belonging to [userId].
  Future<Either<Failure, List<Application>>> getApplications(String userId);

  /// Creates a new application record.
  Future<Either<Failure, Application>> createApplication(
      Application application);

  /// Updates the status of an existing application.
  Future<Either<Failure, Application>> updateApplicationStatus({
    required String id,
    required ApplicationStatus status,
  });

  /// Deletes an application by its [id].
  Future<Either<Failure, void>> deleteApplication(String id);
}
