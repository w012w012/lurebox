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

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
              encoding: any(named: 'encoding'),
            ),).thenAnswer((_) async => mockResponse);

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

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
              encoding: any(named: 'encoding'),
            ),).thenAnswer((_) async => mockResponse);

        // Act
        await provider.identifySpecies(imageFile, config);

        // Assert - verify request was made with inlineData
        verify(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
              encoding: any(named: 'encoding'),
            ),).called(1);
      });

      test('includes systemInstruction with fishing expert prompt', () async {
        // Arrange
        final imageFile = File('test/fixtures/test_fish.jpg');
        final responseJson = _createSuccessfulGeminiResponse();
        final mockResponse = _createUtf8Response(jsonEncode(responseJson), 200);

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
              encoding: any(named: 'encoding'),
            ),).thenAnswer((_) async => mockResponse);

        // Act
        await provider.identifySpecies(imageFile, config);

        // Assert - verify request was made
        verify(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
              encoding: any(named: 'encoding'),
            ),).called(1);
      });

      test('correctly parses response to extract species', () async {
        // Arrange
        final imageFile = File('test/fixtures/test_fish.jpg');
        final responseJson = _createSuccessfulGeminiResponse();
        final mockResponse = _createUtf8Response(jsonEncode(responseJson), 200);

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
              encoding: any(named: 'encoding'),
            ),).thenAnswer((_) async => mockResponse);

        // Act
        final result = await provider.identifySpecies(imageFile, config);

        // Assert
        expect(result.primarySpecies.chineseName, equals('BlackFish'));
      });

      test('throws FishRecognitionException on rate limit (429)', () async {
        // Arrange
        final imageFile = File('test/fixtures/test_fish.jpg');
        final errorResponse = _createUtf8Response(
            '{"error": {"code": 429, "message": "Rate limit exceeded"}}', 429,);

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
              encoding: any(named: 'encoding'),
            ),).thenAnswer((_) async => errorResponse);

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

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
              encoding: any(named: 'encoding'),
            ),).thenAnswer((_) async => mockResponse);

        // Act
        final result = await provider.identifySpecies(imageFile, config);

        // Assert
        expect(result, isA<FishRecognitionResult>());
        expect(result.primarySpecies.chineseName, equals('BlackFish'));
      });

      test('uses correct URL format for Gemini API', () async {
        // Arrange
        final imageFile = File('test/fixtures/test_fish.jpg');
        final responseJson = _createSuccessfulGeminiResponse();
        final mockResponse = _createUtf8Response(jsonEncode(responseJson), 200);

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
              encoding: any(named: 'encoding'),
            ),).thenAnswer((_) async => mockResponse);

        // Act
        await provider.identifySpecies(imageFile, config);

        // Assert - verify URL contains correct format
        verify(() => mockHttpClient.post(
              Uri.parse(
                  'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=test-api-key',),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
              encoding: any(named: 'encoding'),
            ),).called(1);
      });

      test('includes generationConfig in request', () async {
        // Arrange
        final imageFile = File('test/fixtures/test_fish.jpg');
        final responseJson = _createSuccessfulGeminiResponse();
        final mockResponse = _createUtf8Response(jsonEncode(responseJson), 200);

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
              encoding: any(named: 'encoding'),
            ),).thenAnswer((_) async => mockResponse);

        // Act
        await provider.identifySpecies(imageFile, config);

        // Assert - verify request was made
        verify(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
              encoding: any(named: 'encoding'),
            ),).called(1);
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
