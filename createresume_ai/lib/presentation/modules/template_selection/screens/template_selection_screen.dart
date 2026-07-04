import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/template_selection_notifier.dart';

class TemplateSelectionScreen extends ConsumerWidget {
  final String resumeId;
  const TemplateSelectionScreen({super.key, required this.resumeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedCategory =
        ref.watch(templateSelectionProvider.select((s) => s.selectedCategory));
    final selectedStyle =
        ref.watch(templateSelectionProvider.select((s) => s.selectedStyle));

    // Template categories
    final categories = [
      {'id': 'classic', 'name': 'Classic', 'icon': Icons.article_rounded, 'color': AppColors.navy800},
      {'id': 'modern', 'name': 'Modern', 'icon': Icons.auto_awesome_rounded, 'color': AppColors.blue400},
      {'id': 'minimal', 'name': 'Minimal', 'icon': Icons.minimize_rounded, 'color': AppColors.success},
      {'id': 'executive', 'name': 'Executive', 'icon': Icons.business_center_rounded, 'color': AppColors.gold},
    ];

    // Template styles per category
    final categoryStyles = {
      'classic': [
        {'id': 'classic_style1', 'name': 'Style 1'},
      ],
      'modern': [
        {'id': 'modern_style1', 'name': 'Style 1'},
      ],
      'minimal': [
        {'id': 'minimal_style1', 'name': 'Style 1'},
      ],
      'executive': [
        {'id': 'executive_style1', 'name': 'Style 1'},
        {'id': 'executive_style2', 'name': 'Style 2'},
      ],
    };

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Select Template'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Choose a Template Style",
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              selectedCategory == null
                  ? "Select a template category to see available styles"
                  : "Choose a style within ${categories.firstWhere((c) => c['id'] == selectedCategory)['name'] as String}",
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            if (selectedCategory == null)
              // Show category cards
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];

                  return Semantics(
                    button: true,
                    label: 'Select ${category["name"]} template category',
                    child: InkWell(
                      onTap: () {
                        ref
                            .read(templateSelectionProvider.notifier)
                            .selectCategory(category['id']! as String);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              category['icon'] as IconData,
                              size: 48,
                              color: category['color'] as Color,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              category['name']! as String,
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            else
              // Show styles within selected category
              Column(
                children: [
                  // Back button to categories
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(templateSelectionProvider.notifier).selectCategory(null);
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back to Categories'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Style cards
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: categoryStyles[selectedCategory]?.length ?? 0,
                    itemBuilder: (context, index) {
                      final style = categoryStyles[selectedCategory]![index];
                      final isSelected = selectedStyle == style['id'];

                      return Semantics(
                        button: true,
                        label: 'Select ${style["name"]} template style',
                        child: InkWell(
                          onTap: () {
                            ref
                                .read(templateSelectionProvider.notifier)
                                .selectStyle(style['id']!);
                            // Navigate to resume editor with selected template
                            context.pushNamed(
                              'resumeEditor',
                              pathParameters: {'resumeId': resumeId},
                              queryParameters: {'templateId': style['id']!},
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.blue400 : AppColors.border,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.description_rounded,
                                  size: 48,
                                  color: isSelected
                                      ? AppColors.navy800
                                      : AppColors.textTertiary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  style['name']!,
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
