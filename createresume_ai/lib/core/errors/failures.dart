import 'package:equatable/equatable.dart';

/// Base failure class using Equatable for value equality.
///
/// Failures are returned (via Either/Result) from repository implementations
/// to the Application layer, providing a safe, non-throwing error channel.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'An authentication error occurred.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'A network error occurred.']);
}

class InsufficientCreditsFailure extends Failure {
  final int requested;
  final int available;

  const InsufficientCreditsFailure({
    required this.requested,
    required this.available,
  }) : super('Requested $requested credits but only $available available.');

  @override
  List<Object?> get props => [message, requested, available];
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed.']);
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure([super.message = 'A server error occurred.', this.statusCode]);

  @override
  List<Object?> get props => [message, statusCode];
}
