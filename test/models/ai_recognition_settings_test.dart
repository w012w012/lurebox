import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';

void main() {
  group('AiRecognitionProvider', () {
    group('fromValue', () {
      test('returns correct provider for each value', () {
        expect(
          AiRecognitionProvider.fromValue(0),
          AiRecognitionProvider.gemini,
        );
        expect(
          AiRecognitionProvider.fromValue(1),
          AiRecognitionProvider.openai,
        );
        expect(
          AiRecognitionProvider.fromValue(2),
          AiRecognitionProvider.claude,
        );
        expect(
          AiRecognitionProvider.fromValue(9),
          AiRecognitionProvider.zhipu,
        );
        expect(
          AiRecognitionProvider.fromValue(10),
          AiRecognitionProvider.custom,
        );
      });

      test('falls back to gemini for unknown value', () {
        expect(
          AiRecognitionProvider.fromValue(999),
          AiRecognitionProvider.gemini,
        );
        expect(
          AiRecognitionProvider.fromValue(-1),
          AiRecognitionProvider.gemini,
        );
      });
    });

    test('each provider has unique value', () {
      final values =
          AiRecognitionProvider.values.map((p) => p.value).toSet();
      expect(values.length, AiRecognitionProvider.values.length);
    });

    test('label and displayName are non-empty', () {
      for (final provider in AiRecognitionProvider.values) {
        expect(provider.label, isNotEmpty);
        expect(provider.displayName, isNotEmpty);
      }
    });
  });

  group('AiProviderConfig', () {
    group('constructor', () {
      test('creates with required fields', () {
        const config = AiProviderConfig(
          provider: AiRecognitionProvider.gemini,
          apiKey: 'test-key',
        );
        expect(config.provider, AiRecognitionProvider.gemini);
        expect(config.apiKey, 'test-key');
        expect(config.baseUrl, isNull);
        expect(config.modelName, isNull);
        expect(config.enabled, isTrue);
      });

      test('creates with optional fields', () {
        const config = AiProviderConfig(
          provider: AiRecognitionProvider.openai,
          apiKey: 'key',
          baseUrl: 'https://api.test.com',
          modelName: 'gpt-4',
          enabled: false,
        );
        expect(config.baseUrl, 'https://api.test.com');
        expect(config.modelName, 'gpt-4');
        expect(config.enabled, isFalse);
      });
    });

    group('copyWith', () {
      test('preserves unchanged fields', () {
        const original = AiProviderConfig(
          provider: AiRecognitionProvider.claude,
          apiKey: 'key-1',
          modelName: 'claude-3',
        );
        final copy = original.copyWith(apiKey: 'key-2');

        expect(copy.provider, AiRecognitionProvider.claude);
        expect(copy.apiKey, 'key-2');
        expect(copy.modelName, 'claude-3');
        expect(copy.enabled, isTrue);
      });

      test('updates multiple fields', () {
        const original = AiProviderConfig(
          provider: AiRecognitionProvider.gemini,
          apiKey: 'old-key',
        );
        final copy = original.copyWith(
          provider: AiRecognitionProvider.openai,
          apiKey: 'new-key',
          enabled: false,
        );

        expect(copy.provider, AiRecognitionProvider.openai);
        expect(copy.apiKey, 'new-key');
        expect(copy.enabled, isFalse);
      });
    });

    group('toJson / fromJson', () {
      test('round-trip preserves all fields', () {
        const config = AiProviderConfig(
          provider: AiRecognitionProvider.claude,
          apiKey: 'test-key',
          baseUrl: 'https://api.anthropic.com',
          modelName: 'claude-3-opus',
          enabled: false,
        );

        final json = config.toJson();
        final restored = AiProviderConfig.fromJson(json);

        expect(restored.provider, AiRecognitionProvider.claude);
        expect(restored.apiKey, 'test-key');
        expect(restored.baseUrl, 'https://api.anthropic.com');
        expect(restored.modelName, 'claude-3-opus');
        expect(restored.enabled, isFalse);
      });

      test('fromJson handles missing optional fields', () {
        final json = {
          'provider': 1,
          'apiKey': 'key',
        };
        final config = AiProviderConfig.fromJson(json);

        expect(config.provider, AiRecognitionProvider.openai);
        expect(config.baseUrl, isNull);
        expect(config.modelName, isNull);
        expect(config.enabled, isTrue);
      });

      test('fromJson defaults to gemini for unknown provider value', () {
        final json = {
          'provider': 999,
          'apiKey': 'key',
        };
        final config = AiProviderConfig.fromJson(json);
        expect(config.provider, AiRecognitionProvider.gemini);
      });

      test('fromJson defaults apiKey to empty string when null', () {
        final json = <String, dynamic>{};
        final config = AiProviderConfig.fromJson(json);
        expect(config.apiKey, '');
      });
    });
  });

  group('AiRecognitionSettings', () {
    group('defaults', () {
      test('creates with correct defaults', () {
        const settings = AiRecognitionSettings();
        expect(settings.currentProvider, AiRecognitionProvider.gemini);
        expect(settings.providerConfigs, isEmpty);
        expect(settings.autoRecognize, isTrue);
        expect(settings.timeout, const Duration(seconds: 10));
      });
    });

    group('copyWith', () {
      test('preserves unchanged fields', () {
        const original = AiRecognitionSettings(
          currentProvider: AiRecognitionProvider.claude,
          autoRecognize: false,
        );
        final copy = original.copyWith(timeout: const Duration(seconds: 30));

        expect(copy.currentProvider, AiRecognitionProvider.claude);
        expect(copy.autoRecognize, isFalse);
        expect(copy.timeout, const Duration(seconds: 30));
        expect(copy.providerConfigs, isEmpty);
      });
    });

    group('toJson / fromJson round-trip', () {
      test('serializes and deserializes correctly', () {
        const settings = AiRecognitionSettings(
          currentProvider: AiRecognitionProvider.openai,
          providerConfigs: {
            AiRecognitionProvider.openai: AiProviderConfig(
              provider: AiRecognitionProvider.openai,
              apiKey: 'sk-test',
              modelName: 'gpt-4',
            ),
            AiRecognitionProvider.claude: AiProviderConfig(
              provider: AiRecognitionProvider.claude,
              apiKey: 'sk-ant-test',
              baseUrl: 'https://api.anthropic.com',
            ),
          },
          autoRecognize: false,
          timeout: Duration(seconds: 30),
        );

        final json = settings.toJson();
        final restored = AiRecognitionSettings.fromJson(json);

        expect(restored.currentProvider, AiRecognitionProvider.openai);
        expect(restored.autoRecognize, isFalse);
        expect(restored.timeout, const Duration(seconds: 30));
        expect(restored.providerConfigs.length, 2);

        final openaiConfig =
            restored.providerConfigs[AiRecognitionProvider.openai]!;
        expect(openaiConfig.apiKey, 'sk-test');
        expect(openaiConfig.modelName, 'gpt-4');

        final claudeConfig =
            restored.providerConfigs[AiRecognitionProvider.claude]!;
        expect(claudeConfig.apiKey, 'sk-ant-test');
        expect(claudeConfig.baseUrl, 'https://api.anthropic.com');
      });

      test('fromJson handles empty providerConfigs', () {
        final json = {
          'currentProvider': 0,
          'providerConfigs': <String, dynamic>{},
          'autoRecognize': true,
          'timeout': 10,
        };
        final settings = AiRecognitionSettings.fromJson(json);
        expect(settings.providerConfigs, isEmpty);
      });

      test('fromJson handles missing fields with defaults', () {
        final json = <String, dynamic>{};
        final settings = AiRecognitionSettings.fromJson(json);

        expect(settings.currentProvider, AiRecognitionProvider.gemini);
        expect(settings.providerConfigs, isEmpty);
        expect(settings.autoRecognize, isTrue);
        expect(settings.timeout, const Duration(seconds: 10));
      });
    });

    group('encode / decode', () {
      test('encode produces valid JSON string', () {
        const settings = AiRecognitionSettings(
          currentProvider: AiRecognitionProvider.claude,
          autoRecognize: false,
        );

        final encoded = settings.encode();
        expect(encoded, isNotEmpty);
        // Should not throw when decoded
        final restored = AiRecognitionSettings.decode(encoded);
        expect(restored.currentProvider, AiRecognitionProvider.claude);
        expect(restored.autoRecognize, isFalse);
      });

      test('full encode/decode round-trip with configs', () {
        const settings = AiRecognitionSettings(
          currentProvider: AiRecognitionProvider.zhipu,
          providerConfigs: {
            AiRecognitionProvider.zhipu: AiProviderConfig(
              provider: AiRecognitionProvider.zhipu,
              apiKey: 'zhipu-key',
              modelName: 'glm-4v-plus',
            ),
          },
          timeout: Duration(seconds: 15),
        );

        final restored = AiRecognitionSettings.decode(settings.encode());

        expect(restored.currentProvider, AiRecognitionProvider.zhipu);
        expect(restored.timeout, const Duration(seconds: 15));

        final zhipuConfig =
            restored.providerConfigs[AiRecognitionProvider.zhipu]!;
        expect(zhipuConfig.apiKey, 'zhipu-key');
        expect(zhipuConfig.modelName, 'glm-4v-plus');
      });
    });
  });
}
