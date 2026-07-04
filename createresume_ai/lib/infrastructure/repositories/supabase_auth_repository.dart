import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../services/supabase_database_service.dart';

/// Supabase implementation of [IAuthRepository].
///
/// Maps Supabase auth exceptions to domain [AuthFailure].
class SupabaseAuthRepository implements IAuthRepository {
  final SupabaseDatabaseService _db;

  const SupabaseAuthRepository(this._db);

  // ── IAuthRepository ───────────────────────────────────────────────

  @override
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _db.auth.signInWithPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Sign-in timed out after 30 seconds');
        },
      );

      final supaUser = response.user;
      if (supaUser == null) {
        return const Left(AuthFailure('Sign-in returned no user.'));
      }

      final profile = await _fetchProfile(supaUser.id);
      return Right(profile);
    } on supa.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Sign-in failed: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      
      final response = await _db.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
        emailRedirectTo: null,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Sign-up timed out after 30 seconds. Check your internet connection and Supabase project status.');
        },
      );

      final supaUser = response.user;
      if (supaUser == null) {
        return const Left(AuthFailure('Sign-up returned no user.'));
      }

      // Check if email confirmation is required
      if (response.session == null) {
        return const Left(AuthFailure('Please check your email to confirm your account before signing in.'));
      }

      // Upsert a profile row for the new user.
      await _db.from('profiles').upsert({
        'id': supaUser.id,
        'email': email,
        'full_name': fullName,
        'subscription_status': 'free',
        'credit_balance': 3, // Free starter credits
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Profile upsert timed out after 10 seconds');
        },
      );

      final profile = await _fetchProfile(supaUser.id);
      return Right(profile);
    } on supa.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Sign-up failed: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      await _db.auth.signInWithOAuth(
        supa.OAuthProvider.google,
        redirectTo: 'io.supabase.createresume://login-callback/',
      );

      // OAuth is async — wait for session to settle.
      final session = _db.auth.currentSession;
      if (session == null) {
        return const Left(
          AuthFailure('Google sign-in did not produce a session.'),
        );
      }

      final profile = await _fetchProfile(session.user.id);
      return Right(profile);
    } on supa.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Google sign-in failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _db.auth.signOut();
      return const Right(null);
    } on supa.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Sign-out failed: $e'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final supaUser = _db.auth.currentUser;
      if (supaUser == null) return const Right(null);

      final profile = await _fetchProfile(supaUser.id);
      return Right(profile);
    } catch (e) {
      return Left(AuthFailure('Failed to get current user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _db.auth.resetPasswordForEmail(email);
      return const Right(null);
    } on supa.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Password reset failed: $e'));
    }
  }

  @override
  Stream<User?> authStateChanges() {
    return _db.auth.onAuthStateChange.asyncMap((event) async {
      final supaUser = event.session?.user;
      if (supaUser == null) return null;

      try {
        return await _fetchProfile(supaUser.id);
      } catch (e) {
        // Log the error but return null to avoid breaking the stream
        // In production, consider logging this to a monitoring service
        return null;
      }
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────

  Future<User> _fetchProfile(String userId) async {
    try {
      final response = await _db.from('profiles').select().eq('id', userId).maybeSingle();
      
      if (response == null) {
        // Profile doesn't exist, create a default one
        final user = _db.auth.currentUser;
        if (user == null) {
          throw Exception('No authenticated user found');
        }
        
        final metadata = user.userMetadata ?? {};
        final fullName = metadata['full_name'] as String? ?? 
                         user.email?.split('@')[0] ?? 
                         'User';
        
        await _db.from('profiles').upsert({
          'id': userId,
          'email': user.email,
          'full_name': fullName,
          'subscription_status': 'free',
          'credit_balance': 3,
        });
        
        // Fetch again after creating
        final data = await _db.from('profiles').select().eq('id', userId).single();
        return _mapToUser(data);
      }
      
      return _mapToUser(response);
    } catch (e) {
      throw Exception('Failed to fetch profile for user $userId: $e');
    }
  }

  User _mapToUser(Map<String, dynamic> data) {
    return User(
      id: data['id'] as String,
      email: data['email'] as String,
      fullName: data['full_name'] as String,
      photoUrl: data['photo_url'] as String?,
      subscriptionStatus: (data['subscription_status'] as String?) == 'premium'
          ? SubscriptionStatus.premium
          : SubscriptionStatus.free,
      creditBalance: data['credit_balance'] as int? ?? 0,
      aiWritingStyle: data['ai_writing_style'] as String?,
      themePreference: data['theme_preference'] as String?,
    );
  }
}
