import 'package:flutter/material.dart';

import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/widgets/common/premium_card.dart';

/// Progress status of the achievement
enum AchievementProgressStatus {
  locked, // Grey progress bar
  inProgress, // Blue gradient progress bar with percentage
  completed, // Green progress bar with checkmark
}

/// Achievement overview card showing unlock progress.
/// Displays achievement count, progress bar, and monthly new additions.
class AchievementOverviewCard extends StatelessWidget {

  const AchievementOverviewCard({
    required this.unlockedCount, required this.totalCount, required this.monthlyNewCount, super.key,
    this.status = AchievementProgressStatus.inProgress,
    this.strings,
    this.onTap,
  });
  final int unlockedCount;
  final int totalCount;
  final int monthlyNewCount;
  final AchievementProgressStatus status;
  final AppStrings? strings;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;
    final progressPercent = (progress * 100).round();

    return PremiumCard(
      variant: PremiumCardVariant.elevated,
      padding: const EdgeInsets.all(20),
      backgroundColor: Theme.of(context).colorScheme.primary,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with trophy icon
          Row(
            children: [
              const Text(
                '🏆',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                strings?.unlockProgress ?? '解锁进度',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: TeslaColors.white,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          _buildProgressBar(context, progress, progressPercent),
          const SizedBox(height: 8),

          // Count text
          Text(
            '$unlockedCount / $totalCount 种鱼',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TeslaColors.white.withValues(alpha: 0.9),
                ),
          ),
          const SizedBox(height: 8),

          // Monthly new count
          if (monthlyNewCount > 0)
            Text(
              '本月新增: +$monthlyNewCount 种',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TeslaColors.white.withValues(alpha: 0.7),
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    double progress,
    int progressPercent,
  ) {
    Widget? trailingIcon;

    switch (status) {
      case AchievementProgressStatus.locked:
        trailingIcon = const Icon(
          Icons.lock_outline,
          color: TeslaColors.pewter,
          size: 16,
        );
      case AchievementProgressStatus.inProgress:
        trailingIcon = null;
      case AchievementProgressStatus.completed:
        trailingIcon = const Icon(
          Icons.check_circle,
          color: TeslaColors.electricBlue,
          size: 16,
        );
    }

    return Row(
      children: [
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: TeslaTheme.transitionDuration,
            curve: TeslaTheme.transitionCurve,
            builder: (context, value, child) {
              return Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: TeslaColors.white.withValues(alpha: 0.2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: TeslaColors.electricBlue,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        if (trailingIcon != null)
          trailingIcon
        else
          Text(
            '$progressPercent%',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: TeslaColors.white,
                ),
          ),
      ],
    );
  }
}
