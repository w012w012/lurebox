import 'dart:io';

import 'package:lurebox/core/models/ai_recognition_settings.dart';
import 'package:lurebox/core/services/adapters/aliyun_provider.dart';
import 'package:lurebox/core/services/adapters/baidu_provider.dart';
import 'package:lurebox/core/services/adapters/claude_provider.dart';
import 'package:lurebox/core/services/adapters/custom_provider.dart';
import 'package:lurebox/core/services/adapters/deepseek_provider.dart';
import 'package:lurebox/core/services/adapters/gemini_provider.dart';
import 'package:lurebox/core/services/adapters/minimax_provider.dart';
import 'package:lurebox/core/services/adapters/openai_provider.dart';
import 'package:lurebox/core/services/adapters/siliconflow_provider.dart';
import 'package:lurebox/core/services/adapters/tencent_provider.dart';
import 'package:lurebox/core/services/adapters/zhipu_provider.dart';

/// 鱼类识别结果
class FishRecognitionResult {

  const FishRecognitionResult({
    required this.primarySpecies,
    required this.confidence,
    this.alternatives = const [],
    this.notes = '',
  });

  factory FishRecognitionResult.fromJson(Map<String, dynamic> json) {
    final primaryJson = json['primarySpecies'];
    if (primaryJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid primarySpecies in recognition result');
    }
    return FishRecognitionResult(
      primarySpecies: SpeciesInfo.fromJson(primaryJson),
      confidence: json['confidence'] as int? ?? 0,
      alternatives: (json['alternatives'] as List<dynamic>?)
              ?.map((e) => SpeciesInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String? ?? '',
    );
  }
  /// 主要识别物种
  final SpeciesInfo primarySpecies;

  /// 置信度 (0-100)
  final int confidence;

  /// 候选物种列表
  final List<SpeciesInfo> alternatives;

  /// 备注信息
  final String notes;

  Map<String, dynamic> toJson() => {
        'primarySpecies': primarySpecies.toJson(),
        'confidence': confidence,
        'alternatives': alternatives.map((e) => e.toJson()).toList(),
        'notes': notes,
      };
}

/// 物种信息
class SpeciesInfo {

  const SpeciesInfo({
    required this.chineseName,
    required this.scientificName,
    this.confidence = 0,
  });

  factory SpeciesInfo.fromJson(Map<String, dynamic> json) {
    return SpeciesInfo(
      chineseName: (json['chineseName'] as String?)?.isNotEmpty ?? false
          ? json['chineseName'] as String
          : '未知物种',
      scientificName: json['scientificName'] as String? ?? '',
      confidence: (json['confidence'] as int?)?.clamp(0, 100) ?? 0,
    );
  }
  /// 中文名称
  final String chineseName;

  /// 学名
  final String scientificName;

  /// 置信度 (0-100)
  final int confidence;

  Map<String, dynamic> toJson() => {
        'chineseName': chineseName,
        'scientificName': scientificName,
        'confidence': confidence,
      };
}

/// 鱼类识别异常
class FishRecognitionException implements Exception {

  const FishRecognitionException(this.type, this.message);
  final FishRecognitionErrorType type;
  final String message;

  @override
  String toString() => 'FishRecognitionException($type): $message';
}

/// 鱼类识别错误类型
enum FishRecognitionErrorType {
  /// API 密钥无效
  apiKeyInvalid,

  /// 请求超时
  timeout,

  /// 网络错误
  networkError,

  /// 速率限制
  rateLimited,

  /// 未知错误
  unknown,
}

/// 鱼类识别提供者接口
abstract class FishRecognitionProvider {
  /// 识别鱼类物种
  ///
  /// [image] 图片文件
  /// [config] AI 提供商配置
  ///
  /// 返回 [FishRecognitionResult]
  Future<FishRecognitionResult> identifySpecies(
    File image,
    AiProviderConfig config,
  );
}

/// 鱼类识别服务
///
/// 统一的鱼类识别服务接口，根据配置选择不同的 AI 提供商
class FishRecognitionService {
  static const int _maxImageSizeBytes = 10 * 1024 * 1024; // 10MB
  static const Set<String> _supportedExtensions = {'.jpg', '.jpeg', '.png', '.webp'};

  /// Provider factory map — only the selected provider is instantiated
  static final Map<AiRecognitionProvider, FishRecognitionProvider Function()>
      _factories = {
    AiRecognitionProvider.gemini: GeminiFishRecognitionProvider.new,
    AiRecognitionProvider.openai: OpenAIFishRecognitionProvider.new,
    AiRecognitionProvider.claude: ClaudeFishRecognitionProvider.new,
    AiRecognitionProvider.minimax: MiniMaxFishRecognitionProvider.new,
    AiRecognitionProvider.siliconflow: SiliconFlowFishRecognitionProvider.new,
    AiRecognitionProvider.deepseek: DeepSeekFishRecognitionProvider.new,
    AiRecognitionProvider.baidu: BaiduFishRecognitionProvider.new,
    AiRecognitionProvider.aliyun: AliyunFishRecognitionProvider.new,
    AiRecognitionProvider.tencent: TencentFishRecognitionProvider.new,
    AiRecognitionProvider.zhipu: ZhipuFishRecognitionProvider.new,
    AiRecognitionProvider.custom: CustomFishRecognitionProvider.new,
  };

  /// 识别鱼类物种
  ///
  /// 根据 [settings] 中的当前提供商配置进行识别
  ///
  /// [image] 图片文件
  /// [settings] AI 识别设置
  ///
  /// 返回 [FishRecognitionResult]
  /// 抛出 [FishRecognitionException] 识别失败时
  Future<FishRecognitionResult> identifySpecies(
    File image,
    AiRecognitionSettings settings,
  ) async {
    if (!await image.exists()) {
      throw const FishRecognitionException(
        FishRecognitionErrorType.unknown,
        '图片文件不存在',
      );
    }

    final fileSize = await image.length();
    if (fileSize > _maxImageSizeBytes) {
      throw const FishRecognitionException(
        FishRecognitionErrorType.unknown,
        '图片大小超过10MB限制',
      );
    }

    final ext = image.path.toLowerCase().split('.').last;
    if (!_supportedExtensions.contains('.$ext')) {
      throw const FishRecognitionException(
        FishRecognitionErrorType.unknown,
        '不支持的图片格式，请使用 JPG、PNG 或 WebP',
      );
    }

    final config = settings.providerConfigs[settings.currentProvider];

    if (config == null || config.apiKey.isEmpty) {
      throw const FishRecognitionException(
        FishRecognitionErrorType.apiKeyInvalid,
        '未配置 API 密钥',
      );
    }

    if (!config.enabled) {
      throw const FishRecognitionException(
        FishRecognitionErrorType.unknown,
        '当前提供商已禁用',
      );
    }

    final factory = _factories[settings.currentProvider];
    if (factory == null) {
      throw const FishRecognitionException(
        FishRecognitionErrorType.unknown,
        '未知的识别提供商',
      );
    }

    final provider = factory();
    return provider.identifySpecies(image, config);
  }
}
