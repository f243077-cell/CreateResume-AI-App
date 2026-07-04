import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/routing/app_routes.dart';
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

        // Show a dialog indicating the file was selected
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Resume Selected'),
              content: Text(
                'Selected: $fileName\n\nThis feature will analyze your uploaded resume with AI and provide an ATS score.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
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
}
