import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import 'providers/onboarding_notifier.dart';
import 'widgets/onboarding_slide.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  final List<Widget> _slides = const [
    OnboardingSlide(
      icon: Icons.auto_awesome,
      title: 'AI-Powered Resume Builder',
      description:
          'Craft professional, high-impact resumes in minutes using our advanced AI engine trained on winning profiles.',
    ),
    OnboardingSlide(
      icon: Icons.document_scanner,
      title: 'Beat the Bots',
      description:
          'Our intelligent analyzer ensures your resume is 100% ATS-friendly, targeting the exact keywords recruiters look for.',
    ),
    OnboardingSlide(
      icon: Icons.work,
      title: 'Land Your Dream Role',
      description:
          'Directly apply to top companies with tailored cover letters generated specifically for each role.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    final currentIndex = ref.read(onboardingProvider);
    if (currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.goNamed(AppRouteNames.login);
    }
  }

  void _onSkip() {
    context.goNamed(AppRouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Semantics(
                    button: true,
                    label: 'Skip onboarding',
                    child: TextButton(
                      onPressed: _onSkip,
                      child: const Text('Skip'),
                    ),
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  ref.read(onboardingProvider.notifier).setPage(index);
                },
                children: _slides,
              ),
            ),

            // Bottom Controls
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _slides.length,
                    effect: const ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: AppColors.navy800,
                      dotColor: AppColors.border,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Semantics(
                    button: true,
                    label: currentIndex == _slides.length - 1 ? 'Get started' : 'Next step',
                    child: ElevatedButton(
                      onPressed: _onNext,
                      child: Text(
                        currentIndex == _slides.length - 1 ? 'Get Started' : 'Next Step',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
