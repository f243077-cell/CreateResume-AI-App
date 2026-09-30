import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/user.dart';

/// User profile management repository contract.
abstract class IUserProfileRepository {
  /// Fetches the user profile by [userId].
  Future<Either<Failure, User>> getProfile(String userId);

  /// Persists updates to a user profile.
  Future<Either<Failure, User>> updateProfile(User user);

  /// Uploads a profile photo and returns the resulting URL.
  Future<Either<Failure, String>> uploadProfilePhoto({
    required String userId,
    required String filePath,
  });
}
