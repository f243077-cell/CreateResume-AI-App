import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/resume.dart';
import '../providers/all_resumes_notifier.dart';
import '../widgets/resume_card.dart';

/// Same deep warm background used on the Home Dashboard, for visual
/// consistency across the main tabs.
const Color _screenBg = Color(0xFF3D2418);

class AllResumesScreen extends ConsumerWidget {
  const AllResumesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumesAsync = ref.watch(allResumesProvider);

    return Scaffold(
      backgroundColor: _screenBg,
      appBar: AppBar(
        backgroundColor: _screenBg,
        foregroundColor: Colors.white,
        title: const Text(
          'All Resumes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: resumesAsync.when(
        loading: () => _buildLoading(),
        error: (error, stack) => _buildError(context, ref, error.toString()),
        data: (state) => _buildContent(context, ref, state.resumes),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRouteNames.resumeWizard),
        icon: const Icon(Icons.add),
        label: const Text('New Resume'),
        backgroundColor: AppColors.burntOrange,
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.burntOrange),
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
          Text(
            'Error loading resumes: $error',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(allResumesProvider.notifier).refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<Resume> resumes,
  ) {
    if (resumes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.vanilla,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.note_add_rounded,
                  size: 40,
                  color: AppColors.burntOrange,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "You haven't created any resumes yet.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
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
      color: AppColors.burntOrange,
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
