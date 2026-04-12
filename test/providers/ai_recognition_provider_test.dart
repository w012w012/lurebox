import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/fish_recognition_service.dart';
import 'package:lurebox/core/services/adapters/openai_provider.dart';
import 'package:lurebox/core/services/adapters/openai_compatible_provider.dart';
import 'package:lurebox/core/services/adapters/gemini_provider.dart';
import 'package:lurebox/core/services/adapters/claude_provider.dart';
import 'package:lurebox/core/services/adapters/minimax_provider.dart';
import 'package:lurebox/core/services/adapters/siliconflow_provider.dart';
import 'package:lurebox/core/services/adapters/deepseek_provider.dart';
import 'package:lurebox/core/services/adapters/baidu_provider.dart';
import 'package:lurebox/core/services/adapters/aliyun_provider.dart';
import 'package:lurebox/core/services/adapters/tencent_provider.dart';
import 'package:lurebox/core/services/adapters/zhipu_provider.dart';
import 'package:lurebox/core/services/adapters/custom_provider.dart';

void main() {
  group('AiRecognitionProvider.fromConfig', () {
    test('returns OpenAIFishRecognitionProvider for type "openai"', () {
      final provider = AiRecognitionProvider.fromConfig('openai');
      expect(provider, isA<OpenAIFishRecognitionProvider>());
      expect(provider, isA<OpenAICompatibleProvider>());
    });

    test('returns GeminiFishRecognitionProvider for type "gemini"', () {
      final provider = AiRecognitionProvider.fromConfig('gemini');
      expect(provider, isA<GeminiFishRecognitionProvider>());
    });

    test('returns ClaudeFishRecognitionProvider for type "claude"', () {
      final provider = AiRecognitionProvider.fromConfig('claude');
      expect(provider, isA<ClaudeFishRecognitionProvider>());
    });

    test('returns MiniMaxFishRecognitionProvider for type "minimax"', () {
      final provider = AiRecognitionProvider.fromConfig('minimax');
      expect(provider, isA<MiniMaxFishRecognitionProvider>());
    });

    test('returns SiliconFlowFishRecognitionProvider for type "siliconflow"',
        () {
      final provider = AiRecognitionProvider.fromConfig('siliconflow');
      expect(provider, isA<SiliconFlowFishRecognitionProvider>());
    });

    test('returns DeepSeekFishRecognitionProvider for type "deepseek"', () {
      final provider = AiRecognitionProvider.fromConfig('deepseek');
      expect(provider, isA<DeepSeekFishRecognitionProvider>());
    });

    test('returns BaiduFishRecognitionProvider for type "baidu"', () {
      final provider = AiRecognitionProvider.fromConfig('baidu');
      expect(provider, isA<BaiduFishRecognitionProvider>());
      expect(provider, isA<OpenAICompatibleProvider>());
    });

    test('returns AliyunFishRecognitionProvider for type "aliyun"', () {
      final provider = AiRecognitionProvider.fromConfig('aliyun');
      expect(provider, isA<AliyunFishRecognitionProvider>());
    });

    test('returns TencentFishRecognitionProvider for type "tencent"', () {
      final provider = AiRecognitionProvider.fromConfig('tencent');
      expect(provider, isA<TencentFishRecognitionProvider>());
    });

    test('returns ZhipuFishRecognitionProvider for type "zhipu"', () {
      final provider = AiRecognitionProvider.fromConfig('zhipu');
      expect(provider, isA<ZhipuFishRecognitionProvider>());
    });

    test('returns CustomFishRecognitionProvider for type "custom"', () {
      final provider = AiRecognitionProvider.fromConfig('custom');
      expect(provider, isA<CustomFishRecognitionProvider>());
    });

    test('is case insensitive for type parameter', () {
      expect(
        AiRecognitionProvider.fromConfig('OPENAI'),
        isA<OpenAIFishRecognitionProvider>(),
      );
      expect(
        AiRecognitionProvider.fromConfig('Gemini'),
        isA<GeminiFishRecognitionProvider>(),
      );
      expect(
        AiRecognitionProvider.fromConfig('CLAUDE'),
        isA<ClaudeFishRecognitionProvider>(),
      );
    });

    test('throws ArgumentError for unknown type', () {
      expect(
        () => AiRecognitionProvider.fromConfig('unknown'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError with correct error message for unknown type',
        () {
      try {
        AiRecognitionProvider.fromConfig('unknown_provider');
        fail('Expected ArgumentError was not thrown');
      } on ArgumentError catch (e) {
        expect(e.message, contains('Unknown AI recognition provider type'));
        expect(e.message, contains('unknown_provider'));
      }
    });

    test('all enum values have corresponding provider', () {
      for (final provider in AiRecognitionProvider.values) {
        final result = AiRecognitionProvider.fromConfig(provider.label);
        expect(result, isA<FishRecognitionProvider>());
      }
    });
  });
}
