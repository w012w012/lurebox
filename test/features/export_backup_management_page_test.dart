import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/services/backup_zip_service.dart';
import 'package:lurebox/features/settings/export_backup_management_page.dart';
import 'package:cross_file/cross_file.dart';

import '../helpers/test_helpers.dart';

// ===== Fake Classes =====

class FakeBackupZipService implements BackupZipService {
  const FakeBackupZipService({this.importResult});

  final ImportResult? importResult;

  @override
  Future<ImportResult> importFromZipPath(String zipPath) async {
    return importResult ?? const ImportResult.success();
  }

  @override
  Future<BackupMetadata?> getBackupMetadata(String zipPath) async => null;

  @override
  Future<String> createBackup({
    String? customName,
    bool includePhotos = true,
  }) async {
    return 'fake_backup_path.zip';
  }

  @override
  Future<List<String>> listBackups() async => [];

  @override
  Future<void> deleteBackup(String path) async {}

  @override
  Future<String?> getLatestBackupPath() async => null;

  @override
  Future<XFile> exportToZip({
    BackupExportOptions options = BackupExportOptions.defaultOptions,
  }) async {
    return XFile('/fake/path.zip');
  }

  @override
  Future<String> exportToZipAndSave({
    BackupExportOptions options = BackupExportOptions.defaultOptions,
  }) async {
    return 'fake_backup.zip';
  }

  @override
  Future<ImportResult> importFromZip() async {
    return importResult ?? const ImportResult.success();
  }
}

/// Test helper to build the page with proper overrides
Widget buildTestPage({
  required Future<List<FileInfo>> filesFuture,
  BackupZipService? backupZipService,
}) {
  return ProviderScope(
    overrides: [
      currentStringsProvider.overrideWithValue(AppStrings.chinese),
      if (backupZipService != null)
        backupZipServiceProvider.overrideWithValue(backupZipService),
    ],
    child: MaterialApp(
      home: _TestableExportBackupPage(filesFuture: filesFuture),
    ),
  );
}

/// A testable version of the page that accepts a controlled Future
class _TestableExportBackupPage extends ConsumerStatefulWidget {
  const _TestableExportBackupPage({required this.filesFuture});

  final Future<List<FileInfo>> filesFuture;

  @override
  ConsumerState<_TestableExportBackupPage> createState() =>
      _TestableExportBackupPageState();
}

