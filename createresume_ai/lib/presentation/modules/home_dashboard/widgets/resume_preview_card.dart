import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/resume.dart';

class ResumePreviewCard extends StatelessWidget {
  final Resume resume;
  final VoidCallback onTap;

  const ResumePreviewCard({
    super.key,
    required this.resume,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Format relative time (e.g., "Oct 24, 2023")
    final dateFormatted = DateFormat.yMMMd().format(resume.updatedAt);
    final score = resume.atsScore ?? 0;

    // Determine badge color based on ATS score
    Color badgeColor;
    if (score >= 80) {
      badgeColor = AppColors.success;
    } else if (score >= 50) {
      badgeColor = AppColors.warning;
    } else {
      badgeColor = AppColors.error;
    }

    return Card(
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 240,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Score badge and icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: badgeColor.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.analytics_rounded,
                          size: 14,
                          color: badgeColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$score',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: badgeColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.more_vert_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
              const Spacer(),
              // Title
              Text(
                resume.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              // Date
              Text(
                'Edited $dateFormatted',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
