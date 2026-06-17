import 'package:lurebox/core/services/adapters/openai_compatible_provider.dart';

/// OpenAI 鱼类识别提供者
///
/// 使用 OpenAI Chat Completions API (GPT-4o) 进行鱼类识别
class OpenAIFishRecognitionProvider extends OpenAICompatibleProvider {
  /// Creates an OpenAI provider with optional HTTP client injection
  OpenAIFishRecognitionProvider({super.client});

  @override
  String get defaultBaseUrl => 'https://api.openai.com';

  @override
  String get defaultModel => 'gpt-4o';

  @override
  UrlPathStrategy get urlPathStrategy => UrlPathStrategy.appendPath;
}
