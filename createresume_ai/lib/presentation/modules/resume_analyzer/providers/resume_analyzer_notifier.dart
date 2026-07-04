import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/use_cases/resume/analyze_ats_compatibility_use_case.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../domain/entities/resume.dart';

class ResumeAnalyzerNotifier
    extends AsyncNotifier<AtsAnalysisResult> {
  @override
  Future<AtsAnalysisResult> build() async {
    final resumeId = ref.watch(resumeIdProvider);
    return _fetchAndAnalyze(resumeId);
  }

  Future<AtsAnalysisResult> _fetchAndAnalyze(String resumeId) async {
    final getResume = ref.watch(getResumeByIdUseCaseProvider);
    final analyzeAts = ref.watch(analyzeAtsCompatibilityUseCaseProvider);
    final resumeResult = await getResume(resumeId: resumeId);

    final Resume resume = resumeResult.fold((l) => throw l, (r) => r);

    final analysisResult = await analyzeAts.call(
      resume: resume,
      resumeText: resume.title,
      jobDescription: 'Software Engineer, Product Designer, Project Manager',
    );

    return analysisResult.fold((l) => throw l, (r) => r);
  }

  Future<void> reAnalyze() async {
    final resumeId = ref.read(resumeIdProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAndAnalyze(resumeId));
  }
}

final resumeIdProvider = Provider<String>((ref) {
  throw UnimplementedError('resumeIdProvider must be overridden');
});

final resumeAnalyzerProvider = AsyncNotifierProvider<ResumeAnalyzerNotifier, AtsAnalysisResult>(
  ResumeAnalyzerNotifier.new,
);
