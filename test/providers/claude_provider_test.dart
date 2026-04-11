import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/fish_recognition_service.dart';
import 'package:lurebox/core/services/providers/claude_provider.dart';

/// Creates an HTTP response with proper UTF-8 encoding for Chinese characters
http.Response _createUtf8Response(String body, int statusCode) {
  final bytes = utf8.encode(body);
  return http.Response.bytes(bytes, statusCode, headers: {
    'Content-Type': 'application/json; charset=utf-8',
  });
}

/// Mock HTTP Client for testing
class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient mockHttpClient;
  late AiProviderConfig config;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    config = const AiProviderConfig(
      provider: AiRecognitionProvider.claude,
      apiKey: 'test-api-key',
      baseUrl: 'https://api.anthropic.com',
      modelName: 'claude-3-5-sonnet-20241022',
      enabled: true,
    );
  });

  group('ClaudeFishRecognitionProvider', () {
    group('identifySpecies', () {
      test('returns FishRecognitionResult on successful response', () async {
        // Arrange
        final tempDir = Directory.systemTemp;
        final tempFile = File(
            '${tempDir.path}/test_fish_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes([1, 2, 3, 4, 5]);

        try {
          final responseJson = {
            'content': [
              {
                'type': 'text',
                'text':
                    '{"primarySpecies":{"chineseName":"鲈鱼","scientificName":"Lateolabrax japonicus","confidence":85},"confidence":85,"alternatives":[],"notes":""}',
              },
            ],
          };

          when(() => mockHttpClient.post(
                any(),
                headers: any(named: 'headers'),
                body: any(named: 'body'),
              )).thenAnswer((_) async =>
              _createUtf8Response(jsonEncode(responseJson), 200));

          final provider = ClaudeFishRecognitionProvider(client: mockHttpClient);

          // Act
          final result = await provider.identifySpecies(tempFile, config);

          // Assert
          expect(result, isA<FishRecognitionResult>());
          expect(result.primarySpecies.chineseName, equals('鲈鱼'));
          expect(result.primarySpecies.scientificName,
              equals('Lateolabrax japonicus'));
          expect(result.confidence, equals(85));
        } finally {
          await tempFile.delete();
        }
      });

      test('sends request with Anthropic Messages API format', () async {
        // Arrange
        final tempDir = Directory.systemTemp;
        final tempFile = File(
            '${tempDir.path}/test_fish_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes([1, 2, 3, 4, 5]);

        try {
          final responseJson = {
            'content': [
              {
                'type': 'text',
                'text':
                    '{"primarySpecies":{"chineseName":"鲈鱼","scientificName":"Lateolabrax japonicus","confidence":85},"confidence":85,"alternatives":[],"notes":""}',
              },
            ],
          };

          when(() => mockHttpClient.post(
                any(),
                headers: any(named: 'headers'),
                body: any(named: 'body'),
              )).thenAnswer((_) async =>
              _createUtf8Response(jsonEncode(responseJson), 200));

          final provider = ClaudeFishRecognitionProvider(client: mockHttpClient);

          // Act
          await provider.identifySpecies(tempFile, config);

          // Assert
          final captured = verify(() => mockHttpClient.post(
                captureAny(),
                headers: captureAny(named: 'headers'),
                body: captureAny(named: 'body'),
              )).captured;

          final uri = captured[0] as Uri;
          final headers = captured[1] as Map<String, String>;
          final body = captured[2] as String;

          expect(uri.path, equals('/v1/messages'));
          expect(headers['anthropic-version'], equals('2023-06-01'));
          expect(headers['x-api-key'], equals('test-api-key'));
          expect(headers['Content-Type'], equals('application/json'));

          // Verify request body
          final requestBody = jsonDecode(body) as Map<String, dynamic>;
          expect(requestBody['model'], equals('claude-3-5-sonnet-20241022'));
          expect(requestBody['max_tokens'], equals(2048));
          expect(requestBody.containsKey('system'), isTrue);

          final messages = requestBody['messages'] as List<dynamic>;
          expect(messages.length, equals(1));

          final message = messages[0] as Map<String, dynamic>;
          expect(message['role'], equals('user'));

          final content = message['content'] as List<dynamic>;
          expect(content.length, equals(2));

          // First content item is text
          final textContent = content[0] as Map<String, dynamic>;
          expect(textContent['type'], equals('text'));
          expect(textContent['text'], equals('请识别这张图片中的鱼类品种。'));

          // Second content item is image with base64 source
          final imageContent = content[1] as Map<String, dynamic>;
          expect(imageContent['type'], equals('image'));

          final source = imageContent['source'] as Map<String, dynamic>;
          expect(source['type'], equals('base64'));
          expect(source['media_type'], equals('image/jpeg'));
          expect(source['data'], isA<String>());
          expect((source['data'] as String).isNotEmpty, isTrue);
        } finally {
          await tempFile.delete();
        }
      });

      test('parses response with markdown code blocks correctly', () async {
        // Arrange
        final tempDir = Directory.systemTemp;
        final tempFile = File(
            '${tempDir.path}/test_fish_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes([1, 2, 3, 4, 5]);

        try {
          final responseJson = {
            'content': [
              {
                'type': 'text',
                'text': '''
```json
{"primarySpecies":{"chineseName":"翘嘴","scientificName":"Culter alburnus","confidence":78},"confidence":78,"alternatives":[{"chineseName":"鳜鱼","scientificName":"Siniperca chuatsi","confidence":60}],"notes":"典型翘嘴体型"}
```
''',
              },
            ],
          };

          when(() => mockHttpClient.post(
                any(),
                headers: any(named: 'headers'),
                body: any(named: 'body'),
              )).thenAnswer((_) async =>
              _createUtf8Response(jsonEncode(responseJson), 200));

          final provider = ClaudeFishRecognitionProvider(client: mockHttpClient);

          // Act
          final result = await provider.identifySpecies(tempFile, config);

          // Assert
          expect(result.primarySpecies.chineseName, equals('翘嘴'));
          expect(result.primarySpecies.scientificName,
              equals('Culter alburnus'));
          expect(result.confidence, equals(78));
          expect(result.alternatives.length, equals(1));
          expect(result.alternatives[0].chineseName, equals('鳜鱼'));
          expect(result.notes, equals('典型翘嘴体型'));
        } finally {
          await tempFile.delete();
        }
      });

      test('throws FishRecognitionException on API authentication error',
          () async {
        // Arrange
        final tempDir = Directory.systemTemp;
        final tempFile = File(
            '${tempDir.path}/test_fish_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes([1, 2, 3, 4, 5]);

        try {
          final responseJson = {
            'error': {
              'type': 'authentication_error',
              'message': 'Invalid API key',
            },
          };

          when(() => mockHttpClient.post(
                any(),
                headers: any(named: 'headers'),
                body: any(named: 'body'),
              )).thenAnswer((_) async =>
              _createUtf8Response(jsonEncode(responseJson), 401));

          final provider = ClaudeFishRecognitionProvider(client: mockHttpClient);

          // Act & Assert
          expect(
            () => provider.identifySpecies(tempFile, config),
            throwsA(isA<FishRecognitionException>()),
          );
        } finally {
          await tempFile.delete();
        }
      });

      test('throws FishRecognitionException on rate limit', () async {
        // Arrange
        final tempDir = Directory.systemTemp;
        final tempFile = File(
            '${tempDir.path}/test_fish_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes([1, 2, 3, 4, 5]);

        try {
          final responseJson = {
            'error': {
              'type': 'rate_limit_error',
              'message': 'Rate limit exceeded',
            },
          };

          when(() => mockHttpClient.post(
                any(),
                headers: any(named: 'headers'),
                body: any(named: 'body'),
              )).thenAnswer((_) async =>
              _createUtf8Response(jsonEncode(responseJson), 429));

          final provider = ClaudeFishRecognitionProvider(client: mockHttpClient);

          // Act & Assert
          expect(
            () => provider.identifySpecies(tempFile, config),
            throwsA(isA<FishRecognitionException>()),
          );
        } finally {
          await tempFile.delete();
        }
      });

      test('throws FishRecognitionException when response has no content',
          () async {
        // Arrange
        final tempDir = Directory.systemTemp;
        final tempFile = File(
            '${tempDir.path}/test_fish_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes([1, 2, 3, 4, 5]);

        try {
          final responseJson = {
            'content': <dynamic>[],
          };

          when(() => mockHttpClient.post(
                any(),
                headers: any(named: 'headers'),
                body: any(named: 'body'),
              )).thenAnswer((_) async =>
              _createUtf8Response(jsonEncode(responseJson), 200));

          final provider = ClaudeFishRecognitionProvider(client: mockHttpClient);

          // Act & Assert
          expect(
            () => provider.identifySpecies(tempFile, config),
            throwsA(isA<FishRecognitionException>()),
          );
        } finally {
          await tempFile.delete();
        }
      });

      test('throws FishRecognitionException when response has no text block',
          () async {
        // Arrange
        final tempDir = Directory.systemTemp;
        final tempFile = File(
            '${tempDir.path}/test_fish_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes([1, 2, 3, 4, 5]);

        try {
          final responseJson = {
            'content': [
              {
                'type': 'image',
                'source': {'data': 'abc123'}
              },
            ],
          };

          when(() => mockHttpClient.post(
                any(),
                headers: any(named: 'headers'),
                body: any(named: 'body'),
              )).thenAnswer((_) async =>
              _createUtf8Response(jsonEncode(responseJson), 200));

          final provider = ClaudeFishRecognitionProvider(client: mockHttpClient);

          // Act & Assert
          expect(
            () => provider.identifySpecies(tempFile, config),
            throwsA(isA<FishRecognitionException>()),
          );
        } finally {
          await tempFile.delete();
        }
      });

      test('throws FishRecognitionException on HTTP 400', () async {
        // Arrange
        final tempDir = Directory.systemTemp;
        final tempFile = File(
            '${tempDir.path}/test_fish_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes([1, 2, 3, 4, 5]);

        try {
          when(() => mockHttpClient.post(
                any(),
                headers: any(named: 'headers'),
                body: any(named: 'body'),
              )).thenAnswer(
              (_) async => _createUtf8Response('Bad Request', 400));

          final provider = ClaudeFishRecognitionProvider(client: mockHttpClient);

          // Act & Assert
          expect(
            () => provider.identifySpecies(tempFile, config),
            throwsA(isA<FishRecognitionException>()),
          );
        } finally {
          await tempFile.delete();
        }
      });

      test('throws FishRecognitionException on HTTP 500', () async {
        // Arrange
        final tempDir = Directory.systemTemp;
        final tempFile = File(
            '${tempDir.path}/test_fish_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes([1, 2, 3, 4, 5]);

        try {
          when(() => mockHttpClient.post(
                any(),
                headers: any(named: 'headers'),
                body: any(named: 'body'),
              )).thenAnswer(
              (_) async => _createUtf8Response('Server Error', 500));

          final provider = ClaudeFishRecognitionProvider(client: mockHttpClient);

          // Act & Assert
          expect(
            () => provider.identifySpecies(tempFile, config),
            throwsA(isA<FishRecognitionException>()),
          );
        } finally {
          await tempFile.delete();
        }
      });

      test('uses custom baseUrl from config', () async {
        // Arrange
        final tempDir = Directory.systemTemp;
        final tempFile = File(
            '${tempDir.path}/test_fish_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes([1, 2, 3, 4, 5]);

        final customConfig = const AiProviderConfig(
          provider: AiRecognitionProvider.claude,
          apiKey: 'test-api-key',
          baseUrl: 'https://custom.anthropic.com',
          modelName: 'claude-3-5-sonnet-20241022',
          enabled: true,
        );

        try {
          final responseJson = {
            'content': [
              {
                'type': 'text',
                'text':
                    '{"primarySpecies":{"chineseName":"鲈鱼","scientificName":"Lateolabrax japonicus","confidence":85},"confidence":85,"alternatives":[],"notes":""}',
              },
            ],
          };

          when(() => mockHttpClient.post(
                any(),
                headers: any(named: 'headers'),
                body: any(named: 'body'),
              )).thenAnswer((_) async =>
              _createUtf8Response(jsonEncode(responseJson), 200));

          final provider = ClaudeFishRecognitionProvider(client: mockHttpClient);

          // Act
          await provider.identifySpecies(tempFile, customConfig);

          // Assert
          final captured = verify(() => mockHttpClient.post(
                captureAny(),
                headers: any(named: 'headers'),
                body: any(named: 'body'),
              )).captured;

          final uri = captured[0] as Uri;
          expect(uri.host, equals('custom.anthropic.com'));
          expect(uri.path, equals('/v1/messages'));
        } finally {
          await tempFile.delete();
        }
      });

      test('uses default model when modelName is null', () async {
        // Arrange
        final tempDir = Directory.systemTemp;
        final tempFile = File(
            '${tempDir.path}/test_fish_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes([1, 2, 3, 4, 5]);

        final configWithNullModel = const AiProviderConfig(
          provider: AiRecognitionProvider.claude,
          apiKey: 'test-api-key',
          baseUrl: 'https://api.anthropic.com',
          modelName: null,
          enabled: true,
        );

        try {
          final responseJson = {
            'content': [
              {
                'type': 'text',
                'text':
                    '{"primarySpecies":{"chineseName":"鲈鱼","scientificName":"Lateolabrax japonicus","confidence":85},"confidence":85,"alternatives":[],"notes":""}',
              },
            ],
          };

          when(() => mockHttpClient.post(
                any(),
                headers: any(named: 'headers'),
                body: any(named: 'body'),
              )).thenAnswer((_) async =>
              _createUtf8Response(jsonEncode(responseJson), 200));

          final provider = ClaudeFishRecognitionProvider(client: mockHttpClient);

          // Act
          await provider.identifySpecies(tempFile, configWithNullModel);

          // Assert
          final captured = verify(() => mockHttpClient.post(
                captureAny(),
                headers: captureAny(named: 'headers'),
                body: captureAny(named: 'body'),
              )).captured;

          final body = captured[2] as String;
          final requestBody = jsonDecode(body) as Map<String, dynamic>;
          expect(requestBody['model'], equals('claude-3-5-sonnet-20241022'));
        } finally {
          await tempFile.delete();
        }
      });

      test('parses alternatives from response', () async {
        // Arrange
        final tempDir = Directory.systemTemp;
        final tempFile = File(
            '${tempDir.path}/test_fish_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes([1, 2, 3, 4, 5]);

        try {
          final responseJson = {
            'content': [
              {
                'type': 'text',
                'text':
                    '{"primarySpecies":{"chineseName":"鲈鱼","scientificName":"Lateolabrax japonicus","confidence":85},"confidence":85,"alternatives":[{"chineseName":"黑鱼","scientificName":"Channa argus","confidence":60},{"chineseName":"鳜鱼","scientificName":"Siniperca chuatsi","confidence":45}],"notes":""}',
              },
            ],
          };

          when(() => mockHttpClient.post(
                any(),
                headers: any(named: 'headers'),
                body: any(named: 'body'),
              )).thenAnswer((_) async =>
              _createUtf8Response(jsonEncode(responseJson), 200));

          final provider = ClaudeFishRecognitionProvider(client: mockHttpClient);

          // Act
          final result = await provider.identifySpecies(tempFile, config);

          // Assert
          expect(result.alternatives.length, equals(2));
          expect(result.alternatives[0].chineseName, equals('黑鱼'));
          expect(result.alternatives[0].scientificName, equals('Channa argus'));
          expect(result.alternatives[0].confidence, equals(60));
          expect(result.alternatives[1].chineseName, equals('鳜鱼'));
          expect(result.alternatives[1].scientificName,
              equals('Siniperca chuatsi'));
          expect(result.alternatives[1].confidence, equals(45));
        } finally {
          await tempFile.delete();
        }
      });
    });
  });
}
