import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class EditorSection<T> extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final void Function(int oldIndex, int newIndex)? onReorder;
  final VoidCallback onAdd;
  final VoidCallback? onAiImprove;

  const EditorSection({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    required this.itemBuilder,
    this.onReorder,
    required this.onAdd,
    this.onAiImprove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: AppColors.navy800),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onAiImprove != null)
                  TextButton.icon(
                    onPressed: onAiImprove,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                    label: const Text('AI Improve'),
                  ),
                IconButton(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded),
                  color: AppColors.navy800,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          // List
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'No $title added yet.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            )
          else
            RepaintBoundary(
              child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: items.length,
                onReorderItem: (oldIndex, newIndex) {
                  if (onReorder != null) {
                    onReorder!(oldIndex, newIndex);
                  }
                },
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ReorderableDragStartListener(
                    key: ValueKey(item.hashCode),
                    index: index,
                    child: itemBuilder(context, item),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
