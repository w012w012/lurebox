import 'package:flutter/material.dart';

import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/animation_constants.dart';
import '../../../widgets/common/premium_card.dart';

/// Progress status of the achievement
enum AchievementProgressStatus {
  locked, // Grey progress bar
  inProgress, // Blue gradient progress bar with percentage
  completed, // Green progress bar with checkmark
}

/// Achievement overview card showing unlock progress.
/// Displays achievement count, progress bar, and monthly new additions.
class AchievementOverviewCard extends StatelessWidget {
  final int unlockedCount;
  final int totalCount;
  final int monthlyNewCount;
  final AchievementProgressStatus status;
  final VoidCallback? onTap;

  const AchievementOverviewCard({
    super.key,
    required this.unlockedCount,
    required this.totalCount,
    required this.monthlyNewCount,
    this.status = AchievementProgressStatus.inProgress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;
    final progressPercent = (progress * 100).round();

    return PremiumCard(
      variant: PremiumCardVariant.elevated,
      padding: const EdgeInsets.all(20),
      showBorder: false,
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
                '解锁进度',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.surfaceLight,
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
                  color: AppColors.surfaceLight.withValues(alpha: 0.9),
                ),
          ),
          const SizedBox(height: 8),

          // Monthly new count
          if (monthlyNewCount > 0)
            Text(
              '本月新增: +$monthlyNewCount 种',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.surfaceLight.withValues(alpha: 0.7),
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
    Color progressColor;
    Widget? trailingIcon;

    switch (status) {
      case AchievementProgressStatus.locked:
        progressColor = AppColors.grey500;
        trailingIcon = const Icon(
          Icons.lock_outline,
          color: AppColors.grey500,
          size: 16,
        );
        break;
      case AchievementProgressStatus.inProgress:
        progressColor = AppColors.accentLight;
        trailingIcon = null;
        break;
      case AchievementProgressStatus.completed:
        progressColor = AppColors.success;
        trailingIcon = const Icon(
          Icons.check_circle,
          color: AppColors.success,
          size: 16,
        );
        break;
    }

    return Row(
      children: [
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: AnimationConstants.pageTransitionDuration,
            curve: AnimationConstants.defaultCurve,
            builder: (context, value, child) {
              return Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors.surfaceLight.withValues(alpha: 0.2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: status == AchievementProgressStatus.inProgress
                          ? LinearGradient(
                              colors: [
                                AppColors.accentLight,
                                AppColors.accentLight.withValues(alpha: 0.8),
                              ],
                            )
                          : null,
                      color: status != AchievementProgressStatus.inProgress
                          ? progressColor
                          : null,
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
                  fontWeight: FontWeight.bold,
                  color: AppColors.surfaceLight,
                ),
          ),
      ],
    );
  }
}
