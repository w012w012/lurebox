import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/design/theme/tesla_theme.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/settings_view_model.dart';
import '../../core/services/export_service.dart';
import '../../widgets/common/premium_card.dart';
import '../../widgets/common/app_snack_bar.dart';
import '../settings/widgets/webdav_config_dialog.dart';

class BackupExportPage extends ConsumerWidget {
  const BackupExportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);
    final settingsState = ref.watch(settingsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.backupAndExport),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: TeslaTheme.spacingMd,
          vertical: TeslaTheme.spacingSm,
        ),
        children: [
          // WebDAV备份
          _buildSettingTile(
            context: context,
            icon: Icons.cloud_upload,
            title: strings.webdavBackup,
            subtitle: strings.syncToCloud,
            onTap: () => _showWebDAVDialog(context),
          ),
          const SizedBox(height: TeslaTheme.spacingMicro),

          // 导出CSV
          _buildSettingTile(
            context: context,
            icon: Icons.table_chart,
            title: strings.exportCsv,
            subtitle: strings.exportCsvDesc,
            onTap: settingsState.isExporting ? null : () => _handleCsvExport(context, ref),
            isLoading: settingsState.isExporting,
          ),
          const SizedBox(height: TeslaTheme.spacingMicro),

          // 完整备份
          _buildSettingTile(
            context: context,
            icon: Icons.archive,
            title: strings.fullBackup,
            subtitle: strings.fullBackupDesc,
            onTap: settingsState.isCreatingZipBackup ? null : () => _showFullBackupDialog(context, ref, strings),
            isLoading: settingsState.isCreatingZipBackup,
          ),
          const SizedBox(height: TeslaTheme.spacingMicro),

          // 恢复备份
          _buildSettingTile(
            context: context,
            icon: Icons.restore,
            title: strings.restoreBackup,
            subtitle: strings.restoreBackupDesc,
            onTap: settingsState.isRestoringZipBackup ? null : () => _handleZipRestore(context, ref, strings),
            isLoading: settingsState.isRestoringZipBackup,
          ),
          const SizedBox(height: TeslaTheme.spacingMicro),

          // 文件管理
          _buildSettingTile(
            context: context,
            icon: Icons.folder_open,
            title: strings.fileManagement,
            subtitle: strings.fileManagementDesc,
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
    required VoidCallback? onTap,
    bool isLoading = false,
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
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  void _showWebDAVDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const WebDAVConfigDialog(),
    );
  }

  Future<void> _handleCsvExport(BuildContext context, WidgetRef ref) async {
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    try {
      final xFile = await viewModel.exportDataWithFormat(format: ExportFormat.csv);
      if (context.mounted && xFile != null) {
        await Share.shareXFiles([xFile], subject: 'LureBox CSV Export');
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(context, '导出失败', debugError: e);
      }
    }
  }

  void _showFullBackupDialog(BuildContext context, WidgetRef ref, AppStrings strings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('完整备份'),
        content: const Text(
          '将创建包含数据库和所有照片的完整备份。\n\n是否继续？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _handleFullBackup(context, ref, includePhotos: true);
            },
            child: const Text('开始备份'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleFullBackup(
    BuildContext context,
    WidgetRef ref, {
    required bool includePhotos,
  }) async {
    final viewModel = ref.read(settingsViewModelProvider.notifier);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('正在创建备份'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: TeslaTheme.spacingMd),
            Text('备份正在后台运行，请稍候...'),
          ],
        ),
      ),
    );

    try {
      final savedPath = await viewModel.startZipBackup(includePhotos: includePhotos);

      if (!context.mounted) return;

      Navigator.of(context).pop();

      if (savedPath != null) {
        AppSnackBar.showSuccess(context, '备份已完成，请到"导出和备份管理"中查看');
      } else {
        AppSnackBar.showError(context, '备份失败');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        AppSnackBar.showError(context, '备份失败', debugError: e);
      }
    }
  }

  Future<void> _handleZipRestore(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) async {
    final viewModel = ref.read(settingsViewModelProvider.notifier);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('恢复备份'),
        content: const Text(
          '恢复备份将覆盖当前所有数据。建议在恢复前导出一份当前数据的备份。\n\n是否继续？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('继续'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await viewModel.importZipBackup();

      if (!context.mounted) return;

      if (result.isSuccess) {
        final metadata = result.metadata;
        String message = '恢复成功';
        if (metadata != null) {
          message = '恢复成功\n'
              '渔获: ${metadata.fishCatchesCount} 条\n'
              '装备: ${metadata.equipmentCount} 件\n'
              '照片: ${metadata.photoCount} 张';
        }
        AppSnackBar.showSuccess(context, message);
      } else {
        AppSnackBar.showError(
          context,
          '恢复失败: ${result.errorMessage ?? "未知错误"}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(context, '恢复失败', debugError: e);
      }
    }
  }
}