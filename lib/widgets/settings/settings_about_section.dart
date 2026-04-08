import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/strings.dart';
import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/app_theme.dart';
import '../../../core/providers/language_provider.dart';
import '../common/premium_button.dart';
import '../common/premium_card.dart';

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
      debugPrint('获取版本失败: $e');
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
                  ?.copyWith(color: AppColors.secondaryLight),
            ),
            onTap: null,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;

    final child = Padding(
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
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
              child: Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500))),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.set_meal, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
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
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                '主要功能',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildFeatureItem('🐟', '渔获记录', '拍照记录、GPS定位、天气信息'),
              _buildFeatureItem('🎣', '装备管理', '鱼竿、渔轮、鱼饵全面管理'),
              _buildFeatureItem('📊', '数据统计', '趋势分析、物种分布、装备使用'),
              _buildFeatureItem('📸', 'AI识别', '智能识别鱼种，自动填充信息'),
              _buildFeatureItem('💧', '图片水印', '自定义水印样式，分享精彩瞬间'),
              _buildFeatureItem('📤', '数据导出', '支持CSV、PDF导出与分享'),
              _buildFeatureItem('☁️', '云备份', 'WebDAV同步，数据安全无忧'),
              _buildFeatureItem('🏆', '成就系统', '解锁成就，记录钓鱼里程碑'),
              const SizedBox(height: 16),
              Text(
                '© 2026 LureBox 路亚鱼护',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryLight,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryLight,
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
