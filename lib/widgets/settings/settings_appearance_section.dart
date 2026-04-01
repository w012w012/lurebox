import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/theme/app_colors.dart';
import '../../core/design/theme/app_theme.dart';
import '../../core/models/app_settings.dart';
import '../../core/providers/app_settings_provider.dart';
import '../../core/providers/language_provider.dart';
import '../common/premium_card.dart';
import '../common/premium_input.dart';

class SettingsAppearanceSection extends ConsumerWidget {
  const SettingsAppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider);
    final strings = ref.watch(currentStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PremiumCard(
      child: Column(
        children: [
          // Dark Mode
          _buildSettingRow(
            context: context,
            icon: Icons.dark_mode,
            isDark: isDark,
            child: Expanded(
              child: Text(
                strings.darkMode,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
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
          _buildSettingRow(
            context: context,
            icon: Icons.language,
            isDark: isDark,
            child: Expanded(
              child: Text(
                strings.language,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
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

  Widget _buildSettingRow({
    required BuildContext context,
    required IconData icon,
    required bool isDark,
    required Widget child,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacingMd,
        horizontal: AppTheme.spacingSm,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? AppColors.accentDark : AppColors.accentLight,
          ),
          const SizedBox(width: 16),
          child,
          trailing,
        ],
      ),
    );
  }
}
