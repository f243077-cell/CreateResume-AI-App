import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../widgets/shimmer_skeleton.dart';
import '../providers/resume_analyzer_notifier.dart';

class ResumeAnalyzerScreen extends ConsumerWidget {
  final String resumeId;

  const ResumeAnalyzerScreen({super.key, required this.resumeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analyzerState = ref.watch(resumeAnalyzerProvider);

    return ProviderScope(
      overrides: [
        resumeIdProvider.overrideWithValue(resumeId),
      ],
      child: Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: Semantics(
          button: true,
          label: 'Go back',
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        title: const Text('Resume Analyzer'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.read(resumeAnalyzerProvider.notifier).reAnalyze(),
        child: analyzerState.when(
          data: (result) {
            final score = result.score.value;
            final rating = result.score.rating;

            Color scoreColor;
            if (rating == 'excellent') {
              scoreColor = AppColors.success;
            } else if (rating == 'good') {
              scoreColor = AppColors.blue400;
            } else if (rating == 'fair') {
              scoreColor = AppColors.warning;
            } else {
              scoreColor = AppColors.error;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ATS Score Gauge
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.navy800, AppColors.blue400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        CircularPercentIndicator(
                          radius: 80.0,
                          lineWidth: 12.0,
                          animation: true,
                          percent: score / 100,
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$score',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                              Text(
                                'ATS SCORE',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.white70,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: scoreColor,
                          backgroundColor: AppColors.white24,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Great Match!',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your resume is highly compatible with your target role.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Keywords Section
                  Text(
                    'Keywords & Skills',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${result.keywordMatch.matchedKeywords.length} Matched',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: result.keywordMatch.matchedKeywords
                              .map(
                                (kw) => Chip(
                                  label: Text(
                                    kw,
                                    style: const TextStyle(
                                      color: AppColors.success,
                                    ),
                                  ),
                                  backgroundColor: AppColors.success.withValues(
                                    alpha: 0.1,
                                  ),
                                  side: BorderSide(
                                    color: AppColors.success.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '${result.keywordMatch.missingKeywords.length} Missing',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: result.keywordMatch.missingKeywords
                              .map(
                                (kw) => Chip(
                                  label: Text(
                                    kw,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                    ),
                                  ),
                                  backgroundColor: AppColors.error.withValues(
                                    alpha: 0.1,
                                  ),
                                  side: BorderSide(
                                    color: AppColors.error.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Optimization Suggestions
                  Text(
                    'Top Suggestions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSuggestionCard(
                    theme,
                    title: 'Quantify Achievements',
                    content:
                        'Your experience section lacks numbers. Try adding metrics like "Increased revenue by 15%".',
                  ),
                  _buildSuggestionCard(
                    theme,
                    title: 'Add Missing Keywords',
                    content:
                        'We noticed you are missing core skills like ${result.keywordMatch.missingKeywords.take(2).join(", ")}. Consider adding them.',
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    button: true,
                    label: 'Re-analyze resume',
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(resumeAnalyzerProvider.notifier)
                            .reAnalyze();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Re-analyze'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => _buildLoadingSkeleton(theme),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text('Failed to analyze: $e'),
                const SizedBox(height: 16),
                Semantics(
                  button: true,
                  label: 'Retry analyzing resume',
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(resumeAnalyzerProvider.notifier)
                          .reAnalyze();
                    },
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShimmerSkeleton(
            width: 120,
            height: 120,
            borderRadius: BorderRadius.circular(60),
          ),
          const SizedBox(height: 24),
          ShimmerSkeleton(width: 200, height: 24),
          const SizedBox(height: 8),
          ShimmerSkeleton(width: 150, height: 16),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(
    ThemeData theme, {
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(content, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
