import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';

class ShimmerSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surfaceCard,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double? width;
  final double? height;

  const ShimmerCard({
    super.key,
    this.width,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surfaceCard,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
      ),
    );
  }
}
