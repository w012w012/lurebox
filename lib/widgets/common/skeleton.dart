import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/design/theme/app_colors.dart';

/// iOS-style skeleton loader with smooth shimmer animation
class Skeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const Skeleton({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // iOS-style colors: subtle grey tones for shimmer
    final baseColor = isDark
        ? AppColors.grey800 // #2D3748 - subtle dark grey
        : AppColors.grey200; // #EDF2F7 - light grey
    final highlightColor = isDark
        ? AppColors.grey700 // #4A5568 - slightly lighter dark grey
        : AppColors.grey100; // #F7FAFC - very light grey

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1500), // Smooth iOS-style animation
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
