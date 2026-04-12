import 'openai_compatible_provider.dart';

/// Zhipu (智谱AI) 鱼类识别提供者
///
/// 使用智谱AI API (OpenAI 兼容接口) 进行鱼类识别
/// 支持 glm-4v-plus 视觉模型
class ZhipuFishRecognitionProvider extends OpenAICompatibleProvider {
  /// Creates a Zhipu provider with optional HTTP client injection
  ZhipuFishRecognitionProvider({super.client});

  @override
  String get defaultBaseUrl =>
      'https://open.bigmodel.cn/api/paas/v4/chat/completions';

  @override
  String get defaultModel => 'glm-4v-plus';

  @override
  UrlPathStrategy get urlPathStrategy => UrlPathStrategy.useDirect;
}
