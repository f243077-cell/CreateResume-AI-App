// File: lib/presentation/modules/resume_wizard/providers/resume_generation_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/providers/auth_state_provider.dart';
import '../../../../application/use_cases/resume/generate_resume_with_ai_use_case.dart';
import '../../../../app_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../domain/entities/resume.dart';

/// AsyncNotifierProvider for AI resume generation.
///
/// State is AsyncValue.Resume?> - null when no resume has been generated yet.
/// Provides the generateResume method to trigger AI generation.
class ResumeGenerationNotifier extends AsyncNotifier<Resume?> {
  late final GenerateResumeWithAIUseCase _generateResumeUseCase;

  @override
  Resume? build() {
    _generateResumeUseCase = ref.read(generateResumeWithAIUseCaseProvider);
    return null;
  }

  /// Generates a complete resume from a user description using AI.
  ///
  /// Parameters:
  /// - [description]: User's self-description (experience, skills, education)
  /// - [careerStage]: Career stage (entry-level, mid-level, senior, executive)
  /// - [jobTitle]: Target job title for the resume
  /// - [templateId]: Template ID to use for the resume
  ///
  /// Sets state to AsyncValue.loading() while generating.
  /// On success: sets state to AsyncValue.data(resume) and navigates to ResumeEditor.
  /// On failure: sets state to AsyncValue.error(...).
  Future<void> generateResume({
    required String description,
    required String careerStage,
    required String jobTitle,
    required String templateId,
  }) async {
    try {
      // Get userId from auth state provider
      final user = ref.read(authStateProvider).value;
      if (user == null) {
        state = AsyncValue.error(
          ServerFailure('User not authenticated'),
          StackTrace.current,
        );
        return;
      }

      state = const AsyncValue.loading();

      final result = await _generateResumeUseCase.call(
        description: description,
        careerStage: careerStage,
        jobTitle: jobTitle,
        templateId: templateId,
        userId: user.id,
      );

      result.fold(
        (failure) {
          state = AsyncValue.error(failure, StackTrace.current);
        },
        (resume) {
          state = AsyncValue.data(resume);
          // Navigate to ResumeEditor screen with the generated resume
          ref.read(routerProvider).pushNamed(
            AppRouteNames.resumeEditor,
            pathParameters: {'resumeId': resume.id},
          );
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(
        ServerFailure('Unexpected error: ${e.toString()}'),
        stackTrace,
      );
    }
  }
}

/// Provider for the ResumeGenerationNotifier.
final resumeGenerationProvider =
    AsyncNotifierProvider<ResumeGenerationNotifier, Resume?>(
  ResumeGenerationNotifier.new,
);
