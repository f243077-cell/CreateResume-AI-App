import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/i_user_profile_repository.dart';

/// Updates user profile information (name, writing style and contact
/// details). Null arguments keep the current value; pass an empty string to
/// clear a contact field.
class UpdateUserProfileUseCase {
  final IUserProfileRepository _userProfileRepository;

  const UpdateUserProfileUseCase(this._userProfileRepository);

  Future<Either<Failure, User>> call({
    required User user,
    String? fullName,
    String? email,
    String? aiWritingStyle,
    String? phone,
    String? location,
    String? jobTitle,
    String? linkedin,
    String? github,
    String? leetcode,
  }) async {
    final updatedUser = user.copyWith(
      fullName: fullName ?? user.fullName,
      email: email ?? user.email,
      aiWritingStyle: aiWritingStyle ?? user.aiWritingStyle,
      phone: phone,
      location: location,
      jobTitle: jobTitle,
      linkedin: linkedin,
      github: github,
      leetcode: leetcode,
    );
    return await _userProfileRepository.updateProfile(updatedUser);
  }
}
