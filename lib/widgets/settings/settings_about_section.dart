import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/strings.dart';
import '../../../core/design/theme/app_colors.dart';
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
    final child = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.appDescription),
            const SizedBox(height: 12),
            Text(strings.features),
            const SizedBox(height: 4),
            Text('• ${strings.recordCatch}'),
            Text('• ${strings.location}'),
            Text('• ${strings.time}'),
            Text('• ${strings.release}/${strings.keep}'),
            Text('• ${strings.statistics}'),
            Text('• ${strings.watermarkSettings}'),
            const SizedBox(height: 12),
            Text(
              '© 2026 ${strings.appName}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.secondaryLight),
            ),
          ],
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
}
