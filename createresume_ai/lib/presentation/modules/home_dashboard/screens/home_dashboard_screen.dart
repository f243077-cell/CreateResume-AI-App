import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/resume.dart';
import '../../../widgets/shimmer_skeleton.dart';
import '../providers/home_dashboard_notifier.dart';
import '../widgets/ats_trend_chart.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/resume_preview_card.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(homeDashboardProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                sliver: const SliverToBoxAdapter(child: _DashboardHeader()),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Quick Actions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.2,
                        children: [
                          Semantics(
                            button: true,
                            label: 'Build new resume',
                            child: QuickActionCard(
                              icon: Icons.add_circle_rounded,
                              label: 'Build New Resume',
                              iconColor: AppColors.amber,
                              onTap: () =>
                                  context.pushNamed(AppRouteNames.resumeWizard),
                            ),
                          ),
                          Semantics(
                            button: true,
                            label: 'Analyze resume',
                            child: QuickActionCard(
                              icon: Icons.analytics_rounded,
                              label: 'Analyze Resume',
                              iconColor: AppColors.blue400,
                              onTap: () =>
                                  context.goNamed(AppRouteNames.resumeAnalyzer),
                            ),
                          ),
                          Semantics(
                            button: true,
                            label: 'Create cover letter',
                            child: QuickActionCard(
                              icon: Icons.help_outline_rounded,
                              label: 'Create Cover Letter',
                              iconColor: AppColors.warning,
                              onTap: () =>
                                  context.pushNamed(AppRouteNames.aiTools),
                            ),
                          ),
                          Semantics(
                            button: true,
                            label: 'Track applications',
                            child: QuickActionCard(
                              icon: Icons.view_kanban_rounded,
                              label: 'Track Applications',
                              iconColor: AppColors.navy800,
                              onTap: () =>
                                  context.goNamed(AppRouteNames.applicationTracker),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(24, 32, 24, 32),
                sliver: SliverToBoxAdapter(child: _DashboardInsights()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends ConsumerWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(
      homeDashboardProvider.select((async) => async.isLoading),
    );
    final fullName = ref.watch(
      homeDashboardProvider.select(
        (async) => async.value?.user?.fullName,
      ),
    );

    if (isLoading && fullName == null) {
      return _buildHeaderSkeleton(theme);
    }

    return _buildHeader(context, theme, fullName);
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, String? fullName) {
    final firstName = fullName?.split(' ').first ?? 'User';
    final initials = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning,',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              firstName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Semantics(
          button: true,
          label: 'Go to profile',
          child: AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 100),
            child: GestureDetector(
              onTap: () => context.goNamed(AppRouteNames.profile),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.navy800,
                child: Text(
                  initials,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSkeleton(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerSkeleton(width: 80, height: 14),
            const SizedBox(height: 8),
            ShimmerSkeleton(width: 120, height: 24),
          ],
        ),
        ShimmerSkeleton(
          width: 48,
          height: 48,
          borderRadius: BorderRadius.circular(24),
        ),
      ],
    );
  }
}

class _DashboardInsights extends ConsumerWidget {
  const _DashboardInsights();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(
      homeDashboardProvider.select((async) => async.isLoading),
    );
    final recentResumes = ref.watch(
      homeDashboardProvider.select(
        (async) => async.value?.recentResumes ?? const <Resume>[],
      ),
    );
    final hasError = ref.watch(
      homeDashboardProvider.select((async) => async.hasError),
    );
    final error = ref.watch(
      homeDashboardProvider.select((async) => async.error),
    );

    if (isLoading && recentResumes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text('Error loading insights: $error'),
            const SizedBox(height: 16),
            Semantics(
              button: true,
              label: 'Retry loading dashboard',
              child: ElevatedButton(
                onPressed: () =>
                    ref.read(homeDashboardProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      );
    }

    return _buildInsights(context, theme, recentResumes);
  }

  Widget _buildInsights(
    BuildContext context,
    ThemeData theme,
    List<Resume> recentResumes,
  ) {
    if (recentResumes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.note_add_rounded,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              "You haven't created any resumes yet.",
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            Semantics(
              button: true,
              label: 'Build first resume',
              child: ElevatedButton(
                onPressed: () => context.pushNamed(AppRouteNames.resumeWizard),
                child: const Text('Build Your First Resume'),
              ),
            ),
          ],
        ),
      );
    }

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Resumes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.pushNamed(AppRouteNames.resumeWizard),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recentResumes.length,
              itemBuilder: (context, index) {
                return ResumePreviewCard(
                  resume: recentResumes[index],
                  onTap: () {
                    context.pushNamed(
                      AppRouteNames.resumeEditor,
                      pathParameters: {'resumeId': recentResumes[index].id},
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'AI Resume Score Trend',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          AtsTrendChart(resumes: recentResumes),
        ],
      ),
    );
  }
}
