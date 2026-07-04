import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/repositories/i_auth_repository.dart';

/// Signs the current user out.
class SignOutUseCase {
  final IAuthRepository _authRepository;

  const SignOutUseCase(this._authRepository);

  Future<Either<Failure, void>> call() {
    return _authRepository.signOut();
  }
}
