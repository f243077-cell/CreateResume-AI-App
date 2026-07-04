import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/resume.dart';
import '../../../widgets/shimmer_skeleton.dart';
import '../providers/all_resumes_notifier.dart';
import '../widgets/resume_card.dart';

class AllResumesScreen extends ConsumerWidget {
  const AllResumesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final resumesAsync = ref.watch(allResumesProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('All Resumes'),
        centerTitle: true,
      ),
      body: resumesAsync.when(
        loading: () => _buildLoading(),
        error: (error, stack) => _buildError(context, ref, error.toString()),
        data: (state) => _buildContent(context, ref, theme, state.resumes),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRouteNames.resumeWizard),
        icon: const Icon(Icons.add),
        label: const Text('New Resume'),
        backgroundColor: AppColors.navy800,
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String error) {
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
          Text('Error loading resumes: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(allResumesProvider.notifier).refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, ThemeData theme, List<Resume> resumes) {
    if (resumes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.note_add_rounded,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                "You haven't created any resumes yet.",
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.pushNamed(AppRouteNames.resumeWizard),
                icon: const Icon(Icons.add),
                label: const Text('Create Your First Resume'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(allResumesProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: resumes.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ResumeCard(
              resume: resumes[index],
              onTap: () {
                context.pushNamed(
                  AppRouteNames.resumeEditor,
                  pathParameters: {'resumeId': resumes[index].id},
                );
              },
            ),
          );
        },
      ),
    );
  }
}
