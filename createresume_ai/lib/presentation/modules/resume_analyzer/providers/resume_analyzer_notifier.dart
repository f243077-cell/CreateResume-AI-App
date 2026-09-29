import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/providers/auth_state_provider.dart';
import '../../../../application/use_cases/resume/analyze_ats_compatibility_use_case.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../domain/entities/resume.dart';

/// Job description pasted on the resume picker; empty means "score without
/// keyword matching".
class AtsJobDescriptionNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final atsJobDescriptionProvider =
    NotifierProvider<AtsJobDescriptionNotifier, String>(AtsJobDescriptionNotifier.new);

/// Analyzes one resume. Keyed by resume ID (a family) instead of a scoped
/// resumeIdProvider override, which the screen could not see.
class ResumeAnalyzerNotifier
    extends AsyncNotifier<AtsAnalysisResult> {
  ResumeAnalyzerNotifier(this.resumeId);

  final String resumeId;

  @override
  Future<AtsAnalysisResult> build() async {
    // Watch before the first await; re-analyze when the job description changes.
    final jobDescription = ref.watch(atsJobDescriptionProvider);
    return _fetchAndAnalyze(jobDescription);
  }

  Future<AtsAnalysisResult> _fetchAndAnalyze(String jobDescription) async {
    final getResume = ref.read(getResumeByIdUseCaseProvider);
    final analyzeAts = ref.read(analyzeAtsCompatibilityUseCaseProvider);
    final resumeResult = await getResume(resumeId: resumeId);

    final Resume resume = resumeResult.fold((l) => throw l, (r) => r);

    // Contact details live on the profile; scoring still works without it.
    final authUser = ref.read(authStateProvider).value;
    final profile = authUser == null
        ? null
        : (await ref.read(getUserProfileUseCaseProvider)(userId: authUser.id))
            .fold((_) => authUser, (p) => p);

    final analysisResult = await analyzeAts.call(
      resume: resume,
      resumeText: resume.toPlainText(),
      jobDescription: jobDescription,
      profile: profile,
    );

    return analysisResult.fold((l) => throw l, (r) => r);
  }

  Future<void> reAnalyze() async {
    final jobDescription = ref.read(atsJobDescriptionProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAndAnalyze(jobDescription));
  }
}

final resumeAnalyzerProvider = AsyncNotifierProvider.family<
    ResumeAnalyzerNotifier, AtsAnalysisResult, String>(
  ResumeAnalyzerNotifier.new,
);
