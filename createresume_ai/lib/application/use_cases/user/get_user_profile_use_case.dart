import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/i_user_profile_repository.dart';

/// Fetches a user profile by ID.
class GetUserProfileUseCase {
  final IUserProfileRepository _userProfileRepository;

  const GetUserProfileUseCase(this._userProfileRepository);

  Future<Either<Failure, User>> call({required String userId}) {
    return _userProfileRepository.getProfile(userId);
  }
}
