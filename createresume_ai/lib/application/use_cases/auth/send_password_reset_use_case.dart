import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/repositories/i_auth_repository.dart';

/// Sends a password-reset email to the given address.
class SendPasswordResetUseCase {
  final IAuthRepository _authRepository;

  const SendPasswordResetUseCase(this._authRepository);

  Future<Either<Failure, void>> call({required String email}) {
    return _authRepository.sendPasswordResetEmail(email: email);
  }
}
