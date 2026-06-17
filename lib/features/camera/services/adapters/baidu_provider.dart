import 'package:lurebox/core/services/adapters/openai_compatible_provider.dart';

/// Baidu AI 鱼类识别提供者
///
/// 使用百度 AI API (OpenAI 兼容接口) 进行鱼类识别
/// 支持百度 ERNIE-VL 视觉模型
class BaiduFishRecognitionProvider extends OpenAICompatibleProvider {
  /// Creates a Baidu provider with optional HTTP client injection
  BaiduFishRecognitionProvider({super.client});

  @override
  String get defaultBaseUrl => 'https://api.baidubce.com/v1/chat/completions';

  @override
  String get defaultModel => 'ernie-vl-72b';

  @override
  UrlPathStrategy get urlPathStrategy => UrlPathStrategy.useDirect;
}
