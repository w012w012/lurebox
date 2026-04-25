import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/adapters/fish_recognition_shared.dart';
import 'package:lurebox/core/services/adapters/openai_compatible_provider.dart';
import 'package:lurebox/core/services/app_logger.dart';
import 'package:lurebox/core/services/fish_recognition_service.dart';

/// 自定义 鱼类识别提供者
///
/// 使用 OpenAI 兼容接口进行鱼类识别
/// 支持用户自定义 Base URL 和 Model Name
class CustomFishRecognitionProvider extends OpenAICompatibleProvider {
  /// Creates a Custom provider with optional HTTP client injection
  CustomFishRecognitionProvider({super.client});

  @override
  String get defaultBaseUrl => '';

  @override
  String get defaultModel => '';

  @override
  UrlPathStrategy get urlPathStrategy => UrlPathStrategy.custom;

  @override
  String get systemPrompt => fishRecognitionSystemPrompt;

  @override
  Uri buildUrl(String baseUrl) {
    // 智能处理：如果 baseUrl 已包含 /chat/completions 则直接使用
    // 否则自动追加 /v1/chat/completions
    if (baseUrl.endsWith('/chat/completions')) {
      // 用户已填写完整路径
      return Uri.parse(baseUrl);
    } else if (baseUrl.endsWith('/v1')) {
      // 用户填到了 /v1
      return Uri.parse('$baseUrl/chat/completions');
    } else if (baseUrl.endsWith('/')) {
      // 末尾有斜杠
      return Uri.parse('${baseUrl}v1/chat/completions');
    } else {
      // 标准情况
      return Uri.parse('$baseUrl/v1/chat/completions');
    }
  }

  @override
  Future<FishRecognitionResult> identifySpecies(
    File image,
    AiProviderConfig config,
  ) async {
    // 验证 baseUrl
    final baseUrl = config.baseUrl ?? '';
    if (baseUrl.isEmpty) {
      throw const FishRecognitionException(
        FishRecognitionErrorType.apiKeyInvalid,
        '未配置 Base URL',
      );
    }

    // 读取图片并转换为 base64
    final imageBytes = await image.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    // 确定使用的模型名称
    final modelName =
        config.modelName?.isNotEmpty ?? false ? config.modelName! : defaultModel;

    // 构建请求体 - 使用 OpenAI 兼容的 vision API
    final requestBody = {
      'model': modelName,
      'messages': [
        {
          'role': 'system',
          'content': systemPrompt,
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': '请识别这张图片中的鱼类品种。',
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image',
              },
            },
          ],
        },
      ],
      'temperature': 0.2,
      'max_tokens': 2048,
      'response_format': {'type': 'json_object'},
    };

    AppLogger.i('CustomProvider', 'Model: ${config.modelName}');
    AppLogger.i(
        'CustomProvider', 'Request body size: ${jsonEncode(requestBody).length} bytes',);

    // 构建请求 URL - 使用用户自定义的 Base URL
    final url = buildUrl(baseUrl);
    AppLogger.i('CustomProvider', 'URL: $url');

    try {
      // 发送请求，设置 10 秒超时
      final response = await (client ?? http.Client())
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${config.apiKey}',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      // 处理响应
      return handleOpenAIResponse(response);
    } on TimeoutException catch (_) {
      throw const FishRecognitionException(
        FishRecognitionErrorType.timeout,
        '请求超时，请检查网络连接',
      );
    } on http.ClientException catch (e) {
      throw FishRecognitionException(
        FishRecognitionErrorType.networkError,
        '网络错误: ${e.message}',
      );
    } on FormatException catch (e) {
      throw FishRecognitionException(
        FishRecognitionErrorType.unknown,
        '响应解析错误: ${e.message}',
      );
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
}
