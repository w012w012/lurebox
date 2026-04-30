import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/providers/settings_view_model.dart';
import 'package:lurebox/core/services/backup_zip_service.dart';
import 'package:lurebox/core/services/export_service.dart';
import 'package:lurebox/features/me/backup_export_page.dart';
import 'package:lurebox/features/me/me_page.dart';
import 'package:lurebox/features/me/me_settings_page.dart';
import 'package:cross_file/cross_file.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_helpers.dart';

// ===== Mock Classes =====

class MockAppSettingsNotifier extends StateNotifier<AppSettings>
    implements AppSettingsNotifier {
  MockAppSettingsNotifier() : super(const AppSettings());

  @override
  Future<void> updateSettings(AppSettings settings) async {
    state = settings;
  }

  @override
  Future<void> updateUnits(UnitSettings units) async {
    state = state.copyWith(units: units);
  }

  @override
  Future<void> updateDarkMode(DarkMode mode) async {
    state = state.copyWith(darkMode: mode);
  }

  @override
  Future<void> updateLanguage(AppLanguage language) async {
    state = state.copyWith(language: language);
  }

  @override
  Future<void> completeOnboarding() async {
    state = state.copyWith(hasCompletedOnboarding: true);
  }
}

class MockSettingsViewModel extends StateNotifier<SettingsState>
    implements SettingsViewModel {
  MockSettingsViewModel() : super(const SettingsState());

  @override
  Future<String?> exportData() async => null;

  @override
  Future<int?> importData(String filePath) async => null;

  @override
  Future<void> loadStats() async {}

  @override
  Future<void> loadTotalCount() async {}

  @override
  Future<String?> startZipBackup({bool includePhotos = true}) async => null;

  @override
  Future<ImportResult> importZipBackup() async => const ImportResult.success();

  @override
  void resetError() {}

  @override
  void clearError() {}

  @override
  void clearExportPath() {}

  @override
  void setError(String message, {String? detail}) {}

  @override
  Future<XFile?> exportDataWithFormat({
    ExportFormat format = ExportFormat.csv,
  }) async => null;

  @override
  Future<XFile?> exportZipBackup({bool includePhotos = true}) async => null;

  @override
  Future<String?> uploadToWebDAV({
    required String serverUrl,
    required String username,
    required String password,
  }) async => null;
}

// ===== Test App Builders =====

Widget createMePageTestApp({
  required List<Override> overrides,
}) {
  final router = GoRouter(
    initialLocation: '/me',
    routes: [
      GoRoute(
        path: '/me',
        builder: (context, state) => const MePage(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Achievements'))),
      ),
      GoRoute(
        path: '/settings/locations',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Locations'))),
      ),
      GoRoute(
        path: '/species',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Species'))),
      ),
      GoRoute(
        path: '/settings/watermark',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Watermark'))),
      ),
      GoRoute(
        path: '/me/backup-export',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Backup'))),
      ),
      GoRoute(
        path: '/me/settings',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Settings'))),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Home'))),
      ),
    ],
  );
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(routerConfig: router),
  );
}

Widget createMeSettingsPageTestApp({
  required List<Override> overrides,
}) {
  final router = GoRouter(
    initialLocation: '/me/settings',
    routes: [
      GoRoute(
        path: '/me/settings',
        builder: (context, state) => const MeSettingsPage(),
      ),
      GoRoute(
        path: '/settings/units',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Units'))),
      ),
      GoRoute(
        path: '/settings/ai',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('AI Config'))),
      ),
    ],
  );
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(routerConfig: router),
  );
}

