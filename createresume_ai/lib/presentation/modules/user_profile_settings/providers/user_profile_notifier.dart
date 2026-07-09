import 'package:createresume_app/presentation/modules/home_dashboard/providers/home_dashboard_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../application/providers/auth_state_provider.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../domain/entities/user.dart';

class UserProfileState {
  final User? profile;
  final bool isLoading;
  final String? error;

  const UserProfileState({this.profile, this.isLoading = false, this.error});

  UserProfileState copyWith({
    User? profile,
    bool? isLoading,
    Object? error = _sentinel,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

const _sentinel = Object();

class UserProfileNotifier extends Notifier<UserProfileState> {
  @override
  UserProfileState build() {
    _loadProfile();
    return const UserProfileState(isLoading: true);
  }

  Future<void> _loadProfile() async {
    final userAuth = ref.watch(authStateProvider).value;
    if (userAuth == null) {
      state = const UserProfileState(error: 'Not authenticated');
      return;
    }

    final getProfile = ref.watch(getUserProfileUseCaseProvider);
    final result = await getProfile(userId: userAuth.id);

    result.fold(
      (l) => state = state.copyWith(isLoading: false, error: l.message),
      (profile) => state = state.copyWith(isLoading: false, profile: profile),
    );
  }

  Future<void> updateProfilePhoto() async {
    final userAuth = ref.read(authStateProvider).value;
    if (userAuth == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    state = state.copyWith(isLoading: true, error: null);

    final uploadPhoto = ref.read(uploadProfilePhotoUseCaseProvider);
    final result = await uploadPhoto(
      userId: userAuth.id,
      filePath: pickedFile.path,
    );

    result.fold(
      (l) => state = state.copyWith(isLoading: false, error: l.message),
      (photoUrl) {
        if (state.profile != null) {
          final updated = state.profile!.copyWith(photoUrl: photoUrl);
          state = state.copyWith(isLoading: false, profile: updated);
        } else {
          state = state.copyWith(isLoading: false);
        }
        ref.invalidate(authStateProvider); // ← add this line
        ref.invalidate(homeDashboardProvider);
      },
    );
  }

  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? aiWritingStyle,
  }) async {
    final userAuth = ref.read(authStateProvider).value;
    if (userAuth == null) return;

    state = state.copyWith(isLoading: true, error: null);

    final updateProfile = ref.read(updateUserProfileUseCaseProvider);
    final result = await updateProfile(
      user: userAuth,
      fullName: fullName,
      email: email,
      aiWritingStyle: aiWritingStyle,
    );

    result.fold(
      (l) => state = state.copyWith(isLoading: false, error: l.message),
      (updatedProfile) {
        state = state.copyWith(isLoading: false, profile: updatedProfile);
        ref.invalidate(authStateProvider); // ← add this line
        ref.invalidate(homeDashboardProvider);
      },
    );
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    final signOut = ref.read(signOutUseCaseProvider);
    final result = await signOut();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) => state = const UserProfileState(isLoading: false),
    );
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfileState>(
      UserProfileNotifier.new,
    );
