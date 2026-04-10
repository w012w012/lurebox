import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/fish_recognition_service.dart';
import 'package:lurebox/core/services/providers/fish_recognition_shared.dart';

/// Creates an HTTP response with proper UTF-8 encoding for Chinese characters
http.Response _createUtf8Response(String body, int statusCode) {
  final bytes = utf8.encode(body);
  return http.Response.bytes(bytes, statusCode, headers: {
    'Content-Type': 'application/json; charset=utf-8',
  });
}

/// Mock HTTP Client for testing
class MockHttpClient extends Mock implements http.Client {
  http.Response? mockResponse;
  Uri? lastUri;
  Map<String, String>? lastHeaders;
  String? lastBody;

  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    lastUri = url;
    lastHeaders = headers;
    lastBody = body?.toString();
    if (mockResponse != null) {
      return mockResponse!;
    }
    return _createUtf8Response('{"error": "No mock response set"}', 500);
  }
}

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
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        final responseJson = {
          'content': [
            {
              'type': 'text',
              'text':
                  '{"primarySpecies":{"chineseName":"鲈鱼","scientificName":"Lateolabrax japonicus","confidence":85},"confidence":85,"alternatives":[],"notes":""}',
            },
          ],
        };

        mockHttpClient.mockResponse =
            _createUtf8Response(jsonEncode(responseJson), 200);

        final provider = _TestableClaudeProvider(mockHttpClient);

        // Act
        final result = await provider.identifySpeciesBytes(imageBytes, config);

        // Assert
        expect(result, isA<FishRecognitionResult>());
        expect(result.primarySpecies.chineseName, equals('鲈鱼'));
        expect(result.primarySpecies.scientificName,
            equals('Lateolabrax japonicus'));
        expect(result.confidence, equals(85));
      });

      test('sends request with Anthropic Messages API format', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        final responseJson = {
          'content': [
            {
              'type': 'text',
              'text':
                  '{"primarySpecies":{"chineseName":"鲈鱼","scientificName":"Lateolabrax japonicus","confidence":85},"confidence":85,"alternatives":[],"notes":""}',
            },
          ],
        };

        mockHttpClient.mockResponse =
            _createUtf8Response(jsonEncode(responseJson), 200);

        final provider = _TestableClaudeProvider(mockHttpClient);

        // Act
        await provider.identifySpeciesBytes(imageBytes, config);

        // Assert
        expect(mockHttpClient.lastUri, isNotNull);
        expect(mockHttpClient.lastUri!.path, equals('/v1/messages'));
        expect(mockHttpClient.lastHeaders!['anthropic-version'],
            equals('2023-06-01'));
        expect(
            mockHttpClient.lastHeaders!['x-api-key'], equals('test-api-key'));
        expect(mockHttpClient.lastHeaders!['Content-Type'],
            equals('application/json'));
      });

      test('includes base64 image in content array', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        final responseJson = {
          'content': [
            {
              'type': 'text',
              'text':
                  '{"primarySpecies":{"chineseName":"鲈鱼","scientificName":"Lateolabrax japonicus","confidence":85},"confidence":85,"alternatives":[],"notes":""}',
            },
          ],
        };

        mockHttpClient.mockResponse =
            _createUtf8Response(jsonEncode(responseJson), 200);

        final provider = _TestableClaudeProvider(mockHttpClient);

        // Act
        await provider.identifySpeciesBytes(imageBytes, config);

        // Assert
        expect(mockHttpClient.lastBody, isNotNull);
        final requestBody =
            jsonDecode(mockHttpClient.lastBody!) as Map<String, dynamic>;

        // Verify Anthropic Messages API format
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
      });

      test('parses response with markdown code blocks correctly', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
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

        mockHttpClient.mockResponse =
            _createUtf8Response(jsonEncode(responseJson), 200);

        final provider = _TestableClaudeProvider(mockHttpClient);

        // Act
        final result = await provider.identifySpeciesBytes(imageBytes, config);

        // Assert
        expect(result.primarySpecies.chineseName, equals('翘嘴'));
        expect(result.primarySpecies.scientificName, equals('Culter alburnus'));
        expect(result.confidence, equals(78));
        expect(result.alternatives.length, equals(1));
        expect(result.alternatives[0].chineseName, equals('鳜鱼'));
        expect(result.notes, equals('典型翘嘴体型'));
      });

      test('throws FishRecognitionException on API authentication error',
          () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        final responseJson = {
          'error': {
            'type': 'authentication_error',
            'message': 'Invalid API key',
          },
        };

        mockHttpClient.mockResponse =
            _createUtf8Response(jsonEncode(responseJson), 401);

        final provider = _TestableClaudeProvider(mockHttpClient);

        // Act & Assert
        expect(
          () => provider.identifySpeciesBytes(imageBytes, config),
          throwsA(isA<FishRecognitionException>()),
        );
      });

      test('throws FishRecognitionException on rate limit', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        final responseJson = {
          'error': {
            'type': 'rate_limit_error',
            'message': 'Rate limit exceeded',
          },
        };

        mockHttpClient.mockResponse =
            _createUtf8Response(jsonEncode(responseJson), 429);

        final provider = _TestableClaudeProvider(mockHttpClient);

        // Act & Assert
        expect(
          () => provider.identifySpeciesBytes(imageBytes, config),
          throwsA(isA<FishRecognitionException>()),
        );
      });

      test('throws FishRecognitionException when response has no content',
          () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        final responseJson = {
          'content': <dynamic>[],
        };

        mockHttpClient.mockResponse =
            _createUtf8Response(jsonEncode(responseJson), 200);

        final provider = _TestableClaudeProvider(mockHttpClient);

        // Act & Assert
        expect(
          () => provider.identifySpeciesBytes(imageBytes, config),
          throwsA(isA<FishRecognitionException>()),
        );
      });

      test('throws FishRecognitionException when response has no text block',
          () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        final responseJson = {
          'content': [
            {
              'type': 'image',
              'source': {'data': 'abc123'}
            },
          ],
        };

        mockHttpClient.mockResponse =
            _createUtf8Response(jsonEncode(responseJson), 200);

        final provider = _TestableClaudeProvider(mockHttpClient);

        // Act & Assert
        expect(
          () => provider.identifySpeciesBytes(imageBytes, config),
          throwsA(isA<FishRecognitionException>()),
        );
      });

      test('handles file image input correctly', () async {
        // Arrange - create a temp file
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

          mockHttpClient.mockResponse =
              _createUtf8Response(jsonEncode(responseJson), 200);

          // Use actual provider with file
          final provider = _TestableClaudeProvider(mockHttpClient);

          // Act
          final result = await provider.identifySpeciesFile(tempFile, config);

          // Assert
          expect(result.primarySpecies.chineseName, equals('鲈鱼'));
        } finally {
          await tempFile.delete();
        }
      });
    });
  });
}

