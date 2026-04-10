import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/strings.dart';
import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/app_theme.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/settings_view_model.dart';
import '../../../core/services/export_service.dart';
import '../common/premium_card.dart';
import 'webdav_config_dialog.dart';

class SettingsBackupSection extends ConsumerWidget {
  const SettingsBackupSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);
    final settingsState = ref.watch(settingsViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;

    return PremiumCard(
      child: Column(
        children: [
          // WebDAV Backup
          InkWell(
            onTap: () => _showWebDAVDialog(context, ref, strings),
            child: Padding(
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
                    child:
                        Icon(Icons.cloud_upload, color: accentColor, size: 22),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.webdavBackup,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          strings.syncToCloud,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
// Export CSV
          InkWell(
            onTap: settingsState.isExporting
                ? null
                : () => _handleCsvExport(context, ref),
            child: Padding(
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
                    child: Icon(
                      settingsState.isExporting
                          ? Icons.hourglass_empty
                          : Icons.table_chart,
                      color: accentColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '导出 CSV',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '导出渔获记录为 CSV 表格',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (settingsState.isExporting)
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
// ZIP Full Backup
          InkWell(
            onTap: settingsState.isCreatingZipBackup
                ? null
                : () => _showFullBackupDialog(context, ref, strings),
            child: Padding(
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
                    child: Icon(
                      settingsState.isCreatingZipBackup
                          ? Icons.hourglass_empty
                          : Icons.archive,
                      color: accentColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '完整备份',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '导出包含数据库和照片的ZIP备份',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (settingsState.isCreatingZipBackup)
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
          const Divider(height: 1),
          // ZIP Restore
          InkWell(
            onTap: settingsState.isRestoringZipBackup
                ? null
                : () => _handleZipRestore(context, ref, strings),
            child: Padding(
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
                    child: Icon(
                      settingsState.isRestoringZipBackup
                          ? Icons.hourglass_empty
                          : Icons.restore,
                      color: accentColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '恢复备份',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '从ZIP备份文件恢复数据',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (settingsState.isRestoringZipBackup)
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
          const Divider(height: 1),
          // Export/Backup Management
          InkWell(
            onTap: () => context.push('/settings/export-backup'),
            child: Padding(
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
                    child: Icon(
                      Icons.folder_open,
                      color: accentColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '导出和备份管理',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '查看和管理导出备份文件',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCsvExport(BuildContext context, WidgetRef ref) async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  void _showWebDAVDialog(
      BuildContext context, WidgetRef ref, AppStrings strings) {
    showDialog(
      context: context,
      builder: (context) => const WebDAVConfigDialog(),
    );
  }

  /// 显示完整备份确认对话框（ZIP格式）
  void _showFullBackupDialog(
      BuildContext context, WidgetRef ref, AppStrings strings) {
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

  /// 处理完整备份（保存到后台，不立即分享）
  Future<void> _handleFullBackup(
    BuildContext context,
    WidgetRef ref, {
    required bool includePhotos,
  }) async {
    final viewModel = ref.read(settingsViewModelProvider.notifier);

    // 显示备份进行中对话框
    showDialog(
      context: context,
      barrierDismissible: false, // 防止用户关闭对话框
      builder: (context) => const AlertDialog(
        title: Text('正在创建备份'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('备份正在后台运行，请稍候...'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('备份已完成，请到"导出和备份管理"中查看'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('备份失败')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // 关闭对话框
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('备份失败: $e')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('恢复失败: ${result.errorMessage ?? "未知错误"}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('恢复失败: $e')),
        );
      }
    }
  }
}
