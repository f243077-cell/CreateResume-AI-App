import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/value_objects/career_stage.dart';

class ResumeWizardState {
  final CareerStage? careerStage;
  final String targetJobTitle;
  final String industry;
  final String? templateId;
  final String? templateCategory;
  final String jobDescription;
  final int currentPageIndex;

  const ResumeWizardState({
    this.careerStage,
    this.targetJobTitle = '',
    this.industry = '',
    this.templateId,
    this.templateCategory,
    this.jobDescription = '',
    this.currentPageIndex = 0,
  });

  ResumeWizardState copyWith({
    CareerStage? careerStage,
    String? targetJobTitle,
    String? industry,
    String? templateId,
    String? templateCategory,
    String? jobDescription,
    int? currentPageIndex,
  }) {
    return ResumeWizardState(
      careerStage: careerStage ?? this.careerStage,
      targetJobTitle: targetJobTitle ?? this.targetJobTitle,
      industry: industry ?? this.industry,
      templateId: templateId ?? this.templateId,
      templateCategory: templateCategory ?? this.templateCategory,
      jobDescription: jobDescription ?? this.jobDescription,
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

  void reset() {
    state = const ResumeWizardState();
  }

  void updateJobTitleAndIndustry(String title, String industry) =>
      state = state.copyWith(targetJobTitle: title, industry: industry);

  void updateJobDescription(String description) =>
      state = state.copyWith(jobDescription: description);

  void updateTemplateId(String templateId) =>
      state = state.copyWith(templateId: templateId);

  void updateTemplateCategory(String category) =>
      state = state.copyWith(templateCategory: category, templateId: null);

  void setPageIndex(int index) =>
      state = state.copyWith(currentPageIndex: index);
}

final resumeWizardProvider =
    NotifierProvider<ResumeWizardNotifier, ResumeWizardState>(
      ResumeWizardNotifier.new,
    );
