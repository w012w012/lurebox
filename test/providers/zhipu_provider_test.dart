import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/adapters/zhipu_provider.dart';
import 'package:lurebox/core/services/adapters/openai_compatible_provider.dart';
import '../helpers/openai_provider_test_helpers.dart';

void main() {
  group('ZhipuFishRecognitionProvider', () {
    group('configuration', () {
      late ZhipuFishRecognitionProvider provider;

      setUp(() {
        provider = ZhipuFishRecognitionProvider(client: MockHttpClient());
      });

      test('defaultBaseUrl points to GLM endpoint', () {
        expect(
          provider.defaultBaseUrl,
          equals('https://open.bigmodel.cn/api/paas/v4/chat/completions'),
        );
      });

      test('defaultModel is glm-4v-plus', () {
        expect(provider.defaultModel, equals('glm-4v-plus'));
      });

      test('urlPathStrategy is useDirect', () {
        expect(provider.urlPathStrategy, equals(UrlPathStrategy.useDirect));
      });
    });

    runOpenAICompatibleProviderTests(
      providerName: 'Zhipu',
      createProvider: (client) => ZhipuFishRecognitionProvider(client: client),
      aiProvider: AiRecognitionProvider.zhipu,
      expectedUrlFragment: 'open.bigmodel.cn',
      expectedModel: 'glm-4v-plus',
    );
  });
}
