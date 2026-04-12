import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/services/adapters/zhipu_provider.dart';
import 'package:lurebox/core/services/adapters/openai_compatible_provider.dart';

void main() {
  group('ZhipuFishRecognitionProvider', () {
    late ZhipuFishRecognitionProvider provider;

    setUp(() {
      provider = ZhipuFishRecognitionProvider();
    });

    group('constructor', () {
      test('configures correct GLM endpoint as defaultBaseUrl', () {
        expect(
          provider.defaultBaseUrl,
          equals('https://open.bigmodel.cn/api/paas/v4/chat/completions'),
        );
      });

      test('sets GLM model as defaultModel', () {
        expect(provider.defaultModel, equals('glm-4v-plus'));
      });

      test('uses direct URL path strategy', () {
        expect(provider.urlPathStrategy, equals(UrlPathStrategy.useDirect));
      });

      test('buildUrl returns baseUrl directly without modification', () {
        final url = provider.buildUrl(provider.defaultBaseUrl);
        expect(
          url.toString(),
          equals('https://open.bigmodel.cn/api/paas/v4/chat/completions'),
        );
      });

      test('buildUrl uses custom baseUrl when provided', () {
        const customUrl = 'https://custom.api.com/endpoint';
        final url = provider.buildUrl(customUrl);
        expect(url.toString(), equals(customUrl));
      });
    });
  });
}
