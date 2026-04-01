import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../fish_recognition_service.dart';
import '../../models/ai_recognition_settings.dart';

/// Baidu AI 鱼类识别提供者
///
/// 使用百度 AI API (OpenAI 兼容接口) 进行鱼类识别
/// 支持百度 ERNIE-VL 视觉模型
class BaiduFishRecognitionProvider implements FishRecognitionProvider {
  /// 系统提示词 - 用于指导模型识别鱼类物种
  static const String _systemPrompt = '''你是一个专业的鱼类识别助手，专门帮助用户识别钓鱼时钓到的鱼类。

请根据用户提供的图片识别鱼类的品种。

## 输出要求
请以 JSON 格式返回识别结果，包含以下字段：
- primarySpecies: 主要识别物种，包含 chineseName（中文名称）、scientificName（学名）、confidence（置信度 0-100）
- alternatives: 候选物种列表（可选），每个物种包含 chineseName、scientificName、confidence
- notes: 备注信息（可选），如识别依据、相似物种区分等

## 识别原则
1. 优先识别常见淡水鱼和海水鱼
2. 中国常见的路亚目标鱼包括：黑鱼（鳢）、鲈鱼、翘嘴（翘嘴鲌）、鳜鱼、鲶鱼、鲤鱼、鲫鱼、草鱼、青鱼等
3. 海水路亚目标鱼包括：海鲈、石斑、GT（浪人鲹）、GT（牛港鲹）、马鲛、金枪鱼等
4. 如果无法确定具体品种，请给出最可能的科属
5. 置信度评分要客观，不要过高估计

## 常见鱼类参考
- 黑鱼: 鳢科，学名 Channa argus
- 鲈鱼: 鲈科，学名 Lateolabrax japonicus
- 翘嘴: 鲤科，学名 Culter alburnus
- 鳜鱼: 鲈科，学名 Siniperca chuatsi
- 鲶鱼: 鲶科，学名 Silurus asotus
- 鲤鱼: 鲤科，学名 Cyprinus carpio
- 鲫鱼: 鲤科，学名 Carassius auratus
- 草鱼: 鲤科，学名 Ctenopharyngodon idella
- 青鱼: 鲤科，学名 Mylopharyngodon piceus
- 罗非鱼: 丽鱼科，学名 Oreochromis mossambicus
- 太阳鱼: 太阳鱼科，学名 Lepomis macrochirus
- 海鲈: 鲈科，学名 Morone saxatilis
- 石斑: 鲈科，学名 Epinephelus spp.
- GT/牛港鲹: 鲹科，学名 Caranx sexfasciatus
- 马鲛: 鲭科，学名 Scomberomorus spp.

请直接返回 JSON，不要包含其他文字说明。''';

  @override
  Future<FishRecognitionResult> identifySpecies(
    File image,
    AiProviderConfig config,
  ) async {
    // 读取图片并转换为 base64
    final imageBytes = await image.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    // 构建请求体 - 使用 OpenAI 兼容的 vision API
    final requestBody = {
      'model': config.modelName ?? 'ernie-vl-72b',
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

    // 构建请求 URL - Baidu AI API 端点 (OpenAI 兼容接口)
    final baseUrl =
        config.baseUrl ?? 'https://api.baidubce.com/v1/chat/completions';
    final url = Uri.parse(baseUrl);

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
      String jsonText = content.trim();
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      }
      if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }
      jsonText = jsonText.trim();

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
