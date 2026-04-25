import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/providers/settings_view_model.dart';
import 'package:lurebox/widgets/common/premium_card.dart';

class SettingsStatsCard extends ConsumerWidget {
  const SettingsStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsViewModelProvider);
    final strings = ref.watch(currentStringsProvider);
    const accentColor = TeslaColors.electricBlue;

    return PremiumCard(
      margin: const EdgeInsets.symmetric(
        horizontal: TeslaTheme.spacingLg,
        vertical: TeslaTheme.spacingMicro,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: TeslaTheme.spacingMd,
        horizontal: TeslaTheme.spacingSm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(TeslaTheme.spacingSm),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
            ),
            child: Icon(Icons.analytics_outlined, color: accentColor, size: 22),
          ),
          const SizedBox(width: TeslaTheme.spacingMd),
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
