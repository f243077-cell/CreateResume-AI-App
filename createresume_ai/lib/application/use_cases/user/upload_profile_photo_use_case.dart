import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/repositories/i_user_profile_repository.dart';

/// Uploads a profile photo and returns the resulting URL.
class UploadProfilePhotoUseCase {
  final IUserProfileRepository _userProfileRepository;

  const UploadProfilePhotoUseCase(this._userProfileRepository);

  Future<Either<Failure, String>> call({
    required String userId,
    required String filePath,
  }) {
    return _userProfileRepository.uploadProfilePhoto(
      userId: userId,
      filePath: filePath,
    );
  }
}
