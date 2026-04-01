import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/strings.dart';
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

    return PremiumCard(
      child: Column(
        children: [
          // WebDAV Backup
          InkWell(
            onTap: () => _showWebDAVDialog(context, ref, strings),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Row(
                children: [
                  Icon(Icons.cloud_upload,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 16),
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
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Row(
                children: [
                  Icon(
                    settingsState.isExporting
                        ? Icons.hourglass_empty
                        : Icons.table_chart,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
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
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Row(
                children: [
                  Icon(
                    settingsState.isCreatingZipBackup
                        ? Icons.hourglass_empty
                        : Icons.archive,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
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
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Row(
                children: [
                  Icon(
                    settingsState.isRestoringZipBackup
                        ? Icons.hourglass_empty
                        : Icons.restore,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
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

  /// 显示完整备份对话框（ZIP格式）
  void _showFullBackupDialog(
      BuildContext context, WidgetRef ref, AppStrings strings) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '完整备份',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('完整备份（含照片）'),
              subtitle: const Text('包含数据库和所有照片，文件较大'),
              onTap: () {
                Navigator.pop(context);
                _handleFullBackup(context, ref, includePhotos: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('仅备份数据库'),
              subtitle: const Text('只包含数据记录，文件较小'),
              onTap: () {
                Navigator.pop(context);
                _handleFullBackup(context, ref, includePhotos: false);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// 处理完整备份
  Future<void> _handleFullBackup(
    BuildContext context,
    WidgetRef ref, {
    required bool includePhotos,
  }) async {
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    try {
      final xFile =
          await viewModel.exportZipBackup(includePhotos: includePhotos);
      if (context.mounted && xFile != null) {
        await Share.shareXFiles(
          [xFile],
          subject: 'LureBox 完整备份',
          text: '包含数据库${includePhotos ? "和照片" : ""}的完整备份',
        );
      }
    } catch (e) {
      if (context.mounted) {
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
