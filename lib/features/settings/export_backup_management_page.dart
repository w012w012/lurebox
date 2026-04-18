import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/design/theme/tesla_theme.dart';
import '../../core/providers/language_provider.dart';
import '../../core/di/di.dart';
import '../../widgets/common/app_snack_bar.dart';

/// 文件类型枚举
enum FileType {
  /// CSV 导出文件
  csvExport,

  /// JSON 导出文件
  jsonExport,

  /// ZIP 备份文件
  zipBackup,
}

/// 文件信息类
class FileInfo {
  final String name;
  final String path;
  final DateTime modified;
  final int size;
  final FileType fileType;

  const FileInfo({
    required this.name,
    required this.path,
    required this.modified,
    required this.size,
    required this.fileType,
  });

  String get formattedSize {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  bool get isExport =>
      fileType == FileType.csvExport || fileType == FileType.jsonExport;

  bool get isBackup => fileType == FileType.zipBackup;
}

/// 列出导出和备份文件
Future<List<FileInfo>> _listExportBackupFiles() async {
  final directory = await getApplicationDocumentsDirectory();
  final dir = Directory(directory.path);
  final List<FileInfo> files = [];

  await for (final entity in dir.list()) {
    if (entity is File) {
      final name = entity.uri.pathSegments.last;

      FileType? fileType;

      // 判断文件类型
      if (name.startsWith('fish_catches_') && name.endsWith('.csv')) {
        fileType = FileType.csvExport;
      } else if (name.startsWith('fish_catches_') && name.endsWith('.json')) {
        fileType = FileType.jsonExport;
      } else if (name.startsWith('lurebox_backup_') && name.endsWith('.zip')) {
        fileType = FileType.zipBackup;
      }

      if (fileType != null) {
        final stat = await entity.stat();
        files.add(FileInfo(
          name: name,
          path: entity.path,
          modified: stat.modified,
          size: stat.size,
          fileType: fileType,
        ));
      }
    }
  }

  // 按修改时间倒序排列
  files.sort((a, b) => b.modified.compareTo(a.modified));
  return files;
}

/// 导出备份管理页面
class ExportBackupManagementPage extends ConsumerStatefulWidget {
  const ExportBackupManagementPage({super.key});

  @override
  ConsumerState<ExportBackupManagementPage> createState() =>
      _ExportBackupManagementPageState();
}

class _ExportBackupManagementPageState
    extends ConsumerState<ExportBackupManagementPage> {
  late Future<List<FileInfo>> _filesFuture;

  @override
  void initState() {
    super.initState();
    _refreshFiles();
  }

  void _refreshFiles() {
    setState(() {
      _filesFuture = _listExportBackupFiles();
    });
  }

  Future<void> _deleteFile(FileInfo file) async {
    final strings = ref.read(currentStringsProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.confirmDelete),
        content: Text('${strings.confirmDelete}\n${file.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              strings.delete,
              style: const TextStyle(color: TeslaColors.electricBlue),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final fileToDelete = File(file.path);
        await fileToDelete.delete();
        if (mounted) {
          AppSnackBar.showSuccess(context, '删除成功');
          _refreshFiles();
        }
      } catch (e) {
        if (mounted) {
          AppSnackBar.showError(context, strings.errorFileDelete);
        }
      }
    }
  }

  /// 分享文件
  Future<void> _shareFile(FileInfo file) async {
    try {
      final xFile = XFile(file.path);
      await Share.shareXFiles(
        [xFile],
        subject: file.isBackup ? 'LureBox 完整备份' : 'LureBox 数据导出',
      );
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, '分享失败', debugError: e);
      }
    }
  }

  /// 从 ZIP 备份恢复数据
  Future<void> _restoreBackup(FileInfo file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('恢复备份'),
        content: Text(
          '恢复备份将覆盖当前所有数据。建议在恢复前导出一份当前数据的备份。\n\n'
          '即将恢复: ${file.name}\n\n'
          '是否继续？',
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
      if (mounted) {
        AppSnackBar.showInfo(context, '正在恢复备份...');
      }

      final backupZipService = ref.read(backupZipServiceProvider);
      final result = await backupZipService.importFromZipPath(file.path);

      if (!mounted) return;

      if (result.isSuccess) {
        AppSnackBar.showSuccess(context, '恢复成功');
      } else {
        AppSnackBar.showError(
          context,
          '恢复失败: ${result.errorMessage ?? "未知错误"}',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, '恢复失败', debugError: e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(currentStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('导出和备份管理'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<FileInfo>>(
        future: _filesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: TeslaColors.electricBlue,
                  ),
                  const SizedBox(height: TeslaTheme.spacingMd),
                  Text(strings.error),
                  const SizedBox(height: TeslaTheme.spacingMd),
                  ElevatedButton(
                    onPressed: _refreshFiles,
                    child: Text(strings.retry),
                  ),
                ],
              ),
            );
          }

          final files = snapshot.data ?? [];

          if (files.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: isDark
                        ? const Color(0xFF9A9A9A)
                        : TeslaColors.graphite,
                  ),
                  const SizedBox(height: TeslaTheme.spacingMd),
                  Text(
                    strings.noData,
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF9A9A9A)
                          : TeslaColors.graphite,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshFiles(),
            child: ListView.builder(
              padding: const EdgeInsets.all(TeslaTheme.spacingMd),
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return _buildFileCard(context, file, strings, isDark);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFileCard(
    BuildContext context,
    FileInfo file,
    AppStrings strings,
    bool isDark,
  ) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    IconData icon;
    Color iconColor;
    String fileTypeLabel;

    if (file.isBackup) {
      icon = Icons.backup;
      iconColor = TeslaColors.electricBlue;
      fileTypeLabel = '完整备份';
    } else if (file.fileType == FileType.csvExport) {
      icon = Icons.table_chart;
      iconColor = TeslaColors.electricBlue;
      fileTypeLabel = 'CSV 导出';
    } else {
      icon = Icons.code;
      iconColor = TeslaColors.electricBlue;
      fileTypeLabel = 'JSON 导出';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: TeslaTheme.spacingSm),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(TeslaTheme.spacingSm),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          file.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
                  ),
                  child: Text(
                    fileTypeLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: iconColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: TeslaTheme.spacingSm),
                Text(
                  dateFormat.format(file.modified),
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF9A9A9A)
                        : TeslaColors.graphite,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              file.formattedSize,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF9A9A9A)
                    : TeslaColors.graphite,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Share button for all files
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: strings.share,
              onPressed: () => _shareFile(file),
            ),
            // Restore button only for ZIP backups
            if (file.isBackup)
              IconButton(
                icon: const Icon(Icons.restore),
                tooltip: '恢复备份',
                onPressed: () => _restoreBackup(file),
              ),
            // Delete button for all files
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: strings.delete,
              onPressed: () => _deleteFile(file),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
