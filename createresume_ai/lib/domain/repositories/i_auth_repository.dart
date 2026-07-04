import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/user.dart';

/// Authentication repository contract.
///
/// All methods return [Either<Failure, T>] for consistent error handling
/// across the application boundary.
abstract class IAuthRepository {
  /// Signs in with email and password.
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Creates a new account with email and password.
  Future<Either<Failure, User>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  });

  /// Initiates Google OAuth sign-in flow.
  Future<Either<Failure, User>> signInWithGoogle();

  /// Signs the current user out.
  Future<Either<Failure, void>> signOut();

  /// Returns the currently authenticated user, or null if not signed in.
  Future<Either<Failure, User?>> getCurrentUser();

  /// Sends a password-reset email to the given address.
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  /// Streams the authenticated [User], or `null` when signed out.
  Stream<User?> authStateChanges();
}
