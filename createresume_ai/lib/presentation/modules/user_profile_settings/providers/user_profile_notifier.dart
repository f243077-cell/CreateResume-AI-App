import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../application/providers/auth_state_provider.dart';
import '../../../../application/providers/current_profile_provider.dart';
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
    // The shared profile (E3); edits below update it for every screen.
    final profile = ref.watch(currentProfileProvider);
    return UserProfileState(
      profile: profile.value,
      isLoading: profile.isLoading,
      error: profile.hasError ? profile.error.toString() : null,
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
        final profile = state.profile;
        if (profile != null) {
          // Updates the dashboard avatar too; no refetch needed.
          ref
              .read(currentProfileProvider.notifier)
              .setProfile(profile.copyWith(photoUrl: photoUrl));
        } else {
          state = state.copyWith(isLoading: false);
        }
      },
    );
  }

  Future<void> updateProfile({
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
    final userAuth = ref.read(authStateProvider).value;
    if (userAuth == null) return;

    state = state.copyWith(isLoading: true, error: null);

    // Base the update on the loaded profile: the auth snapshot has no contact
    // fields, and the repository writes every column, so using it would wipe
    // phone, location and links on every name change.
    final updateProfile = ref.read(updateUserProfileUseCaseProvider);
    final result = await updateProfile(
      user: state.profile ?? userAuth,
      fullName: fullName,
      email: email,
      aiWritingStyle: aiWritingStyle,
      phone: phone,
      location: location,
      jobTitle: jobTitle,
      linkedin: linkedin,
      github: github,
      leetcode: leetcode,
    );

    result.fold(
      (l) => state = state.copyWith(isLoading: false, error: l.message),
      (updatedProfile) {
        // Every screen showing the profile updates from this.
        ref.read(currentProfileProvider.notifier).setProfile(updatedProfile);
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
