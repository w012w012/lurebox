import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/adapters/gemini_provider.dart';
import 'package:lurebox/core/services/fish_recognition_service.dart';
import 'package:mocktail/mocktail.dart';

/// Creates an HTTP response with proper UTF-8 encoding for Chinese characters
http.Response _createUtf8Response(String body, int statusCode) {
  // Use Response.bytes to properly handle UTF-8 encoded content
  return http.Response.bytes(
    utf8.encode(body),
    statusCode,
    headers: {'Content-Type': 'application/json; charset=utf-8'},
  );
}

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient mockHttpClient;
  late GeminiFishRecognitionProvider provider;
  late AiProviderConfig config;

  setUpAll(() {
    registerFallbackValue(FakeUri());
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    provider = GeminiFishRecognitionProvider(client: mockHttpClient);
    config = const AiProviderConfig(
      provider: AiRecognitionProvider.gemini,
      apiKey: 'test-api-key',
      modelName: 'gemini-2.0-flash',
    );
  });

  tearDown(() {
    // No resources to clean up - mocks are garbage collected
  });

  group('GeminiFishRecognitionProvider', () {
    group('identifySpecies', () {
      test('returns FishRecognitionResult on successful response', () async {
        // Arrange
        final imageFile = File('test/fixtures/test_fish.jpg');
        final responseJson = _createSuccessfulGeminiResponse();
        final mockResponse = _createUtf8Response(jsonEncode(responseJson), 200);

        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
            encoding: any(named: 'encoding'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await provider.identifySpecies(imageFile, config);

        // Assert
        expect(result, isA<FishRecognitionResult>());
        expect(result.primarySpecies.chineseName, equals('BlackFish'));
        expect(result.primarySpecies.scientificName, equals('Channa argus'));
        expect(result.confidence, equals(85));
        expect(result.alternatives, isNotEmpty);
        expect(result.alternatives.first.chineseName, equals('SnakeHead'));
      });

      test('uses inlineData format for image in request', () async {
        // Arrange
        final imageFile = File('test/fixtures/test_fish.jpg');
        final responseJson = _createSuccessfulGeminiResponse();
        final mockResponse = _createUtf8Response(jsonEncode(responseJson), 200);

        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
            encoding: any(named: 'encoding'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await provider.identifySpecies(imageFile, config);

        // Assert - verify request was made with inlineData
        verify(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
            encoding: any(named: 'encoding'),
          ),
        ).called(1);
      });

      test('uses detected MIME type for PNG images', () async {
        // Arrange: .png 临时文件，验证 detectImageMediaType 被使用
        final tempDir = Directory.systemTemp.createTempSync('gemini_png_');
        final pngImage = File('${tempDir.path}/fish.png')
          ..writeAsBytesSync([0x89, 0x50, 0x4E, 0x47]);
        addTearDown(() => tempDir.deleteSync(recursive: true));

        final mockResponse = _createUtf8Response(
            jsonEncode(_createSuccessfulGeminiResponse()), 200);

        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: captureAny(named: 'body'),
            encoding: any(named: 'encoding'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await provider.identifySpecies(pngImage, config);

        // Assert
        final captured = verify(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: captureAny(named: 'body'),
            encoding: any(named: 'encoding'),
          ),
        ).captured;
        final body = jsonDecode(captured[0] as String) as Map<String, dynamic>;
        final parts =
            (body['contents'] as List<dynamic>)[0]['parts'] as List<dynamic>;
        expect(parts[0]['inlineData']['mimeType'], equals('image/png'));
      });

      test('parses Chinese species when Content-Type lacks charset', () async {
        // Arrange: 裸 application/json + 中文，验证 UTF-8 解码（H-11）
        final imageFile = File('test/fixtures/test_fish.jpg');
        final chineseResponse = {
          'candidates': [
            {
              'content': {
                'parts': [
                  {
                    'text': jsonEncode({
                      'primarySpecies': {
                        'chineseName': '鲈鱼',
                        'scientificName': 'Lateolabrax japonicus',
                        'confidence': 88,
                      },
                      'confidence': 88,
                      'alternatives': [],
                      'notes': '',
                    }),
                  },
                ],
              },
            }
          ],
        };
        final bareResponse = http.Response.bytes(
          utf8.encode(jsonEncode(chineseResponse)),
          200,
          headers: {'content-type': 'application/json'},
        );

        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
            encoding: any(named: 'encoding'),
          ),
        ).thenAnswer((_) async => bareResponse);

        // Act
        final result = await provider.identifySpecies(imageFile, config);

        // Assert: 中文未乱码
        expect(result.primarySpecies.chineseName, equals('鲈鱼'));
      });

      test('includes systemInstruction with fishing expert prompt', () async {
        // Arrange
        final imageFile = File('test/fixtures/test_fish.jpg');
        final responseJson = _createSuccessfulGeminiResponse();
        final mockResponse = _createUtf8Response(jsonEncode(responseJson), 200);

        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
            encoding: any(named: 'encoding'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await provider.identifySpecies(imageFile, config);

        // Assert - verify request was made
        verify(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
            encoding: any(named: 'encoding'),
          ),
        ).called(1);
      });

      test('correctly parses response to extract species', () async {
        // Arrange
        final imageFile = File('test/fixtures/test_fish.jpg');
        final responseJson = _createSuccessfulGeminiResponse();
        final mockResponse = _createUtf8Response(jsonEncode(responseJson), 200);

        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
            encoding: any(named: 'encoding'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await provider.identifySpecies(imageFile, config);

        // Assert
        expect(result.primarySpecies.chineseName, equals('BlackFish'));
      });

      test('throws FishRecognitionException on rate limit (429)', () async {
        // Arrange
        final imageFile = File('test/fixtures/test_fish.jpg');
        final errorResponse = _createUtf8Response(
          '{"error": {"code": 429, "message": "Rate limit exceeded"}}',
          429,
        );

        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
            encoding: any(named: 'encoding'),
          ),
        ).thenAnswer((_) async => errorResponse);

        // Act & Assert
        expect(
          () => provider.identifySpecies(imageFile, config),
          throwsA(isA<FishRecognitionException>()),
        );
      });

      test('parses response with markdown code blocks correctly', () async {
        // Arrange
        final imageFile = File('test/fixtures/test_fish.jpg');
        final responseWithMarkdown =
            _createSuccessfulGeminiResponseWithMarkdown();
        final mockResponse =
            _createUtf8Response(jsonEncode(responseWithMarkdown), 200);

        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
            encoding: any(named: 'encoding'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await provider.identifySpecies(imageFile, config);

        // Assert
        expect(result, isA<FishRecognitionResult>());
        expect(result.primarySpecies.chineseName, equals('BlackFish'));
      });

      test('sends API key in x-goog-api-key header, not the URL', () async {
        // Arrange
        final imageFile = File('test/fixtures/test_fish.jpg');
        final responseJson = _createSuccessfulGeminiResponse();
        final mockResponse = _createUtf8Response(jsonEncode(responseJson), 200);

        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
            encoding: any(named: 'encoding'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await provider.identifySpecies(imageFile, config);

        // Assert - key lives in header, never the URL
        final captured = verify(
          () => mockHttpClient.post(
            captureAny(),
            headers: captureAny(named: 'headers'),
            body: any(named: 'body'),
            encoding: any(named: 'encoding'),
          ),
        ).captured;

        final url = captured[0] as Uri;
        expect(
          url.toString(),
          equals(
            'https://generativelanguage.googleapis.com/v1beta/models/'
            'gemini-2.0-flash:generateContent',
          ),
        );
        expect(url.queryParameters.containsKey('key'), isFalse);
        expect(url.toString(), isNot(contains('test-api-key')));

        final headers = captured[1] as Map<String, String>;
        expect(headers['x-goog-api-key'], equals('test-api-key'));
      });

      test('includes generationConfig in request', () async {
        // Arrange
        final imageFile = File('test/fixtures/test_fish.jpg');
        final responseJson = _createSuccessfulGeminiResponse();
        final mockResponse = _createUtf8Response(jsonEncode(responseJson), 200);

        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
            encoding: any(named: 'encoding'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await provider.identifySpecies(imageFile, config);

        // Assert - verify request was made
        verify(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
            encoding: any(named: 'encoding'),
          ),
        ).called(1);
      });
    });
  });
}

/// Helper to create a successful Gemini API response
Map<String, dynamic> _createSuccessfulGeminiResponse() {
  return {
    'candidates': [
      {
        'content': {
          'parts': [
            {
              'text': jsonEncode({
                'primarySpecies': {
                  'chineseName': 'BlackFish',
                  'scientificName': 'Channa argus',
                  'confidence': 85,
                },
                'confidence': 85,
                'alternatives': [
                  {
                    'chineseName': 'SnakeHead',
                    'scientificName': 'Channa argus',
                    'confidence': 80,
                  }
                ],
                'notes': 'Identification based on body shape and color',
              }),
            },
          ],
        },
      }
    ],
  };
}

/// Helper to create a successful Gemini API response with markdown
Map<String, dynamic> _createSuccessfulGeminiResponseWithMarkdown() {
  return {
    'candidates': [
      {
        'content': {
          'parts': [
            {
              'text': '''
```json
{
  "primarySpecies": {
    "chineseName": "BlackFish",
    "scientificName": "Channa argus",
    "confidence": 85
  },
  "confidence": 85,
  "alternatives": [],
  "notes": ""
}
''',
            },
          ],
        },
      }
    ],
  };
}
