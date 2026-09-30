import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/providers/auth_state_provider.dart';
import '../../../../application/providers/current_profile_provider.dart';
import '../../../../application/use_cases/user/run_ai_tool_use_case.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/user.dart';

class AiToolState {
  final User? profile;
  final bool isLoading;
  final String? error;
  final bool requiresUpgrade;
  final String? resultText;

  const AiToolState({
    this.profile,
    this.isLoading = false,
    this.error,
    this.requiresUpgrade = false,
    this.resultText,
  });

  AiToolState copyWith({
    User? profile,
    bool? isLoading,
    String? error,
    bool? requiresUpgrade,
    String? resultText,
  }) {
    return AiToolState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      requiresUpgrade: requiresUpgrade ?? this.requiresUpgrade,
      resultText: resultText,
    );
  }
}

class AiToolNotifier extends Notifier<AiToolState> {
  @override
  AiToolState build() {
    // Credits come from the shared profile (E3), so they match every screen.
    final profile = ref.watch(currentProfileProvider);
    return AiToolState(
      profile: profile.value,
      isLoading: profile.isLoading,
      error: profile.hasError ? profile.error.toString() : null,
    );
  }

  Future<void> runTool(AiToolRequest request) async {
    state = state.copyWith(isLoading: true, error: null, resultText: null);

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      state = state.copyWith(isLoading: false, error: 'User not authenticated.');
      return;
    }

    final runToolUseCase = ref.read(runAiToolUseCaseProvider);
    final result = await runToolUseCase.call(
      userId: user.id,
      request: request,
    );

    result.fold(
      (failure) {
        if (failure is InsufficientCreditsFailure) {
          state = state.copyWith(isLoading: false, requiresUpgrade: true);
        } else {
          state = state.copyWith(isLoading: false, error: failure.message);
        }
      },
      (data) {
        state = state.copyWith(
          isLoading: false,
          profile: data.profile,
          resultText: data.resultText,
        );
        // Share the new balance with the other screens.
        ref.read(currentProfileProvider.notifier).setProfile(data.profile);
      },
    );
  }
}

final aiToolProvider = NotifierProvider<AiToolNotifier, AiToolState>(
  AiToolNotifier.new,
);
