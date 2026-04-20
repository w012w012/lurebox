import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/tesla_theme.dart';
import '../../../core/providers/language_provider.dart';
import '../../../widgets/common/premium_card.dart';

/// 二级设置页面 — "我的 → 设置" 内展示的 4 个设置入口
class MeSettingsPage extends ConsumerWidget {
  const MeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);

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
          // 外观与语言
          _buildSettingTile(
            context: context,
            icon: Icons.dark_mode,
            title: strings.appearanceSettings,
            subtitle: strings.appearanceSettingsDesc,
            onTap: () => context.push('/settings'),
          ),
          const SizedBox(height: TeslaTheme.spacingMicro),

          // 水印设置
          _buildSettingTile(
            context: context,
            icon: Icons.branding_watermark,
            title: strings.watermarkSettings,
            subtitle: strings.watermarkSettingsDesc,
            onTap: () => context.push('/settings/watermark'),
          ),
          const SizedBox(height: TeslaTheme.spacingMicro),

          // AI 识别配置
          _buildSettingTile(
            context: context,
            icon: Icons.auto_awesome,
            title: strings.aiConfiguration,
            subtitle: strings.aiConfigurationDesc,
            onTap: () => context.push('/settings/ai'),
          ),
          const SizedBox(height: TeslaTheme.spacingMicro),

          // 备份与导出
          _buildSettingTile(
            context: context,
            icon: Icons.cloud_upload,
            title: strings.webdavBackup,
            subtitle: strings.syncToCloud,
            onTap: () => context.push('/settings/export-backup'),
          ),
          const SizedBox(height: TeslaTheme.spacingXl),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    const accentColor = TeslaColors.electricBlue;

    return PremiumCard(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
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
      ),
    );
  }
}
