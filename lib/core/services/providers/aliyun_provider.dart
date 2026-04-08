import 'openai_compatible_provider.dart';

/// Aliyun 鱼类识别提供者
///
/// 使用阿里云 DashScope API (OpenAI 兼容接口) 进行鱼类识别
/// 支持多种开源视觉模型
class AliyunFishRecognitionProvider extends OpenAICompatibleProvider {
  @override
  String get defaultBaseUrl => 'https://dashscope.aliyuncs.com/compatible-mode/v1';

  @override
  String get defaultModel => 'qwen-vl-max';

  @override
  UrlPathStrategy get urlPathStrategy => UrlPathStrategy.appendPath;
}
