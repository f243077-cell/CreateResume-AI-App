import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the current onboarding page index.
class OnboardingNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setPage(int index) => state = index;

  void nextPage(int totalPages) {
    if (state < totalPages - 1) {
      state = state + 1;
    }
  }

  bool get isLastPage => false; // Evaluated at call site with total
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, int>(OnboardingNotifier.new);
