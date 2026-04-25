import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lurebox/core/services/adapters/fish_recognition_shared.dart';
import 'package:lurebox/core/services/fish_recognition_service.dart';

void main() {
  group('extractJsonFromResponse', () {
    test('returns original string when no markdown blocks', () {
      const content = '{"primarySpecies": {"chineseName": "测试"}}';
      expect(extractJsonFromResponse(content), equals(content));
    });

    test('extracts JSON from markdown code block with json language', () {
      const content = '```json\n{"primarySpecies": {"chineseName": "鲈鱼"}}\n```';
      expect(
        extractJsonFromResponse(content),
        equals('{"primarySpecies": {"chineseName": "鲈鱼"}}'),
      );
    });

    test('extracts JSON from markdown code block without language', () {
      const content = '```\n{"primarySpecies": {"chineseName": "鳜鱼"}}\n```';
      expect(
        extractJsonFromResponse(content),
        equals('{"primarySpecies": {"chineseName": "鳜鱼"}}'),
      );
    });

    test('handles content with extra newlines and spaces', () {
      const content = '''
      ```json
      {
        "primarySpecies": {"chineseName": "黑鱼"}
      }
      ```
      ''';
      final result = extractJsonFromResponse(content);
      expect(result.contains('```'), isFalse);
      expect(result.contains('黑鱼'), isTrue);
    });

    test('trims whitespace', () {
      const content = '  \n  {"primarySpecies": {}}  \n  ';
      expect(
        extractJsonFromResponse(content),
        equals('{"primarySpecies": {}}'),
      );
    });
  });

  group('parseHttpStatus', () {
    test('returns null for status 200', () {
      final response = http.Response('OK', 200);
      final (type, message) = parseHttpStatus(response);
      expect(type, isNull);
      expect(message, isNull);
    });

    test('maps 401 to apiKeyInvalid', () {
      final response = http.Response('Unauthorized', 401);
      final (type, message) = parseHttpStatus(response);
      expect(type, equals(FishRecognitionErrorType.apiKeyInvalid));
      expect(message, equals('API 密钥无效或无权限'));
    });

    test('maps 403 to apiKeyInvalid', () {
      final response = http.Response('Forbidden', 403);
      final (type, message) = parseHttpStatus(response);
      expect(type, equals(FishRecognitionErrorType.apiKeyInvalid));
      expect(message, equals('API 密钥无效或无权限'));
    });

    test('maps 429 to rateLimited', () {
      final response = http.Response('Too Many Requests', 429);
      final (type, message) = parseHttpStatus(response);
      expect(type, equals(FishRecognitionErrorType.rateLimited));
      expect(message, equals('请求过于频繁'));
    });

    test('maps 500 to networkError', () {
      final response = http.Response('Internal Server Error', 500);
      final (type, message) = parseHttpStatus(response);
      expect(type, equals(FishRecognitionErrorType.networkError));
      expect(message, equals('服务器错误: 500'));
    });

    test('maps 502 to networkError', () {
      final response = http.Response('Bad Gateway', 502);
      final (type, message) = parseHttpStatus(response);
      expect(type, equals(FishRecognitionErrorType.networkError));
      expect(message, equals('服务器错误: 502'));
    });

    test('maps 503 to networkError', () {
      final response = http.Response('Service Unavailable', 503);
      final (type, message) = parseHttpStatus(response);
      expect(type, equals(FishRecognitionErrorType.networkError));
      expect(message, equals('服务器错误: 503'));
    });

    test('maps 400 to unknown', () {
      final response = http.Response('Bad Request', 400);
      final (type, message) = parseHttpStatus(response);
      expect(type, equals(FishRecognitionErrorType.unknown));
      expect(message, equals('请求错误: 400'));
    });

    test('maps unknown status code to unknown', () {
      final response = http.Response('Unknown', 418);
      final (type, message) = parseHttpStatus(response);
      expect(type, equals(FishRecognitionErrorType.unknown));
      expect(message, equals('未知错误: 418'));
    });
  });

  group('throwHttpError', () {
    test('does not throw for status 200', () {
      final response = http.Response('OK', 200);
      expect(
        () => throwHttpError(response),
        returnsNormally,
      );
    });

    test('throws FishRecognitionException for 401', () {
      final response = http.Response('Unauthorized', 401);
      expect(
        () => throwHttpError(response),
        throwsA(
          isA<FishRecognitionException>().having(
            (e) => e.type,
            'type',
            FishRecognitionErrorType.apiKeyInvalid,
          ),
        ),
      );
    });

    test('throws FishRecognitionException for 500', () {
      final response = http.Response('Internal Server Error', 500);
      expect(
        () => throwHttpError(response),
        throwsA(
          isA<FishRecognitionException>().having(
            (e) => e.type,
            'type',
            FishRecognitionErrorType.networkError,
          ),
        ),
      );
    });

    test('throws FishRecognitionException with correct message', () {
      final response = http.Response('Too Many Requests', 429);
      expect(
        () => throwHttpError(response),
        throwsA(
          isA<FishRecognitionException>().having(
            (e) => e.message,
            'message',
            '请求过于频繁',
          ),
        ),
      );
    });

    test('calls onRateLimited callback when provided for 429', () {
      final response = http.Response('Too Many Requests', 429);
      var callbackCalled = false;
      expect(
        () => throwHttpError(
          response,
          onRateLimited: () => callbackCalled = true,
        ),
        throwsA(isA<FishRecognitionException>()),
      );
      expect(callbackCalled, isTrue);
    });

    test('does not call onRateLimited callback for non-429 errors', () {
      final response = http.Response('Unauthorized', 401);
      var callbackCalled = false;
      expect(
        () => throwHttpError(
          response,
          onRateLimited: () => callbackCalled = true,
        ),
        throwsA(isA<FishRecognitionException>()),
      );
      expect(callbackCalled, isFalse);
    });
  });
}
