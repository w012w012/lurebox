import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/adapters/openai_compatible_provider.dart';
import 'package:lurebox/core/services/adapters/siliconflow_provider.dart';

import '../helpers/openai_provider_test_helpers.dart';

void main() {
  group('SiliconFlowFishRecognitionProvider', () {
    group('configuration', () {
      late SiliconFlowFishRecognitionProvider provider;

      setUp(() {
        provider = SiliconFlowFishRecognitionProvider(client: MockHttpClient());
      });

      tearDown(() {
        // No resources to clean up - mocks are garbage collected
      });

      test('defaultBaseUrl points to SiliconFlow endpoint', () {
        expect(
          provider.defaultBaseUrl,
          equals('https://api.siliconflow.cn'),
        );
      });

      test('defaultModel is Qwen2-VL-72B', () {
        expect(
          provider.defaultModel,
          equals('Qwen/Qwen2-VL-72B-Instruct'),
        );
      });

      test('urlPathStrategy is appendPath', () {
        expect(provider.urlPathStrategy, equals(UrlPathStrategy.appendPath));
      });
    });

    runOpenAICompatibleProviderTests(
      providerName: 'SiliconFlow',
      createProvider: (client) =>
          SiliconFlowFishRecognitionProvider(client: client),
      aiProvider: AiRecognitionProvider.siliconflow,
      expectedUrlFragment: 'api.siliconflow.cn',
      expectedModel: 'Qwen/Qwen2-VL-72B-Instruct',
      chineseName: '鲈鱼',
      scientificName: 'Lateolabrax japonicus',
      confidence: 82,
    );
  });
}
