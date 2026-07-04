import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/providers/auth_state_provider.dart';
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
    _loadProfile();
    return const AiToolState();
  }

  Future<void> _loadProfile() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final getProfile = ref.read(getUserProfileUseCaseProvider);
    final result = await getProfile(userId: user.id);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (profile) => state = state.copyWith(profile: profile),
    );
  }

  Future<void> runTool(String toolName, String input) async {
    state = state.copyWith(isLoading: true, error: null, resultText: null);

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      state = state.copyWith(isLoading: false, error: 'User not authenticated.');
      return;
    }

    final runToolUseCase = ref.read(runAiToolUseCaseProvider);
    final result = await runToolUseCase.call(
      userId: user.id,
      toolName: toolName,
      input: input,
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
      },
    );
  }
}

final aiToolProvider = NotifierProvider<AiToolNotifier, AiToolState>(
  AiToolNotifier.new,
);