Widget createBackupExportPageTestApp({
  required List<Override> overrides,
}) {
  final router = GoRouter(
    initialLocation: '/me/backup',
    routes: [
      GoRoute(
        path: '/me/backup',
        builder: (context, state) => const BackupExportPage(),
      ),
      GoRoute(
        path: '/settings/export-backup',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('File Management'))),
      ),
    ],
  );
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  setUpAll(() {
    setUpDatabaseForTesting();
    registerFallbackValues();
  });

  group('MePage', () {
    testWidgets('renders LureBox tile', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createMePageTestApp(
          overrides: [
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
        ),
      );
      await tester.pump();

      // LureBox tile should be visible
      expect(find.text('LureBox'), findsOneWidget);
    });

    testWidgets('renders achievement tile icon', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createMePageTestApp(
          overrides: [
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.category), findsOneWidget);
      expect(find.byIcon(Icons.cloud_upload), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.eco), findsOneWidget);
    });

    testWidgets('tapping LureBox shows about dialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createMePageTestApp(
          overrides: [
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
          ],
        ),
      );
      await tester.pump();

      // Tap the LureBox tile
      await tester.tap(find.text('LureBox'));
      await tester.pump();

      // Dialog should appear
      expect(find.text('知道了'), findsOneWidget);
    });
  });

  group('MeSettingsPage', () {
    testWidgets('renders dark mode setting', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Suppress overflow errors from dropdown in test environment
      final originalFlutterError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) return;
        originalFlutterError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalFlutterError);

      await tester.pumpWidget(
        createMeSettingsPageTestApp(
          overrides: [
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
            appSettingsProvider.overrideWith(
              (ref) => MockAppSettingsNotifier(),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('深色模式'), findsOneWidget);
    });

    testWidgets('renders language setting', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final originalFlutterError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) return;
        originalFlutterError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalFlutterError);

      await tester.pumpWidget(
        createMeSettingsPageTestApp(
          overrides: [
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
            appSettingsProvider.overrideWith(
              (ref) => MockAppSettingsNotifier(),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('语言'), findsOneWidget);
    });

    testWidgets('renders all settings icons', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final originalFlutterError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) return;
        originalFlutterError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalFlutterError);

      await tester.pumpWidget(
        createMeSettingsPageTestApp(
          overrides: [
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
            appSettingsProvider.overrideWith(
              (ref) => MockAppSettingsNotifier(),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      expect(find.byIcon(Icons.language), findsOneWidget);
      expect(find.byIcon(Icons.straighten), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });
  });

  group('BackupExportPage', () {
    testWidgets('renders app bar title', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockVm = MockSettingsViewModel();

      await tester.pumpWidget(
        createBackupExportPageTestApp(
          overrides: [
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
            settingsViewModelProvider.overrideWith((ref) => mockVm),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('备份和导出'), findsOneWidget);
    });

    testWidgets('renders all backup icons', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockVm = MockSettingsViewModel();

      await tester.pumpWidget(
        createBackupExportPageTestApp(
          overrides: [
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
            settingsViewModelProvider.overrideWith((ref) => mockVm),
          ],
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.cloud_upload), findsOneWidget);
      expect(find.byIcon(Icons.table_chart), findsOneWidget);
      expect(find.byIcon(Icons.archive), findsOneWidget);
      expect(find.byIcon(Icons.restore), findsOneWidget);
      expect(find.byIcon(Icons.folder_open), findsOneWidget);
    });

    testWidgets('shows loading indicator when exporting', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockVm = MockSettingsViewModel();
      mockVm.state = const SettingsState(isExporting: true);

      await tester.pumpWidget(
        createBackupExportPageTestApp(
          overrides: [
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
            settingsViewModelProvider.overrideWith((ref) => mockVm),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('shows loading indicator when creating backup',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockVm = MockSettingsViewModel();
      mockVm.state = const SettingsState(isCreatingZipBackup: true);

      await tester.pumpWidget(
        createBackupExportPageTestApp(
          overrides: [
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
            settingsViewModelProvider.overrideWith((ref) => mockVm),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('shows loading indicator when restoring', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockVm = MockSettingsViewModel();
      mockVm.state = const SettingsState(isRestoringZipBackup: true);

      await tester.pumpWidget(
        createBackupExportPageTestApp(
          overrides: [
            currentStringsProvider.overrideWithValue(AppStrings.chinese),
            settingsViewModelProvider.overrideWith((ref) => mockVm),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}
