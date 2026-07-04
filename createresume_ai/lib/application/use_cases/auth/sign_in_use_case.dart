import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/i_auth_repository.dart';

/// Signs in an existing user with email and password.
class SignInUseCase {
  final IAuthRepository _authRepository;

  const SignInUseCase(this._authRepository);

  /// Attempts sign-in and returns the authenticated [User] or a [Failure].
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) {
    return _authRepository.signInWithEmail(
      email: email,
      password: password,
    );
  }

  /// Initiates Google OAuth sign-in flow.
  Future<Either<Failure, User>> signInWithGoogle() {
    return _authRepository.signInWithGoogle();
  }
}
