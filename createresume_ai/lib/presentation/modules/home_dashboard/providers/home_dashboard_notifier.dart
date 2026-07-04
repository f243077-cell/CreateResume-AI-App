import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/providers/auth_state_provider.dart';
import '../../../../application/providers/connectivity_provider.dart';
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

class HomeDashboardNotifier
    extends AsyncNotifier<HomeDashboardState> {
  @override
  Future<HomeDashboardState> build() async {
    return _fetchData();
  }

  Future<HomeDashboardState> _fetchData() async {
    final getResumes = ref.watch(getResumesUseCaseProvider);
    final user = await ref.watch(authStateProvider.future);
    final isConnected = await ref.watch(connectivityProvider.future);

    if (user == null) {
      return HomeDashboardState(
        user: null,
        recentResumes: [],
        isOffline: !isConnected,
      );
    }

    final resumeResult = await getResumes(userId: user.id);

    final List<Resume> resumes = resumeResult.fold((failure) => [], (resumes) {
      final sorted = List<Resume>.from(resumes)
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return sorted.take(5).toList();
    });

    return HomeDashboardState(
      user: user,
      recentResumes: resumes,
      isOffline: !isConnected,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchData());
  }
}

final homeDashboardProvider =
    AsyncNotifierProvider<HomeDashboardNotifier, HomeDashboardState>(
      HomeDashboardNotifier.new,
    );
