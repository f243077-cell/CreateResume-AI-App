import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/providers/resume_list_provider.dart';
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
    // Shared with the dashboard, which shows the first five.
    try {
      final resumes = await ref.watch(resumeListProvider.future);
      return AllResumesState(resumes: resumes, isLoading: false);
    } catch (failure) {
      return AllResumesState(
        resumes: [],
        isLoading: false,
        error: failure.toString(),
      );
    }
  }

  Future<void> refresh() async {
    // Refetch the shared resume list too (e.g. after a delete).
    ref.invalidate(resumeListProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchData());
  }
}

final allResumesProvider =
    AsyncNotifierProvider<AllResumesNotifier, AllResumesState>(
      AllResumesNotifier.new,
    );
