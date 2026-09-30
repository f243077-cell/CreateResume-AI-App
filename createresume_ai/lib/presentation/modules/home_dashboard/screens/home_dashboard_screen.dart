import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/shimmer_skeleton.dart';
import '../providers/home_dashboard_notifier.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

const Color _dashboardBg = Color(0xFF3D2418);

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _dashboardBg,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.burntOrange,
          onRefresh: () => ref.read(homeDashboardProvider.notifier).refresh(),
          child: const CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
                sliver: SliverToBoxAdapter(child: _DashboardHeader()),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 24),
                sliver: SliverToBoxAdapter(child: _BentoGrid()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────

class _DashboardHeader extends ConsumerWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      homeDashboardProvider.select((async) => async.isLoading),
    );
    final fullName = ref.watch(
      homeDashboardProvider.select((async) => async.value?.user?.fullName),
    );
    final photoUrl = ref.watch(
      homeDashboardProvider.select((async) => async.value?.user?.photoUrl),
    );

    if (isLoading && fullName == null) {
      return _buildHeaderSkeleton();
    }

    return _buildHeader(context, fullName, photoUrl);
  }

  Widget _buildHeader(
    BuildContext context,
    String? fullName,
    String? photoUrl,
  ) {
    final firstName = fullName?.split(' ').first ?? 'User';
    final initials = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Good Morning \u{1F44B}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                const SizedBox(width: 12),
                Semantics(
                  button: true,
                  label: 'Go to profile',
                  child: GestureDetector(
                    onTap: () => context.goNamed(AppRouteNames.profile),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.burntOrange,
                      backgroundImage: photoUrl != null
                          ? _cachedProfileImage(context, photoUrl)
                          : null,
                      child: photoUrl == null
                          ? Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Hi, $firstName',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Your Resumes!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  ImageProvider _cachedProfileImage(BuildContext context, String url) {
    final cacheSize = (40 * MediaQuery.devicePixelRatioOf(context)).round();
    return ResizeImage.resizeIfNeeded(cacheSize, cacheSize, NetworkImage(url));
  }

  Widget _buildHeaderSkeleton() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerSkeleton(width: 100, height: 14),
        SizedBox(height: 12),
        ShimmerSkeleton(width: 180, height: 34),
      ],
    );
  }
}

// ── Bento grid ────────────────────────────────────────────────────

class _BentoGrid extends StatelessWidget {
  const _BentoGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          button: true,
          label: 'Build new resume',
          child: _BentoCard(
            height: 160,
            backgroundColor: AppColors.burntOrange,
            onTap: () => context.pushNamed(AppRouteNames.resumeWizard),
            child: _BentoCardContent(
              icon: Icons.add_circle_rounded,
              label: 'Build New Resume',
              labelColor: Colors.white,
              iconBgColor: Colors.white.withValues(alpha: 0.25),
              iconColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Semantics(
          button: true,
          label: 'View all resumes',
          child: _BentoCard(
            height: 130,
            backgroundColor: AppColors.vanilla,
            onTap: () => context.pushNamed(AppRouteNames.allResumes),
            child: _BentoCardContent(
              icon: Icons.folder_rounded,
              label: 'All Resumes',
              labelColor: AppColors.textPrimary,
              iconBgColor: Colors.white.withValues(alpha: 0.6),
              iconColor: AppColors.burntOrangeDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _BentoCard extends StatelessWidget {
  final double height;
  final Color backgroundColor;
  final Widget child;
  final VoidCallback onTap;

  const _BentoCard({
    required this.height,
    required this.backgroundColor,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: height,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: child,
      ),
    );
  }
}

class _BentoCardContent extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color labelColor;
  final Color iconBgColor;
  final Color iconColor;

  const _BentoCardContent({
    required this.icon,
    required this.label,
    required this.labelColor,
    required this.iconBgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const Spacer(),
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
