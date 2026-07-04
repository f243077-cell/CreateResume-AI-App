import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A single onboarding slide with an animated icon, headline, and description.
class OnboardingSlide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconBgColor;

  const OnboardingSlide({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.iconBgColor = AppColors.blue100,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Icon container ────────────────────────────
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: iconBgColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.navy800, AppColors.navy500],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy800.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 40),
              ),
            ),
          ),
          const SizedBox(height: 48),

          // ── Title ────────────────────────────────────
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),

          // ── Description ──────────────────────────────
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
