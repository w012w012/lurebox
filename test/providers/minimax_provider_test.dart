import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/fish_recognition_service.dart';
import 'package:lurebox/core/services/providers/minimax_provider.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MiniMaxFishRecognitionProvider provider;
  late MockHttpClient mockHttpClient;
  late AiProviderConfig testConfig;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    provider = MiniMaxFishRecognitionProvider(client: mockHttpClient);
    testConfig = const AiProviderConfig(
      provider: AiRecognitionProvider.minimax,
      apiKey: 'test-api-key',
      modelName: 'abab6.5s-chat',
    );
  });

  // Helper to create a UTF-8 encoded HTTP response
  http.Response _createUtf8Response(Map<String, dynamic> json, int statusCode) {
    return http.Response.bytes(
      utf8.encode(jsonEncode(json)),
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  group('MiniMaxFishRecognitionProvider', () {
    group('identifySpecies', () {
      test('returns FishRecognitionResult on successful识别', () async {
        // Arrange
        final testImage = File('test/fixtures/test_fish.jpg');
        final mockResponse = _createUtf8Response({
          'base_resp': {'status_code': 0, 'status_msg': ''},
          'choices': [
            {
              'message': {
                'role': 'assistant',
                'content':
                    '{"primarySpecies":{"chineseName":"鲈鱼","scientificName":"Lateolabrax japonicus","confidence":85},"confidence":85,"alternatives":[],"notes":""}',
              },
            },
          ],
        }, 200);

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await provider.identifySpecies(testImage, testConfig);

        // Assert
        expect(result, isA<FishRecognitionResult>());
        expect(result.primarySpecies.chineseName, equals('鲈鱼'));
        expect(result.primarySpecies.scientificName,
            equals('Lateolabrax japonicus'));
        expect(result.confidence, equals(85));
      });

      test('uses MiniMax text/chatcompletion_v2 API endpoint', () async {
        // Arrange
        final testImage = File('test/fixtures/test_fish.jpg');
        final mockResponse = _createUtf8Response({
          'base_resp': {'status_code': 0, 'status_msg': ''},
          'choices': [
            {
              'message': {
                'role': 'assistant',
                'content':
                    '{"primarySpecies":{"chineseName":"鲈鱼","scientificName":"Lateolabrax japonicus","confidence":85},"confidence":85,"alternatives":[],"notes":""}',
              },
            },
          ],
        }, 200);

        Uri? capturedUri;
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((invocation) async {
          capturedUri = invocation.positionalArguments[0] as Uri;
          return mockResponse;
        });

        // Act
        await provider.identifySpecies(testImage, testConfig);

        // Assert
        expect(capturedUri, isNotNull);
        expect(capturedUri.toString(), contains('/v1/text/chatcompletion_v2'));
      });

      test('constructs request with correct MiniMax API format', () async {
        // Arrange
        final testImage = File('test/fixtures/test_fish.jpg');
        final mockResponse = _createUtf8Response({
          'base_resp': {'status_code': 0, 'status_msg': ''},
          'choices': [
            {
              'message': {
                'role': 'assistant',
                'content':
                    '{"primarySpecies":{"chineseName":"鲈鱼","scientificName":"Lateolabrax japonicus","confidence":85},"confidence":85,"alternatives":[],"notes":""}',
              },
            },
          ],
        }, 200);

        Map<String, String>? capturedHeaders;
        String? capturedBody;

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((invocation) async {
          capturedHeaders = invocation.namedArguments[Symbol('headers')]
              as Map<String, String>?;
          capturedBody = invocation.namedArguments[Symbol('body')] as String?;
          return mockResponse;
        });

        // Act
        await provider.identifySpecies(testImage, testConfig);

        // Assert
        expect(capturedHeaders, isNotNull);
        expect(capturedHeaders!['Content-Type'], equals('application/json'));
        expect(
            capturedHeaders!['Authorization'], equals('Bearer test-api-key'));

        expect(capturedBody, isNotNull);
        final requestBody = jsonDecode(capturedBody!) as Map<String, dynamic>;

        // Verify MiniMax chatcompletion_v2 format
        expect(requestBody['model'], equals('abab6.5s-chat'));
        expect(requestBody['temperature'], equals(0.2));
        expect(requestBody['max_tokens'], equals(2048));

        // Verify messages structure
        final messages = requestBody['messages'] as List<dynamic>;
        expect(messages.length, equals(2));

        // System message
        expect(messages[0]['role'], equals('system'));
        expect(messages[0]['content'], isA<String>());

        // User message with image
        expect(messages[1]['role'], equals('user'));
        final userContent = messages[1]['content'] as List<dynamic>;
        expect(userContent.length, equals(2));

        // Text part
        expect(userContent[0]['type'], equals('text'));
        expect(userContent[0]['text'], contains('识别'));

        // Image URL part
        expect(userContent[1]['type'], equals('image_url'));
        expect(userContent[1]['image_url']['url'],
            startsWith('data:image/jpeg;base64,'));
      });

      test('parses response with alternatives correctly', () async {
        // Arrange
        final testImage = File('test/fixtures/test_fish.jpg');
        final mockResponse = _createUtf8Response({
          'base_resp': {'status_code': 0, 'status_msg': ''},
          'choices': [
            {
              'message': {
                'role': 'assistant',
                'content':
                    '{"primarySpecies":{"chineseName":"翘嘴","scientificName":"Culter alburnus","confidence":78},"confidence":78,"alternatives":[{"chineseName":"鳜鱼","scientificName":"Siniperca chuatsi","confidence":45},{"chineseName":"鲈鱼","scientificName":"Lateolabrax japonicus","confidence":30}],"notes":"结合体型和颜色判断"}',
              },
            },
          ],
        }, 200);

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => mockResponse);

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

      test('throws FishRecognitionException on API error status', () async {
        // Arrange
        final testImage = File('test/fixtures/test_fish.jpg');
        final mockResponse = _createUtf8Response({
          'base_resp': {'status_code': 1003, 'status_msg': 'invalid api_key'},
        }, 200);

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => mockResponse);

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

      test('throws FishRecognitionException on rate limit', () async {
        // Arrange
        final testImage = File('test/fixtures/test_fish.jpg');
        final mockResponse = _createUtf8Response({
          'base_resp': {
            'status_code': 1004,
            'status_msg': 'rate limit exceeded'
          },
        }, 200);

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => provider.identifySpecies(testImage, testConfig),
          throwsA(isA<FishRecognitionException>().having(
            (e) => e.type,
            'type',
            equals(FishRecognitionErrorType.rateLimited),
          )),
        );
      });

      test('handles response with markdown code blocks', () async {
        // Arrange
        final testImage = File('test/fixtures/test_fish.jpg');
        final mockResponse = _createUtf8Response({
          'base_resp': {'status_code': 0, 'status_msg': ''},
          'choices': [
            {
              'message': {
                'role': 'assistant',
                'content':
                    '```json\n{"primarySpecies":{"chineseName":"鲈鱼","scientificName":"Lateolabrax japonicus","confidence":85},"confidence":85,"alternatives":[],"notes":""}\n```',
              },
            },
          ],
        }, 200);

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await provider.identifySpecies(testImage, testConfig);

        // Assert
        expect(result.primarySpecies.chineseName, equals('鲈鱼'));
        expect(result.confidence, equals(85));
      });

      test('uses custom baseUrl when provided in config', () async {
        // Arrange
        final customConfig = testConfig.copyWith(
          baseUrl: 'https://custom-api.example.com',
        );
        final testImage = File('test/fixtures/test_fish.jpg');
        final mockResponse = _createUtf8Response({
          'base_resp': {'status_code': 0, 'status_msg': ''},
          'choices': [
            {
              'message': {
                'role': 'assistant',
                'content':
                    '{"primarySpecies":{"chineseName":"鲈鱼","scientificName":"Lateolabrax japonicus","confidence":85},"confidence":85,"alternatives":[],"notes":""}',
              },
            },
          ],
        }, 200);

        Uri? capturedUri;
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((invocation) async {
          capturedUri = invocation.positionalArguments[0] as Uri;
          return mockResponse;
        });

        // Act
        await provider.identifySpecies(testImage, customConfig);

        // Assert
        expect(capturedUri, isNotNull);
        expect(capturedUri.toString(),
            startsWith('https://custom-api.example.com'));
        expect(capturedUri.toString(), contains('/v1/text/chatcompletion_v2'));
      });
    });
  });
}
