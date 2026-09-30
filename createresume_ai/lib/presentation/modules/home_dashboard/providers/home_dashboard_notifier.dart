import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/providers/auth_state_provider.dart';
import '../../../../application/providers/connectivity_provider.dart';
import '../../../../application/providers/resume_list_provider.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../domain/entities/resume.dart';
import '../../../../domain/entities/user.dart';

class HomeDashboardState {
  final User? user;
  final List<Resume> recentResumes;
  final bool isOffline;

  HomeDashboardState({
    required this.user,
    required this.recentResumes,
    this.isOffline = false,
  });
}

class HomeDashboardNotifier extends AsyncNotifier<HomeDashboardState> {
  @override
  Future<HomeDashboardState> build() async {
    return _fetchData();
  }

  Future<HomeDashboardState> _fetchData() async {
    // Watch everything before the first await.
    final resumesFuture = ref.watch(resumeListProvider.future);
    final getProfile = ref.watch(getUserProfileUseCaseProvider);
    // Read, not watch: a connectivity change must not refetch the profile and
    // all resumes. The offline banner watches connectivityProvider directly.
    final isConnected = ref.read(connectivityProvider).value ?? true;
    final authUser = await ref.watch(authStateProvider.future);

    if (authUser == null) {
      return HomeDashboardState(
        user: null,
        recentResumes: [],
        isOffline: !isConnected,
      );
    }

    // Fetch the full, up-to-date profile (including photoUrl) directly from
    // the profiles table — the same source the Settings screen uses. This
    // avoids depending on authStateProvider's cached snapshot, which only
    // refreshes on real auth events (sign in/out), not on profile edits.
    final profileResult = await getProfile(userId: authUser.id);
    final user = profileResult.fold(
      (failure) => authUser,
      (profile) => profile,
    );

    // Shared with All Resumes; already newest first.
    List<Resume> resumes;
    try {
      resumes = (await resumesFuture).take(5).toList();
    } catch (_) {
      resumes = [];
    }

    return HomeDashboardState(
      user: user,
      recentResumes: resumes,
      isOffline: !isConnected,
    );
  }

  Future<void> refresh() async {
    // Refetch the shared resume list too (e.g. after a delete).
    ref.invalidate(resumeListProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchData());
  }
}

final homeDashboardProvider =
    AsyncNotifierProvider<HomeDashboardNotifier, HomeDashboardState>(
      HomeDashboardNotifier.new,
    );
