import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/design/theme/tesla_theme.dart';
import '../../core/providers/language_provider.dart';
import '../../widgets/common/premium_card.dart';

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
          // 成就
          _buildTile(
            context: context,
            icon: Icons.emoji_events,
            iconColor: const Color(0xFFD4AF37),
            title: strings.achievement,
            subtitle: strings.viewAchievements,
            onTap: () => context.push('/achievements'),
          ),
          const SizedBox(height: TeslaTheme.spacingMicro),

          // 钓点管理
          _buildTile(
            context: context,
            icon: Icons.location_on,
            title: strings.locationManagement,
            subtitle: strings.locationManagementDesc,
            onTap: () => context.push('/settings/locations'),
          ),
          const SizedBox(height: TeslaTheme.spacingMicro),

          // 鱼种管理
          _buildTile(
            context: context,
            icon: Icons.category,
            title: strings.speciesManagement,
            subtitle: strings.speciesManagementDesc,
            onTap: () => context.push('/species'),
          ),
          const SizedBox(height: TeslaTheme.spacingMicro),

          // 水印管理
          _buildTile(
            context: context,
            icon: Icons.branding_watermark,
            title: strings.watermarkManagement,
            subtitle: strings.watermarkManagementDesc,
            onTap: () => context.push('/settings/watermark'),
          ),
          const SizedBox(height: TeslaTheme.spacingMicro),

          // 备份和导出
          _buildTile(
            context: context,
            icon: Icons.cloud_upload,
            title: strings.backupAndExport,
            subtitle: strings.backupAndExportDesc,
            onTap: () => context.push('/me/backup-export'),
          ),
          const SizedBox(height: TeslaTheme.spacingMicro),

          // 设置
          _buildTile(
            context: context,
            icon: Icons.settings,
            title: strings.settings,
            subtitle: strings.darkMode,
            onTap: () => context.push('/me/settings'),
          ),
          const SizedBox(height: TeslaTheme.spacingSm),

          // 关于 LureBox
          _buildTile(
            context: context,
            icon: Icons.eco,
            title: 'LureBox',
            subtitle: 'v$_appVersion · ${strings.appName}',
            onTap: () => _showAboutDialog(context, strings),
          ),

          const SizedBox(height: TeslaTheme.spacingXl),
        ],
      ),
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final accentColor = iconColor ?? TeslaColors.electricBlue;

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
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
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

  void _showAboutDialog(BuildContext context, AppStrings strings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.set_meal, color: Theme.of(ctx).colorScheme.primary),
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
                strings.appDescription,
                style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: TeslaTheme.spacingMd),
              Text(
                strings.features,
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
