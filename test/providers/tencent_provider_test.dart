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

      test('defaultBaseUrl is Hunyuan host only', () {
        expect(
          provider.defaultBaseUrl,
          equals('https://api.hunyuan.cloud.tencent.com'),
        );
      });

      test('defaultModel is hunyuan-vision', () {
        expect(provider.defaultModel, equals('hunyuan-vision'));
      });

      test('urlPathStrategy is appendPath', () {
        expect(provider.urlPathStrategy, equals(UrlPathStrategy.appendPath));
      });

      test('buildUrl on default base yields documented endpoint', () {
        expect(
          provider.buildUrl(provider.defaultBaseUrl),
          equals(
            Uri.parse(
              'https://api.hunyuan.cloud.tencent.com/v1/chat/completions',
            ),
          ),
        );
      });

      test('buildUrl appends path on user-supplied host override', () {
        expect(
          provider.buildUrl('https://proxy.example.com'),
          equals(Uri.parse('https://proxy.example.com/v1/chat/completions')),
        );
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
