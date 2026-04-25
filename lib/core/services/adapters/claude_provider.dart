import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/adapters/fish_recognition_shared.dart';
import 'package:lurebox/core/services/fish_recognition_service.dart';

/// Claude 鱼类识别提供者
///
/// 使用 Anthropic Claude Messages API (Claude 3.5) 进行鱼类识别
class ClaudeFishRecognitionProvider implements FishRecognitionProvider {

  /// Creates a Claude provider with optional HTTP client injection
  /// If no client is provided, uses the default http.Client
  ClaudeFishRecognitionProvider({http.Client? client}) : _client = client;
  static const String _systemPrompt = fishRecognitionSystemPrompt;

  /// HTTP client for making requests (injectable for testing)
  final http.Client? _client;

  @override
  Future<FishRecognitionResult> identifySpecies(
    File image,
    AiProviderConfig config,
  ) async {
    // 读取图片并转换为 base64
    final imageBytes = await image.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    // 构建请求体 - 使用 Anthropic Messages API
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

    // 构建请求 URL
    final baseUrl = config.baseUrl ?? 'https://api.anthropic.com';
    final url = Uri.parse('$baseUrl/v1/messages');

    try {
      // 发送请求，设置 10 秒超时
      final response = await (_client ?? http.Client())
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

      // 处理响应
      return _handleResponse(response);
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

  /// 处理 API 响应
  FishRecognitionResult _handleResponse(http.Response response) {
    // 检查 HTTP 状态码
    throwHttpError(response);

    // 解析响应体
    try {
      // Use utf8.decode for proper Chinese character support
      final bodyString = utf8.decode(response.bodyBytes);
      final json = jsonDecode(bodyString) as Map<String, dynamic>;

      // 检查 API 错误
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

      // 提取模型回复
      final content = json['content'] as List<dynamic>?;
      if (content == null || content.isEmpty) {
        throw const FishRecognitionException(
          FishRecognitionErrorType.unknown,
          '未收到有效响应',
        );
      }

      // 查找 text 类型的 content block
      var jsonText = '';
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

      // 清理 JSON 文本（移除可能的 markdown 代码块标记）
      jsonText = extractJsonFromResponse(jsonText);

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
