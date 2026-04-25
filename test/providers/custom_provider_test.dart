import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/adapters/custom_provider.dart';
import 'package:lurebox/core/services/adapters/fish_recognition_shared.dart';
import 'package:lurebox/core/services/adapters/openai_compatible_provider.dart';
import 'package:lurebox/core/services/fish_recognition_service.dart';
import 'package:mocktail/mocktail.dart';

/// Mock HTTP Client for testing
class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

/// Helper to create a UTF-8 encoded HTTP response
http.Response _createUtf8Response(Map<String, dynamic> json, int statusCode) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(json)),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

/// Creates a successful OpenAI-compatible API response
Map<String, dynamic> _createSuccessfulOpenAIResponse({
  required String chineseName,
  required String scientificName,
  required int confidence,
  List<Map<String, dynamic>>? alternatives,
  String notes = '',
}) {
  final altList = alternatives ?? [];
  final content = jsonEncode({
    'primarySpecies': {
      'chineseName': chineseName,
      'scientificName': scientificName,
      'confidence': confidence,
    },
    'confidence': confidence,
    'alternatives': altList,
    'notes': notes,
  });

  return {
    'choices': [
      {
        'message': {
          'role': 'assistant',
          'content': content,
        },
      },
    ],
  };
}

void main() {
  late MockHttpClient mockClient;
  late AiProviderConfig testConfig;
  late File testImage;

  setUpAll(() {
    registerFallbackValue(FakeUri());
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  setUp(() {
    mockClient = MockHttpClient();
    testImage = File('test/fixtures/test_fish.jpg');
    testConfig = const AiProviderConfig(
      provider: AiRecognitionProvider.custom,
      apiKey: 'test-api-key',
      baseUrl: 'https://api.custom.com',
      modelName: 'custom-model',
    );
  });

  group('CustomFishRecognitionProvider - URL building', () {
    late CustomFishRecognitionProvider provider;

    setUp(() {
      provider = CustomFishRecognitionProvider(client: mockClient);
    });

    test('buildUrl with /chat/completions suffix uses URL as-is', () {
      final uri =
          provider.buildUrl('https://api.custom.com/v1/chat/completions');
      expect(
          uri.toString(), equals('https://api.custom.com/v1/chat/completions'),);
    });

    test('buildUrl with /v1 suffix appends /chat/completions', () {
      final uri = provider.buildUrl('https://api.custom.com/v1');
      expect(
          uri.toString(), equals('https://api.custom.com/v1/chat/completions'),);
    });

    test('buildUrl with trailing slash appends v1/chat/completions', () {
      final uri = provider.buildUrl('https://api.custom.com/');
      expect(
          uri.toString(), equals('https://api.custom.com/v1/chat/completions'),);
    });

    test('buildUrl standard case appends /v1/chat/completions', () {
      final uri = provider.buildUrl('https://api.custom.com');
      expect(
          uri.toString(), equals('https://api.custom.com/v1/chat/completions'),);
    });
  });

  group('CustomFishRecognitionProvider - identifySpecies', () {
    late CustomFishRecognitionProvider provider;

    setUp(() {
      provider = CustomFishRecognitionProvider(client: mockClient);
    });

    tearDown(() {
      // No resources to clean up - mocks are garbage collected
    });

    test('throws FishRecognitionException when baseUrl is empty', () async {
      final configWithoutBaseUrl = testConfig.copyWith(baseUrl: '');

      expect(
        () => provider.identifySpecies(testImage, configWithoutBaseUrl),
        throwsA(isA<FishRecognitionException>()
            .having(
              (e) => e.type,
              'type',
              equals(FishRecognitionErrorType.apiKeyInvalid),
            )
            .having(
              (e) => e.message,
              'message',
              contains('Base URL'),
            ),),
      );
    });

    test('throws FishRecognitionException when baseUrl is null', () async {
      final configWithNullBaseUrl = AiProviderConfig(
        provider: AiRecognitionProvider.custom,
        apiKey: 'test-api-key',
        modelName: 'custom-model',
      );

      expect(
        () => provider.identifySpecies(testImage, configWithNullBaseUrl),
        throwsA(isA<FishRecognitionException>().having(
          (e) => e.type,
          'type',
          equals(FishRecognitionErrorType.apiKeyInvalid),
        ),),
      );
    });

    test('successful identifySpecies returns FishRecognitionResult', () async {
      final mockResponse = _createUtf8Response(
        _createSuccessfulOpenAIResponse(
          chineseName: '黑鱼',
          scientificName: 'Channa argus',
          confidence: 85,
        ),
        200,
      );

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),).thenAnswer((_) async => mockResponse);

      final result = await provider.identifySpecies(testImage, testConfig);

      expect(result, isA<FishRecognitionResult>());
      expect(result.primarySpecies.chineseName, equals('黑鱼'));
      expect(result.primarySpecies.scientificName, equals('Channa argus'));
      expect(result.confidence, equals(85));
    });

    test('uses config.modelName when provided', () async {
      final mockResponse = _createUtf8Response(
        _createSuccessfulOpenAIResponse(
          chineseName: '鲈鱼',
          scientificName: 'Lateolabrax japonicus',
          confidence: 90,
        ),
        200,
      );

      String? capturedBody;
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),).thenAnswer((invocation) async {
        capturedBody =
            invocation.namedArguments[const Symbol('body')] as String?;
        return mockResponse;
      });

      await provider.identifySpecies(testImage, testConfig);

      expect(capturedBody, isNotNull);
      final requestBody = jsonDecode(capturedBody!) as Map<String, dynamic>;
      expect(requestBody['model'], equals('custom-model'));
    });

    test(
        'uses empty string as model when both config.modelName and defaultModel are empty',
        () async {
      final configWithEmptyModel = testConfig.copyWith(modelName: '');
      final mockResponse = _createUtf8Response(
        _createSuccessfulOpenAIResponse(
          chineseName: '鲈鱼',
          scientificName: 'Lateolabrax japonicus',
          confidence: 90,
        ),
        200,
      );

      String? capturedBody;
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),).thenAnswer((invocation) async {
        capturedBody =
            invocation.namedArguments[const Symbol('body')] as String?;
        return mockResponse;
      });

      await provider.identifySpecies(testImage, configWithEmptyModel);

      expect(capturedBody, isNotNull);
      final requestBody = jsonDecode(capturedBody!) as Map<String, dynamic>;
      // CustomProvider's defaultModel is empty string
      expect(requestBody['model'], equals(''));
    });

    test('constructs correct request body with base64 image', () async {
      final mockResponse = _createUtf8Response(
        _createSuccessfulOpenAIResponse(
          chineseName: '鲈鱼',
          scientificName: 'Lateolabrax japonicus',
          confidence: 90,
        ),
        200,
      );

      String? capturedBody;
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),).thenAnswer((invocation) async {
        capturedBody =
            invocation.namedArguments[const Symbol('body')] as String?;
        return mockResponse;
      });

      await provider.identifySpecies(testImage, testConfig);

      expect(capturedBody, isNotNull);
      final requestBody = jsonDecode(capturedBody!) as Map<String, dynamic>;

      expect(requestBody['model'], equals('custom-model'));
      expect(requestBody['temperature'], equals(0.2));
      expect(requestBody['max_tokens'], equals(2048));
      expect(requestBody['response_format'], equals({'type': 'json_object'}));

      // Check messages structure
      final messages = requestBody['messages'] as List<dynamic>;
      expect(messages.length, equals(2));

      // System message
      expect(messages[0]['role'], equals('system'));
      expect(messages[0]['content'], equals(fishRecognitionSystemPrompt));

      // User message
      expect(messages[1]['role'], equals('user'));
      final userContent = messages[1]['content'] as List<dynamic>;
      expect(userContent.length, equals(2));
      expect(userContent[0]['type'], equals('text'));
      expect(userContent[0]['text'], contains('识别'));
      expect(userContent[1]['type'], equals('image_url'));
      expect(userContent[1]['image_url']['url'],
          startsWith('data:image/jpeg;base64,'),);
    });

    test('sets correct headers including Authorization', () async {
      final mockResponse = _createUtf8Response(
        _createSuccessfulOpenAIResponse(
          chineseName: '鲈鱼',
          scientificName: 'Lateolabrax japonicus',
          confidence: 90,
        ),
        200,
      );

      Map<String, String>? capturedHeaders;
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),).thenAnswer((invocation) async {
        capturedHeaders = invocation.namedArguments[const Symbol('headers')]
            as Map<String, String>?;
        return mockResponse;
      });

      await provider.identifySpecies(testImage, testConfig);

      expect(capturedHeaders, isNotNull);
      expect(capturedHeaders!['Content-Type'], equals('application/json'));
      expect(capturedHeaders!['Authorization'], equals('Bearer test-api-key'));
    });

    test('builds URL using custom buildUrl logic', () async {
      final customConfig =
          testConfig.copyWith(baseUrl: 'https://custom.api.com/v1');
      final mockResponse = _createUtf8Response(
        _createSuccessfulOpenAIResponse(
          chineseName: '鲈鱼',
          scientificName: 'Lateolabrax japonicus',
          confidence: 90,
        ),
        200,
      );

      Uri? capturedUri;
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),).thenAnswer((invocation) async {
        capturedUri = invocation.positionalArguments[0] as Uri;
        return mockResponse;
      });

      await provider.identifySpecies(testImage, customConfig);

      // CustomProvider appends /chat/completions when baseUrl ends with /v1
      expect(capturedUri, isNotNull);
      expect(capturedUri.toString(),
          equals('https://custom.api.com/v1/chat/completions'),);
    });
  });

  group('CustomFishRecognitionProvider - error handling', () {
    late CustomFishRecognitionProvider provider;

    setUp(() {
      provider = CustomFishRecognitionProvider(client: mockClient);
    });

    tearDown(() {
      // No resources to clean up - mocks are garbage collected
    });

    test('throws FishRecognitionException on timeout', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),).thenThrow(TimeoutException('Connection timed out'));

      expect(
        () => provider.identifySpecies(testImage, testConfig),
        throwsA(isA<FishRecognitionException>().having(
          (e) => e.type,
          'type',
          equals(FishRecognitionErrorType.timeout),
        ),),
      );
    });

    test('throws FishRecognitionException on network error', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),).thenThrow(http.ClientException('Network is unreachable'));

      expect(
        () => provider.identifySpecies(testImage, testConfig),
        throwsA(isA<FishRecognitionException>().having(
          (e) => e.type,
          'type',
          equals(FishRecognitionErrorType.networkError),
        ),),
      );
    });

    test('throws FishRecognitionException on 401 unauthorized', () async {
      final errorResponse = http.Response('Unauthorized', 401);

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),).thenAnswer((_) async => errorResponse);

      expect(
        () => provider.identifySpecies(testImage, testConfig),
        throwsA(isA<FishRecognitionException>().having(
          (e) => e.type,
          'type',
          equals(FishRecognitionErrorType.apiKeyInvalid),
        ),),
      );
    });

    test('throws FishRecognitionException on 403 forbidden', () async {
      final errorResponse = http.Response('Forbidden', 403);

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),).thenAnswer((_) async => errorResponse);

      expect(
        () => provider.identifySpecies(testImage, testConfig),
        throwsA(isA<FishRecognitionException>().having(
          (e) => e.type,
          'type',
          equals(FishRecognitionErrorType.apiKeyInvalid),
        ),),
      );
    });

    test('throws FishRecognitionException on 429 rate limited', () async {
      final errorResponse = http.Response('Too Many Requests', 429);

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),).thenAnswer((_) async => errorResponse);

      expect(
        () => provider.identifySpecies(testImage, testConfig),
        throwsA(isA<FishRecognitionException>().having(
          (e) => e.type,
          'type',
          equals(FishRecognitionErrorType.rateLimited),
        ),),
      );
    });

    test('throws FishRecognitionException on 500 server error', () async {
      final errorResponse = http.Response('Internal Server Error', 500);

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),).thenAnswer((_) async => errorResponse);

      expect(
        () => provider.identifySpecies(testImage, testConfig),
        throwsA(isA<FishRecognitionException>().having(
          (e) => e.type,
          'type',
          equals(FishRecognitionErrorType.networkError),
        ),),
      );
    });
  });

  group('CustomFishRecognitionProvider - properties', () {
    test('defaultBaseUrl returns empty string', () {
      final provider = CustomFishRecognitionProvider();
      expect(provider.defaultBaseUrl, equals(''));
    });

    test('defaultModel returns empty string', () {
      final provider = CustomFishRecognitionProvider();
      expect(provider.defaultModel, equals(''));
    });

    test('urlPathStrategy returns custom', () {
      final provider = CustomFishRecognitionProvider();
      expect(provider.urlPathStrategy, equals(UrlPathStrategy.custom));
    });

    test('systemPrompt returns fishRecognitionSystemPrompt', () {
      final provider = CustomFishRecognitionProvider();
      expect(provider.systemPrompt, equals(fishRecognitionSystemPrompt));
    });
  });
}
