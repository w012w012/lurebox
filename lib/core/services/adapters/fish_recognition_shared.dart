
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:lurebox/core/services/fish_recognition_service.dart';

/// Shared HTTP client for AI recognition providers.
///
/// Reuses a single connection pool instead of creating a new client per request,
/// which leaks sockets. Disposed when the app process exits.
final http.Client sharedHttpClient = http.Client();

/// Detect image MIME type from file extension.
String detectImageMediaType(File image) {
  final ext = image.path.split('.').last.toLowerCase();
  switch (ext) {
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    case 'gif':
      return 'image/gif';
    default:
      return 'image/jpeg';
  }
}

/// 系统提示词 - 用于指导模型识别鱼类物种
const String fishRecognitionSystemPrompt = '''
你是一个专业的鱼类识别助手，专门帮助用户识别钓鱼时钓到的鱼类。

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

/// 从 AI 响应内容中提取 JSON 字符串
///
/// Handles ```json\n...\n``` fence variants, with or without language tag,
/// optional newlines after opening fence, and extra whitespace.
String extractJsonFromResponse(String content) {
  var text = content.trim();
  // Try matching full fenced block: opening ```json + body + closing ```
  final fullFence = RegExp(
    r'^```(?:json)?\s*\n?(.*?)\n?\s*```$',
    dotAll: true,
  );
  final fullMatch = fullFence.firstMatch(text);
  if (fullMatch != null) {
    return fullMatch.group(1)!.trim();
  }
  // Opening fence without closing
  if (text.startsWith('```')) {
    text = text.replaceFirst(RegExp(r'^```(?:json)?\s*\n?'), '');
  }
  // Trailing fence without opening
  if (text.endsWith('```')) {
    text = text.substring(0, text.length - 3).trimRight();
  }
  return text.trim();
}

/// 解析 HTTP 响应状态码，返回 (错误类型, 错误消息)
///
/// [response] HTTP 响应
/// 返回 (FishRecognitionErrorType, 错误消息)。若状态码为 200，返回 (null, null)
(FishRecognitionErrorType?, String?) parseHttpStatus(http.Response response) {
  switch (response.statusCode) {
    case 200:
      return (null, null);
    case 400:
      return (FishRecognitionErrorType.unknown, '请求错误: 400');
    case 401:
    case 403:
      return (FishRecognitionErrorType.apiKeyInvalid, 'API 密钥无效或无权限');
    case 429:
      return (FishRecognitionErrorType.rateLimited, '请求过于频繁');
    case 500:
    case 502:
    case 503:
      return (
        FishRecognitionErrorType.networkError,
        '服务器错误: ${response.statusCode}'
      );
    default:
      return (FishRecognitionErrorType.unknown, '未知错误: ${response.statusCode}');
  }
}

/// 根据 HTTP 错误类型抛出对应的异常
///
/// [response] HTTP 响应
/// [onRateLimited] 可选的速率限制额外处理回调
void throwHttpError(
  http.Response response, {
  void Function()? onRateLimited,
}) {
  final (type, message) = parseHttpStatus(response);
  if (type == null) return; // 200 OK

  if (type == FishRecognitionErrorType.rateLimited && onRateLimited != null) {
    onRateLimited();
  }

  throw FishRecognitionException(type, message ?? '未知错误');
}
