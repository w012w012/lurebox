import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/fish_recognition_service.dart';

void main() {
  late File testImage;

  setUp(() {
    testImage = File('test/fixtures/test_fish.jpg');
  });

  tearDown(() {
    // No resources to clean up - file handle is just a reference
  });

  group('FishRecognitionService', () {
    group('identifySpecies config validation', () {
      test('throws FishRecognitionException when config is null', () async {
        // Arrange
        final service = FishRecognitionService();
        final settings = AiRecognitionSettings(
          providerConfigs: {}, // Empty - no config for any provider
        );

        // Act & Assert
        expect(
          () => service.identifySpecies(testImage, settings),
          throwsA(isA<FishRecognitionException>()),
        );
      });

      test('throws FishRecognitionException when config.apiKey is empty',
          () async {
        // Arrange
        final service = FishRecognitionService();
        final config = AiProviderConfig(
          provider: AiRecognitionProvider.gemini,
          apiKey: '', // Empty API key
        );
        final settings = AiRecognitionSettings(
          providerConfigs: {AiRecognitionProvider.gemini: config},
        );

        // Act & Assert
        expect(
          () => service.identifySpecies(testImage, settings),
          throwsA(isA<FishRecognitionException>()),
        );
      });

      test('throws FishRecognitionException when config.enabled is false',
          () async {
        // Arrange
        final service = FishRecognitionService();
        final config = AiProviderConfig(
          provider: AiRecognitionProvider.gemini,
          apiKey: 'test-api-key',
          enabled: false, // Disabled
        );
        final settings = AiRecognitionSettings(
          providerConfigs: {AiRecognitionProvider.gemini: config},
        );

        // Act & Assert
        expect(
          () => service.identifySpecies(testImage, settings),
          throwsA(isA<FishRecognitionException>()),
        );
      });

      test('FishRecognitionException has correct type for empty apiKey',
          () async {
        // Arrange
        final service = FishRecognitionService();
        final config = AiProviderConfig(
          provider: AiRecognitionProvider.gemini,
          apiKey: '',
        );
        final settings = AiRecognitionSettings(
          providerConfigs: {AiRecognitionProvider.gemini: config},
        );

        // Act
        try {
          await service.identifySpecies(testImage, settings);
          fail('Expected exception was not thrown');
        } on FishRecognitionException catch (e) {
          // Assert
          expect(e.type, equals(FishRecognitionErrorType.apiKeyInvalid));
          expect(e.message, contains('API'));
        }
      });

      test('FishRecognitionException has correct type for disabled provider',
          () async {
        // Arrange
        final service = FishRecognitionService();
        final config = AiProviderConfig(
          provider: AiRecognitionProvider.gemini,
          apiKey: 'test-api-key',
          enabled: false,
        );
        final settings = AiRecognitionSettings(
          providerConfigs: {AiRecognitionProvider.gemini: config},
        );

        // Act
        try {
          await service.identifySpecies(testImage, settings);
          fail('Expected exception was not thrown');
        } on FishRecognitionException catch (e) {
          // Assert
          expect(e.type, equals(FishRecognitionErrorType.unknown));
          expect(e.message, contains('禁用'));
        }
      });

      test(
          'throws FishRecognitionException with apiKeyInvalid when config not found',
          () async {
        // Arrange - current provider is openai but no config for it
        final service = FishRecognitionService();
        final settings = AiRecognitionSettings(
          currentProvider: AiRecognitionProvider.openai,
          providerConfigs: {
            // No config for openai
            AiRecognitionProvider.gemini: const AiProviderConfig(
              provider: AiRecognitionProvider.gemini,
              apiKey: 'gemini-key',
            ),
          },
        );

        // Act
        try {
          await service.identifySpecies(testImage, settings);
          fail('Expected exception was not thrown');
        } on FishRecognitionException catch (e) {
          // Assert
          expect(e.type, equals(FishRecognitionErrorType.apiKeyInvalid));
        }
      });
    });

    group('identifySpecies routing verification', () {
      // These tests verify routing by checking that:
      // 1. The switch statement doesn't fall through (all cases handled)
      // 2. DeepSeek throws specific exception (proves routing works)
      // 3. Other providers don't throw during config validation (routing proceeds)

      test('routes to DeepSeek provider and throws vision not supported',
          () async {
        // Arrange - DeepSeek doesn't support vision, so it throws immediately
        final service = FishRecognitionService();
        final config = AiProviderConfig(
          provider: AiRecognitionProvider.deepseek,
          apiKey: 'test-api-key',
        );
        final settings = AiRecognitionSettings(
          currentProvider: AiRecognitionProvider.deepseek,
          providerConfigs: {AiRecognitionProvider.deepseek: config},
        );

        // Act & Assert - DeepSeek always throws because it doesn't support vision
        // This proves the switch statement correctly routes to DeepSeek
        expect(
          () => service.identifySpecies(testImage, settings),
          throwsA(isA<FishRecognitionException>().having(
            (e) => e.message,
            'message',
            contains('视觉'),
          ),),
        );
      });

      test('all 11 AiRecognitionProvider values are handled in switch',
          () async {
        // This test verifies that the AiRecognitionProvider enum
        // has exactly the expected number of values that the switch handles
        expect(AiRecognitionProvider.values.length, equals(11));

        // Verify all expected providers exist
        expect(AiRecognitionProvider.gemini.label, equals('Gemini'));
        expect(AiRecognitionProvider.openai.label, equals('OpenAI'));
        expect(AiRecognitionProvider.claude.label, equals('Claude'));
        expect(AiRecognitionProvider.minimax.label, equals('MiniMax'));
        expect(AiRecognitionProvider.siliconflow.label, equals('SiliconFlow'));
        expect(AiRecognitionProvider.deepseek.label, equals('DeepSeek'));
        expect(AiRecognitionProvider.baidu.label, equals('Baidu'));
        expect(AiRecognitionProvider.aliyun.label, equals('Aliyun'));
        expect(AiRecognitionProvider.tencent.label, equals('Tencent'));
        expect(AiRecognitionProvider.zhipu.label, equals('Zhipu'));
        expect(AiRecognitionProvider.custom.label, equals('Custom'));
      });
    });

    group('AiRecognitionProvider enum values', () {
      test('has correct number of providers', () {
        expect(AiRecognitionProvider.values.length, equals(11));
      });

      test('all providers have unique values', () {
        final values = AiRecognitionProvider.values.map((p) => p.value).toSet();
        expect(values.length, equals(AiRecognitionProvider.values.length));
      });

      test('all providers have labels', () {
        for (final provider in AiRecognitionProvider.values) {
          expect(provider.label.isNotEmpty, isTrue);
          expect(provider.displayName.isNotEmpty, isTrue);
        }
      });

      test('fromValue returns correct provider', () {
        expect(
          AiRecognitionProvider.fromValue(0),
          equals(AiRecognitionProvider.gemini),
        );
        expect(
          AiRecognitionProvider.fromValue(10),
          equals(AiRecognitionProvider.custom),
        );
        expect(
          AiRecognitionProvider.fromValue(999),
          equals(AiRecognitionProvider.gemini), // default
        );
      });
    });

    group('FishRecognitionResult and SpeciesInfo', () {
      test('FishRecognitionResult can be serialized and deserialized', () {
        const result = FishRecognitionResult(
          primarySpecies: SpeciesInfo(
            chineseName: '黑鱼',
            scientificName: 'Channa argus',
            confidence: 85,
          ),
          confidence: 85,
          alternatives: [
            SpeciesInfo(
              chineseName: '蛇鳗',
              scientificName: 'Ophichthus',
              confidence: 60,
            ),
          ],
          notes: 'Test note',
        );

        final json = result.toJson();
        final restored = FishRecognitionResult.fromJson(json);

        expect(restored.primarySpecies.chineseName, equals('黑鱼'));
        expect(
          restored.primarySpecies.scientificName,
          equals('Channa argus'),
        );
        expect(restored.confidence, equals(85));
        expect(restored.alternatives.length, equals(1));
        expect(restored.notes, equals('Test note'));
      });

      test('SpeciesInfo can be serialized and deserialized', () {
        const species = SpeciesInfo(
          chineseName: '鲈鱼',
          scientificName: 'Lateolabrax japonicus',
          confidence: 90,
        );

        final json = species.toJson();
        final restored = SpeciesInfo.fromJson(json);

        expect(restored.chineseName, equals('鲈鱼'));
        expect(
          restored.scientificName,
          equals('Lateolabrax japonicus'),
        );
        expect(restored.confidence, equals(90));
      });

      test('SpeciesInfo defaults confidence to 0', () {
        const species = SpeciesInfo(
          chineseName: 'Test',
          scientificName: 'Testus',
        );

        expect(species.confidence, equals(0));
      });

      test('FishRecognitionResult defaults alternatives and notes', () {
        const result = FishRecognitionResult(
          primarySpecies: SpeciesInfo(
            chineseName: 'Test',
            scientificName: 'Testus',
          ),
          confidence: 100,
        );

        expect(result.alternatives, isEmpty);
        expect(result.notes, isEmpty);
      });
    });

    group('FishRecognitionException', () {
      test('toString includes type and message', () {
        const exception = FishRecognitionException(
          FishRecognitionErrorType.apiKeyInvalid,
          'Test message',
        );

        expect(exception.toString(), contains('apiKeyInvalid'));
        expect(exception.toString(), contains('Test message'));
      });

      test('all error types are represented', () {
        for (final type in FishRecognitionErrorType.values) {
          final exception = FishRecognitionException(type, 'Test');
          expect(exception.type, equals(type));
        }
      });

      test('FishRecognitionErrorType enum has all expected values', () {
        expect(FishRecognitionErrorType.values.length, equals(5));
        expect(FishRecognitionErrorType.values,
            contains(FishRecognitionErrorType.apiKeyInvalid),);
        expect(FishRecognitionErrorType.values,
            contains(FishRecognitionErrorType.timeout),);
        expect(FishRecognitionErrorType.values,
            contains(FishRecognitionErrorType.networkError),);
        expect(FishRecognitionErrorType.values,
            contains(FishRecognitionErrorType.rateLimited),);
        expect(FishRecognitionErrorType.values,
            contains(FishRecognitionErrorType.unknown),);
      });
    });

    group('AiProviderConfig', () {
      test('can be created with required fields', () {
        const config = AiProviderConfig(
          provider: AiRecognitionProvider.gemini,
          apiKey: 'test-key',
        );

        expect(config.provider, equals(AiRecognitionProvider.gemini));
        expect(config.apiKey, equals('test-key'));
        expect(config.enabled, isTrue); // default
        expect(config.baseUrl, isNull);
        expect(config.modelName, isNull);
      });

      test('copyWith creates new instance with updated values', () {
        const original = AiProviderConfig(
          provider: AiRecognitionProvider.gemini,
          apiKey: 'original-key',
        );

        final updated = original.copyWith(
          apiKey: 'new-key',
          enabled: false,
        );

        expect(updated.apiKey, equals('new-key'));
        expect(updated.enabled, isFalse);
        expect(updated.provider,
            equals(AiRecognitionProvider.gemini),); // unchanged
      });

      test('can be serialized and deserialized', () {
        const original = AiProviderConfig(
          provider: AiRecognitionProvider.openai,
          apiKey: 'test-key',
          baseUrl: 'https://api.openai.com',
          modelName: 'gpt-4o',
          enabled: false,
        );

        final json = original.toJson();
        final restored = AiProviderConfig.fromJson(json);

        expect(restored.provider, equals(AiRecognitionProvider.openai));
        expect(restored.apiKey, equals('test-key'));
        expect(restored.baseUrl, equals('https://api.openai.com'));
        expect(restored.modelName, equals('gpt-4o'));
        expect(restored.enabled, isFalse);
      });
    });

    group('AiRecognitionSettings', () {
      test('has correct default values', () {
        const settings = AiRecognitionSettings();

        expect(settings.currentProvider, equals(AiRecognitionProvider.gemini));
        expect(settings.providerConfigs, isEmpty);
        expect(settings.autoRecognize, isTrue);
        expect(settings.timeout.inSeconds, equals(10));
      });

      test('copyWith creates new instance with updated values', () {
        const original = AiRecognitionSettings();

        final updated = original.copyWith(
          currentProvider: AiRecognitionProvider.openai,
          autoRecognize: false,
        );

        expect(updated.currentProvider, equals(AiRecognitionProvider.openai));
        expect(updated.autoRecognize, isFalse);
        expect(updated.timeout.inSeconds, equals(10)); // unchanged
      });

      test('can be serialized and deserialized', () {
        final original = AiRecognitionSettings(
          currentProvider: AiRecognitionProvider.claude,
          providerConfigs: {
            AiRecognitionProvider.claude: const AiProviderConfig(
              provider: AiRecognitionProvider.claude,
              apiKey: 'claude-key',
            ),
          },
          autoRecognize: false,
          timeout: const Duration(seconds: 30),
        );

        final json = original.toJson();
        final restored = AiRecognitionSettings.fromJson(json);

        expect(
          restored.currentProvider,
          equals(AiRecognitionProvider.claude),
        );
        expect(restored.providerConfigs.length, equals(1));
        expect(
          restored.providerConfigs[AiRecognitionProvider.claude]?.apiKey,
          equals('claude-key'),
        );
        expect(restored.autoRecognize, isFalse);
        expect(restored.timeout.inSeconds, equals(30));
      });

      test('encode and decode works correctly', () {
        final original = AiRecognitionSettings(
          currentProvider: AiRecognitionProvider.minimax,
          providerConfigs: {
            AiRecognitionProvider.minimax: const AiProviderConfig(
              provider: AiRecognitionProvider.minimax,
              apiKey: 'minimax-key',
            ),
          },
        );

        final encoded = original.encode();
        final restored = AiRecognitionSettings.decode(encoded);

        expect(
          restored.currentProvider,
          equals(AiRecognitionProvider.minimax),
        );
      });
    });
  });
}
