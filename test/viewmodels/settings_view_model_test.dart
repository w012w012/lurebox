import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/providers/settings_view_model.dart';
import 'package:lurebox/core/services/backup_service.dart';
import 'package:lurebox/core/services/backup_zip_service.dart';
import 'package:lurebox/core/services/export_service.dart';
import 'package:lurebox/core/services/fish_catch_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:share_plus/share_plus.dart';

class MockBackupService extends Mock implements BackupService {}

class MockBackupZipService extends Mock implements BackupZipService {}

class MockFishCatchService extends Mock implements FishCatchService {}

class FakeBackupExportOptions extends Fake implements BackupExportOptions {}

class FakeImportResult extends Fake implements ImportResult {}

void main() {
  late SettingsViewModel viewModel;
  late MockBackupService mockBackupService;
  late MockBackupZipService mockBackupZipService;
  late MockFishCatchService mockFishCatchService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/package_info'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return {
            'appName': 'LureBox',
            'packageName': 'com.lurebox.app',
            'version': '1.0.6',
            'buildNumber': '6',
          };
        }
        return null;
      },
    );

    registerFallbackValue(FakeBackupExportOptions());
    registerFallbackValue(FakeImportResult());
    registerFallbackValue(const BackupExportOptions());
    registerFallbackValue(ExportFormat.csv);
  });

  setUp(() {
    mockBackupService = MockBackupService();
    mockBackupZipService = MockBackupZipService();
    mockFishCatchService = MockFishCatchService();

    // Default mock behavior
    when(() => mockFishCatchService.getCount()).thenAnswer((_) async => 0);
    when(() => mockFishCatchService.getAll()).thenAnswer((_) async => []);
    when(() => mockBackupService.exportToJson())
        .thenAnswer((_) async => '/path/to/export.json');
    when(() => mockBackupService.importFromJson(any()))
        .thenAnswer((_) async => 10);
    when(() => mockBackupZipService.exportToZip(
          options: any(named: 'options'),
        ),).thenAnswer((_) async => XFile('/path/to/backup.zip'));
    when(() => mockBackupZipService.exportToZipAndSave(
          options: any(named: 'options'),
        ),).thenAnswer((_) async => '/path/to/saved/backup.zip');
    when(() => mockBackupZipService.importFromZip())
        .thenAnswer((_) async => const ImportResult.success());

    viewModel = SettingsViewModel(
      mockBackupService,
      mockBackupZipService,
      mockFishCatchService,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('SettingsViewModel', () {
    // ============================================================
    // Initial State Tests
    // ============================================================
    group('initial state', () {
      test('has correct default values after construction', () async {
        // Wait for loadStats() to complete (called in constructor)
        await Future<void>.delayed(Duration.zero);
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, isNull);
        expect(viewModel.state.totalCount, 0);
        expect(viewModel.state.appVersion, '1.0.6+6');
        expect(viewModel.state.isExporting, false);
        expect(viewModel.state.isImporting, false);
        expect(viewModel.state.isUploading, false);
        expect(viewModel.state.isCreatingZipBackup, false);
        expect(viewModel.state.isRestoringZipBackup, false);
        expect(viewModel.state.exportPath, isNull);
        expect(viewModel.state.errorDetail, isNull);
      });

      test('constructor calls loadStats() on initialization', () {
        verify(() => mockFishCatchService.getCount()).called(1);
      });
    });

    // ============================================================
    // loadStats Tests
    // ============================================================
    group('loadStats', () {
      test('loadStats success - returns correct totalCount', () async {
        when(() => mockFishCatchService.getCount()).thenAnswer((_) async => 42);

        await viewModel.loadStats();

        expect(viewModel.state.totalCount, 42);
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, isNull);
      });

      test('loadStats error - sets errorMessage on failure', () async {
        when(() => mockFishCatchService.getCount())
            .thenThrow(Exception('Database error'));

        await viewModel.loadStats();

        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, contains('Database error'));
      });

      test('loadStats sets isLoading to true before operation completes',
          () async {
        var loadingState = false;
        when(() => mockFishCatchService.getCount()).thenAnswer((_) async {
          loadingState = viewModel.state.isLoading;
          return 10;
        });

        await viewModel.loadStats();

        expect(loadingState, true);
      });
    });

    // ============================================================
    // exportData Tests
    // ============================================================
    group('exportData', () {
      test('exportData success - returns path and updates state', () async {
        const expectedPath = '/documents/lurebox_backup_123.json';
        when(() => mockBackupService.exportToJson())
            .thenAnswer((_) async => expectedPath);

        final result = await viewModel.exportData();

        expect(result, expectedPath);
        expect(viewModel.state.exportPath, expectedPath);
        expect(viewModel.state.isExporting, false);
        expect(viewModel.state.errorMessage, isNull);
      });

      test('exportData error - sets errorMessage on failure', () async {
        when(() => mockBackupService.exportToJson())
            .thenThrow(Exception('Export failed'));

        final result = await viewModel.exportData();

        expect(result, isNull);
        expect(viewModel.state.isExporting, false);
        expect(viewModel.state.errorMessage, contains('Export failed'));
      });

      test('exportData sets isExporting to true during operation', () async {
        var exportingState = false;
        when(() => mockBackupService.exportToJson()).thenAnswer((_) async {
          exportingState = viewModel.state.isExporting;
          return '/path/to/export.json';
        });

        await viewModel.exportData();

        expect(exportingState, true);
      });

      test('exportData clears previous errorMessage', () async {
        // Trigger an error first
        when(() => mockFishCatchService.getCount())
            .thenThrow(Exception('Initial error'));

        // Wait for the error state to be set
        try {
          await viewModel.loadStats();
        } catch (_) {}

        // Now export should clear the error
        when(() => mockBackupService.exportToJson())
            .thenAnswer((_) async => '/path/to/export.json');

        await viewModel.exportData();

        expect(viewModel.state.errorMessage, isNull);
      });
    });

    // ============================================================
    // importData Tests
    // ============================================================
    group('importData', () {
      test('importData success - returns count and updates totalCount',
          () async {
        const testFilePath = '/path/to/import.json';
        when(() => mockBackupService.importFromJson(testFilePath))
            .thenAnswer((_) async => 15);
        when(() => mockFishCatchService.getCount()).thenAnswer((_) async => 15);

        final result = await viewModel.importData(testFilePath);

        expect(result, 15);
        expect(viewModel.state.isImporting, false);
        expect(viewModel.state.totalCount, 15);
        expect(viewModel.state.errorMessage, isNull);
      });

      test('importData error - sets errorMessage on failure', () async {
        const testFilePath = '/path/to/import.json';
        when(() => mockBackupService.importFromJson(testFilePath))
            .thenThrow(Exception('Import failed'));

        final result = await viewModel.importData(testFilePath);

        expect(result, isNull);
        expect(viewModel.state.isImporting, false);
        expect(viewModel.state.errorMessage, contains('Import failed'));
      });

      test('importData sets isImporting to true during operation', () async {
        var importingState = false;
        const testFilePath = '/path/to/import.json';
        when(() => mockBackupService.importFromJson(testFilePath))
            .thenAnswer((_) async {
          importingState = viewModel.state.isImporting;
          return 10;
        });
        when(() => mockFishCatchService.getCount()).thenAnswer((_) async => 10);

        await viewModel.importData(testFilePath);

        expect(importingState, true);
      });

      test('importData clears previous errorMessage', () async {
        const testFilePath = '/path/to/import.json';
        // Trigger an error first
        when(() => mockFishCatchService.getCount())
            .thenThrow(Exception('Initial error'));
        try {
          await viewModel.loadStats();
        } catch (_) {}

        // Now import should clear the error
        when(() => mockBackupService.importFromJson(testFilePath))
            .thenAnswer((_) async => 5);
        when(() => mockFishCatchService.getCount()).thenAnswer((_) async => 5);

        await viewModel.importData(testFilePath);

        expect(viewModel.state.errorMessage, isNull);
      });

      test('importData calls loadStats after successful import', () async {
        const testFilePath = '/path/to/import.json';
        when(() => mockBackupService.importFromJson(testFilePath))
            .thenAnswer((_) async => 10);
        when(() => mockFishCatchService.getCount()).thenAnswer((_) async => 10);

        await viewModel.importData(testFilePath);

        verify(() => mockFishCatchService.getCount()).called(2);
      });
    });

    // ============================================================
    // clearError Tests
    // ============================================================
    group('clearError', () {
      test('clearError clears both errorMessage and errorDetail', () {
        // Set an error first via loadStats failure
        when(() => mockFishCatchService.getCount())
            .thenThrow(Exception('Test error'));

        // ignore: invalid_use_of_protected_member
        viewModel.loadStats();

        // Now clear
        viewModel.clearError();

        expect(viewModel.state.errorMessage, isNull);
        expect(viewModel.state.errorDetail, isNull);
      });
    });

    // ============================================================
    // clearExportPath Tests
    // ============================================================
    group('clearExportPath', () {
      test('clearExportPath sets exportPath to null', () {
        const exportPath = '/path/to/export.json';
        when(() => mockBackupService.exportToJson())
            .thenAnswer((_) async => exportPath);

        // Set export path
        viewModel.state = viewModel.state.copyWith(exportPath: () => exportPath);
        expect(viewModel.state.exportPath, exportPath);

        // Clear - now correctly sets to null
        viewModel.clearExportPath();
        expect(viewModel.state.exportPath, isNull);
      });

      test('clearExportPath does not affect other state fields', () {
        const exportPath = '/path/to/export.json';
        viewModel.state = viewModel.state.copyWith(
          exportPath: () => exportPath,
          totalCount: 42,
          errorMessage: () => 'some error',
        );

        viewModel.clearExportPath();

        expect(viewModel.state.exportPath, isNull);
        expect(viewModel.state.totalCount, 42);
        expect(viewModel.state.errorMessage, 'some error');
      });

      test('setError can be used to verify state updates work', () {
        viewModel.setError('Test error', detail: 'Test detail');
        expect(viewModel.state.errorMessage, 'Test error');
        expect(viewModel.state.errorDetail, 'Test detail');
      });
    });

    // ============================================================
    // setError Tests
    // ============================================================
    group('setError', () {
      test('setError sets errorMessage and errorDetail', () {
        viewModel.setError('Test error', detail: 'Test detail');

        expect(viewModel.state.errorMessage, 'Test error');
        expect(viewModel.state.errorDetail, 'Test detail');
      });

      test('setError works without detail', () {
        viewModel.setError('Test error only');

        expect(viewModel.state.errorMessage, 'Test error only');
        expect(viewModel.state.errorDetail, isNull);
      });
    });

    // ============================================================
    // State Transition Tests
    // ============================================================
    group('state transitions', () {
      test('multiple operations maintain correct state', () async {
        when(() => mockFishCatchService.getCount()).thenAnswer((_) async => 25);
        when(() => mockBackupService.exportToJson())
            .thenAnswer((_) async => '/path/to/export.json');

        await viewModel.loadStats();
        expect(viewModel.state.totalCount, 25);
        expect(viewModel.state.isLoading, false);

        await viewModel.exportData();
        expect(viewModel.state.exportPath, '/path/to/export.json');
        expect(viewModel.state.isExporting, false);
        // Note: clearExportPath() now correctly clears exportPath via closure pattern
        expect(viewModel.state.totalCount, 25); // preserved
      });

      test('loadStats error and clearError works correctly', () async {
        when(() => mockFishCatchService.getCount())
            .thenThrow(Exception('Stats error'));

        await viewModel.loadStats();
        expect(viewModel.state.errorMessage, contains('Stats error'));

        viewModel.clearError();
        expect(viewModel.state.errorMessage, isNull);
      });
    });

    // ============================================================
    // Edge Cases
    // ============================================================
    group('edge cases', () {
      test('handles empty import path gracefully', () async {
        when(() => mockBackupService.importFromJson(''))
            .thenThrow(Exception('Invalid path'));

        final result = await viewModel.importData('');

        expect(result, isNull);
        expect(viewModel.state.errorMessage, contains('Invalid path'));
      });

      test('handles zero totalCount correctly', () async {
        when(() => mockFishCatchService.getCount()).thenAnswer((_) async => 0);

        await viewModel.loadStats();

        expect(viewModel.state.totalCount, 0);
        expect(viewModel.state.isLoading, false);
      });

      test('handles large totalCount correctly', () async {
        when(() => mockFishCatchService.getCount())
            .thenAnswer((_) async => 999999);

        await viewModel.loadStats();

        expect(viewModel.state.totalCount, 999999);
      });
    });

    // ============================================================
    // Backup/Zip Operations Tests
    // ============================================================
    group('backup and zip operations', () {
      test('exportZipBackup success', () async {
        when(() => mockBackupZipService.exportToZip(
              options: any(named: 'options'),
            ),).thenAnswer((_) async => XFile('/path/to/backup.zip'));

        final result = await viewModel.exportZipBackup();

        expect(result, isNotNull);
        expect(viewModel.state.isCreatingZipBackup, false);
      });

      test('exportZipBackup error', () async {
        when(() => mockBackupZipService.exportToZip(
              options: any(named: 'options'),
            ),).thenThrow(Exception('Zip error'));

        final result = await viewModel.exportZipBackup();

        expect(result, isNull);
        expect(viewModel.state.errorMessage, contains('Zip error'));
      });

      test('startZipBackup success', () async {
        when(() => mockBackupZipService.exportToZipAndSave(
              options: any(named: 'options'),
            ),).thenAnswer((_) async => '/saved/backup.zip');

        final result = await viewModel.startZipBackup();

        expect(result, '/saved/backup.zip');
        expect(viewModel.state.isCreatingZipBackup, false);
      });

      test('importZipBackup success', () async {
        when(() => mockBackupZipService.importFromZip())
            .thenAnswer((_) async => const ImportResult.success());
        when(() => mockFishCatchService.getCount()).thenAnswer((_) async => 0);

        final result = await viewModel.importZipBackup();

        expect(result.isSuccess, true);
        expect(viewModel.state.isRestoringZipBackup, false);
      });

      test('importZipBackup error', () async {
        when(() => mockBackupZipService.importFromZip()).thenAnswer(
            (_) async => const ImportResult.failure('Import failed'),);

        final result = await viewModel.importZipBackup();

        expect(result.isSuccess, false);
        expect(viewModel.state.isRestoringZipBackup, false);
      });
    });

    // ============================================================
    // uploadToWebDAV Tests
    // ============================================================
    group('uploadToWebDAV', () {
      test('uploadToWebDAV success', () async {
        when(() => mockBackupService.uploadToWebDAV(
              serverUrl: any(named: 'serverUrl'),
              username: any(named: 'username'),
              password: any(named: 'password'),
            ),).thenAnswer((_) async => 'https://example.com/backup.json');

        final result = await viewModel.uploadToWebDAV(
          serverUrl: 'https://example.com/',
          username: 'user',
          password: 'pass',
        );

        expect(result, 'https://example.com/backup.json');
        expect(viewModel.state.isUploading, false);
      });

      test('uploadToWebDAV error', () async {
        when(() => mockBackupService.uploadToWebDAV(
              serverUrl: any(named: 'serverUrl'),
              username: any(named: 'username'),
              password: any(named: 'password'),
            ),).thenThrow(Exception('Upload failed'));

        final result = await viewModel.uploadToWebDAV(
          serverUrl: 'https://example.com/',
          username: 'user',
          password: 'pass',
        );

        expect(result, isNull);
        expect(viewModel.state.errorMessage, contains('Upload failed'));
      });

      test('uploadToWebDAV sets isUploading to true during operation',
          () async {
        var uploadingState = false;
        when(() => mockBackupService.uploadToWebDAV(
              serverUrl: any(named: 'serverUrl'),
              username: any(named: 'username'),
              password: any(named: 'password'),
            ),).thenAnswer((_) async {
          uploadingState = viewModel.state.isUploading;
          return 'https://example.com/backup.json';
        });

        await viewModel.uploadToWebDAV(
          serverUrl: 'https://example.com/',
          username: 'user',
          password: 'pass',
        );

        expect(uploadingState, true);
      });
    });
  });
}
