import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/services/settings_service.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';

class MockSettingsService extends Mock implements SettingsService {}

class FakeAppSettings extends Fake implements AppSettings {}

void main() {
  late MockSettingsService mockService;

  setUpAll(() {
    registerFallbackValue(FakeAppSettings());
  });

  setUp(() {
    mockService = MockSettingsService();
  });

  group('AppSettingsNotifier', () {
    test('constructor calls _loadSettings and updates state', () async {
      // Arrange
      const loadedSettings = AppSettings(
        darkMode: DarkMode.dark,
        language: AppLanguage.english,
      );
      when(() => mockService.getAppSettings())
          .thenAnswer((_) async => loadedSettings);

      // Act - create notifier (constructor calls _loadSettings)
      final notifier = AppSettingsNotifier(mockService);

      // Wait for _loadSettings to complete
      await Future.delayed(Duration.zero);

      // Assert
      expect(notifier.state.darkMode, DarkMode.dark);
      expect(notifier.state.language, AppLanguage.english);
      verify(() => mockService.getAppSettings()).called(1);
    });

    // Note: _loadSettings failure is hard to test because the exception
    // propagates asynchronously from the constructor (not awaited).
    // The behavior can be verified by checking that state remains at default
    // when getAppSettings fails, but the exception itself is unhandled.

    test('updateSettings updates state and saves', () async {
      // Arrange
      const initialSettings = AppSettings();
      const newSettings = AppSettings(
        darkMode: DarkMode.dark,
        language: AppLanguage.english,
      );
      when(() => mockService.getAppSettings())
          .thenAnswer((_) async => initialSettings);
      when(() => mockService.saveAppSettings(any())).thenAnswer((_) async {});

      final notifier = AppSettingsNotifier(mockService);
      await Future.delayed(Duration.zero);

      // Act
      await notifier.updateSettings(newSettings);

      // Assert - state was updated
      expect(notifier.state.darkMode, DarkMode.dark);
      expect(notifier.state.language, AppLanguage.english);
      // save was called
      verify(() => mockService.saveAppSettings(any())).called(1);
    });

    test('updateSettings calls service.saveAppSettings with correct settings',
        () async {
      // Arrange
      const initialSettings = AppSettings();
      const newSettings = AppSettings(
        darkMode: DarkMode.dark,
        language: AppLanguage.english,
      );
      when(() => mockService.getAppSettings())
          .thenAnswer((_) async => initialSettings);
      when(() => mockService.saveAppSettings(any())).thenAnswer((_) async {});

      final notifier = AppSettingsNotifier(mockService);
      await Future.delayed(Duration.zero);

      // Act
      await notifier.updateSettings(newSettings);

      // Assert - save was called with correct settings
      verify(() => mockService.saveAppSettings(newSettings)).called(1);
    });

    test(
        'updateUnits creates new settings with new units and calls updateSettings',
        () async {
      // Arrange
      const initialSettings = AppSettings();
      const newUnits = UnitSettings(fishLengthUnit: 'inch');
      when(() => mockService.getAppSettings())
          .thenAnswer((_) async => initialSettings);
      when(() => mockService.saveAppSettings(any())).thenAnswer((_) async {});

      final notifier = AppSettingsNotifier(mockService);
      await Future.delayed(Duration.zero);

      // Act
      await notifier.updateUnits(newUnits);

      // Assert - state has new units
      expect(notifier.state.units.fishLengthUnit, 'inch');
      // save was called
      verify(() => mockService.saveAppSettings(any())).called(1);
    });

    test(
        'updateDarkMode creates new settings with new darkMode and calls updateSettings',
        () async {
      // Arrange
      const initialSettings = AppSettings(darkMode: DarkMode.light);
      when(() => mockService.getAppSettings())
          .thenAnswer((_) async => initialSettings);
      when(() => mockService.saveAppSettings(any())).thenAnswer((_) async {});

      final notifier = AppSettingsNotifier(mockService);
      await Future.delayed(Duration.zero);

      // Act
      await notifier.updateDarkMode(DarkMode.dark);

      // Assert - state has new darkMode
      expect(notifier.state.darkMode, DarkMode.dark);
      // save was called
      verify(() => mockService.saveAppSettings(any())).called(1);
    });

    test(
        'updateLanguage creates new settings with new language and calls updateSettings',
        () async {
      // Arrange
      const initialSettings = AppSettings(language: AppLanguage.chinese);
      when(() => mockService.getAppSettings())
          .thenAnswer((_) async => initialSettings);
      when(() => mockService.saveAppSettings(any())).thenAnswer((_) async {});

      final notifier = AppSettingsNotifier(mockService);
      await Future.delayed(Duration.zero);

      // Act
      await notifier.updateLanguage(AppLanguage.english);

      // Assert - state has new language
      expect(notifier.state.language, AppLanguage.english);
      // save was called
      verify(() => mockService.saveAppSettings(any())).called(1);
    });

    test('updateSettings preserves state when save fails', () async {
      // Arrange
      const initialSettings = AppSettings(
        darkMode: DarkMode.light,
        language: AppLanguage.chinese,
      );
      const newSettings = AppSettings(
        darkMode: DarkMode.dark,
        language: AppLanguage.english,
      );
      when(() => mockService.getAppSettings())
          .thenAnswer((_) async => initialSettings);
      when(() => mockService.saveAppSettings(any()))
          .thenThrow(Exception('Save failed'));

      final notifier = AppSettingsNotifier(mockService);
      await Future.delayed(Duration.zero);

      // Act - try to update, but save fails (exception is rethrown)
      expect(
        () => notifier.updateSettings(newSettings),
        throwsA(isA<Exception>()),
      );

      // Assert - state should remain unchanged because save failed
      expect(notifier.state.darkMode, DarkMode.light);
      expect(notifier.state.language, AppLanguage.chinese);
      verify(() => mockService.saveAppSettings(any())).called(1);
    });
  });
}
