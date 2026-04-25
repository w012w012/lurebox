import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/providers/settings_view_model.dart';
import 'package:lurebox/core/services/export_service.dart';
import 'package:lurebox/features/settings/widgets/webdav_config_dialog.dart';
import 'package:lurebox/widgets/common/app_snack_bar.dart';
import 'package:lurebox/widgets/common/premium_card.dart';
import 'package:share_plus/share_plus.dart';

class SettingsBackupSection extends ConsumerWidget {
  const SettingsBackupSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);
    final settingsState = ref.watch(settingsViewModelProvider);

    return PremiumCard(
      child: Column(
        children: [
          _buildTile(
            context: context,
            icon: Icons.cloud_upload,
            title: strings.webdavBackup,
            subtitle: strings.syncToCloud,
            onTap: () => _showWebDAVDialog(context, ref, strings),
          ),
          const Divider(height: 1),
          _buildTile(
            context: context,
            icon: Icons.table_chart,
            title: strings.csvExport,
            subtitle: strings.exportCsvDesc,
            isLoading: settingsState.isExporting,
            onTap: () => _handleCsvExport(context, ref),
          ),
          _buildTile(
            context: context,
            icon: Icons.archive,
            title: strings.fullBackupTitle,
            subtitle: strings.fullBackupDesc,
            isLoading: settingsState.isCreatingZipBackup,
            onTap: () => _showFullBackupDialog(context, ref, strings),
          ),
          const Divider(height: 1),
          _buildTile(
            context: context,
            icon: Icons.restore,
            title: strings.restoreTitle,
            subtitle: strings.restoreBackupDesc,
            isLoading: settingsState.isRestoringZipBackup,
            onTap: () => _handleZipRestore(context, ref, strings),
          ),
          const Divider(height: 1),
          _buildTile(
            context: context,
            icon: Icons.folder_open,
            title: strings.exportAndBackupManagement,
            subtitle: strings.exportAndBackupManagementDesc,
            onTap: () => context.push('/settings/export-backup'),
          ),
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
    bool isLoading = false,
  }) {
    const accentColor = TeslaColors.electricBlue;
    return InkWell(
      onTap: isLoading ? null : onTap,
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
              child: Icon(
                isLoading ? Icons.hourglass_empty : icon,
                color: accentColor,
                size: 22,
              ),
            ),
            const SizedBox(width: TeslaTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
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
    );
  }

  Future<void> _handleCsvExport(BuildContext context, WidgetRef ref) async {
    final strings = ref.read(currentStringsProvider);
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    try {
      final xFile =
          await viewModel.exportDataWithFormat(format: ExportFormat.csv);
      if (context.mounted && xFile != null) {
        await Share.shareXFiles(
          [xFile],
          subject: 'LureBox CSV Export',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(context, strings.exportFailedMsg, debugError: e);
      }
    }
  }

  void _showWebDAVDialog(
      BuildContext context, WidgetRef ref, AppStrings strings,) {
    showDialog<void>(
      context: context,
      builder: (context) => const WebDAVConfigDialog(),
    );
  }

  /// 显示完整备份确认对话框（ZIP格式）
  void _showFullBackupDialog(
      BuildContext context, WidgetRef ref, AppStrings strings,) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.fullBackupTitle),
        content: Text(
          strings.fullBackupCreateDesc,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _handleFullBackup(context, ref, strings, includePhotos: true);
            },
            child: Text(strings.startBackup),
          ),
        ],
      ),
    );
  }

  /// 处理完整备份（保存到后台，不立即分享）
  Future<void> _handleFullBackup(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings, {
    required bool includePhotos,
  }) async {
    final viewModel = ref.read(settingsViewModelProvider.notifier);

    // 显示备份进行中对话框
    showDialog<void>(
      context: context,
      barrierDismissible: false, // 防止用户关闭对话框
      builder: (context) => AlertDialog(
        title: Text(strings.creatingBackup),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: TeslaTheme.spacingMd),
            Text(strings.backupRunning),
          ],
        ),
      ),
    );

    try {
      final savedPath =
          await viewModel.startZipBackup(includePhotos: includePhotos);

      if (!context.mounted) return;

      // 关闭"正在创建备份"对话框
      Navigator.of(context).pop();

      if (savedPath != null) {
        // 显示备份完成提示
        AppSnackBar.showSuccess(context, strings.backupComplete);
      } else {
        AppSnackBar.showError(context, strings.backupFailed);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // 关闭对话框
        AppSnackBar.showError(context, strings.backupFailed, debugError: e);
      }
    }
  }

  /// 处理 ZIP 备份恢复
  Future<void> _handleZipRestore(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) async {
    final viewModel = ref.read(settingsViewModelProvider.notifier);

    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.restoreTitle),
        content: Text(
          strings.restoreOverwriteWarning,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.continueAction),
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
        var message = strings.restoreSuccessMsg;
        if (metadata != null) {
          message = '${strings.restoreSuccessMsg}\n'
              '渔获: ${metadata.fishCatchesCount} 条\n'
              '装备: ${metadata.equipmentCount} 件\n'
              '照片: ${metadata.photoCount} 张';
        }
        AppSnackBar.showSuccess(context, message);
      } else {
        AppSnackBar.showError(
          context,
          '${strings.restoreFailedMsg}: ${result.errorMessage ?? "未知错误"}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(context, strings.restoreFailedMsg, debugError: e);
      }
    }
  }
}
