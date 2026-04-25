import 'dart:convert';

/// AI 识别设置数据模型
///
/// 定义了应用中 AI 鱼类识别功能的配置。
///
/// 组成结构：
/// - [AiRecognitionProvider]: AI 服务提供商枚举
/// - [AiProviderConfig]: 单个 AI 提供商的配置
/// - [AiRecognitionSettings]: AI 识别设置聚合类
///
/// 序列化支持：
/// - toJson(): 转换为 JSON
/// - fromJson(): 从 JSON 创建
/// - encode(): 编码为字符串
/// - decode(): 从字符串解码
///
/// 典型用途：
/// - AI 识别服务配置
/// - API 密钥管理
/// - 自动识别开关

/// AI 识别服务提供商
enum AiRecognitionProvider {
  gemini(0, 'Gemini', 'Google Gemini'),
  openai(1, 'OpenAI', 'OpenAI GPT'),
  claude(2, 'Claude', 'Anthropic Claude'),
  minimax(3, 'MiniMax', 'MiniMax'),
  siliconflow(4, 'SiliconFlow', 'SiliconFlow'),
  deepseek(5, 'DeepSeek', 'DeepSeek'),
  baidu(6, 'Baidu', '百度文心一言'),
  aliyun(7, 'Aliyun', '阿里云通义千问'),
  tencent(8, 'Tencent', '腾讯混元'),
  zhipu(9, 'Zhipu', '智谱AI'),
  custom(10, 'Custom', '自定义');

  const AiRecognitionProvider(this.value, this.label, this.displayName);
  final int value;
  final String label;
  final String displayName;

  static AiRecognitionProvider fromValue(int value) {
    return AiRecognitionProvider.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AiRecognitionProvider.gemini,
    );
  }
}

/// AI 提供商配置
class AiProviderConfig {

  const AiProviderConfig({
    required this.provider,
    required this.apiKey,
    this.baseUrl,
    this.modelName,
    this.enabled = true,
  });

  factory AiProviderConfig.fromJson(Map<String, dynamic> json) {
    return AiProviderConfig(
      provider: AiRecognitionProvider.fromValue(json['provider'] as int? ?? 0),
      apiKey: json['apiKey'] as String? ?? '',
      baseUrl: json['baseUrl'] as String?,
      modelName: json['modelName'] as String?,
      enabled: json['enabled'] as bool? ?? true,
    );
  }
  final AiRecognitionProvider provider;
  final String apiKey;
  final String? baseUrl;
  final String? modelName;
  final bool enabled;

  AiProviderConfig copyWith({
    AiRecognitionProvider? provider,
    String? apiKey,
    String? baseUrl,
    String? modelName,
    bool? enabled,
  }) {
    return AiProviderConfig(
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      modelName: modelName ?? this.modelName,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'provider': provider.value,
        'apiKey': apiKey,
        'baseUrl': baseUrl,
        'modelName': modelName,
        'enabled': enabled,
      };
}

/// AI 识别设置
class AiRecognitionSettings {

  const AiRecognitionSettings({
    this.currentProvider = AiRecognitionProvider.gemini,
    this.providerConfigs = const {},
    this.autoRecognize = true,
    this.timeout = const Duration(seconds: 10),
  });

  factory AiRecognitionSettings.fromJson(Map<String, dynamic> json) {
    final configsJson = json['providerConfigs'] as Map<String, dynamic>? ?? {};
    final configs = <AiRecognitionProvider, AiProviderConfig>{};

    for (final entry in configsJson.entries) {
      final providerValue = int.tryParse(entry.key);
      if (providerValue != null) {
        final provider = AiRecognitionProvider.fromValue(providerValue);
        configs[provider] = AiProviderConfig.fromJson(
          entry.value as Map<String, dynamic>,
        );
      }
    }

    return AiRecognitionSettings(
      currentProvider: AiRecognitionProvider.fromValue(
        json['currentProvider'] as int? ?? 0,
      ),
      providerConfigs: configs,
      autoRecognize: json['autoRecognize'] as bool? ?? true,
      timeout: Duration(seconds: json['timeout'] as int? ?? 10),
    );
  }

  factory AiRecognitionSettings.decode(String source) =>
      AiRecognitionSettings.fromJson(jsonDecode(source) as Map<String, dynamic>);
  final AiRecognitionProvider currentProvider;
  final Map<AiRecognitionProvider, AiProviderConfig> providerConfigs;
  final bool autoRecognize;
  final Duration timeout;

  AiRecognitionSettings copyWith({
    AiRecognitionProvider? currentProvider,
    Map<AiRecognitionProvider, AiProviderConfig>? providerConfigs,
    bool? autoRecognize,
    Duration? timeout,
  }) {
    return AiRecognitionSettings(
      currentProvider: currentProvider ?? this.currentProvider,
      providerConfigs: providerConfigs ?? this.providerConfigs,
      autoRecognize: autoRecognize ?? this.autoRecognize,
      timeout: timeout ?? this.timeout,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentProvider': currentProvider.value,
        'providerConfigs': providerConfigs.map(
          (key, value) => MapEntry(key.value.toString(), value.toJson()),
        ),
        'autoRecognize': autoRecognize,
        'timeout': timeout.inSeconds,
      };

  String encode() => jsonEncode(toJson());
}
