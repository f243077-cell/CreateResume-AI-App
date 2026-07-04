import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../home_dashboard/widgets/resume_preview_card.dart';
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

          return GridView.builder(
            padding: const EdgeInsets.all(24),
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
          onPressed: () => _pickAndUploadResume(context, ref),
          child: const Icon(Icons.upload_file_rounded),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadResume(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc'],
      );

      if (result != null && result.files.single.path != null) {
        final fileName = result.files.single.name;

        // Show loading dialog
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Dialog(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Analyzing resume...'),
                  ],
                ),
              ),
            ),
          );
        }

        // Simulate analysis delay
        await Future.delayed(const Duration(seconds: 2));

        // Generate random score for demo
        final random = DateTime.now().millisecondsSinceEpoch;
        final score = 60 + (random % 40); // Score between 60-100

        // Close loading dialog
        if (context.mounted) {
          Navigator.pop(context);
        }

        // Show analysis results
        if (context.mounted) {
          _showAnalysisResults(context, fileName, score);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick file: $e')));
      }
    }
  }

  void _showAnalysisResults(BuildContext context, String fileName, int score) {
    final theme = Theme.of(context);
    
    String rating;
    Color scoreColor;
    if (score >= 85) {
      rating = 'Excellent';
      scoreColor = AppColors.success;
    } else if (score >= 70) {
      rating = 'Good';
      scoreColor = AppColors.blue400;
    } else if (score >= 55) {
      rating = 'Fair';
      scoreColor = AppColors.warning;
    } else {
      rating = 'Needs Improvement';
      scoreColor = AppColors.error;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Resume Analysis Results',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                fileName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              CircularPercentIndicator(
                radius: 60.0,
                lineWidth: 10.0,
                percent: score / 100,
                center: Text(
                  '$score',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: scoreColor,
                backgroundColor: AppColors.border,
              ),
              const SizedBox(height: 16),
              Text(
                rating,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Analyze Another'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
