import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/watermark_provider.dart';
import '../../core/providers/settings_view_model.dart';
import '../../core/widgets/error_view.dart';
import '../../widgets/common/premium_card.dart';
import '../../widgets/settings/settings_backup_section.dart';
import '../../widgets/settings/settings_appearance_section.dart';
import '../../widgets/settings/settings_units_section.dart';
import '../../widgets/settings/settings_about_section.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);
    final watermarkSettings = ref.watch(watermarkSettingsProvider);
    final settingsState = ref.watch(settingsViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.settings), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(settingsViewModelProvider.notifier).loadStats(),
        child: settingsState.isLoading
            ? const LoadingView()
            : settingsState.errorMessage != null
                ? ErrorView(
                    message: settingsState.errorMessage!,
                    onRetry: () => ref
                        .read(settingsViewModelProvider.notifier)
                        .loadStats(),
                    strings: strings,
                  )
                : _buildSettingsList(context, ref, strings, watermarkSettings),
      ),
    );
  }

  Widget _buildSettingsList(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    dynamic watermarkSettings,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;

        // Tablet: use two-column layout with sections in groups
        if (isTablet) {
          return _buildTabletSettings(context, ref, strings, watermarkSettings);
        }

        // Mobile: single column list (original)
        return _buildMobileSettings(context, ref, strings, watermarkSettings);
      },
    );
  }

  Widget _buildMobileSettings(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    dynamic watermarkSettings,
  ) {
    return ListView(
      children: [
        const SizedBox(height: 16),
        _buildLocationCard(context, strings),
        const SizedBox(height: 8),
        _buildSpeciesCard(context, strings),
        const SizedBox(height: 8),
        _buildWatermarkCard(context, strings, watermarkSettings),
        const SizedBox(height: 8),
        _buildAiRecognitionCard(context, strings),
        const SizedBox(height: 8),
        const SettingsUnitsSection(),
        const SizedBox(height: 8),
        const SettingsAppearanceSection(),
        const SizedBox(height: 8),
        const SettingsBackupSection(),
        const SizedBox(height: 8),
        const SettingsAboutSection(),
        const SizedBox(height: 24),
        _buildFooter(context, strings),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTabletSettings(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    dynamic watermarkSettings,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First row: Location, Species, Watermark
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildLocationCard(context, strings)),
              const SizedBox(width: 16),
              Expanded(child: _buildSpeciesCard(context, strings)),
              const SizedBox(width: 16),
              Expanded(
                  child:
                      _buildWatermarkCard(context, strings, watermarkSettings)),
            ],
          ),
          const SizedBox(height: 16),
          // Second row: AI Recognition
          _buildAiRecognitionCard(context, strings),
          const SizedBox(height: 16),
          // Third row: Units and Appearance in parallel
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: SettingsUnitsSection()),
              SizedBox(width: 16),
              Expanded(child: SettingsAppearanceSection()),
            ],
          ),
          const SizedBox(height: 16),
          // Fourth row: Backup and About
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: SettingsBackupSection()),
              SizedBox(width: 16),
              Expanded(child: SettingsAboutSection()),
            ],
          ),
          const SizedBox(height: 24),
          Center(child: _buildFooter(context, strings)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWatermarkCard(
    BuildContext context,
    AppStrings strings,
    dynamic watermarkSettings,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PremiumCard(
      onTap: () {
        context.push('/settings/watermark');
      },
      child: Row(
        children: [
          Icon(
            Icons.branding_watermark,
            color: isDark ? AppColors.accentDark : AppColors.accentLight,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.watermarkSettings,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  watermarkSettings.enabled
                      ? strings.enabled
                      : strings.disabled,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: watermarkSettings.enabled
                            ? AppColors.success
                            : isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget _buildAiRecognitionCard(
    BuildContext context,
    AppStrings strings,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PremiumCard(
      onTap: () {
        context.push('/settings/ai');
      },
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            color: isDark ? AppColors.accentDark : AppColors.accentLight,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI 配置',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  '管理 AI 识别提供商',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, AppStrings strings) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PremiumCard(
      onTap: () {
        context.push('/settings/locations');
      },
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: isDark ? AppColors.accentDark : AppColors.accentLight,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.locationManagement,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  strings.locationManagementDesc,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget _buildSpeciesCard(BuildContext context, AppStrings strings) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PremiumCard(
      onTap: () {
        context.push('/species');
      },
      child: Row(
        children: [
          Icon(
            Icons.category,
            color: isDark ? AppColors.accentDark : AppColors.accentLight,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '品种管理',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  '管理常用鱼种，合并相似品种',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AppStrings strings) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Icon(Icons.eco, size: 48, color: AppColors.success),
          const SizedBox(height: 12),
          Text(
            strings.protectionEcology,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            strings.reasonableRelease,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
