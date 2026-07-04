import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/providers/auth_state_provider.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../domain/entities/resume.dart';

class ResumePickerNotifier extends AsyncNotifier<List<Resume>> {
  @override
  Future<List<Resume>> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return [];

    final getResumes = ref.watch(getResumesUseCaseProvider);
    final result = await getResumes(userId: user.id);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (resumes) => resumes,
    );
  }
}

final resumePickerProvider =
    AsyncNotifierProvider<ResumePickerNotifier, List<Resume>>(
  ResumePickerNotifier.new,
);
