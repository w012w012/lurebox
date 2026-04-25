import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/fish_recognition_service.dart';
import 'package:lurebox/core/services/adapters/openai_compatible_provider.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

http.Response createUtf8Response(
  Map<String, dynamic> json,
  int statusCode,
) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(json)),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

Map<String, dynamic> successResponse({
  String chineseName = '鲈鱼',
  String scientificName = 'Lateolabrax japonicus',
  int confidence = 85,
}) {
  final content = jsonEncode({
    'primarySpecies': {
      'chineseName': chineseName,
      'scientificName': scientificName,
      'confidence': confidence,
    },
    'confidence': confidence,
    'alternatives': [],
    'notes': '',
  });
  return {
    'choices': [
      {
        'message': {'role': 'assistant', 'content': content},
      },
    ],
  };
}

/// Runs the shared test suite for any [OpenAICompatibleProvider] subclass.
///
/// Tests HTTP wiring, response parsing, and error handling that are identical
/// across all providers. Provider-specific config tests (defaultBaseUrl,
/// defaultModel, urlPathStrategy) should remain in the individual test files.
void runOpenAICompatibleProviderTests({
  required String providerName,
  required OpenAICompatibleProvider Function(http.Client client) createProvider,
  required AiRecognitionProvider aiProvider,
  required String expectedUrlFragment,
  required String expectedModel,
  String chineseName = '鳜鱼',
  String scientificName = 'Siniperca chuatsi',
  int confidence = 92,
}) {
  late MockHttpClient mockClient;
  late OpenAICompatibleProvider provider;
  late File tempImage;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockClient = MockHttpClient();
    provider = createProvider(mockClient);

    final tempDir = Directory.systemTemp.createTempSync(
      '${providerName}_test_',
    );
    tempImage = File('${tempDir.path}/test.jpg');
    tempImage.writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]);
  });

  tearDown(() {
    if (tempImage.parent.existsSync()) {
      tempImage.parent.deleteSync(recursive: true);
    }
  });

  group('$providerName - shared behavior', () {
    test('sends POST with correct URL, headers, and model', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
          (_) async => createUtf8Response(successResponse(), 200));

      final config = AiProviderConfig(
        provider: aiProvider,
        apiKey: 'test-api-key',
      );

      await provider.identifySpecies(tempImage, config);

      final captured = verify(() => mockClient.post(
            captureAny(),
            headers: captureAny(named: 'headers'),
            body: captureAny(named: 'body'),
          )).captured;

      final url = captured[0] as Uri;
      expect(url.toString(), contains(expectedUrlFragment));
      expect(url.toString(), contains('chat/completions'));

      final headers = captured[1] as Map<String, String>;
      expect(headers['Authorization'], 'Bearer test-api-key');

      final body =
          jsonDecode(captured[2] as String) as Map<String, dynamic>;
      expect(body['model'], expectedModel);
    });

    test('returns parsed species from successful response', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => createUtf8Response(
          successResponse(
            chineseName: chineseName,
            scientificName: scientificName,
            confidence: confidence,
          ),
          200));

      final config = AiProviderConfig(
        provider: aiProvider,
        apiKey: 'key',
      );

      final result = await provider.identifySpecies(tempImage, config);

      expect(result.primarySpecies.chineseName, chineseName);
      expect(result.primarySpecies.scientificName, scientificName);
      expect(result.primarySpecies.confidence, confidence);
    });

    test('throws FishRecognitionException on 401', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
          (_) async => createUtf8Response({'error': 'Unauthorized'}, 401));

      final config = AiProviderConfig(
        provider: aiProvider,
        apiKey: 'bad-key',
      );

      expect(
        () => provider.identifySpecies(tempImage, config),
        throwsA(isA<FishRecognitionException>()),
      );
    });

    test('throws FishRecognitionException on 429', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async =>
          createUtf8Response({'error': 'Rate limited'}, 429));

      final config = AiProviderConfig(
        provider: aiProvider,
        apiKey: 'key',
      );

      expect(
        () => provider.identifySpecies(tempImage, config),
        throwsA(isA<FishRecognitionException>()),
      );
    });

    test('throws FishRecognitionException on 500', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => createUtf8Response(
          {'error': 'Internal Server Error'}, 500));

      final config = AiProviderConfig(
        provider: aiProvider,
        apiKey: 'key',
      );

      expect(
        () => provider.identifySpecies(tempImage, config),
        throwsA(isA<FishRecognitionException>()),
      );
    });
  });
}
