import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/adapters/aliyun_provider.dart';
import 'package:lurebox/core/services/adapters/openai_compatible_provider.dart';
import '../helpers/openai_provider_test_helpers.dart';

void main() {
  group('AliyunFishRecognitionProvider', () {
    group('configuration', () {
      late AliyunFishRecognitionProvider provider;

      setUp(() {
        provider = AliyunFishRecognitionProvider(client: MockHttpClient());
      });

      tearDown(() {
        // No resources to clean up - mocks are garbage collected
      });

      test('defaultBaseUrl is the full DashScope compatible-mode endpoint', () {
        expect(
          provider.defaultBaseUrl,
          equals(
            'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions',
          ),
        );
      });

      test('defaultModel is qwen-vl-max', () {
        expect(provider.defaultModel, equals('qwen-vl-max'));
      });

      test('urlPathStrategy is useDirect', () {
        expect(provider.urlPathStrategy, equals(UrlPathStrategy.useDirect));
      });

      test('buildUrl on default base yields documented endpoint', () {
        expect(
          provider.buildUrl(provider.defaultBaseUrl),
          equals(
            Uri.parse(
              'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions',
            ),
          ),
        );
      });

      test('buildUrl uses user-supplied full path directly', () {
        expect(
          provider.buildUrl('https://proxy.example.com/v1/chat/completions'),
          equals(Uri.parse('https://proxy.example.com/v1/chat/completions')),
        );
      });
    });

    runOpenAICompatibleProviderTests(
      providerName: 'Aliyun',
      createProvider: (client) => AliyunFishRecognitionProvider(client: client),
      aiProvider: AiRecognitionProvider.aliyun,
      expectedUrlFragment: 'dashscope.aliyuncs.com',
      expectedModel: 'qwen-vl-max',
      chineseName: '黑鱼',
      scientificName: 'Channa argus',
      confidence: 88,
    );
  });
}
