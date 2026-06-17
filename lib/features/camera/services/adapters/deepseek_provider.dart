import 'dart:io';

import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/fish_recognition_service.dart';

/// DeepSeek 鱼类识别提供者
///
/// DeepSeek 暂不支持视觉识别功能，调用时会抛出异常
class DeepSeekFishRecognitionProvider implements FishRecognitionProvider {
  @override
  Future<FishRecognitionResult> identifySpecies(
    File image,
    AiProviderConfig config,
  ) async {
    // DeepSeek 暂不支持视觉识别，抛出异常
    throw const FishRecognitionException(
      FishRecognitionErrorType.unknown,
      '暂不支持视觉识别',
    );
  }
}
