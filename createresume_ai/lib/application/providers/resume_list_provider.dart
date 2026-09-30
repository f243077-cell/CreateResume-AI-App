import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/service_locator.dart';
import '../../domain/entities/resume.dart';
import 'auth_state_provider.dart';

/// Summaries (no child sections) of the signed-in user's resumes, newest
/// first. Shared by the dashboard, All Resumes and the ATS picker so they
/// fetch once. Invalidate after a resume is created, edited or deleted.
final resumeListProvider = FutureProvider<List<Resume>>((ref) async {
  final getResumes = ref.watch(getResumesUseCaseProvider);
  // Refetch when the signed-in user changes, not on every token refresh.
  final userId = await ref.watch(authStateProvider.selectAsync((u) => u?.id));
  if (userId == null) return const [];

  final result = await getResumes(userId: userId);
  return result.fold((failure) => throw failure, (resumes) => resumes);
});
