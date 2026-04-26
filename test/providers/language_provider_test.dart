import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/constants/strings/app_strings.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/services/settings_service.dart';

class MockSettingsService extends Mock implements SettingsService {}

void main() {
  late MockSettingsService mockService;

  setUpAll(() {
    registerFallbackValue(const AppSettings());
  });

  setUp(() {
    mockService = MockSettingsService();
    when(() => mockService.getAppSettings())
        .thenAnswer((_) async => const AppSettings());
    when(() => mockService.saveAppSettings(any()))
        .thenAnswer((_) async {});
  });

  group('appLanguageProvider', () {
    test('returns chinese when appSettings has chinese language', () {
      // Arrange — chinese is the default language, no need to pass it
      final container = ProviderContainer(
        overrides: [
          appSettingsProvider.overrideWith(
            (ref) => _FakeAppSettingsNotifier(
              const AppSettings(),
              mockService,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Assert
      expect(container.read(appLanguageProvider), AppLanguage.chinese);
    });

    test('returns english when appSettings has english language', () {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          appSettingsProvider.overrideWith(
            (ref) => _FakeAppSettingsNotifier(
              const AppSettings(language: AppLanguage.english),
              mockService,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Assert
      expect(container.read(appLanguageProvider), AppLanguage.english);
    });

    test('language changes when notifier updates language', () async {
      // Arrange — chinese is the default
      final notifier = _FakeAppSettingsNotifier(
        const AppSettings(),
        mockService,
      );
      final container = ProviderContainer(
        overrides: [
          appSettingsProvider.overrideWith((ref) => notifier),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(appLanguageProvider), AppLanguage.chinese);

      // Act
      await notifier.updateLanguage(AppLanguage.english);

      // Assert
      expect(container.read(appLanguageProvider), AppLanguage.english);
    });
  });

  group('currentStringsProvider', () {
    test('returns chinese AppStrings when language is chinese', () {
      // Arrange — chinese is the default language
      final container = ProviderContainer(
        overrides: [
          appSettingsProvider.overrideWith(
            (ref) => _FakeAppSettingsNotifier(
              const AppSettings(),
              mockService,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Assert
      final strings = container.read(currentStringsProvider);
      expect(strings, AppStrings.chinese);
      expect(strings.appName, '路亚鱼护');
    });

    test('returns english AppStrings when language is english', () {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          appSettingsProvider.overrideWith(
            (ref) => _FakeAppSettingsNotifier(
              const AppSettings(language: AppLanguage.english),
              mockService,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Assert
      final strings = container.read(currentStringsProvider);
      expect(strings, AppStrings.english);
      expect(strings.appName, 'LureBox');
    });

    test('currentStringsProvider updates when language changes', () async {
      // Arrange — chinese is the default
      final notifier = _FakeAppSettingsNotifier(
        const AppSettings(),
        mockService,
      );
      final container = ProviderContainer(
        overrides: [
          appSettingsProvider.overrideWith((ref) => notifier),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(currentStringsProvider), AppStrings.chinese);

      // Act
      await notifier.updateLanguage(AppLanguage.english);

      // Assert
      expect(container.read(currentStringsProvider), AppStrings.english);
    });
  });

  group('language persistence', () {
    test('updateLanguage calls saveAppSettings', () async {
      // Arrange — chinese is the default
      final notifier = _FakeAppSettingsNotifier(
        const AppSettings(),
        mockService,
      );
      // Act
      await notifier.updateLanguage(AppLanguage.english);
      // Assert
      verify(() => mockService.saveAppSettings(any())).called(1);
    });

    test('updateLanguage updates internal state', () async {
      // Arrange — chinese is the default
      final notifier = _FakeAppSettingsNotifier(
        const AppSettings(),
        mockService,
      );
      // Act
      await notifier.updateLanguage(AppLanguage.english);
      // Assert
      expect(notifier.state.language, AppLanguage.english);
    });
  });
}

/// A fake notifier for language testing that extends AppSettingsNotifier
/// and bypasses the async _loadSettings().
///
/// Note: _loadSettings is private to AppSettingsNotifier's library, so we
/// cannot truly override it. The parent's _loadSettings() runs during
/// super() but has no effect because getAppSettings returns defaults and
/// the state is overwritten immediately after by the constructor body.
class _FakeAppSettingsNotifier extends AppSettingsNotifier {
  _FakeAppSettingsNotifier(AppSettings initialSettings, SettingsService service)
      : super(service) {
    state = initialSettings;
  }
}
