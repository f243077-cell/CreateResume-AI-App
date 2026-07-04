import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/widgets/subscription_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/ai_tool_notifier.dart';

class AiToolLibraryScreen extends ConsumerWidget {
  const AiToolLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final aiToolState = ref.watch(aiToolProvider);
    final credits = aiToolState.profile?.creditBalance ?? 0;

    ref.listen(aiToolProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: AppColors.error),
        );
      }
      if (next.requiresUpgrade && !(prev?.requiresUpgrade ?? false)) {
        showUpgradeRequiredDialog(
          context,
          message:
              'You need more AI credits to use this tool. Please upgrade your plan.',
        );
      }
      if (next.resultText != null && next.resultText != prev?.resultText) {
        _showResultDialog(context, next.resultText!);
      }
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('AI Tool Library'),
        centerTitle: true,
      ),
      body: aiToolState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : aiToolState.profile == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      const Text('Failed to load profile'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(aiToolProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Credits Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.navy800, AppColors.blue400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available Credits',
                                  style: TextStyle(color: AppColors.white70, fontSize: 14),
                                ),
                                Text(
                                  '$credits',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Semantics(
                              button: true,
                              label: 'Get more credits',
                              child: OutlinedButton(
                                onPressed: () => navigateToSubscription(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.white,
                                  side: const BorderSide(color: AppColors.white54),
                                ),
                                child: const Text('Get More'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Available Tools',
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
                        children: [
                          _buildToolCard(
                            context,
                            ref,
                            title: 'Bullet Rewriter',
                            icon: Icons.edit_note_rounded,
                            color: AppColors.success,
                            description: 'Turn weak responsibilities into strong achievements.',
                          ),
                          _buildToolCard(
                            context,
                            ref,
                            title: 'Skill Gap Analyzer',
                            icon: Icons.track_changes_rounded,
                            color: AppColors.warning,
                            description: 'Find missing skills for a target job.',
                          ),
                          _buildToolCard(
                            context,
                            ref,
                            title: 'Cover Letter GPT',
                            icon: Icons.mark_email_read_rounded,
                            color: AppColors.blue400,
                            description: 'Generate a highly tailored cover letter.',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: true,
        label: 'Use $title tool',
        child: InkWell(
          onTap: () => _showToolInputSheet(context, ref, title),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const Spacer(),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showToolInputSheet(BuildContext context, WidgetRef ref, String toolName) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final isLoading =
                ref.watch(aiToolProvider.select((s) => s.isLoading));
            
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(toolName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Paste your text or job description here...',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    button: true,
                    label: 'Run $toolName tool',
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () {
                        if (controller.text.isNotEmpty) {
                          ref.read(aiToolProvider.notifier).runTool(toolName, controller.text);
                          Navigator.pop(context);
                        }
                      },
                      child: isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                        : const Text('Run Tool (1 Credit)'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _showResultDialog(BuildContext context, String result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Result'),
        content: SingleChildScrollView(child: Text(result)),
        actions: [
          Semantics(
            button: true,
            label: 'Close result dialog',
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}
