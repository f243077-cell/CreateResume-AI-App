import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/use_cases/auth/sign_in_use_case.dart';
import '../../../../application/use_cases/auth/sign_up_use_case.dart';
import '../../../../core/di/service_locator.dart';

/// Form controller for handling the sign-in process.
class SignInController extends AsyncNotifier<void> {
  late final SignInUseCase _signInUseCase;

  @override
  Future<void> build() async {
    _signInUseCase = ref.watch(signInUseCaseProvider);
  }

  /// Attempts to sign in the user. Returns an error message if failed, otherwise null.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    
    final result = await _signInUseCase(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return failure.message;
      },
      (user) {
        state = const AsyncValue.data(null);
        return null;
      },
    );
  }

  /// Initiates the Google sign-in flow.
  Future<String?> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final result = await _signInUseCase.signInWithGoogle();

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return failure.message;
      },
      (_) {
        state = const AsyncValue.data(null);
        return null;
      },
    );
  }
}

final signInControllerProvider =
    AsyncNotifierProvider<SignInController, void>(
  SignInController.new,
);

/// Form controller for handling the sign-up process.
class SignUpController extends AsyncNotifier<void> {
  late final SignUpUseCase _signUpUseCase;

  @override
  Future<void> build() async {
    _signUpUseCase = ref.watch(signUpUseCaseProvider);
  }

  /// Attempts to sign up a new user. Returns an error message if failed, otherwise null.
  Future<String?> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    
    final result = await _signUpUseCase(
      fullName: fullName,
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return failure.message;
      },
      (user) {
        state = const AsyncValue.data(null);
        return null;
      },
    );
  }
}

final signUpControllerProvider =
    AsyncNotifierProvider<SignUpController, void>(
  SignUpController.new,
);
