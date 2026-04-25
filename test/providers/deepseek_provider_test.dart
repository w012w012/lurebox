import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/adapters/deepseek_provider.dart';
import 'package:lurebox/core/services/fish_recognition_service.dart';

void main() {
  group('DeepSeekFishRecognitionProvider', () {
    late DeepSeekFishRecognitionProvider provider;
    late File tempImage;

    setUp(() {
      provider = DeepSeekFishRecognitionProvider();
      final tempDir = Directory.systemTemp.createTempSync('deepseek_test_');
      tempImage = File('${tempDir.path}/test.jpg');
      tempImage.writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]);
    });

    tearDown(() {
      if (tempImage.parent.existsSync()) {
        tempImage.parent.deleteSync(recursive: true);
      }
    });

    test('throws FishRecognitionException because vision is unsupported',
        () async {
      final config = AiProviderConfig(
        provider: AiRecognitionProvider.deepseek,
        apiKey: 'test-key',
      );

      expect(
        () => provider.identifySpecies(tempImage, config),
        throwsA(isA<FishRecognitionException>()),
      );
    });

    test('exception has unknown error type', () async {
      final config = AiProviderConfig(
        provider: AiRecognitionProvider.deepseek,
        apiKey: 'test-key',
      );

      try {
        await provider.identifySpecies(tempImage, config);
        fail('Should have thrown');
      } on FishRecognitionException catch (e) {
        expect(e.type, FishRecognitionErrorType.unknown);
      }
    });
  });
}
