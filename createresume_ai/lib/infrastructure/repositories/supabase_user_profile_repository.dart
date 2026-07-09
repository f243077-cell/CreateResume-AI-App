import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_user_profile_repository.dart';
import '../services/supabase_database_service.dart';
import '../services/supabase_storage_service.dart';

/// Supabase implementation of [IUserProfileRepository].
///
/// Uses the `profiles` table for CRUD and the `profile-photos`
/// storage bucket for photo uploads via [SupabaseStorageService].
class SupabaseUserProfileRepository implements IUserProfileRepository {
  final SupabaseDatabaseService _db;
  final SupabaseStorageService _storage;

  const SupabaseUserProfileRepository(this._db, this._storage);

  @override
  Future<Either<Failure, User>> getProfile(String userId) async {
    try {
      final data = await _db
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return Right(_mapToUser(data));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch profile: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(User user) async {
    try {
      final data = await _db
          .from('profiles')
          .update({
            'full_name': user.fullName,
            'photo_url': user.photoUrl,
            'subscription_status': user.subscriptionStatus.name,
            'credit_balance': user.creditBalance,
            'ai_writing_style': user.aiWritingStyle,
            'theme_preference': user.themePreference,
            'phone': user.phone,
            'location': user.location,
            'job_title': user.jobTitle,
            'linkedin': user.linkedin,
            'github': user.github,
            'leetcode': user.leetcode,
          })
          .eq('id', user.id)
          .select()
          .single();

      return Right(_mapToUser(data));
    } catch (e) {
      return Left(ServerFailure('Failed to update profile: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePhoto({
    required String userId,
    required String filePath,
  }) async {
    try {
      final storagePath = '$userId/avatar.jpg';
      final rawUrl = await _storage.uploadFile(
        bucket: 'profile-photos',
        storagePath: storagePath,
        filePath: filePath,
      );

      // Append a cache-busting query param so Flutter's NetworkImage
      // cache (keyed by URL string) treats each re-upload as a new
      // image instead of serving stale cached bytes for the same path.
      final url = '$rawUrl?v=${DateTime.now().millisecondsSinceEpoch}';

      // Persist the cache-busted URL to profile row so it's consistent
      // on next app load too.
      await _db.from('profiles').update({'photo_url': url}).eq('id', userId);

      return Right(url);
    } catch (e) {
      return Left(ServerFailure('Failed to upload profile photo: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> deductCredits({
    required String userId,
    required int amount,
  }) async {
    try {
      final currentData = await _db
          .from('profiles')
          .select('credit_balance')
          .eq('id', userId)
          .single();
      final currentBalance = currentData['credit_balance'] as int;

      if (currentBalance < amount) {
        return Left(
          InsufficientCreditsFailure(
            requested: amount,
            available: currentBalance,
          ),
        );
      }

      final data = await _db
          .from('profiles')
          .update({'credit_balance': currentBalance - amount})
          .eq('id', userId)
          .select()
          .single();

      return Right(_mapToUser(data));
    } catch (e) {
      if (e is InsufficientCreditsFailure) return Left(e);
      return Left(ServerFailure('Failed to deduct credits: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> addCredits({
    required String userId,
    required int amount,
  }) async {
    try {
      final currentData = await _db
          .from('profiles')
          .select('credit_balance')
          .eq('id', userId)
          .single();
      final currentBalance = currentData['credit_balance'] as int;

      final data = await _db
          .from('profiles')
          .update({'credit_balance': currentBalance + amount})
          .eq('id', userId)
          .select()
          .single();

      return Right(_mapToUser(data));
    } catch (e) {
      return Left(ServerFailure('Failed to add credits: $e'));
    }
  }

  // ── Mapping ───────────────────────────────────────────────────────

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
      phone: data['phone'] as String?,
      location: data['location'] as String?,
      jobTitle: data['job_title'] as String?,
      linkedin: data['linkedin'] as String?,
      github: data['github'] as String?,
      leetcode: data['leetcode'] as String?,
    );
  }
}
