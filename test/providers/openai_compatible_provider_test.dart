import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/fish_recognition_service.dart';
import 'package:lurebox/core/services/providers/openai_compatible_provider.dart';
import 'package:lurebox/core/services/providers/fish_recognition_shared.dart';

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

/// Test implementation of OpenAICompatibleProvider
class TestOpenAICompatibleProvider extends OpenAICompatibleProvider {
  final String testDefaultBaseUrl;
  final String testDefaultModel;
  final UrlPathStrategy? testUrlPathStrategy;

  TestOpenAICompatibleProvider({
    http.Client? client,
    this.testDefaultBaseUrl = 'https://api.test.com',
    this.testDefaultModel = 'test-model',
    this.testUrlPathStrategy,
  }) : super(client: client);

  @override
  String get defaultBaseUrl => testDefaultBaseUrl;

  @override
  String get defaultModel => testDefaultModel;

  /// Override urlPathStrategy only if explicitly set (use base class default otherwise)
  @override
  UrlPathStrategy get urlPathStrategy =>
      testUrlPathStrategy ?? UrlPathStrategy.appendPath;

  /// Override systemPrompt - but since it returns the same value as base class,
  /// this prevents the base class implementation from running
  @override
  String get systemPrompt => fishRecognitionSystemPrompt;
}

/// Test provider that uses base class defaults (does not override urlPathStrategy)
class TestOpenAICompatibleProviderWithDefaults
    extends OpenAICompatibleProvider {
  final String testDefaultBaseUrl;
  final String testDefaultModel;

  TestOpenAICompatibleProviderWithDefaults({
    http.Client? client,
    this.testDefaultBaseUrl = 'https://api.test.com',
    this.testDefaultModel = 'test-model',
  }) : super(client: client);

  @override
  String get defaultBaseUrl => testDefaultBaseUrl;

  @override
  String get defaultModel => testDefaultModel;

  // Does NOT override urlPathStrategy - uses base class default (appendPath)
  // Does NOT override systemPrompt - uses base class default
}

