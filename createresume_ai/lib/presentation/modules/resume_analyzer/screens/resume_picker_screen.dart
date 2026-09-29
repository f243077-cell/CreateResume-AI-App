import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../home_dashboard/widgets/resume_preview_card.dart';
import '../providers/resume_analyzer_notifier.dart';
import '../providers/resume_picker_notifier.dart';

class ResumePickerScreen extends ConsumerWidget {
  const ResumePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final resumesAsync = ref.watch(resumePickerProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Select a Resume'), centerTitle: true),
      body: resumesAsync.when(
        data: (resumes) {
          if (resumes.isEmpty) {
            return const Center(
              child: Text('No resumes found. Build one first!'),
            );
          }

          return CustomScrollView(
            slivers: [
              // Optional target job; the analyzer matches its keywords.
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: TextFormField(
                    initialValue: ref.read(atsJobDescriptionProvider),
                    minLines: 2,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Target job description (optional)',
                      hintText:
                          'Paste a job description to check keyword matches...',
                      alignLabelWithHint: true,
                    ),
                    onChanged: (value) =>
                        ref.read(atsJobDescriptionProvider.notifier).set(value),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: resumes.length,
                  itemBuilder: (context, index) {
                    final resume = resumes[index];
                    return ResumePreviewCard(
                      resume: resume,
                      onTap: () {
                        context.pushNamed(
                          AppRouteNames.resumeAnalyzerDetail,
                          pathParameters: {'resumeId': resume.id},
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48),
              const SizedBox(height: 16),
              Text('Failed to load resumes: $e'),
              const SizedBox(height: 16),
              Semantics(
                button: true,
                label: 'Retry loading resumes',
                child: ElevatedButton(
                  onPressed: () => ref.invalidate(resumePickerProvider),
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Semantics(
        button: true,
        label: 'Upload resume from device',
        child: FloatingActionButton(
          // Scoring uploaded files needs PDF/DOCX text extraction, which the
          // app does not have yet; it used to show a random score here.
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Scoring uploaded files is coming soon. Pick one of your resumes to analyze it.',
              ),
            ),
          ),
          child: const Icon(Icons.upload_file_rounded),
        ),
      ),
    );
  }
}
