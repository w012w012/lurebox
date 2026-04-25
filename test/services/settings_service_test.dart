import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/models/watermark_settings.dart';
import 'package:lurebox/core/services/error_service.dart';
import 'package:lurebox/core/services/secure_storage_service.dart';
import 'package:lurebox/core/services/settings_service.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_helpers.dart';

void main() {
  late MockSettingsRepository mockRepository;
  late SettingsService settingsService;
  late InMemoryApiKeyStorage mockSecureStorage;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockRepository = MockSettingsRepository();
    mockSecureStorage = InMemoryApiKeyStorage();
    settingsService = SettingsService(
      mockRepository,
      secureStorage: SecureStorageService(storage: mockSecureStorage),
    );
  });

  tearDown(() {
    // No resources to clean up - mocks are garbage collected
  });

  group('SettingsService', () {
    group('WatermarkSettings', () {
      test('saveWatermarkSettings calls repository.set with encoded JSON',
          () async {
        const settings = WatermarkSettings(
          blurRadius: 15,
          backgroundOpacity: 0.7,
          backgroundColor: 0xFF111111,
          fontSize: 16,
          textColor: 0xFF222222,
          position: WatermarkPosition.topRight,
        );

        when(() => mockRepository.set(any(), any())).thenAnswer((_) async {});

        await settingsService.saveWatermarkSettings(settings);

        verify(() =>
                mockRepository.set('watermark_settings', settings.encode()),)
            .called(1);
      });

      test('getWatermarkSettings decodes JSON from repository', () async {
        const settings = WatermarkSettings(
          enabled: false,
          blurRadius: 20,
          backgroundOpacity: 0.8,
          backgroundColor: 0xFF333333,
          fontSize: 18,
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

        // Now throws SettingsCorruptedException instead of silently returning defaults
        expect(
          () => settingsService.getWatermarkSettings(),
          throwsA(isA<SettingsCorruptedException>()),
        );
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
          ),
          darkMode: DarkMode.light,
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

        // Now throws SettingsCorruptedException instead of silently returning defaults
        expect(
          () => settingsService.getAppSettings(),
          throwsA(isA<SettingsCorruptedException>()),
        );
      });
    });

    group('AiRecognitionSettings', () {
      test('saveAiRecognitionSettings writes API keys to secure storage and cleaned JSON to repository',
          () async {
        final apiKeyStorage = InMemoryApiKeyStorage();
        final service =
            SettingsService(mockRepository, secureStorage: SecureStorageService(storage: apiKeyStorage));

        const settings = AiRecognitionSettings(
          currentProvider: AiRecognitionProvider.openai,
          autoRecognize: false,
          timeout: Duration(seconds: 30),
        );

        when(() => mockRepository.set(any(), any())).thenAnswer((_) async {});

        await service.saveAiRecognitionSettings(settings);

        // Verify repository.set was called for cleaned JSON (no API keys)
        verify(() => mockRepository.set('ai_recognition_settings', any()))
            .called(1);
        // Verify migration marker was set
        verify(() => mockRepository.set('_ai_keys_migrated', 'true')).called(1);
      });

      test('saveAiRecognitionSettings with provider config writes API key to secure storage',
          () async {
        final apiKeyStorage = InMemoryApiKeyStorage();
        final service =
            SettingsService(mockRepository, secureStorage: SecureStorageService(storage: apiKeyStorage));

        final settings = AiRecognitionSettings(
          currentProvider: AiRecognitionProvider.openai,
          autoRecognize: false,
          timeout: const Duration(seconds: 30),
          providerConfigs: {
            AiRecognitionProvider.openai: AiProviderConfig(
              provider: AiRecognitionProvider.openai,
              apiKey: 'sk-from-settings',
            ),
          },
        );

        when(() => mockRepository.set(any(), any())).thenAnswer((_) async {});

        await service.saveAiRecognitionSettings(settings);

        // API key should be saved to secure storage
        expect(await apiKeyStorage.get('1'), equals('sk-from-settings'));
      });

      test('getAiRecognitionSettings decodes JSON from repository', () async {
        const settings = AiRecognitionSettings(
          currentProvider: AiRecognitionProvider.minimax,
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
            equals(AiRecognitionProvider.gemini),); // default
        expect(result.autoRecognize, equals(true)); // default
        expect(result.timeout, equals(const Duration(seconds: 10))); // default
      });

      test('getAiRecognitionSettings returns default when JSON parsing fails',
          () async {
        when(() => mockRepository.get('ai_recognition_settings'))
            .thenAnswer((_) async => 'corrupted json }}');

        // Now throws SettingsCorruptedException instead of silently returning defaults
        expect(
          () => settingsService.getAiRecognitionSettings(),
          throwsA(isA<SettingsCorruptedException>()),
        );
      });

      test('getAiRecognitionSettings migrates API keys from legacy JSON',
          () async {
        // Legacy JSON with API keys
        // NOTE: timeout must be valid ISO8601 duration string (not int)
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

        String? savedJson;
        when(() => mockRepository.set('ai_recognition_settings', any()))
            .thenAnswer((invocation) async {
          savedJson = invocation.positionalArguments[1] as String;
        });
        when(() => mockRepository.set('_ai_keys_migrated', any()))
            .thenAnswer((_) async {});

        await settingsService.getAiRecognitionSettings();

        // Verify API keys were migrated to secure storage
        expect(
            await mockSecureStorage.get('0'), equals('sk-test-gemini'),);
        expect(
            await mockSecureStorage.get('1'), equals('sk-test-openai'),);

        // Verify saved JSON has API keys removed
        expect(savedJson, isNotNull);
        expect(savedJson!.contains('sk-test-gemini'), isFalse);
        expect(savedJson!.contains('sk-test-openai'), isFalse);
        expect(savedJson!.contains('"apiKey"'), isFalse);
        expect(savedJson!.contains('"currentProvider"'), isTrue); // other fields preserved
      });

      test('getAiRecognitionSettings re-runs migration on next call if cleaned JSON write fails',
          () async {
        const legacyJson = '''
{
  "currentProvider": 0,
  "providerConfigs": {
    "0": {"provider": 0, "apiKey": "sk-test-gemini", "baseUrl": null, "modelName": null, "enabled": true}
  },
  "autoRecognize": true,
  "timeout": 10
}
''';

        // First call: cleaned JSON write fails after keys are saved to secure storage
        when(() => mockRepository.get('ai_recognition_settings'))
            .thenAnswer((_) async => legacyJson);
        when(() => mockRepository.get('_ai_keys_migrated'))
            .thenAnswer((_) async => null);

        // Simulate cleaned JSON write failure (but keys already saved to secure storage)
        var callCount = 0;
        when(() => mockRepository.set('ai_recognition_settings', any()))
            .thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw Exception('DB write failed');
          }
        });
        when(() => mockRepository.set('_ai_keys_migrated', any()))
            .thenAnswer((_) async {});

        // First call throws (settings corruption), but API keys should be in secure storage
        try {
          await settingsService.getAiRecognitionSettings();
        } on SettingsCorruptedException catch (_) {}

        // Keys should be migrated even though the save failed
        expect(await mockSecureStorage.get('0'), equals('sk-test-gemini'));

        // Second call: migration runs again (same legacy JSON since write failed)
        // this time cleaned JSON write succeeds
        var secondCallCount = 0;
        when(() => mockRepository.set('ai_recognition_settings', any()))
            .thenAnswer((_) async {
          secondCallCount++;
          if (secondCallCount == 1) {
            throw Exception('DB write failed');
          }
        });

        try {
          await settingsService.getAiRecognitionSettings();
        } on SettingsCorruptedException catch (_) {}

        // Third call: migration completed, keys should be readable
        when(() => mockRepository.set('ai_recognition_settings', any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.get('_ai_keys_migrated'))
            .thenAnswer((_) async => null); // reset for fresh test

        final result = await settingsService.getAiRecognitionSettings();

        // API keys should be readable from secure storage
        expect(result.providerConfigs[AiRecognitionProvider.gemini]?.apiKey,
            equals('sk-test-gemini'),);
      });

      test('deleteAiRecognitionSettings clears all storage', () async {
        // Pre-populate secure storage with API keys
        await mockSecureStorage.save('0', 'sk-test-gemini');
        await mockSecureStorage.save('1', 'sk-test-openai');

        when(() => mockRepository.delete(any())).thenAnswer((_) async {});

        await settingsService.deleteAiRecognitionSettings();

        verify(() => mockRepository.delete('ai_recognition_settings')).called(1);
        verify(() => mockRepository.delete('_ai_keys_migrated')).called(1);

        // Secure storage should be cleared
        expect(await mockSecureStorage.get('0'), isNull);
        expect(await mockSecureStorage.get('1'), isNull);
      });
    });
  });
}
