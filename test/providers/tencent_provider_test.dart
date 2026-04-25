import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/adapters/openai_compatible_provider.dart';
import 'package:lurebox/core/services/adapters/tencent_provider.dart';

import '../helpers/openai_provider_test_helpers.dart';

void main() {
  group('TencentFishRecognitionProvider', () {
    group('configuration', () {
      late TencentFishRecognitionProvider provider;

      setUp(() {
        provider = TencentFishRecognitionProvider(client: MockHttpClient());
      });

      tearDown(() {
        // No resources to clean up - mocks are garbage collected
      });

      test('defaultBaseUrl points to Hunyuan endpoint', () {
        expect(
          provider.defaultBaseUrl,
          equals('https://api.hunyuan.cloud.tencent.com/v1/chat/completions'),
        );
      });

      test('defaultModel is hunyuan-vision', () {
        expect(provider.defaultModel, equals('hunyuan-vision'));
      });

      test('urlPathStrategy is appendPath', () {
        expect(provider.urlPathStrategy, equals(UrlPathStrategy.appendPath));
      });
    });

    runOpenAICompatibleProviderTests(
      providerName: 'Tencent',
      createProvider: (client) =>
          TencentFishRecognitionProvider(client: client),
      aiProvider: AiRecognitionProvider.tencent,
      expectedUrlFragment: 'hunyuan.cloud.tencent.com',
      expectedModel: 'hunyuan-vision',
    );
  });
}
