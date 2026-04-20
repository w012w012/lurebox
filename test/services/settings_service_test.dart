import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/services/settings_service.dart';
import 'package:lurebox/core/services/secure_storage_service.dart';
import 'package:lurebox/core/models/watermark_settings.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import '../helpers/test_helpers.dart';

void main() {
  late MockSettingsRepository mockRepository;
  late SettingsService settingsService;
  late InMemoryApiKeyStorage mockSecureStorage;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockRepository = MockSettingsRepository();
    mockSecureStorage = InMemoryApiKeyStorage();
    settingsService = SettingsService(
      mockRepository,
      secureStorage: SecureStorageService(storage: mockSecureStorage),
    );
  });

  group('SettingsService', () {
    group('WatermarkSettings', () {
      test('saveWatermarkSettings calls repository.set with encoded JSON',
          () async {
        const settings = WatermarkSettings(
          enabled: true,
          style: WatermarkStyle.minimal,
          blurRadius: 15.0,
          backgroundOpacity: 0.7,
          backgroundColor: 0xFF111111,
          fontSize: 16.0,
          textColor: 0xFF222222,
          position: WatermarkPosition.topRight,
        );

        when(() => mockRepository.set(any(), any())).thenAnswer((_) async {});

        await settingsService.saveWatermarkSettings(settings);

        verify(() =>
                mockRepository.set('watermark_settings', settings.encode()))
            .called(1);
      });

      test('getWatermarkSettings decodes JSON from repository', () async {
        const settings = WatermarkSettings(
          enabled: false,
          style: WatermarkStyle.minimal,
          blurRadius: 20.0,
          backgroundOpacity: 0.8,
          backgroundColor: 0xFF333333,
          fontSize: 18.0,
          textColor: 0xFF444444,
          position: WatermarkPosition.center,
        );
        final encoded = settings.encode();

        when(() => mockRepository.get('watermark_settings'))
            .thenAnswer((_) async => encoded);

        final result = await settingsService.getWatermarkSettings();

        expect(result.enabled, equals(false));
        expect(result.blurRadius, equals(20.0));
        expect(result.backgroundOpacity, equals(0.8));
        expect(result.backgroundColor, equals(0xFF333333));
        expect(result.fontSize, equals(18.0));
        expect(result.textColor, equals(0xFF444444));
        expect(result.position, equals(WatermarkPosition.center));
      });

      test('getWatermarkSettings returns default when repository returns null',
          () async {
        when(() => mockRepository.get('watermark_settings'))
            .thenAnswer((_) async => null);

        final result = await settingsService.getWatermarkSettings();

        expect(result.enabled, equals(true)); // default
        expect(result.style, equals(WatermarkStyle.minimal)); // default
        expect(result.blurRadius, equals(10.0)); // default
        expect(result.backgroundOpacity, equals(0.5)); // default
      });

      test('getWatermarkSettings returns default when JSON parsing fails',
          () async {
        when(() => mockRepository.get('watermark_settings'))
            .thenAnswer((_) async => 'invalid json {');

        final result = await settingsService.getWatermarkSettings();

        expect(result.enabled, equals(true)); // default
        expect(result.blurRadius, equals(10.0)); // default
      });
    });

    group('AppSettings', () {
      test('saveAppSettings calls repository.set with encoded JSON', () async {
        const settings = AppSettings(
          units: UnitSettings(
            fishLengthUnit: 'inch',
            fishWeightUnit: 'lb',
          ),
          darkMode: DarkMode.dark,
          language: AppLanguage.english,
        );

        when(() => mockRepository.set(any(), any())).thenAnswer((_) async {});

        await settingsService.saveAppSettings(settings);

        verify(() => mockRepository.set('app_settings', settings.encode()))
            .called(1);
      });

      test('getAppSettings decodes JSON from repository', () async {
        const settings = AppSettings(
          units: UnitSettings(
            fishLengthUnit: 'm',
            fishWeightUnit: 'kg',
          ),
          darkMode: DarkMode.light,
          language: AppLanguage.chinese,
        );
        final encoded = settings.encode();

        when(() => mockRepository.get('app_settings'))
            .thenAnswer((_) async => encoded);

        final result = await settingsService.getAppSettings();

        expect(result.units.fishLengthUnit, equals('m'));
        expect(result.units.fishWeightUnit, equals('kg'));
        expect(result.darkMode, equals(DarkMode.light));
        expect(result.language, equals(AppLanguage.chinese));
      });

      test('getAppSettings returns default when repository returns null',
          () async {
        when(() => mockRepository.get('app_settings'))
            .thenAnswer((_) async => null);

        final result = await settingsService.getAppSettings();

        expect(result.units.fishLengthUnit, equals('cm')); // default
        expect(result.units.fishWeightUnit, equals('kg')); // default
        expect(result.darkMode, equals(DarkMode.system)); // default
        expect(result.language, equals(AppLanguage.chinese)); // default
      });

      test('getAppSettings returns default when JSON parsing fails', () async {
        when(() => mockRepository.get('app_settings'))
            .thenAnswer((_) async => 'not valid json');

        final result = await settingsService.getAppSettings();

        expect(result.units.fishLengthUnit, equals('cm')); // default
        expect(result.darkMode, equals(DarkMode.system)); // default
      });
    });

    group('AiRecognitionSettings', () {
      test('saveAiRecognitionSettings calls repository.set with encoded JSON',
          () async {
        const settings = AiRecognitionSettings(
          currentProvider: AiRecognitionProvider.openai,
          autoRecognize: false,
          timeout: Duration(seconds: 30),
        );

        when(() => mockRepository.set(any(), any())).thenAnswer((_) async {});
        when(() => mockRepository.get(any())).thenAnswer((_) async => null);

        await settingsService.saveAiRecognitionSettings(settings);

        verify(() => mockRepository.set(
            'ai_recognition_settings', any())).called(1);
      });

      test('getAiRecognitionSettings decodes JSON from repository', () async {
        const settings = AiRecognitionSettings(
          currentProvider: AiRecognitionProvider.minimax,
          autoRecognize: true,
          timeout: Duration(seconds: 15),
        );
        final encoded = settings.encode();

        when(() => mockRepository.get('ai_recognition_settings'))
            .thenAnswer((_) async => encoded);
        when(() => mockRepository.get('_ai_keys_migrated'))
            .thenAnswer((_) async => 'true');

        final result = await settingsService.getAiRecognitionSettings();

        expect(result.currentProvider, equals(AiRecognitionProvider.minimax));
        expect(result.autoRecognize, equals(true));
        expect(result.timeout, equals(const Duration(seconds: 15)));
      });

      test(
          'getAiRecognitionSettings returns default when repository returns null',
          () async {
        when(() => mockRepository.get('ai_recognition_settings'))
            .thenAnswer((_) async => null);

        final result = await settingsService.getAiRecognitionSettings();

        expect(result.currentProvider,
            equals(AiRecognitionProvider.gemini)); // default
        expect(result.autoRecognize, equals(true)); // default
        expect(result.timeout, equals(const Duration(seconds: 10))); // default
      });

      test('getAiRecognitionSettings returns default when JSON parsing fails',
          () async {
        when(() => mockRepository.get('ai_recognition_settings'))
            .thenAnswer((_) async => 'corrupted json }}');

        final result = await settingsService.getAiRecognitionSettings();

        expect(result.currentProvider,
            equals(AiRecognitionProvider.gemini)); // default
        expect(result.autoRecognize, equals(true)); // default
      });

      test('getAiRecognitionSettings migrates API keys from legacy JSON',
          () async {
        // Legacy JSON with API keys
        const legacyJson = '''
{
  "currentProvider": 0,
  "providerConfigs": {
    "0": {"provider": 0, "apiKey": "sk-test-gemini", "baseUrl": null, "modelName": null, "enabled": true},
    "1": {"provider": 1, "apiKey": "sk-test-openai", "baseUrl": null, "modelName": null, "enabled": true}
  },
  "autoRecognize": true,
  "timeout": 10
}
''';

        when(() => mockRepository.get('ai_recognition_settings'))
            .thenAnswer((_) async => legacyJson);
        when(() => mockRepository.get('_ai_keys_migrated'))
            .thenAnswer((_) async => null); // Not migrated yet

        final result = await settingsService.getAiRecognitionSettings();

        // Verify API keys were migrated to secure storage
        expect(
            await mockSecureStorage.get('0'), equals('sk-test-gemini'));
        expect(
            await mockSecureStorage.get('1'), equals('sk-test-openai'));

        // Verify settings were saved without API keys
        verify(() => mockRepository.set('ai_recognition_settings', any()))
            .called(greaterThan(0));
      });
    });
  });
}
