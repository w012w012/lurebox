import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/app_theme.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/settings_view_model.dart';
import '../../../widgets/common/premium_card.dart';

class SettingsStatsCard extends ConsumerWidget {
  const SettingsStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsViewModelProvider);
    final strings = ref.watch(currentStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;

    return PremiumCard(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingLg,
        vertical: AppTheme.spacingSm,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacingMd,
        horizontal: AppTheme.spacingSm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(Icons.analytics_outlined, color: accentColor, size: 22),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Text(
              strings.fishCount,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Text(
            '${settingsState.totalCount} ${strings.fishCountUnit}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