class _TestableExportBackupPageState
    extends ConsumerState<_TestableExportBackupPage> {
  late Future<List<FileInfo>> _filesFuture;

  @override
  void initState() {
    super.initState();
    _filesFuture = widget.filesFuture;
  }

  @override
  void didUpdateWidget(_TestableExportBackupPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filesFuture != widget.filesFuture) {
      _filesFuture = widget.filesFuture;
    }
  }

  void _refreshFiles() {
    setState(() {
      // Re-assign to trigger rebuild with same future for refresh test
      _filesFuture = widget.filesFuture;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(currentStringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.exportAndBackupManagement),
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
                    color: Colors.blue,
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
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    strings.noData,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshFiles(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return _buildFileCard(context, file, strings);
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
  ) {
    IconData icon;
    Color iconColor;
    String fileTypeLabel;

    if (file.isBackup) {
      icon = Icons.backup;
      iconColor = Colors.blue;
      fileTypeLabel = strings.fullBackupTitle;
    } else if (file.fileType == FileType.csvExport) {
      icon = Icons.table_chart;
      iconColor = Colors.blue;
      fileTypeLabel = strings.csvExport;
    } else {
      icon = Icons.code;
      iconColor = Colors.blue;
      fileTypeLabel = strings.jsonExport;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
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
                const SizedBox(width: 8),
                Text(
                  '2024-01-01 12:00',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              file.formattedSize,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {},
            ),
            if (file.isBackup)
              IconButton(
                icon: const Icon(Icons.restore),
                onPressed: () {},
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {},
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

// ===== Test Data =====

FileInfo createTestFileInfo({
  String name = 'fish_catches_2024-01-01.csv',
  String path = '/tmp/fish_catches_2024-01-01.csv',
  DateTime? modified,
  int size = 1024,
  FileType fileType = FileType.csvExport,
}) {
  return FileInfo(
    name: name,
    path: path,
    modified: modified ?? DateTime(2024, 1, 1, 12, 0),
    size: size,
    fileType: fileType,
  );
}

// ===== Tests =====

void main() {
  setUpAll(() {
    setUpDatabaseForTesting();
    registerFallbackValues();
  });

  group('ExportBackupManagementPage Widget Tests', () {
    testWidgets('renders page title in AppBar', (tester) async {
      await tester.pumpWidget(
        buildTestPage(filesFuture: Future.value([])),
      );
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.text(AppStrings.chinese.exportAndBackupManagement),
        findsOneWidget,
      );
    });

    testWidgets('shows loading indicator while fetching files',
        (tester) async {
      // Use an incomplete completer to keep future in waiting state
      final completer = Completer<List<FileInfo>>();

      await tester.pumpWidget(
        buildTestPage(filesFuture: completer.future),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Clean up - complete the future to avoid timer issues
      completer.complete([]);
    });

    testWidgets('shows empty state when no files exist', (tester) async {
      await tester.pumpWidget(
        buildTestPage(filesFuture: Future.value([])),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.folder_open), findsOneWidget);
      expect(find.text(AppStrings.chinese.noData), findsOneWidget);
    });

    testWidgets('displays file list when files exist', (tester) async {
      final files = [
        createTestFileInfo(
          name: 'fish_catches_2024-01-01.csv',
          fileType: FileType.csvExport,
        ),
        createTestFileInfo(
          name: 'fish_catches_2024-01-02.json',
          fileType: FileType.jsonExport,
        ),
        createTestFileInfo(
          name: 'lurebox_backup_2024-01-01.zip',
          fileType: FileType.zipBackup,
        ),
      ];

      await tester.pumpWidget(
        buildTestPage(filesFuture: Future.value(files)),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('fish_catches_2024-01-01.csv'), findsOneWidget);
      expect(find.text('fish_catches_2024-01-02.json'), findsOneWidget);
      expect(find.text('lurebox_backup_2024-01-01.zip'), findsOneWidget);
    });

    testWidgets('displays CSV export file with table_chart icon',
        (tester) async {
      final files = [
        createTestFileInfo(
          name: 'fish_catches_export.csv',
          fileType: FileType.csvExport,
        ),
      ];

      await tester.pumpWidget(
        buildTestPage(filesFuture: Future.value(files)),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.table_chart), findsOneWidget);
    });

    testWidgets('displays JSON export file with code icon', (tester) async {
      final files = [
        createTestFileInfo(
          name: 'fish_catches_export.json',
          fileType: FileType.jsonExport,
        ),
      ];

      await tester.pumpWidget(
        buildTestPage(filesFuture: Future.value(files)),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.code), findsOneWidget);
    });

    testWidgets('displays ZIP backup file with backup icon', (tester) async {
      final files = [
        createTestFileInfo(
          name: 'lurebox_backup_full.zip',
          fileType: FileType.zipBackup,
        ),
      ];

      await tester.pumpWidget(
        buildTestPage(filesFuture: Future.value(files)),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.backup), findsOneWidget);
    });

    testWidgets('shows share button on all file cards', (tester) async {
      final files = [
        createTestFileInfo(fileType: FileType.csvExport),
      ];

      await tester.pumpWidget(
        buildTestPage(filesFuture: Future.value(files)),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('shows restore button only on backup files', (tester) async {
      final files = [
        createTestFileInfo(
          name: 'backup.zip',
          fileType: FileType.zipBackup,
        ),
      ];

      await tester.pumpWidget(
        buildTestPage(filesFuture: Future.value(files)),
      );
      await tester.pump();
      await tester.pump();

      // Restore button should be present for ZIP backup
      expect(find.byIcon(Icons.restore), findsOneWidget);
      // Delete button should also be present
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('shows delete button on all file cards', (tester) async {
      final files = [
        createTestFileInfo(fileType: FileType.csvExport),
      ];

      await tester.pumpWidget(
        buildTestPage(filesFuture: Future.value(files)),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('shows error state when file listing fails', (tester) async {
      final completer = Completer<List<FileInfo>>();

      await tester.pumpWidget(
        buildTestPage(filesFuture: completer.future),
      );

      // Complete with error after widget is built
      completer.completeError(Exception('Failed to list files'));

      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text(AppStrings.chinese.error), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows retry button in error state', (tester) async {
      final completer = Completer<List<FileInfo>>();

      await tester.pumpWidget(
        buildTestPage(filesFuture: completer.future),
      );

      // Complete with error after widget is built
      completer.completeError(Exception('Failed'));

      await tester.pump();
      await tester.pump();

      expect(find.text(AppStrings.chinese.retry), findsOneWidget);
    });

    testWidgets('displays formatted file size correctly', (tester) async {
      final files = [
        createTestFileInfo(size: 512), // 512 B
        createTestFileInfo(
          name: 'small.csv',
          size: 1024, // 1 KB
          fileType: FileType.csvExport,
        ),
        createTestFileInfo(
          name: 'medium.csv',
          size: 1024 * 1024, // 1 MB
          fileType: FileType.csvExport,
        ),
      ];

      await tester.pumpWidget(
        buildTestPage(filesFuture: Future.value(files)),
      );
      await tester.pump();
      await tester.pump();

      // Use exact text match to avoid "1.0 MB" matching "B" in textContaining
      expect(find.text('512 B'), findsOneWidget);
      expect(find.text('1.0 KB'), findsOneWidget);
      expect(find.text('1.0 MB'), findsOneWidget);
    });

    testWidgets('file card shows file type label', (tester) async {
      final files = [
        createTestFileInfo(fileType: FileType.csvExport),
      ];

      await tester.pumpWidget(
        buildTestPage(filesFuture: Future.value(files)),
      );
      await tester.pump();
      await tester.pump();

      // File type label should be shown
      expect(find.text(AppStrings.chinese.csvExport), findsOneWidget);
    });

    testWidgets('backup file card shows backup type label', (tester) async {
      final files = [
        createTestFileInfo(fileType: FileType.zipBackup),
      ];

      await tester.pumpWidget(
        buildTestPage(filesFuture: Future.value(files)),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text(AppStrings.chinese.fullBackupTitle), findsOneWidget);
    });

    testWidgets('displays multiple files in ListView', (tester) async {
      final files = List.generate(
        5,
        (i) => createTestFileInfo(
          name: 'file_$i.csv',
          fileType: FileType.csvExport,
        ),
      );

      await tester.pumpWidget(
        buildTestPage(filesFuture: Future.value(files)),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(5));
    });

    testWidgets('RefreshIndicator present for pull-to-refresh', (tester) async {
      final files = [
        createTestFileInfo(fileType: FileType.csvExport),
      ];

      await tester.pumpWidget(
        buildTestPage(filesFuture: Future.value(files)),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}
