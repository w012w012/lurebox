import 'openai_compatible_provider.dart';

/// Tencent (腾讯混元) 鱼类识别提供者
///
/// 使用腾讯混元 API (OpenAI 兼容接口) 进行鱼类识别
/// 支持混元视觉模型
class TencentFishRecognitionProvider extends OpenAICompatibleProvider {
  @override
  String get defaultBaseUrl => 'https://api.hunyuan.cloud.tencent.com/v1/chat/completions';

  @override
  String get defaultModel => 'hunyuan-vision';

  @override
  UrlPathStrategy get urlPathStrategy => UrlPathStrategy.appendPath;
}
