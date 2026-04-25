import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/adapters/fish_recognition_shared.dart';
import 'package:lurebox/core/services/fish_recognition_service.dart';

/// URL 路径策略枚举
///
/// 用于不同 AI 服务商的 URL 构建方式
enum UrlPathStrategy {
  /// 追加 /v1/chat/completions 到 baseUrl
  ///
  /// 例如: `https://api.openai.com` -> `https://api.openai.com/v1/chat/completions`
  appendPath,

  /// 直接使用 baseUrl（已包含完整路径）
  ///
  /// 例如: `https://api.baidubce.com/v1/chat/completions` -> 直接使用
  useDirect,

  /// 自定义 URL 构建逻辑
  ///
  /// 子类覆盖 [buildUrl] 方法实现自定义逻辑
  custom,
}

/// OpenAI 兼容接口的鱼类识别提供者基类
///
/// 封装了 OpenAI Chat Completions 兼容 API 的通用逻辑，
/// 子类只需提供默认配置（baseUrl、model、URL策略），
/// 无需重复实现识别逻辑。
abstract class OpenAICompatibleProvider implements FishRecognitionProvider {

  /// Creates an OpenAI compatible provider with optional HTTP client injection
  /// If no client is provided, uses the default http.Client
  OpenAICompatibleProvider({http.Client? client}) : _client = client;
  /// HTTP client for making requests (injectable for testing)
  final http.Client? _client;

  /// Protected getter for HTTP client (allows subclasses to use injected client)
  http.Client? get client => _client;

  /// 默认 Base URL
  ///
  /// 子类应返回其 API 的默认端点
  String get defaultBaseUrl;

  /// 默认模型名称
  ///
  /// 子类应返回其推荐的默认模型
  String get defaultModel;

  /// URL 路径策略
  ///
  /// 决定如何将 [AiProviderConfig.baseUrl] 转换为完整的 API URL
  UrlPathStrategy get urlPathStrategy => UrlPathStrategy.appendPath;

  /// 构建请求 URL
  ///
  /// 根据 [baseUrl] 和 [urlPathStrategy] 构建完整的 API URL
  /// 当 [urlPathStrategy] 为 [UrlPathStrategy.custom] 时，
  /// 子类应覆盖此方法实现自定义逻辑。
  Uri buildUrl(String baseUrl) {
    switch (urlPathStrategy) {
      case UrlPathStrategy.appendPath:
        // 追加 /v1/chat/completions
        final cleanedBase = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl;
        return Uri.parse('$cleanedBase/v1/chat/completions');
      case UrlPathStrategy.useDirect:
        // 直接使用 baseUrl
        return Uri.parse(baseUrl);
      case UrlPathStrategy.custom:
        // 自定义逻辑由子类实现
        throw UnimplementedError(
          'custom URL strategy requires buildUrl override',
        );
    }
  }

  /// 获取系统提示词
  ///
  /// 子类可覆盖此方法返回自定义的提示词
  String get systemPrompt => fishRecognitionSystemPrompt;

  @override
  Future<FishRecognitionResult> identifySpecies(
    File image,
    AiProviderConfig config,
  ) async {
    // 读取图片并转换为 base64
    final imageBytes = await image.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    // 确定使用的模型名称
    final modelName =
        config.modelName?.isNotEmpty ?? false ? config.modelName! : defaultModel;

    // 构建请求体 - 使用 vision API
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

    // 确定 baseUrl
    final effectiveBaseUrl =
        config.baseUrl?.isNotEmpty ?? false ? config.baseUrl! : defaultBaseUrl;

    // 构建请求 URL
    final url = buildUrl(effectiveBaseUrl);

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

  /// 处理 API 响应
  ///
  /// 解析 HTTP 响应，提取鱼类识别结果
  /// 子类可通过覆盖此方法自定义响应处理
  FishRecognitionResult handleOpenAIResponse(http.Response response) {
    // 检查 HTTP 状态码
    throwHttpError(response);

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
