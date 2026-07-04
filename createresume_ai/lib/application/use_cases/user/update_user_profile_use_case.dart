import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/i_user_profile_repository.dart';

/// Updates user profile information (name, email, etc.).
class UpdateUserProfileUseCase {
  final IUserProfileRepository _userProfileRepository;

  const UpdateUserProfileUseCase(this._userProfileRepository);

  Future<Either<Failure, User>> call({
    required User user,
    String? fullName,
    String? email,
    String? aiWritingStyle,
  }) async {
    final updatedUser = user.copyWith(
      fullName: fullName ?? user.fullName,
      email: email ?? user.email,
      aiWritingStyle: aiWritingStyle ?? user.aiWritingStyle,
    );
    return await _userProfileRepository.updateProfile(updatedUser);
  }
}
