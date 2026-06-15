import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/adapters/openai_compatible_provider.dart';
import 'package:lurebox/core/services/adapters/openai_provider.dart';

import '../helpers/openai_provider_test_helpers.dart';

void main() {
  group('OpenAIFishRecognitionProvider', () {
    group('configuration', () {
      late OpenAIFishRecognitionProvider provider;

      setUp(() {
        provider = OpenAIFishRecognitionProvider(client: MockHttpClient());
      });

      tearDown(() {
        // No resources to clean up - mocks are garbage collected
      });

      test('defaultBaseUrl points to OpenAI endpoint', () {
        expect(
          provider.defaultBaseUrl,
          equals('https://api.openai.com'),
        );
      });

      test('defaultModel is gpt-4o', () {
        expect(provider.defaultModel, equals('gpt-4o'));
      });

      test('urlPathStrategy is appendPath', () {
        expect(provider.urlPathStrategy, equals(UrlPathStrategy.appendPath));
      });

      test('buildUrl on default base yields documented endpoint', () {
        expect(
          provider.buildUrl(provider.defaultBaseUrl),
          equals(Uri.parse('https://api.openai.com/v1/chat/completions')),
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
      providerName: 'OpenAI',
      createProvider: (client) => OpenAIFishRecognitionProvider(client: client),
      aiProvider: AiRecognitionProvider.openai,
      expectedUrlFragment: 'api.openai.com',
      expectedModel: 'gpt-4o',
    );
  });
}
