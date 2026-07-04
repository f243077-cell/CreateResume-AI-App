import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/i_auth_repository.dart';

/// Creates a new user account with email, password, and full name.
class SignUpUseCase {
  final IAuthRepository _authRepository;

  const SignUpUseCase(this._authRepository);

  /// Attempts registration and returns the newly created [User] or a [Failure].
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    required String fullName,
  }) {
    return _authRepository.signUpWithEmail(
      email: email,
      password: password,
      fullName: fullName,
    );
  }
}
