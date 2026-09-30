// File: lib/presentation/modules/resume_wizard/providers/resume_generation_provider.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/providers/auth_state_provider.dart';
import '../../../../application/providers/current_profile_provider.dart';
import '../../../../application/providers/resume_list_provider.dart';
import '../../../../application/use_cases/resume/generate_resume_with_ai_use_case.dart';
import '../../../../core/constants/template_ids.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/resume.dart';

/// AsyncNotifierProvider for AI resume generation.
///
/// State is AsyncValue.Resume?> - null when no resume has been generated yet.
/// Provides the generateResume method to trigger AI generation.
class ResumeGenerationNotifier extends AsyncNotifier<Resume?> {
  /// The last AI-generated resume that failed to save. Kept so [retrySave]
  /// can save it again without paying for a second AI call.
  Resume? _unsavedResume;

  @override
  Resume? build() => null;

  /// Resets generation state back to its initial null value.
  /// Call this whenever the wizard flow is (re)entered, so a
  /// previously-generated resume doesn't leak into a new session.
  void reset() {
    _unsavedResume = null;
    state = const AsyncValue.data(null);
  }

  /// Generates a complete resume from a user description using AI.
  ///
  /// Parameters:
  /// - [description]: User's self-description (experience, skills, education)
  /// - [careerStage]: Career stage (entry-level, mid-level, senior, executive)
  /// - [jobTitle]: Target job title for the resume
  /// - [templateId]: Template ID to use for the resume (nullable, selected after generation)
  /// - [jobDescription]: Optional pasted job posting to target
  /// - [industry]: Optional target industry
  ///
  /// Sets state to AsyncValue.loading() while generating.
  /// On success: sets state to AsyncValue.data(resume); the screen navigates.
  /// On failure: sets state to AsyncValue.error(failure), e.g.
  /// [InsufficientCreditsFailure] or [GeneratedResumeNotSavedFailure].
  Future<void> generateResume({
    required String description,
    required String careerStage,
    required String jobTitle,
    String? templateId,
    String? jobDescription,
    String? industry,
  }) async {
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) {
        state = AsyncValue.error(
          const ServerFailure('User not authenticated'),
          StackTrace.current,
        );
        return;
      }

      state = const AsyncValue.loading();

      final result = await ref.read(generateResumeWithAIUseCaseProvider).call(
        description: description,
        careerStage: careerStage,
        jobTitle: jobTitle,
        templateId: templateId ?? TemplateIds.classic,
        userId: user.id,
        jobDescription: jobDescription,
        industry: industry,
      );
      _applyResult(result);
    } catch (e, stackTrace) {
      state = AsyncValue.error(
        ServerFailure('Unexpected error: ${e.toString()}'),
        stackTrace,
      );
    }
  }

  /// Retries saving the last generated resume after a failed save.
  Future<void> retrySave() async {
    final resume = _unsavedResume;
    final user = ref.read(authStateProvider).value;
    if (resume == null || user == null) return;

    state = const AsyncValue.loading();
    try {
      final result = await ref
          .read(generateResumeWithAIUseCaseProvider)
          .saveGenerated(resume: resume, userId: user.id);
      _applyResult(result);
    } catch (e, stackTrace) {
      state = AsyncValue.error(
        GeneratedResumeNotSavedFailure(resume, 'Unexpected error: $e'),
        stackTrace,
      );
    }
  }

  void _applyResult(Either<Failure, Resume> result) {
    result.fold(
      (failure) {
        _unsavedResume =
            failure is GeneratedResumeNotSavedFailure ? failure.resume : null;
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (resume) {
        _unsavedResume = null;
        ref.invalidate(resumeListProvider);
        // The server charged credits; show the new balance everywhere.
        ref.invalidate(currentProfileProvider);
        state = AsyncValue.data(resume);
      },
    );
  }
}

/// Provider for the ResumeGenerationNotifier.
final resumeGenerationProvider =
    AsyncNotifierProvider<ResumeGenerationNotifier, Resume?>(
      ResumeGenerationNotifier.new,
    );