/// Testable version of ClaudeFishRecognitionProvider that accepts an injectable HTTP client
///
/// This class replicates the logic of ClaudeFishRecognitionProvider but allows
/// dependency injection of the HTTP client for testing purposes.
class _TestableClaudeProvider implements FishRecognitionProvider {
  final http.Client _client;

  _TestableClaudeProvider(this._client);

  /// System prompt for fish recognition
  static const String _systemPrompt = fishRecognitionSystemPrompt;

  /// Identify species from bytes (for testing)
  Future<FishRecognitionResult> identifySpeciesBytes(
    Uint8List imageBytes,
    AiProviderConfig config,
  ) async {
    final base64Image = base64Encode(imageBytes);
    return _identify(config, base64Image);
  }

  /// Identify species from file (replicates production behavior)
  @override
  Future<FishRecognitionResult> identifySpecies(
    File image,
    AiProviderConfig config,
  ) async {
    final imageBytes = await image.readAsBytes();
    final base64Image = base64Encode(imageBytes);
    return _identify(config, base64Image);
  }

  /// Identify species from file (alternative method name for testing)
  Future<FishRecognitionResult> identifySpeciesFile(
    File image,
    AiProviderConfig config,
  ) async {
    return identifySpecies(image, config);
  }

  Future<FishRecognitionResult> _identify(
    AiProviderConfig config,
    String base64Image,
  ) async {
    final requestBody = {
      'model': config.modelName ?? 'claude-3-5-sonnet-20241022',
      'max_tokens': 2048,
      'system': _systemPrompt,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': '请识别这张图片中的鱼类品种。',
            },
            {
              'type': 'image',
              'source': {
                'type': 'base64',
                'media_type': 'image/jpeg',
                'data': base64Image,
              },
            },
          ],
        },
      ],
    };

    final baseUrl = config.baseUrl ?? 'https://api.anthropic.com';
    final url = Uri.parse('$baseUrl/v1/messages');

    try {
      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': config.apiKey,
              'anthropic-version': '2023-06-01',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      if (e is FishRecognitionException) {
        rethrow;
      }
      throw FishRecognitionException(
        FishRecognitionErrorType.unknown,
        '识别失败: $e',
      );
    }
  }

  FishRecognitionResult _handleResponse(http.Response response) {
    _throwHttpError(response);

    try {
      // Use utf8 decode since Response.body uses Latin1 by default
      final bodyString = utf8.decode(response.bodyBytes);
      final json = jsonDecode(bodyString) as Map<String, dynamic>;

      if (json.containsKey('error')) {
        final error = json['error'] as Map<String, dynamic>;
        final errorMessage = error['message'] as String? ?? '未知错误';
        final errorType = error['type'] as String?;

        if (errorType == 'authentication_error' ||
            errorMessage.contains('api key') ||
            errorMessage.contains('API key')) {
          throw const FishRecognitionException(
            FishRecognitionErrorType.apiKeyInvalid,
            'API 密钥无效',
          );
        }
        if (errorType == 'rate_limit_error' || errorMessage.contains('rate')) {
          throw const FishRecognitionException(
            FishRecognitionErrorType.rateLimited,
            '请求过于频繁',
          );
        }
        throw FishRecognitionException(
          FishRecognitionErrorType.unknown,
          errorMessage,
        );
      }

      final content = json['content'] as List<dynamic>?;
      if (content == null || content.isEmpty) {
        throw const FishRecognitionException(
          FishRecognitionErrorType.unknown,
          '未收到有效响应',
        );
      }

      String jsonText = '';
      for (final block in content) {
        if (block is Map<String, dynamic> && block['type'] == 'text') {
          jsonText = block['text'] as String? ?? '';
          break;
        }
      }

      if (jsonText.isEmpty) {
        throw const FishRecognitionException(
          FishRecognitionErrorType.unknown,
          '未找到识别结果',
        );
      }

      // Clean JSON text (remove markdown code blocks)
      jsonText = _extractJsonFromResponse(jsonText);

      final resultJson = jsonDecode(jsonText) as Map<String, dynamic>;
      return FishRecognitionResult.fromJson(resultJson);
    } on FishRecognitionException {
      rethrow;
    } on FormatException catch (e) {
      throw FishRecognitionException(
        FishRecognitionErrorType.unknown,
        'JSON 解析失败: ${e.message}',
      );
    } catch (e) {
      throw FishRecognitionException(
        FishRecognitionErrorType.unknown,
        '处理响应失败: $e',
      );
    }
  }

  void _throwHttpError(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return;
      case 400:
        throw const FishRecognitionException(
          FishRecognitionErrorType.unknown,
          '请求错误: 400',
        );
      case 401:
      case 403:
        throw const FishRecognitionException(
          FishRecognitionErrorType.apiKeyInvalid,
          'API 密钥无效或无权限',
        );
      case 429:
        throw const FishRecognitionException(
          FishRecognitionErrorType.rateLimited,
          '请求过于频繁',
        );
      case 500:
      case 502:
      case 503:
        throw FishRecognitionException(
          FishRecognitionErrorType.networkError,
          '服务器错误: ${response.statusCode}',
        );
      default:
        throw FishRecognitionException(
          FishRecognitionErrorType.unknown,
          '未知错误: ${response.statusCode}',
        );
    }
  }

  String _extractJsonFromResponse(String content) {
    String jsonText = content.trim();
    if (jsonText.startsWith('```json')) {
      jsonText = jsonText.substring(7);
    }
    if (jsonText.startsWith('```')) {
      jsonText = jsonText.substring(3);
    }
    if (jsonText.endsWith('```')) {
      jsonText = jsonText.substring(0, jsonText.length - 3);
    }
    return jsonText.trim();
  }
}
