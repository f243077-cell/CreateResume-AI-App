// File: lib/presentation/modules/template_selection/screens/template_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/template_ids.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/template_selection_notifier.dart';

const Color _bgColor = Color(0xFF3D2418);
const Color _cardColor = Color(0xFF5C3A28);
const Color _cardSelected = Color(0xFF7A4A2E);

class TemplateSelectionScreen extends ConsumerWidget {
  final String resumeId;
  const TemplateSelectionScreen({super.key, required this.resumeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(
      templateSelectionProvider.select((s) => s.selectedCategory),
    );
    final selectedStyle = ref.watch(
      templateSelectionProvider.select((s) => s.selectedStyle),
    );

    final categories = [
      {
        'id': 'classic',
        'name': 'Classic',
        'icon': Icons.article_rounded,
        'color': const Color(0xFFD4A92E),
      },
      {
        'id': 'modern',
        'name': 'Modern',
        'icon': Icons.auto_awesome_rounded,
        'color': AppColors.burntOrange,
      },
      {
        'id': 'minimal',
        'name': 'Minimal',
        'icon': Icons.minimize_rounded,
        'color': const Color(0xFF2E9E77),
      },
      {
        'id': 'executive',
        'name': 'Executive',
        'icon': Icons.business_center_rounded,
        'color': const Color(0xFF6B8CDA),
      },
    ];

    final categoryStyles = {
      'classic': [
        {'id': TemplateIds.classic, 'name': 'Classic Style'},
      ],
      'modern': [
        {'id': TemplateIds.modern, 'name': 'Modern Style'},
      ],
      'minimal': [
        {'id': TemplateIds.minimal, 'name': 'Minimal Style'},
      ],
      'executive': [
        {'id': TemplateIds.executive, 'name': 'Executive v1'},
        {'id': TemplateIds.executive2, 'name': 'Executive v2'},
      ],
    };

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (selectedCategory != null) {
                        ref
                            .read(templateSelectionProvider.notifier)
                            .selectCategory(null);
                      } else {
                        context.pop();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Select Template',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                selectedCategory == null
                    ? 'Choose a template category'
                    : 'Choose a style for ${categories.firstWhere((c) => c['id'] == selectedCategory)['name']}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Grid ─────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: selectedCategory == null
                    ? _CategoriesGrid(
                        categories: categories,
                        onSelect: (id) => ref
                            .read(templateSelectionProvider.notifier)
                            .selectCategory(id),
                      )
                    : _StylesGrid(
                        styles: categoryStyles[selectedCategory] ?? [],
                        selectedStyle: selectedStyle,
                        resumeId: resumeId,
                        onSelect: (id) {
                          ref
                              .read(templateSelectionProvider.notifier)
                              .selectStyle(id);
                          context.pushNamed(
                            'resumeEditor',
                            pathParameters: {'resumeId': resumeId},
                            queryParameters: {'templateId': id},
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Categories Grid ──────────────────────────────────────────────

class _CategoriesGrid extends StatelessWidget {
  final List<Map<String, Object>> categories;
  final void Function(String) onSelect;

  const _CategoriesGrid({required this.categories, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Semantics(
          button: true,
          label: 'Select ${cat["name"]} template',
          child: GestureDetector(
            onTap: () => onSelect(cat['id']! as String),
            child: Container(
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (cat['color'] as Color).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      cat['icon'] as IconData,
                      size: 36,
                      color: cat['color'] as Color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    cat['name']! as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subtitle(cat['id'] as String),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _subtitle(String id) {
    return switch (id) {
      'classic' => '1 style',
      'modern' => '1 style',
      'minimal' => '1 style',
      'executive' => '2 styles',
      _ => '',
    };
  }
}

// ── Styles Grid ──────────────────────────────────────────────────

class _StylesGrid extends StatelessWidget {
  final List<Map<String, String>> styles;
  final String? selectedStyle;
  final String resumeId;
  final void Function(String) onSelect;

  const _StylesGrid({
    required this.styles,
    required this.selectedStyle,
    required this.resumeId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: styles.length,
      itemBuilder: (context, index) {
        final style = styles[index];
        final isSelected = selectedStyle == style['id'];

        return Semantics(
          button: true,
          label: 'Select ${style["name"]} style',
          child: GestureDetector(
            onTap: () => onSelect(style['id']!),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? _cardSelected : _cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.burntOrange
                      : Colors.white.withValues(alpha: 0.08),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.burntOrange.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.description_rounded,
                      size: 36,
                      color: isSelected
                          ? AppColors.burntOrange
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    style['name']!,
                    style: TextStyle(
                      color: isSelected ? AppColors.burntOrange : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.burntOrange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Selected',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
