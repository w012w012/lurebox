import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../fish_recognition_service.dart';
import '../../models/ai_recognition_settings.dart';
import 'fish_recognition_shared.dart';

/// OpenAI 鱼类识别提供者
///
/// 使用 OpenAI Chat Completions API (GPT-4o) 进行鱼类识别
class OpenAIFishRecognitionProvider implements FishRecognitionProvider {
  static const String _systemPrompt = fishRecognitionSystemPrompt;

  @override
  Future<FishRecognitionResult> identifySpecies(
    File image,
    AiProviderConfig config,
  ) async {
    // 读取图片并转换为 base64
    final imageBytes = await image.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    // 构建请求体 - 使用 vision API
    final requestBody = {
      'model': config.modelName ?? 'gpt-4o',
      'messages': [
        {
          'role': 'system',
          'content': _systemPrompt,
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

    // 构建请求 URL
    final baseUrl = config.baseUrl ?? 'https://api.openai.com';
    final url = Uri.parse('$baseUrl/v1/chat/completions');

    try {
      // 发送请求，设置 10 秒超时
      final response = await http
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
      return _handleResponse(response);
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

  /// 处理 API 响应
  FishRecognitionResult _handleResponse(http.Response response) {
    // 检查 HTTP 状态码
    switch (response.statusCode) {
      case 200:
        // 成功
        break;
      case 400:
        // 检查是否是 API 密钥无效
        final body = response.body;
        if (body.contains('invalid_api_key') ||
            body.contains('API key') ||
            body.contains('invalid')) {
          throw const FishRecognitionException(
            FishRecognitionErrorType.apiKeyInvalid,
            'API 密钥无效',
          );
        }
        throw FishRecognitionException(
          FishRecognitionErrorType.unknown,
          '请求错误: ${response.statusCode}',
        );
      case 401:
        throw const FishRecognitionException(
          FishRecognitionErrorType.apiKeyInvalid,
          'API 密钥无效或已过期',
        );
      case 403:
        throw const FishRecognitionException(
          FishRecognitionErrorType.apiKeyInvalid,
          'API 密钥没有权限',
        );
      case 429:
        throw const FishRecognitionException(
          FishRecognitionErrorType.rateLimited,
          '请求过于频繁，请稍后重试',
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

    // 解析响应体
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      // 检查 API 错误
      if (json.containsKey('error')) {
        final error = json['error'] as Map<String, dynamic>;
        final errorMessage = error['message'] as String? ?? '未知错误';
        final errorCode = error['code'] as String?;

        if (errorCode == 'invalid_api_key' ||
            errorMessage.contains('API key') ||
            errorMessage.contains('api_key')) {
          throw const FishRecognitionException(
            FishRecognitionErrorType.apiKeyInvalid,
            'API 密钥无效',
          );
        }
        if (errorMessage.contains('rate') ||
            errorCode == 'rate_limit_exceeded') {
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

      // 提取模型回复
      final choices = json['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw const FishRecognitionException(
          FishRecognitionErrorType.unknown,
          '未收到有效响应',
        );
      }

      final choice = choices.first as Map<String, dynamic>;
      final message = choice['message'] as Map<String, dynamic>?;
      if (message == null) {
        throw const FishRecognitionException(
          FishRecognitionErrorType.unknown,
          '响应内容为空',
        );
      }

      final content = message['content'] as String?;
      if (content == null || content.isEmpty) {
        throw const FishRecognitionException(
          FishRecognitionErrorType.unknown,
          '响应内容为空',
        );
      }

      // 清理 JSON 文本（移除可能的 markdown 代码块标记）
      final jsonText = extractJsonFromResponse(content);

      // 解析 JSON
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
}
