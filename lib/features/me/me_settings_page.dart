import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/widgets/common/premium_card.dart';
import 'package:lurebox/widgets/common/premium_input.dart';

class MeSettingsPage extends ConsumerWidget {
  const MeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider);
    final strings = ref.watch(currentStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.settings),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: TeslaTheme.spacingMd,
          vertical: TeslaTheme.spacingSm,
        ),
        children: [
          PremiumCard(
            padding: const EdgeInsets.symmetric(
              horizontal: TeslaTheme.spacingLg,
              vertical: TeslaTheme.spacingMd,
            ),
            child: Column(
              children: [
                // Dark Mode - inline dropdown
                _buildInlineTile(
                  context: context,
                  ref: ref,
                  icon: Icons.dark_mode,
                  isDark: isDark,
                  title: strings.darkMode,
                  trailing: SizedBox(
                    width: 140,
                    child: PremiumDropdown<DarkMode>(
                      value: appSettings.darkMode,
                      items: [
                        PremiumDropdownItem(
                          value: DarkMode.system,
                          label: strings.followSystem,
                        ),
                        PremiumDropdownItem(
                          value: DarkMode.light,
                          label: strings.off,
                        ),
                        PremiumDropdownItem(
                          value: DarkMode.dark,
                          label: strings.on,
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(appSettingsProvider.notifier)
                              .updateDarkMode(value);
                        }
                      },
                    ),
                  ),
                ),
                const Divider(height: 1),
                // Language - inline dropdown
                _buildInlineTile(
                  context: context,
                  ref: ref,
                  icon: Icons.language,
                  isDark: isDark,
                  title: strings.language,
                  trailing: SizedBox(
                    width: 140,
                    child: PremiumDropdown<AppLanguage>(
                      value: appSettings.language,
                      items: [
                        PremiumDropdownItem(
                          value: AppLanguage.chinese,
                          label: strings.simplifiedChinese,
                        ),
                        const PremiumDropdownItem(
                          value: AppLanguage.english,
                          label: 'English',
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(appSettingsProvider.notifier)
                              .updateLanguage(value);
                        }
                      },
                    ),
                  ),
                ),
                const Divider(height: 1),
                // Unit Settings - navigation tile
                _buildNavigationTile(
                  context: context,
                  icon: Icons.straighten,
                  title: strings.unitsSettings,
                  subtitle: strings.unitsSettings,
                  onTap: () => context.push('/settings/units'),
                ),
                const Divider(height: 1),
                // AI Configuration - navigation tile
                _buildNavigationTile(
                  context: context,
                  icon: Icons.auto_awesome,
                  title: strings.aiConfiguration,
                  subtitle: strings.aiConfigurationDesc,
                  onTap: () => context.push('/settings/ai'),
                ),
              ],
            ),
          ),
          const SizedBox(height: TeslaTheme.spacingXl),
        ],
      ),
    );
  }

  /// Inline setting tile with dropdown (dark mode, language)
  Widget _buildInlineTile({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required bool isDark,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    const accentColor = TeslaColors.electricBlue;

    return InkWell(
      onTap: onTap,
      child: Padding(
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
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: TeslaTheme.spacingMd),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? TeslaColors.white : TeslaColors.carbonDark,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  /// Navigation tile with chevron (units, AI config)
  Widget _buildNavigationTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    const accentColor = TeslaColors.electricBlue;

    return InkWell(
      onTap: onTap,
      child: Padding(
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
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: TeslaTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}