import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/design/theme/app_theme.dart';
import '../../core/providers/language_provider.dart';
import '../../core/di/di.dart';

/// 文件信息类
class FileInfo {
  final String name;
  final String path;
  final DateTime modified;
  final int size;
  final bool isBackup;

  const FileInfo({
    required this.name,
    required this.path,
    required this.modified,
    required this.size,
    required this.isBackup,
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
}

/// 列出导出和备份文件
Future<List<FileInfo>> _listExportBackupFiles() async {
  final directory = await getApplicationDocumentsDirectory();
  final dir = Directory(directory.path);
  final List<FileInfo> files = [];

  await for (final entity in dir.list()) {
    if (entity is File) {
      final name = entity.uri.pathSegments.last;
      final isExport = name.startsWith('fish_catches_') &&
          (name.endsWith('.csv') ||
              name.endsWith('.pdf') ||
              name.endsWith('.json'));
      final isBackup =
          name.startsWith('lurebox_backup_') && name.endsWith('.json');

      if (isExport || isBackup) {
        final stat = await entity.stat();
        files.add(FileInfo(
          name: name,
          path: entity.path,
          modified: stat.modified,
          size: stat.size,
          isBackup: isBackup,
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
              style: const TextStyle(color: AppColors.error),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除成功')),
          );
          _refreshFiles();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.errorFileDelete)),
          );
        }
      }
    }
  }

  Future<void> _importBackup(FileInfo file) async {
    final strings = ref.read(currentStringsProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.confirmImportFile),
        content: Text(file.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.importData),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.importingData)),
          );
        }

        final backupService = ref.read(backupServiceProvider);
        final count = await backupService.importFromJson(file.path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.importedCount
                  .replaceAll(r'$count', count.toString())),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.errorFileImport)),
          );
        }
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
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(strings.error),
                  const SizedBox(height: 16),
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
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    strings.noData,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshFiles(),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
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

    if (file.isBackup) {
      icon = Icons.backup;
      iconColor = AppColors.primaryLight;
    } else if (file.name.endsWith('.csv')) {
      icon = Icons.table_chart;
      iconColor = AppColors.success;
    } else if (file.name.endsWith('.pdf')) {
      icon = Icons.picture_as_pdf;
      iconColor = AppColors.error;
    } else {
      icon = Icons.code;
      iconColor = AppColors.accentLight;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
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
            Text(dateFormat.format(file.modified)),
            const SizedBox(height: 2),
            Text(
              file.formattedSize,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (file.isBackup)
              IconButton(
                icon: const Icon(Icons.restore),
                tooltip: strings.importData,
                onPressed: () => _importBackup(file),
              ),
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
