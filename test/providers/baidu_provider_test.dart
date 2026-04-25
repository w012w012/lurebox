import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/adapters/baidu_provider.dart';
import 'package:lurebox/core/services/adapters/openai_compatible_provider.dart';
import '../helpers/openai_provider_test_helpers.dart';

void main() {
  group('BaiduFishRecognitionProvider', () {
    group('configuration', () {
      late BaiduFishRecognitionProvider provider;

      setUp(() {
        provider = BaiduFishRecognitionProvider(client: MockHttpClient());
      });

      tearDown(() {
        // No resources to clean up - mocks are garbage collected
      });

      test('defaultBaseUrl points to Baidu ERNIE endpoint', () {
        expect(
          provider.defaultBaseUrl,
          equals('https://api.baidubce.com/v1/chat/completions'),
        );
      });

      test('defaultModel is ernie-vl-72b', () {
        expect(provider.defaultModel, equals('ernie-vl-72b'));
      });

      test('urlPathStrategy is useDirect', () {
        expect(provider.urlPathStrategy, equals(UrlPathStrategy.useDirect));
      });
    });

    runOpenAICompatibleProviderTests(
      providerName: 'Baidu',
      createProvider: (client) => BaiduFishRecognitionProvider(client: client),
      aiProvider: AiRecognitionProvider.baidu,
      expectedUrlFragment: 'baidubce.com',
      expectedModel: 'ernie-vl-72b',
      chineseName: '黑鱼',
      scientificName: 'Channa argus',
      confidence: 78,
    );
  });
}