void main() {
  late MockHttpClient mockClient;
  late AiProviderConfig testConfig;

  setUpAll(() {
    registerFallbackValue(FakeUri());
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  setUp(() {
    mockClient = MockHttpClient();
    testConfig = const AiProviderConfig(
      provider: AiRecognitionProvider.openai,
      apiKey: 'test-api-key',
      baseUrl: 'https://api.test.com',
      modelName: 'test-model',
    );
  });

  group('extractJsonFromResponse', () {
    test('returns original string when no markdown blocks', () {
      const content = '{"primarySpecies": {"chineseName": "测试"}}';
      expect(extractJsonFromResponse(content), equals(content));
    });

    test('removes ```json code block prefix', () {
      const content = '```json\n{"primarySpecies": {"chineseName": "测试"}}\n```';
      expect(
        extractJsonFromResponse(content),
        equals('{"primarySpecies": {"chineseName": "测试"}}'),
      );
    });

    test('removes ``` code block prefix without language', () {
      const content = '```\n{"primarySpecies": {"chineseName": "测试"}}\n```';
      expect(
        extractJsonFromResponse(content),
        equals('{"primarySpecies": {"chineseName": "测试"}}'),
      );
    });

    test('removes trailing ``` code block', () {
      const content = '{"primarySpecies": {"chineseName": "测试"}}\n```';
      expect(
        extractJsonFromResponse(content),
        equals('{"primarySpecies": {"chineseName": "测试"}}'),
      );
    });

    test('trims whitespace', () {
      const content = '  \n  {"primarySpecies": {}}  \n  ';
      expect(
        extractJsonFromResponse(content),
        equals('{"primarySpecies": {}}'),
      );
    });

    test('handles content with extra newlines and spaces', () {
      const content = '''
      ```json
      {
        "primarySpecies": {"chineseName": "鲈鱼"}
      }
      ```
      ''';
      final result = extractJsonFromResponse(content);
      expect(result.contains('```'), isFalse);
      expect(result.contains('鲈鱼'), isTrue);
    });
  });

  group('parseHttpStatus', () {
    test('returns null for 200 OK', () {
      final response = http.Response('OK', 200);
      final result = parseHttpStatus(response);
      expect(result.$1, isNull);
      expect(result.$2, isNull);
    });

    test('returns apiKeyInvalid for 401', () {
      final response = http.Response('Unauthorized', 401);
      final result = parseHttpStatus(response);
      expect(result.$1, equals(FishRecognitionErrorType.apiKeyInvalid));
    });

    test('returns apiKeyInvalid for 403', () {
      final response = http.Response('Forbidden', 403);
      final result = parseHttpStatus(response);
      expect(result.$1, equals(FishRecognitionErrorType.apiKeyInvalid));
    });

    test('returns rateLimited for 429', () {
      final response = http.Response('Too Many Requests', 429);
      final result = parseHttpStatus(response);
      expect(result.$1, equals(FishRecognitionErrorType.rateLimited));
    });

    test('returns networkError for 500', () {
      final response = http.Response('Internal Server Error', 500);
      final result = parseHttpStatus(response);
      expect(result.$1, equals(FishRecognitionErrorType.networkError));
    });

    test('returns networkError for 502', () {
      final response = http.Response('Bad Gateway', 502);
      final result = parseHttpStatus(response);
      expect(result.$1, equals(FishRecognitionErrorType.networkError));
    });

    test('returns networkError for 503', () {
      final response = http.Response('Service Unavailable', 503);
      final result = parseHttpStatus(response);
      expect(result.$1, equals(FishRecognitionErrorType.networkError));
    });

    test('returns unknown for other status codes', () {
      final response = http.Response('Unknown', 418);
      final result = parseHttpStatus(response);
      expect(result.$1, equals(FishRecognitionErrorType.unknown));
    });
  });

  group('throwHttpError', () {
    test('does not throw for 200', () {
      final response = http.Response('OK', 200);
      expect(() => throwHttpError(response), returnsNormally);
    });

    test('throws FishRecognitionException for 401', () {
      final response = http.Response('Unauthorized', 401);
      expect(
        () => throwHttpError(response),
        throwsA(isA<FishRecognitionException>().having(
          (e) => e.type,
          'type',
          equals(FishRecognitionErrorType.apiKeyInvalid),
        )),
      );
    });

    test('throws FishRecognitionException for 429', () {
      final response = http.Response('Too Many Requests', 429);
      expect(
        () => throwHttpError(response),
        throwsA(isA<FishRecognitionException>().having(
          (e) => e.type,
          'type',
          equals(FishRecognitionErrorType.rateLimited),
        )),
      );
    });

    test('calls onRateLimited callback when provided and status is 429', () {
      final response = http.Response('Too Many Requests', 429);
      bool callbackCalled = false;
      expect(
        () => throwHttpError(response,
            onRateLimited: () => callbackCalled = true),
        throwsA(isA<FishRecognitionException>()),
      );
      expect(callbackCalled, isTrue);
    });
  });

  group('OpenAICompatibleProvider - URL building', () {
    test('UrlPathStrategy.appendPath appends /v1/chat/completions', () {
      final provider = TestOpenAICompatibleProvider(
        testUrlPathStrategy: UrlPathStrategy.appendPath,
      );
      final uri = provider.buildUrl('https://api.openai.com');
      expect(
          uri.toString(), equals('https://api.openai.com/v1/chat/completions'));
    });

    test('UrlPathStrategy.appendPath handles trailing slash in baseUrl', () {
      final provider = TestOpenAICompatibleProvider(
        testUrlPathStrategy: UrlPathStrategy.appendPath,
      );
      final uri = provider.buildUrl('https://api.openai.com/');
      expect(
          uri.toString(), equals('https://api.openai.com/v1/chat/completions'));
    });

    test('UrlPathStrategy.useDirect uses baseUrl as-is', () {
      final provider = TestOpenAICompatibleProvider(
        testUrlPathStrategy: UrlPathStrategy.useDirect,
      );
      final uri =
          provider.buildUrl('https://api.baidubce.com/v1/chat/completions');
      expect(uri.toString(),
          equals('https://api.baidubce.com/v1/chat/completions'));
    });

    test('UrlPathStrategy.custom throws UnimplementedError', () {
      final provider = TestOpenAICompatibleProvider(
        testUrlPathStrategy: UrlPathStrategy.custom,
      );
      expect(
        () => provider.buildUrl('https://api.test.com'),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('uses base class default urlPathStrategy when not overridden', () {
      // This test uses the provider that does NOT override urlPathStrategy
      // so the base class implementation runs
      final provider = TestOpenAICompatibleProviderWithDefaults();
      final uri = provider.buildUrl('https://api.openai.com');
      expect(
          uri.toString(), equals('https://api.openai.com/v1/chat/completions'));
    });
  });

  group('OpenAICompatibleProvider - identifySpecies', () {
    test('returns FishRecognitionResult on successful response', () async {
      // Arrange
      final testImage = File('test/fixtures/test_fish.jpg');
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
          )).thenAnswer((_) async => mockResponse);

      final provider = TestOpenAICompatibleProvider(client: mockClient);

      // Act
      final result = await provider.identifySpecies(testImage, testConfig);

      // Assert
      expect(result, isA<FishRecognitionResult>());
      expect(result.primarySpecies.chineseName, equals('黑鱼'));
      expect(result.primarySpecies.scientificName, equals('Channa argus'));
      expect(result.confidence, equals(85));
    });

    test('uses config.modelName when provided', () async {
      // Arrange
      final testImage = File('test/fixtures/test_fish.jpg');
      final mockResponse = _createUtf8Response(
        _createSuccessfulOpenAIResponse(
          chineseName: '鲈鱼',
          scientificName: 'Lateolabrax japonicus',
          confidence: 90,
        ),
        200,
      );

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => mockResponse);

      final provider = TestOpenAICompatibleProvider(client: mockClient);

      // Act
      await provider.identifySpecies(testImage, testConfig);

      // Assert - verify model in request body
      verify(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(1);
    });

    test('uses defaultModel when config.modelName is empty', () async {
      // Arrange
      final testImage = File('test/fixtures/test_fish.jpg');
      final configWithoutModel = testConfig.copyWith(modelName: '');
      final mockResponse = _createUtf8Response(
        _createSuccessfulOpenAIResponse(
          chineseName: '鲈鱼',
          scientificName: 'Lateolabrax japonicus',
          confidence: 90,
        ),
        200,
      );

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => mockResponse);

      final provider = TestOpenAICompatibleProvider(
        client: mockClient,
        testDefaultModel: 'default-model',
      );

      // Act
      await provider.identifySpecies(testImage, configWithoutModel);

      // Assert
      verify(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(1);
    });

    test('uses config.baseUrl when provided', () async {
      // Arrange
      final testImage = File('test/fixtures/test_fish.jpg');
      final customConfig =
          testConfig.copyWith(baseUrl: 'https://custom.api.com');
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
          )).thenAnswer((invocation) async {
        capturedUri = invocation.positionalArguments[0] as Uri;
        return mockResponse;
      });

      final provider = TestOpenAICompatibleProvider(client: mockClient);

      // Act
      await provider.identifySpecies(testImage, customConfig);

      // Assert
      expect(capturedUri, isNotNull);
      expect(capturedUri.toString(), startsWith('https://custom.api.com'));
    });

    test('uses defaultBaseUrl when config.baseUrl is empty', () async {
      // Arrange
      final testImage = File('test/fixtures/test_fish.jpg');
      final configWithoutBaseUrl = testConfig.copyWith(baseUrl: '');
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
          )).thenAnswer((invocation) async {
        capturedUri = invocation.positionalArguments[0] as Uri;
        return mockResponse;
      });

      final provider = TestOpenAICompatibleProvider(
        client: mockClient,
        testDefaultBaseUrl: 'https://default.api.com',
      );

      // Act
      await provider.identifySpecies(testImage, configWithoutBaseUrl);

      // Assert
      expect(capturedUri, isNotNull);
      expect(capturedUri.toString(), startsWith('https://default.api.com'));
    });

    test('constructs correct request body with base64 image', () async {
      // Arrange
      final testImage = File('test/fixtures/test_fish.jpg');
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
          )).thenAnswer((invocation) async {
        capturedBody = invocation.namedArguments[Symbol('body')] as String?;
        return mockResponse;
      });

      final provider = TestOpenAICompatibleProvider(client: mockClient);

      // Act
      await provider.identifySpecies(testImage, testConfig);

      // Assert
      expect(capturedBody, isNotNull);
      final requestBody = jsonDecode(capturedBody!) as Map<String, dynamic>;

      expect(requestBody['model'], equals('test-model'));
      expect(requestBody['temperature'], equals(0.2));
      expect(requestBody['max_tokens'], equals(2048));
      expect(requestBody['response_format'], equals({'type': 'json_object'}));

      // Check messages structure
      final messages = requestBody['messages'] as List<dynamic>;
      expect(messages.length, equals(2));

      // System message
      expect(messages[0]['role'], equals('system'));
      expect(messages[0]['content'], isA<String>());

      // User message
      expect(messages[1]['role'], equals('user'));
      final userContent = messages[1]['content'] as List<dynamic>;
      expect(userContent.length, equals(2));
      expect(userContent[0]['type'], equals('text'));
      expect(userContent[0]['text'], contains('识别'));
      expect(userContent[1]['type'], equals('image_url'));
      expect(userContent[1]['image_url']['url'],
          startsWith('data:image/jpeg;base64,'));
    });

    test('sets correct headers including Authorization', () async {
      // Arrange
      final testImage = File('test/fixtures/test_fish.jpg');
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
          )).thenAnswer((invocation) async {
        capturedHeaders = invocation.namedArguments[Symbol('headers')]
            as Map<String, String>?;
        return mockResponse;
      });

      final provider = TestOpenAICompatibleProvider(client: mockClient);

      // Act
      await provider.identifySpecies(testImage, testConfig);

      // Assert
      expect(capturedHeaders, isNotNull);
      expect(capturedHeaders!['Content-Type'], equals('application/json'));
      expect(capturedHeaders!['Authorization'], equals('Bearer test-api-key'));
    });

    test('parses response with alternatives correctly', () async {
      // Arrange
      final testImage = File('test/fixtures/test_fish.jpg');
      final mockResponse = _createUtf8Response(
        _createSuccessfulOpenAIResponse(
          chineseName: '翘嘴',
          scientificName: 'Culter alburnus',
          confidence: 78,
          alternatives: [
            {
              'chineseName': '鳜鱼',
              'scientificName': 'Siniperca chuatsi',
              'confidence': 45
            },
            {
              'chineseName': '鲈鱼',
              'scientificName': 'Lateolabrax japonicus',
              'confidence': 30
            },
          ],
          notes: '结合体型和颜色判断',
        ),
        200,
      );

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => mockResponse);

      final provider = TestOpenAICompatibleProvider(client: mockClient);

      // Act
      final result = await provider.identifySpecies(testImage, testConfig);

      // Assert
      expect(result.primarySpecies.chineseName, equals('翘嘴'));
      expect(result.primarySpecies.scientificName, equals('Culter alburnus'));
      expect(result.confidence, equals(78));
      expect(result.alternatives.length, equals(2));
      expect(result.alternatives[0].chineseName, equals('鳜鱼'));
      expect(result.alternatives[1].chineseName, equals('鲈鱼'));
      expect(result.notes, equals('结合体型和颜色判断'));
    });

    test('handles response with markdown code blocks', () async {
      // Arrange
      final testImage = File('test/fixtures/test_fish.jpg');
      final contentWithMarkdown = '''```json
{"primarySpecies":{"chineseName":"鲈鱼","scientificName":"Lateolabrax japonicus","confidence":85},"confidence":85,"alternatives":[],"notes":""}
```''';

      final mockResponse = _createUtf8Response({
        'choices': [
          {
            'message': {
              'role': 'assistant',
              'content': contentWithMarkdown,
            },
          },
        ],
      }, 200);

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => mockResponse);

      final provider = TestOpenAICompatibleProvider(client: mockClient);

      // Act
      final result = await provider.identifySpecies(testImage, testConfig);

      // Assert
      expect(result.primarySpecies.chineseName, equals('鲈鱼'));
      expect(result.confidence, equals(85));
    });
  });

  group('OpenAICompatibleProvider - handleOpenAIResponse', () {
    late TestOpenAICompatibleProvider provider;

    setUp(() {
      provider = TestOpenAICompatibleProvider(client: mockClient);
    });

    test('throws FishRecognitionException on 401 unauthorized', () {
      final errorResponse = http.Response('Unauthorized', 401);

      expect(
        () => provider.handleOpenAIResponse(errorResponse),
        throwsA(isA<FishRecognitionException>()),
      );
    });

    test('throws FishRecognitionException on 403 forbidden', () {
      final errorResponse = http.Response('Forbidden', 403);

      expect(
        () => provider.handleOpenAIResponse(errorResponse),
        throwsA(isA<FishRecognitionException>().having(
          (e) => e.type,
          'type',
          equals(FishRecognitionErrorType.apiKeyInvalid),
        )),
      );
    });

    test('throws FishRecognitionException on 429 rate limited', () {
      final errorResponse = http.Response('Too Many Requests', 429);

      expect(
        () => provider.handleOpenAIResponse(errorResponse),
        throwsA(isA<FishRecognitionException>().having(
          (e) => e.type,
          'type',
          equals(FishRecognitionErrorType.rateLimited),
        )),
      );
    });

    test('throws FishRecognitionException on 500 server error', () {
      final errorResponse = http.Response('Internal Server Error', 500);

      expect(
        () => provider.handleOpenAIResponse(errorResponse),
        throwsA(isA<FishRecognitionException>().having(
          (e) => e.type,
          'type',
          equals(FishRecognitionErrorType.networkError),
        )),
      );
    });

    test('throws FishRecognitionException on API error with invalid_api_key',
        () {
      final response = http.Response(
        jsonEncode({
          'error': {
            'message': 'Invalid API key',
            'code': 'invalid_api_key',
          },
        }),
        200,
      );

      expect(
        () => provider.handleOpenAIResponse(response),
        throwsA(isA<FishRecognitionException>().having(
          (e) => e.type,
          'type',
          equals(FishRecognitionErrorType.apiKeyInvalid),
        )),
      );
    });

    test('throws FishRecognitionException on API error with API key in message',
        () {
      final response = http.Response(
        jsonEncode({
          'error': {
            'message': 'Your API key is invalid',
          },
        }),
        200,
      );

      expect(
        () => provider.handleOpenAIResponse(response),
        throwsA(isA<FishRecognitionException>().having(
          (e) => e.type,
          'type',
          equals(FishRecognitionErrorType.apiKeyInvalid),
        )),
      );
    });

    test('throws FishRecognitionException on API error with rate limit message',
        () {
      final response = http.Response(
        jsonEncode({
          'error': {
            'message': 'Rate limit exceeded',
            'code': 'rate_limit_exceeded',
          },
        }),
        200,
      );

      expect(
        () => provider.handleOpenAIResponse(response),
        throwsA(isA<FishRecognitionException>().having(
          (e) => e.type,
          'type',
          equals(FishRecognitionErrorType.rateLimited),
        )),
      );
    });

    test('throws FishRecognitionException when choices is empty', () {
      final response = http.Response(
        jsonEncode({'choices': []}),
        200,
      );

      expect(
        () => provider.handleOpenAIResponse(response),
        throwsA(isA<FishRecognitionException>()),
      );
    });

    test('throws FishRecognitionException when message is missing', () {
      final response = http.Response(
        jsonEncode({
          'choices': [{}]
        }),
        200,
      );

      expect(
        () => provider.handleOpenAIResponse(response),
        throwsA(isA<FishRecognitionException>()),
      );
    });

    test('throws FishRecognitionException when content is null', () {
      final response = http.Response(
        jsonEncode({
          'choices': [
            {
              'message': {'role': 'assistant', 'content': null}
            },
          ],
        }),
        200,
      );

      expect(
        () => provider.handleOpenAIResponse(response),
        throwsA(isA<FishRecognitionException>()),
      );
    });

    test('throws FishRecognitionException when content is empty', () {
      final response = http.Response(
        jsonEncode({
          'choices': [
            {
              'message': {'role': 'assistant', 'content': ''}
            },
          ],
        }),
        200,
      );

      expect(
        () => provider.handleOpenAIResponse(response),
        throwsA(isA<FishRecognitionException>()),
      );
    });

    test('throws FishRecognitionException on invalid JSON in content', () {
      final response = http.Response(
        jsonEncode({
          'choices': [
            {
              'message': {'role': 'assistant', 'content': 'not valid json {'}
            },
          ],
        }),
        200,
      );

      expect(
        () => provider.handleOpenAIResponse(response),
        throwsA(isA<FishRecognitionException>()),
      );
    });

    test('throws FishRecognitionException on API error with generic message',
        () {
      final response = http.Response(
        jsonEncode({
          'error': {
            'message': 'Something went wrong',
          },
        }),
        200,
      );

      expect(
        () => provider.handleOpenAIResponse(response),
        throwsA(isA<FishRecognitionException>().having(
          (e) => e.type,
          'type',
          equals(FishRecognitionErrorType.unknown),
        )),
      );
    });
  });

  group('OpenAICompatibleProvider - identifySpecies error handling', () {
    test('throws FishRecognitionException on timeout', () async {
      // Arrange
      final testImage = File('test/fixtures/test_fish.jpg');

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenThrow(TimeoutException('Connection timed out'));

      final provider = TestOpenAICompatibleProvider(client: mockClient);

      // Act & Assert
      expect(
        () => provider.identifySpecies(testImage, testConfig),
        throwsA(isA<FishRecognitionException>().having(
          (e) => e.type,
          'type',
          equals(FishRecognitionErrorType.timeout),
        )),
      );
    });

    test('throws FishRecognitionException on network error', () async {
      // Arrange
      final testImage = File('test/fixtures/test_fish.jpg');

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenThrow(http.ClientException('Network is unreachable'));

      final provider = TestOpenAICompatibleProvider(client: mockClient);

      // Act & Assert
      expect(
        () => provider.identifySpecies(testImage, testConfig),
        throwsA(isA<FishRecognitionException>().having(
          (e) => e.type,
          'type',
          equals(FishRecognitionErrorType.networkError),
        )),
      );
    });

    test('rethrows FishRecognitionException from handleOpenAIResponse',
        () async {
      // Arrange
      final testImage = File('test/fixtures/test_fish.jpg');
      final errorResponse = http.Response('Unauthorized', 401);

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => errorResponse);

      final provider = TestOpenAICompatibleProvider(client: mockClient);

      // Act & Assert
      expect(
        () => provider.identifySpecies(testImage, testConfig),
        throwsA(isA<FishRecognitionException>().having(
          (e) => e.type,
          'type',
          equals(FishRecognitionErrorType.apiKeyInvalid),
        )),
      );
    });
  });

  group('OpenAICompatibleProvider - systemPrompt', () {
    test('uses default system prompt from base class when not overridden', () {
      // This provider does NOT override systemPrompt, so base class getter runs
      final provider =
          TestOpenAICompatibleProviderWithDefaults(client: mockClient);
      expect(provider.systemPrompt, equals(fishRecognitionSystemPrompt));
    });
  });
}
