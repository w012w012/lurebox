import 'package:lurebox/core/services/adapters/openai_compatible_provider.dart';

/// SiliconFlow 鱼类识别提供者
///
/// 使用 SiliconFlow API (OpenAI 兼容接口) 进行鱼类识别
/// 支持多种开源视觉模型
class SiliconFlowFishRecognitionProvider extends OpenAICompatibleProvider {
  /// Creates a SiliconFlow provider with optional HTTP client injection
  SiliconFlowFishRecognitionProvider({super.client});

  @override
  String get defaultBaseUrl => 'https://api.siliconflow.cn';

  @override
  String get defaultModel => 'Qwen/Qwen2-VL-72B-Instruct';

  @override
  UrlPathStrategy get urlPathStrategy => UrlPathStrategy.appendPath;
}
