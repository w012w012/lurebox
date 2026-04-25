import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/widgets/common/premium_card.dart';
import 'package:lurebox/widgets/common/premium_input.dart';

class SettingsAppearanceSection extends ConsumerWidget {
  const SettingsAppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider);
    final strings = ref.watch(currentStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PremiumCard(
      padding: const EdgeInsets.symmetric(
        horizontal: TeslaTheme.spacingLg,
        vertical: TeslaTheme.spacingMd,
      ),
      child: Column(
        children: [
          // Dark Mode
          _buildSettingTile(
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
          // Language
          _buildSettingTile(
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
        ],
      ),
    );
  }

  Widget _buildSettingTile({
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
                  color: isDark
                      ? TeslaColors.white
                      : TeslaColors.carbonDark,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
