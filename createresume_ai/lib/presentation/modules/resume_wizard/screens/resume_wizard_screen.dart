import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../presentation/widgets/subscription_navigation.dart';
import '../../../../presentation/widgets/shimmer_skeleton.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../domain/value_objects/career_stage.dart';
import '../providers/resume_wizard_notifier.dart';
import '../providers/resume_generation_provider.dart';

class ResumeWizardScreen extends ConsumerStatefulWidget {
  const ResumeWizardScreen({super.key});

  @override
  ConsumerState<ResumeWizardScreen> createState() => _ResumeWizardScreenState();
}

class _ResumeWizardScreenState extends ConsumerState<ResumeWizardScreen> {
  final PageController _pageController = PageController();
  static const int _totalPages = 4;

  final _titleController = TextEditingController();
  final _industryController = TextEditingController();
  final _jdController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _industryController.dispose();
    _jdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final currentIndex =
        ref.read(resumeWizardProvider.select((s) => s.currentPageIndex));
    if (currentIndex < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _previousPage() {
    final currentIndex =
        ref.read(resumeWizardProvider.select((s) => s.currentPageIndex));
    if (currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit() async {
    final careerStage =
        ref.read(resumeWizardProvider.select((s) => s.careerStage));

    // Call the new AI generation provider
    ref.read(resumeGenerationProvider.notifier).generateResume(
      description: _descriptionController.text,
      careerStage: careerStage?.name ?? 'entry-level',
      jobTitle: _titleController.text,
      templateId: null, // Will be selected after generation
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex =
        ref.watch(resumeWizardProvider.select((s) => s.currentPageIndex));

    // Handle errors via listener
    ref.listen<ResumeWizardState>(resumeWizardProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
      if (next.requiresUpgrade && !(prev?.requiresUpgrade ?? false)) {
        showUpgradeRequiredDialog(
          context,
          message:
              'You have run out of AI credits. Please upgrade your plan to generate more resumes.',
        );
      }
    });

    // Handle AI generation state
    ref.listen(resumeGenerationProvider, (prev, next) {
      next.when(
        data: (resume) {
          // Navigation is handled in the provider
        },
        loading: () {
          // Loading is handled by the UI overlay
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to generate resume: ${error.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: Semantics(
          button: true,
          label: 'Close wizard',
          child: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        title: const Text('Create New Resume'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (currentIndex + 1) / _totalPages,
            backgroundColor: AppColors.surfaceCard,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue400),
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Force buttons to navigate
                    onPageChanged: (index) => ref
                        .read(resumeWizardProvider.notifier)
                        .setPageIndex(index),
                    children: [
                      _buildCareerStageStep(theme),
                      _buildIndustryTitleStep(theme),
                      _buildJobDescriptionStep(theme),
                      _buildUserDescriptionStep(theme),
                    ],
                  ),
                ),
                _WizardBottomControls(
                  totalPages: _totalPages,
                  onNext: _nextPage,
                  onPrevious: _previousPage,
                  descriptionController: _descriptionController,
                ),
              ],
            ),
          ),
          // Loading overlay
          if (ref.watch(resumeGenerationProvider).isLoading)
            _buildLoadingOverlay(theme),
        ],
      ),
    );
  }

  Widget _buildCareerStageStep(ThemeData theme) {
    final selectedStage =
        ref.watch(resumeWizardProvider.select((s) => s.careerStage));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "What's your career stage?",
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            "We'll tailor the AI suggestions based on your experience level.",
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          ...CareerStage.values.map((stage) {
            final isSelected = selectedStage == stage;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Semantics(
                button: true,
                label: 'Select ${stage.displayLabel} career stage',
                child: InkWell(
                  onTap: () {
                    ref.read(resumeWizardProvider.notifier).updateCareerStage(stage);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.blue100 : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.blue400 : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.work_history_rounded,
                          color: isSelected ? AppColors.navy800 : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          stage.displayLabel,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.navy800 : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildIndustryTitleStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "What role are you targeting?",
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Target Job Title',
              hintText: 'e.g. Senior Product Designer',
              prefixIcon: Icon(Icons.badge_rounded),
            ),
            validator: (val) => Validators.required(val, 'Job title'),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _industryController,
            decoration: const InputDecoration(
              labelText: 'Industry',
              hintText: 'e.g. Technology, Healthcare',
              prefixIcon: Icon(Icons.domain_rounded),
            ),
            validator: (val) => Validators.required(val, 'Industry'),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDescriptionStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Target a specific job? (Optional)",
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            "Paste a job description and we will optimize your resume for it.",
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _jdController,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Paste the job description here...',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDescriptionStep(ThemeData theme) {
    final description = _descriptionController.text;
    final isValid = description.length >= 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Tell us about yourself",
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            "Describe your experience, skills, education — the more detail the better. AI will build your full resume from this.",
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _descriptionController,
            maxLines: 12,
            decoration: InputDecoration(
              hintText: 'Example: I am a software engineer with 5 years of experience building web applications using React and Node.js. I have a Bachelor\'s degree in Computer Science and have worked at two tech companies. My skills include JavaScript, TypeScript, Python, and cloud services like AWS...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minimum 100 characters',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isValid ? AppColors.green600 : AppColors.textSecondary,
                ),
              ),
              Text(
                '${description.length}/100',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isValid ? AppColors.green600 : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (!isValid && description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Please provide more details for better AI generation',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.orange600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(ThemeData theme) {
    return Container(
      color: AppColors.navy800.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'AI is crafting your resume...',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This may take a moment',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 32),
            // Shimmer skeleton for visual feedback
            SizedBox(
              width: 200,
              height: 120,
              child: ShimmerSkeleton(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _WizardBottomControls extends ConsumerWidget {
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final TextEditingController descriptionController;

  const _WizardBottomControls({
    required this.totalPages,
    required this.onNext,
    required this.onPrevious,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentIndex =
        ref.watch(resumeWizardProvider.select((s) => s.currentPageIndex));
    final isLoading =
        ref.watch(resumeWizardProvider.select((s) => s.isLoading));
    final isGenerating = ref.watch(resumeGenerationProvider).isLoading;

    // Check if description has minimum 100 characters on the last step
    final isLastStep = currentIndex == totalPages - 1;
    final descriptionValid = descriptionController.text.length >= 100;
    final canProceed = !isLastStep || descriptionValid;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (currentIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: (isLoading || isGenerating) ? null : onPrevious,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(80, 52),
                ),
                child: const Text('Back'),
              ),
            )
          else
            const SizedBox(width: 80),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: (isLoading || isGenerating || !canProceed) ? null : onNext,
              icon: (isLoading || isGenerating)
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Icon(
                      isLastStep ? Icons.auto_awesome_rounded : Icons.arrow_forward_rounded,
                      size: 20,
                    ),
              label: Text(
                isLastStep ? 'Generate Resume' : 'Next',
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120, 52),
                backgroundColor: isLastStep ? AppColors.gold : null,
                foregroundColor: isLastStep ? AppColors.navy800 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
