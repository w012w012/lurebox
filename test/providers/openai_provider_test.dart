import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/adapters/openai_provider.dart';
import 'package:lurebox/core/services/adapters/openai_compatible_provider.dart';
import '../helpers/openai_provider_test_helpers.dart';

void main() {
  group('OpenAIFishRecognitionProvider', () {
    group('configuration', () {
      late OpenAIFishRecognitionProvider provider;

      setUp(() {
        provider = OpenAIFishRecognitionProvider(client: MockHttpClient());
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
