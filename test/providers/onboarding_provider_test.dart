import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/providers/onboarding_provider.dart';
import 'package:lurebox/core/services/settings_service.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsService extends Mock implements SettingsService {}

class FakeAppSettings extends Fake implements AppSettings {}

/// Fake notifier that bypasses async _loadSettings() by setting state directly
/// after the parent constructor runs — no Future timing required.
class _FakeAppSettingsNotifier extends AppSettingsNotifier {
  _FakeAppSettingsNotifier(AppSettings initialSettings, SettingsService service)
      : super(service) {
    state = initialSettings;
  }
}

void main() {
  late MockSettingsService mockService;

  setUpAll(() {
    registerFallbackValue(FakeAppSettings());
  });

  setUp(() {
    mockService = MockSettingsService();
    when(() => mockService.getAppSettings())
        .thenAnswer((_) async => const AppSettings());
    when(() => mockService.saveAppSettings(any())).thenAnswer((_) async {});
  });

  /// Creates a container with a fake notifier pre-initialized to
  /// [initialSettings]. Captures saved settings via mock service spy.
  ({ProviderContainer container, List<AppSettings> savedSettings})
      makeContainer({required bool hasCompletedOnboarding}) {
    final saved = <AppSettings>[];
    final initialSettings =
        AppSettings(hasCompletedOnboarding: hasCompletedOnboarding);

    when(() => mockService.saveAppSettings(any())).thenAnswer((inv) async {
      saved.add(inv.positionalArguments.first as AppSettings);
    });

    final container = ProviderContainer(
      overrides: [
        appSettingsProvider.overrideWith(
          (_) => _FakeAppSettingsNotifier(initialSettings, mockService),
        ),
      ],
    );
    return (container: container, savedSettings: saved);
  }

  group('onboardingNotifierProvider', () {
    test('initial state is false when hasCompletedOnboarding is false',
        () async {
      final result = makeContainer(hasCompletedOnboarding: false);
      addTearDown(result.container.dispose);

      expect(result.container.read(onboardingNotifierProvider), false);
    });

    test('initial state is true when hasCompletedOnboarding is true',
        () async {
      final result = makeContainer(hasCompletedOnboarding: true);
      addTearDown(result.container.dispose);

      expect(result.container.read(onboardingNotifierProvider), true);
    });

    test('completeOnboarding sets state to true and saves settings',
        () async {
      final result = makeContainer(hasCompletedOnboarding: false);
      addTearDown(result.container.dispose);

      final notifier =
          result.container.read(onboardingNotifierProvider.notifier);
      await notifier.completeOnboarding();

      expect(result.container.read(onboardingNotifierProvider), true);
      expect(result.savedSettings.single.hasCompletedOnboarding, true);
    });

    test('resetOnboarding sets state to false and saves settings',
        () async {
      final result = makeContainer(hasCompletedOnboarding: true);
      addTearDown(result.container.dispose);

      final notifier =
          result.container.read(onboardingNotifierProvider.notifier);
      await notifier.resetOnboarding();

      expect(result.container.read(onboardingNotifierProvider), false);
      expect(result.savedSettings.single.hasCompletedOnboarding, false);
    });
  });

  group('onboardingCompletedProvider', () {
    test('returns false when onboarding not completed', () async {
      final result = makeContainer(hasCompletedOnboarding: false);
      addTearDown(result.container.dispose);

      expect(result.container.read(onboardingCompletedProvider), false);
    });

    test('returns true when onboarding completed', () async {
      final result = makeContainer(hasCompletedOnboarding: true);
      addTearDown(result.container.dispose);

      expect(result.container.read(onboardingCompletedProvider), true);
    });
  });
}
