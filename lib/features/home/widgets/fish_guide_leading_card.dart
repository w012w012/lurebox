import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/animation_constants.dart';
import '../../../core/providers/fish_guide_provider.dart';
import '../../../widgets/common/premium_card.dart';

/// Progress status for the fish guide card
enum FishGuideProgressStatus {
  locked, // Grey progress bar
  inProgress, // Blue gradient progress bar with percentage
  completed, // Green progress bar with checkmark
}

/// Fish Guide leading card for the home page.
/// Displays fish guide unlock progress and navigates to the achievement page.
class FishGuideLeadingCard extends ConsumerWidget {
  const FishGuideLeadingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fishGuideState = ref.watch(fishGuideProvider);
    final unlockedCount = fishGuideState.unlockedCount;
    final totalCount = fishGuideState.totalCount;
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;
    final progressPercent = (progress * 100).round();

    // Calculate monthly new count from species list
    final monthlyNewCount = _calculateMonthlyNewCount(fishGuideState);

    FishGuideProgressStatus status;
    if (unlockedCount == 0) {
      status = FishGuideProgressStatus.locked;
    } else if (unlockedCount == totalCount && totalCount > 0) {
      status = FishGuideProgressStatus.completed;
    } else {
      status = FishGuideProgressStatus.inProgress;
    }

    return PremiumCard(
      variant: PremiumCardVariant.elevated,
      padding: const EdgeInsets.all(20),
      showBorder: false,
      backgroundColor: Theme.of(context).colorScheme.primary,
      onTap: () {
        context.push('/achievements');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with fish icon
          Row(
            children: [
              const Text(
                '🐟',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                '鱼类图鉴',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.surfaceLight,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          _buildProgressBar(context, progress, progressPercent, status),
          const SizedBox(height: 8),

          // Count text
          Text(
            '$unlockedCount / $totalCount 种鱼',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.surfaceLight.withOpacity(0.9),
                ),
          ),
          const SizedBox(height: 8),

          // Monthly new count
          if (monthlyNewCount > 0)
            Text(
              '本月新增: +$monthlyNewCount 种',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.surfaceLight.withOpacity(0.7),
                  ),
            ),
        ],
      ),
    );
  }

  int _calculateMonthlyNewCount(FishGuideState state) {
    if (state.speciesList.isEmpty) return 0;

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    return state.speciesList
        .where((s) =>
            s.stats.isUnlocked &&
            s.stats.firstCaughtAt != null &&
            s.stats.firstCaughtAt!.isAfter(monthStart))
        .length;
  }

  Widget _buildProgressBar(
    BuildContext context,
    double progress,
    int progressPercent,
    FishGuideProgressStatus status,
  ) {
    Color progressColor;
    Widget? trailingIcon;

    switch (status) {
      case FishGuideProgressStatus.locked:
        progressColor = AppColors.grey500;
        trailingIcon = const Icon(
          Icons.lock_outline,
          color: AppColors.grey500,
          size: 16,
        );
        break;
      case FishGuideProgressStatus.inProgress:
        progressColor = AppColors.accentLight;
        trailingIcon = null;
        break;
      case FishGuideProgressStatus.completed:
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
                  color: AppColors.surfaceLight.withOpacity(0.2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: status == FishGuideProgressStatus.inProgress
                          ? LinearGradient(
                              colors: [
                                AppColors.accentLight,
                                AppColors.accentLight.withOpacity(0.8),
                              ],
                            )
                          : null,
                      color: status != FishGuideProgressStatus.inProgress
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
