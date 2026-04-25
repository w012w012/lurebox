import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lurebox/core/services/adapters/fish_recognition_shared.dart';
import 'package:lurebox/core/services/fish_recognition_service.dart';

void main() {
  group('extractJsonFromResponse', () {
    test('returns plain JSON as-is', () {
      const content = '{"primarySpecies": {"chineseName": "鲈鱼"}}';
      expect(extractJsonFromResponse(content), equals(content));
    });

    test('returns already trimmed JSON as-is', () {
      const content = '{"primarySpecies": {"chineseName": "鳜鱼"}}';
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

    test('preserves surrounding text when content does not start with code block',
        () {
      const content =
          '根据图片分析，识别结果如下：```json\n{"primarySpecies": {"chineseName": "黑鱼"}}\n```\n以上结果供参考';
      final result = extractJsonFromResponse(content);
      // Function strips only leading/trailing code blocks, preserves surrounding text
      expect(result.contains('黑鱼'), isTrue);
      expect(result.contains('根据图片分析'), isTrue);
      expect(result.contains('以上结果供参考'), isTrue);
      expect(result.contains('```'), isTrue); // internal ``` not stripped
    });

    test('returns empty string for empty input', () {
      const content = '';
      expect(extractJsonFromResponse(content), equals(''));
    });

    test('trims whitespace from plain JSON', () {
      const content = '  \n  {"primarySpecies": {}}  \n  ';
      expect(extractJsonFromResponse(content), equals('{"primarySpecies": {}}'));
    });

    test('handles extra newlines and spaces in markdown block', () {
      const content = '''
      ```json
      {
        "primarySpecies": {"chineseName": "翘嘴"}
      }
      ```
      ''';
      final result = extractJsonFromResponse(content);
      expect(result.contains('```'), isFalse);
      expect(result.contains('翘嘴'), isTrue);
    });

    test('extracts JSON when content starts with ```json', () {
      const content = '```json\n{"data": "test"}\n```';
      expect(extractJsonFromResponse(content), equals('{"data": "test"}'));
    });

    test('extracts JSON when content starts with plain ```', () {
      const content = '```\n{"data": "test"}\n```';
      expect(extractJsonFromResponse(content), equals('{"data": "test"}'));
    });
  });

  group('parseHttpStatus', () {
    test('returns null type and message for status 200', () {
      final response = http.Response('OK', 200);
      final (type, message) = parseHttpStatus(response);
      expect(type, isNull);
      expect(message, isNull);
    });

    test('maps 400 to unknown error', () {
      final response = http.Response('Bad Request', 400);
      final (type, message) = parseHttpStatus(response);
      expect(type, equals(FishRecognitionErrorType.unknown));
      expect(message, equals('请求错误: 400'));
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

    test('maps unknown status code to unknown', () {
      final response = http.Response('Unknown', 418);
      final (type, message) = parseHttpStatus(response);
      expect(type, equals(FishRecognitionErrorType.unknown));
      expect(message, equals('未知错误: 418'));
    });

    test('maps 404 to unknown', () {
      final response = http.Response('Not Found', 404);
      final (type, message) = parseHttpStatus(response);
      expect(type, equals(FishRecognitionErrorType.unknown));
      expect(message, equals('未知错误: 404'));
    });
  });

  group('throwHttpError', () {
    test('does not throw for status 200', () {
      final response = http.Response('OK', 200);
      expect(() => throwHttpError(response), returnsNormally);
    });

    test('throws FishRecognitionException for 400', () {
      final response = http.Response('Bad Request', 400);
      expect(
        () => throwHttpError(response),
        throwsA(isA<FishRecognitionException>()),
      );
    });

    test('throws FishRecognitionException for 401 with apiKeyInvalid type',
        () {
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

    test('throws FishRecognitionException for 403 with apiKeyInvalid type',
        () {
      final response = http.Response('Forbidden', 403);
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

    test('throws FishRecognitionException for 429 with rateLimited type',
        () {
      final response = http.Response('Too Many Requests', 429);
      expect(
        () => throwHttpError(response),
        throwsA(
          isA<FishRecognitionException>().having(
            (e) => e.type,
            'type',
            FishRecognitionErrorType.rateLimited,
          ),
        ),
      );
    });

    test('throws FishRecognitionException for 500 with networkError type',
        () {
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

    test('exception message contains error code for 500', () {
      final response = http.Response('Internal Server Error', 500);
      expect(
        () => throwHttpError(response),
        throwsA(
          isA<FishRecognitionException>().having(
            (e) => e.message,
            'message',
            '服务器错误: 500',
          ),
        ),
      );
    });

    test('exception message contains error code for 429', () {
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

    test('does not call onRateLimited callback for 401', () {
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

    test('does not call onRateLimited callback for 500', () {
      final response = http.Response('Internal Server Error', 500);
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

    test('FishRecognitionException toString includes type and message', () {
      final response = http.Response('Too Many Requests', 429);
      try {
        throwHttpError(response);
        fail('Expected exception to be thrown');
      } on FishRecognitionException catch (e) {
        expect(e.toString(), contains('rateLimited'));
        expect(e.toString(), contains('请求过于频繁'));
      }
    });
  });
}
