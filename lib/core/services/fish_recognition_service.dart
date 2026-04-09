import 'dart:io';
import '../models/ai_recognition_settings.dart';
import 'providers/gemini_provider.dart';
import 'providers/openai_provider.dart';
import 'providers/claude_provider.dart';
import 'providers/minimax_provider.dart';
import 'providers/siliconflow_provider.dart';
import 'providers/deepseek_provider.dart';
import 'providers/baidu_provider.dart';
import 'providers/aliyun_provider.dart';
import 'providers/tencent_provider.dart';
import 'providers/zhipu_provider.dart';
import 'providers/custom_provider.dart';

/// 鱼类识别结果
class FishRecognitionResult {
  /// 主要识别物种
  final SpeciesInfo primarySpecies;

  /// 置信度 (0-100)
  final int confidence;

  /// 候选物种列表
  final List<SpeciesInfo> alternatives;

  /// 备注信息
  final String notes;

  const FishRecognitionResult({
    required this.primarySpecies,
    required this.confidence,
    this.alternatives = const [],
    this.notes = '',
  });

  factory FishRecognitionResult.fromJson(Map<String, dynamic> json) {
    return FishRecognitionResult(
      primarySpecies: SpeciesInfo.fromJson(
        json['primarySpecies'] as Map<String, dynamic>,
      ),
      confidence: json['confidence'] as int? ?? 0,
      alternatives: (json['alternatives'] as List<dynamic>?)
              ?.map((e) => SpeciesInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'primarySpecies': primarySpecies.toJson(),
        'confidence': confidence,
        'alternatives': alternatives.map((e) => e.toJson()).toList(),
        'notes': notes,
      };
}

/// 物种信息
class SpeciesInfo {
  /// 中文名称
  final String chineseName;

  /// 学名
  final String scientificName;

  /// 置信度 (0-100)
  final int confidence;

  const SpeciesInfo({
    required this.chineseName,
    required this.scientificName,
    this.confidence = 0,
  });

  factory SpeciesInfo.fromJson(Map<String, dynamic> json) {
    return SpeciesInfo(
      chineseName: json['chineseName'] as String? ?? '',
      scientificName: json['scientificName'] as String? ?? '',
      confidence: json['confidence'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'chineseName': chineseName,
        'scientificName': scientificName,
        'confidence': confidence,
      };
}

/// 鱼类识别异常
class FishRecognitionException implements Exception {
  final FishRecognitionErrorType type;
  final String message;

  const FishRecognitionException(this.type, this.message);

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
  late final GeminiFishRecognitionProvider _geminiProvider =
      GeminiFishRecognitionProvider();
  late final OpenAIFishRecognitionProvider _openaiProvider =
      OpenAIFishRecognitionProvider();
  late final ClaudeFishRecognitionProvider _claudeProvider =
      ClaudeFishRecognitionProvider();
  late final MiniMaxFishRecognitionProvider _minimaxProvider =
      MiniMaxFishRecognitionProvider();
  late final SiliconFlowFishRecognitionProvider _siliconflowProvider =
      SiliconFlowFishRecognitionProvider();
  late final DeepSeekFishRecognitionProvider _deepseekProvider =
      DeepSeekFishRecognitionProvider();
  late final BaiduFishRecognitionProvider _baiduProvider =
      BaiduFishRecognitionProvider();
  late final AliyunFishRecognitionProvider _aliyunProvider =
      AliyunFishRecognitionProvider();
  late final TencentFishRecognitionProvider _tencentProvider =
      TencentFishRecognitionProvider();
  late final ZhipuFishRecognitionProvider _zhipuProvider =
      ZhipuFishRecognitionProvider();
  late final CustomFishRecognitionProvider _customProvider =
      CustomFishRecognitionProvider();

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

// 根据当前提供商选择对应的适配器
    switch (settings.currentProvider) {
      case AiRecognitionProvider.gemini:
        return await _geminiProvider.identifySpecies(image, config);
      case AiRecognitionProvider.openai:
        return await _openaiProvider.identifySpecies(image, config);
      case AiRecognitionProvider.claude:
        return await _claudeProvider.identifySpecies(image, config);
      case AiRecognitionProvider.minimax:
        return await _minimaxProvider.identifySpecies(image, config);
      case AiRecognitionProvider.siliconflow:
        return await _siliconflowProvider.identifySpecies(image, config);
      case AiRecognitionProvider.deepseek:
        return await _deepseekProvider.identifySpecies(image, config);
      case AiRecognitionProvider.baidu:
        return await _baiduProvider.identifySpecies(image, config);
      case AiRecognitionProvider.aliyun:
        return await _aliyunProvider.identifySpecies(image, config);
      case AiRecognitionProvider.tencent:
        return await _tencentProvider.identifySpecies(image, config);
      case AiRecognitionProvider.zhipu:
        return await _zhipuProvider.identifySpecies(image, config);
      case AiRecognitionProvider.custom:
        return await _customProvider.identifySpecies(image, config);
    }
  }
}
