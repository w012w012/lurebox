import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/services/app_logger.dart';
import 'package:lurebox/widgets/common/premium_button.dart';
import 'package:lurebox/widgets/common/premium_card.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsAboutSection extends ConsumerStatefulWidget {
  const SettingsAboutSection({super.key});

  @override
  ConsumerState<SettingsAboutSection> createState() =>
      _SettingsAboutSectionState();
}

class _SettingsAboutSectionState extends ConsumerState<SettingsAboutSection> {
  String _appVersion = '1.0.1';

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
    } catch (e) {
      AppLogger.e('SettingsAboutSection', '获取版本失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(currentStringsProvider);

    return PremiumCard(
      child: Column(
        children: [
          _buildSettingRow(
            context: context,
            icon: Icons.info_outline,
            title: strings.about,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(context, strings),
          ),
          const Divider(height: 1),
          _buildSettingRow(
            context: context,
            icon: Icons.code,
            title: strings.version,
            trailing: Text(
              'v$_appVersion',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: TeslaColors.graphite),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    const accentColor = TeslaColors.electricBlue;

    final child = Padding(
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
              child: Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500),),),
          trailing,
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, child: child);
    }
    return child;
  }

  void _showAboutDialog(BuildContext context, AppStrings strings) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.set_meal, color: Theme.of(context).colorScheme.primary),
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
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: TeslaTheme.spacingMd),
              Text(
                strings.features,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: TeslaTheme.spacingSm),
              _buildFeatureItem('🐟', '渔获记录', '拍照记录、GPS定位、天气信息'),
              _buildFeatureItem('🎣', '装备管理', '鱼竿、渔轮、鱼饵全面管理'),
              _buildFeatureItem('📊', '数据统计', '趋势分析、物种分布、装备使用'),
              _buildFeatureItem('📸', 'AI识别', '智能识别鱼种，自动填充信息'),
              _buildFeatureItem('💧', '图片水印', '自定义水印样式，分享精彩瞬间'),
              _buildFeatureItem('📤', '数据导出', '支持CSV、PDF导出与分享'),
              _buildFeatureItem('☁️', '云备份', 'WebDAV同步，数据安全无忧'),
              _buildFeatureItem('🏆', '成就系统', '解锁成就，记录钓鱼里程碑'),
              const SizedBox(height: TeslaTheme.spacingMd),
              Text(
                '© 2026 LureBox 路亚鱼护',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: TeslaColors.graphite,
                    ),
              ),
            ],
          ),
        ),
        actions: [
          PremiumButton(
            text: strings.gotIt,
            variant: PremiumButtonVariant.text,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String title, String description) {
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
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: TeslaColors.graphite,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
