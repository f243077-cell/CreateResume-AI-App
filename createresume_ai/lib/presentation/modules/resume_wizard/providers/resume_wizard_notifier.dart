import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/providers/auth_state_provider.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/resume.dart';
import '../../../../domain/value_objects/career_stage.dart';

class ResumeWizardState {
  final CareerStage? careerStage;
  final String targetJobTitle;
  final String industry;
  final String? templateId;
  final String jobDescription;
  final bool isLoading;
  final String? error;
  final bool requiresUpgrade;
  final int currentPageIndex;

  const ResumeWizardState({
    this.careerStage,
    this.targetJobTitle = '',
    this.industry = '',
    this.templateId,
    this.jobDescription = '',
    this.isLoading = false,
    this.error,
    this.requiresUpgrade = false,
    this.currentPageIndex = 0,
  });

  ResumeWizardState copyWith({
    CareerStage? careerStage,
    String? targetJobTitle,
    String? industry,
    String? templateId,
    String? jobDescription,
    bool? isLoading,
    String? error,
    bool? requiresUpgrade,
    int? currentPageIndex,
  }) {
    return ResumeWizardState(
      careerStage: careerStage ?? this.careerStage,
      targetJobTitle: targetJobTitle ?? this.targetJobTitle,
      industry: industry ?? this.industry,
      templateId: templateId ?? this.templateId,
      jobDescription: jobDescription ?? this.jobDescription,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      requiresUpgrade: requiresUpgrade ?? this.requiresUpgrade,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
    );
  }
}

class ResumeWizardNotifier extends Notifier<ResumeWizardState> {
  @override
  ResumeWizardState build() {
    return const ResumeWizardState();
  }

  void updateCareerStage(CareerStage stage) =>
      state = state.copyWith(careerStage: stage);

  void updateJobTitleAndIndustry(String title, String industry) => state =
      state.copyWith(targetJobTitle: title, industry: industry);

  void updateJobDescription(String description) =>
      state = state.copyWith(jobDescription: description);

  void updateTemplateId(String templateId) =>
      state = state.copyWith(templateId: templateId);

  void setPageIndex(int index) =>
      state = state.copyWith(currentPageIndex: index);

  Future<String?> generateResume() async {
    if (state.careerStage == null) {
      state = state.copyWith(error: 'Please select a career stage.');
      return null;
    }
    if (state.targetJobTitle.isEmpty) {
      state = state.copyWith(error: 'Please enter a target job title.');
      return null;
    }

    state = state.copyWith(isLoading: true, error: null);

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      state = state.copyWith(isLoading: false, error: 'User not authenticated.');
      return null;
    }

    final getProfile = ref.read(getUserProfileUseCaseProvider);
    final profileResult = await getProfile(userId: user.id);
    final credits = profileResult.fold((l) => -1, (u) => u.creditBalance);
    if (credits == 0) {
      state = state.copyWith(isLoading: false, requiresUpgrade: true);
      return null;
    }

    final generateUseCase = ref.read(generateResumeWithAIUseCaseProvider);
    final contentResult = await generateUseCase.call(
      userId: user.id,
      description: state.jobDescription,
      careerStage: state.careerStage!.name,
      jobTitle: state.targetJobTitle,
      templateId: state.templateId ?? 'modern',
    );

    return await contentResult.fold(
      (failure) async {
        if (failure is InsufficientCreditsFailure) {
          state = state.copyWith(isLoading: false, requiresUpgrade: true);
        } else {
          state = state.copyWith(isLoading: false, error: failure.message);
        }
        return null;
      },
      (contentMap) async {
        final createResume = ref.read(createResumeUseCaseProvider);
        final newResume = Resume(
          id: '',
          userId: user.id,
          title: state.targetJobTitle,
          templateId: state.templateId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final createResult = await createResume(resume: newResume);

        return createResult.fold(
          (f) {
            state = state.copyWith(isLoading: false, error: f.message);
            return null;
          },
          (createdResume) {
            state = state.copyWith(isLoading: false);
            return createdResume.id;
          },
        );
      },
    );
  }
}

final resumeWizardProvider =
    NotifierProvider<ResumeWizardNotifier, ResumeWizardState>(
  ResumeWizardNotifier.new,
);
