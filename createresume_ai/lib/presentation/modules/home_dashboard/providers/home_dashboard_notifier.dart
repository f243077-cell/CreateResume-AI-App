import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/providers/connectivity_provider.dart';
import '../../../../application/providers/current_profile_provider.dart';
import '../../../../application/providers/resume_list_provider.dart';
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
    // The shared profile (E3): photo, name and credits edited in Settings or
    // spent in the AI tools show here without a refetch.
    final profileFuture = ref.watch(currentProfileProvider.future);
    // Read, not watch: a connectivity change must not refetch the profile and
    // all resumes. The offline banner watches connectivityProvider directly.
    final isConnected = ref.read(connectivityProvider).value ?? true;

    final user = await profileFuture;
    if (user == null) {
      return HomeDashboardState(
        user: null,
        recentResumes: [],
        isOffline: !isConnected,
      );
    }

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
    // Refetch the shared resume list and profile too (after a delete, or
    // credits used on another device).
    ref.invalidate(resumeListProvider);
    ref.invalidate(currentProfileProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchData());
  }
}

final homeDashboardProvider =
    AsyncNotifierProvider<HomeDashboardNotifier, HomeDashboardState>(
      HomeDashboardNotifier.new,
    );
