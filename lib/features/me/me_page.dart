import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/design/theme/tesla_theme.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/settings_view_model.dart';
import '../../widgets/common/premium_card.dart';
import '../../widgets/common/settings_tile.dart';

class MePage extends ConsumerStatefulWidget {
  const MePage({super.key});

  @override
  ConsumerState<MePage> createState() => _MePageState();
}

class _MePageState extends ConsumerState<MePage> {
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppVersion();
      ref.read(settingsViewModelProvider.notifier).loadStats();
    });
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(currentStringsProvider);
    final settingsState = ref.watch(settingsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.me),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: TeslaTheme.spacingMd,
          vertical: TeslaTheme.spacingSm,
        ),
        children: [
          // Stats summary
          _buildStatsCard(context, strings, settingsState),
          const SizedBox(height: TeslaTheme.spacingSm),

          // Data management section header
          _buildSectionHeader(context, strings.dataManagement),
          const SizedBox(height: TeslaTheme.spacingMicro),

          // 钓点管理
          SettingsTile(
            icon: Icons.location_on,
            title: strings.locationManagement,
            subtitle: strings.locationManagementDesc,
            showChevron: true,
            onTap: () => context.push('/settings/locations'),
          ),
          const SizedBox(height: TeslaTheme.spacingMicro),

          // 鱼种管理
          SettingsTile(
            icon: Icons.category,
            title: strings.speciesManagement,
            subtitle: strings.speciesManagementDesc,
            showChevron: true,
            onTap: () => context.push('/species'),
          ),
          const SizedBox(height: TeslaTheme.spacingSm),

          // Settings section header
          _buildSectionHeader(context, strings.settings),
          const SizedBox(height: TeslaTheme.spacingMicro),

          // All settings entries
          SettingsTile(
            icon: Icons.dark_mode,
            title: strings.appearanceSettings,
            subtitle: strings.appearanceSettingsDesc,
            showChevron: true,
            onTap: () => context.push('/settings'),
          ),
          const SizedBox(height: TeslaTheme.spacingMicro),

          SettingsTile(
            icon: Icons.branding_watermark,
            title: strings.watermarkSettings,
            subtitle: strings.watermarkSettingsDesc,
            showChevron: true,
            onTap: () => context.push('/settings/watermark'),
          ),
          const SizedBox(height: TeslaTheme.spacingMicro),

          SettingsTile(
            icon: Icons.auto_awesome,
            title: strings.aiConfiguration,
            subtitle: strings.aiConfigurationDesc,
            showChevron: true,
            onTap: () => context.push('/settings/ai'),
          ),
          const SizedBox(height: TeslaTheme.spacingMicro),

          SettingsTile(
            icon: Icons.cloud_upload,
            title: strings.webdavBackup,
            subtitle: strings.syncToCloud,
            showChevron: true,
            onTap: () => context.push('/settings/export-backup'),
          ),
          const SizedBox(height: TeslaTheme.spacingSm),

          // About section header
          _buildSectionHeader(context, strings.about),
          const SizedBox(height: TeslaTheme.spacingMicro),

          // About LureBox
          SettingsTile(
            icon: Icons.eco,
            title: 'LureBox',
            subtitle: 'v$_appVersion · 路亚鱼护',
            showChevron: true,
            onTap: () => _showAboutDialog(context, strings),
          ),

          const SizedBox(height: TeslaTheme.spacingXl),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    AppStrings strings,
    SettingsState state,
  ) {
    return PremiumCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(TeslaTheme.spacingMd),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(TeslaTheme.spacingSm),
              decoration: BoxDecoration(
                color: TeslaColors.electricBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: TeslaColors.electricBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: TeslaTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.fishCount,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    '${state.totalCount} ${strings.fishCountUnit}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Text(
              '${state.totalCount}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: TeslaColors.electricBlue,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppStrings strings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.set_meal,
                color: Theme.of(ctx).colorScheme.primary),
            const SizedBox(width: TeslaTheme.spacingSm),
            Text(strings.appName),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '路亚钓鱼爱好者的专业鱼获记录工具',
                style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: TeslaTheme.spacingMd),
              Text(
                '主要功能',
                style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: TeslaTheme.spacingSm),
              _buildFeatureItem(ctx, '🐟', '渔获记录', '拍照记录、GPS定位、天气信息'),
              _buildFeatureItem(ctx, '🎣', '装备管理', '鱼竿、渔轮、鱼饵全面管理'),
              _buildFeatureItem(ctx, '📊', '数据统计', '趋势分析、物种分布、装备使用'),
              _buildFeatureItem(ctx, '📸', 'AI识别', '智能识别鱼种，自动填充信息'),
              _buildFeatureItem(ctx, '💧', '图片水印', '自定义水印样式，分享精彩瞬间'),
              _buildFeatureItem(ctx, '📤', '数据导出', '支持CSV、PDF导出与分享'),
              _buildFeatureItem(ctx, '☁️', '云备份', 'WebDAV同步，数据安全无忧'),
              _buildFeatureItem(ctx, '🏆', '成就系统', '解锁成就，记录钓鱼里程碑'),
              const SizedBox(height: TeslaTheme.spacingMd),
              Text(
                '© 2026 LureBox 路亚鱼护',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: TeslaColors.graphite,
                    ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.gotIt),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
      BuildContext ctx, String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TeslaTheme.spacingMicro),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: TeslaTheme.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: TeslaColors.graphite),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
