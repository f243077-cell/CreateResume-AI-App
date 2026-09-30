import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/service_locator.dart';
import '../../domain/entities/user.dart';
import 'auth_state_provider.dart';

/// The signed-in user's full profile row (credits, contact details, photo),
/// loaded once and shared by every screen, so the credit balance cannot differ
/// between screens. Null when signed out.
///
/// Update it in place after a profile edit ([setProfile]) or when the server
/// reports a new balance ([setCreditBalance]) instead of refetching.
class CurrentProfileNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final getProfile = ref.watch(getUserProfileUseCaseProvider);
    // Reload when the signed-in user changes, not on every token refresh.
    final userId = await ref.watch(authStateProvider.selectAsync((u) => u?.id));
    if (userId == null) return null;

    final result = await getProfile(userId: userId);
    // Fall back to the auth snapshot (no contact fields) if the row is missing.
    return result.fold((_) => ref.read(authStateProvider).value, (profile) => profile);
  }

  void setProfile(User profile) => state = AsyncData(profile);

  void setCreditBalance(int balance) {
    final profile = state.value;
    if (profile != null) state = AsyncData(profile.copyWith(creditBalance: balance));
  }

  /// Reloads from the server, e.g. after credits were spent elsewhere.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final currentProfileProvider =
    AsyncNotifierProvider<CurrentProfileNotifier, User?>(CurrentProfileNotifier.new);
