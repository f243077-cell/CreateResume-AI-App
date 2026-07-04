import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/providers/auth_state_provider.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../domain/entities/resume.dart';

class AllResumesState {
  final List<Resume> resumes;
  final bool isLoading;
  final String? error;

  const AllResumesState({
    this.resumes = const [],
    this.isLoading = false,
    this.error,
  });

  AllResumesState copyWith({
    List<Resume>? resumes,
    bool? isLoading,
    String? error,
  }) {
    return AllResumesState(
      resumes: resumes ?? this.resumes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AllResumesNotifier extends AsyncNotifier<AllResumesState> {
  @override
  Future<AllResumesState> build() async {
    return _fetchData();
  }

  Future<AllResumesState> _fetchData() async {
    final user = await ref.watch(authStateProvider.future);

    if (user == null) {
      return const AllResumesState(resumes: [], isLoading: false);
    }

    final getResumes = ref.watch(getResumesUseCaseProvider);
    final resumeResult = await getResumes(userId: user.id);

    return resumeResult.fold(
      (failure) => AllResumesState(
        resumes: [],
        isLoading: false,
        error: failure.toString(),
      ),
      (resumes) => AllResumesState(
        resumes: resumes,
        isLoading: false,
      ),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchData());
  }
}

final allResumesProvider =
    AsyncNotifierProvider<AllResumesNotifier, AllResumesState>(
      AllResumesNotifier.new,
    );
