import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../fish_recognition_service.dart';
import '../../models/ai_recognition_settings.dart';
import 'fish_recognition_shared.dart';

/// MiniMax 鱼类识别提供者
///
/// 使用 MiniMax 多模态 API 进行鱼类识别
class MiniMaxFishRecognitionProvider implements FishRecognitionProvider {
  static const String _systemPrompt = fishRecognitionSystemPrompt;

  /// HTTP client for making requests (injectable for testing)
  final http.Client? _client;

  /// Creates a MiniMax provider with optional HTTP client injection
  /// If no client is provided, uses the default http.Client
  MiniMaxFishRecognitionProvider({http.Client? client}) : _client = client;

  @override
  Future<FishRecognitionResult> identifySpecies(
    File image,
    AiProviderConfig config,
  ) async {
    // 读取图片并转换为 base64
    final imageBytes = await image.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    // 构建请求体 - MiniMax 多模态 API
    final requestBody = {
      'model': config.modelName ?? 'abab6.5s-chat',
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
    };

    // 构建请求 URL - MiniMax API 端点
    final baseUrl = config.baseUrl ?? 'https://api.minimax.chat';
    final url = Uri.parse('$baseUrl/v1/text/chatcompletion_v2');

    try {
      // 发送请求，设置 10 秒超时
      final response = await (_client ?? http.Client())
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
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      // 检查 API 错误
      if (json.containsKey('base_resp')) {
        final baseResp = json['base_resp'] as Map<String, dynamic>;
        final statusCode = baseResp['status_code'] as int? ?? 0;
        final statusMsg = baseResp['status_msg'] as String? ?? '';

        if (statusCode == 1003 || statusMsg.contains('invalid api_key')) {
          throw const FishRecognitionException(
            FishRecognitionErrorType.apiKeyInvalid,
            'API 密钥无效',
          );
        }
        if (statusCode == 1004 || statusMsg.contains('rate')) {
          throw const FishRecognitionException(
            FishRecognitionErrorType.rateLimited,
            '请求过于频繁',
          );
        }
        if (statusCode != 0) {
          throw FishRecognitionException(
            FishRecognitionErrorType.unknown,
            statusMsg.isNotEmpty ? statusMsg : '请求失败: $statusCode',
          );
        }
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
