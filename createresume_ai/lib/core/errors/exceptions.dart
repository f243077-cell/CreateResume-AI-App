/// Custom exception types for the CreateResume AI application.
///
/// These are thrown at the Infrastructure layer and caught/mapped
/// to [Failure] types before crossing into the Application layer.
library;

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'An authentication error occurred.']);

  @override
  String toString() => 'AuthException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'A network error occurred.']);

  @override
  String toString() => 'NetworkException: $message';
}

class InsufficientCreditsException implements Exception {
  final int requested;
  final int available;

  const InsufficientCreditsException({
    required this.requested,
    required this.available,
  });

  @override
  String toString() =>
      'InsufficientCreditsException: Requested $requested credits '
      'but only $available available.';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException([this.message = 'Validation failed.']);

  @override
  String toString() => 'ValidationException: $message';
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException([this.message = 'A server error occurred.', this.statusCode]);

  @override
  String toString() => 'ServerException($statusCode): $message';
}
