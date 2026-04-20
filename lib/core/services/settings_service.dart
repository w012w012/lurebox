import 'package:flutter/foundation.dart';
import '../models/watermark_settings.dart';
import '../models/app_settings.dart';
import '../models/ai_recognition_settings.dart';
import '../repositories/settings_repository.dart';

/// 设置服务 - 应用配置的持久化管理
///
/// 负责管理两类设置：
/// - 水印设置 [WatermarkSettings]：图片水印的样式、位置、透明度等
/// - 应用设置 [AppSettings]：应用的整体配置选项
///
/// 设置以 JSON 编码字符串形式存储在 SQLite settings 表中。
/// 读取时若解析失败返回默认构造函数的默认值。

class SettingsService {
  final SettingsRepository _repository;

  SettingsService(this._repository);

  Future<void> saveWatermarkSettings(WatermarkSettings settings) async {
    await _repository.set('watermark_settings', settings.encode());
  }

  Future<WatermarkSettings> getWatermarkSettings() async {
    final value = await _repository.get('watermark_settings');
    if (value == null) {
      return const WatermarkSettings();
    }
    try {
      return WatermarkSettings.decode(value);
    } on FormatException catch (e) {
      debugPrint('[SettingsService] Failed to decode watermark settings: $e');
      return const WatermarkSettings();
    } catch (e) {
      debugPrint('[SettingsService] Unexpected error decoding watermark settings: $e');
      return const WatermarkSettings();
    }
  }

  Future<void> saveAppSettings(AppSettings settings) async {
    await _repository.set('app_settings', settings.encode());
  }

  Future<AppSettings> getAppSettings() async {
    final value = await _repository.get('app_settings');
    if (value == null) {
      return const AppSettings();
    }
    try {
      return AppSettings.decode(value);
    } on FormatException catch (e) {
      debugPrint('[SettingsService] Failed to decode app settings: $e');
      return const AppSettings();
    } catch (e) {
      debugPrint('[SettingsService] Unexpected error decoding app settings: $e');
      return const AppSettings();
    }
  }

  Future<void> saveAiRecognitionSettings(AiRecognitionSettings settings) async {
    await _repository.set('ai_recognition_settings', settings.encode());
  }

  Future<AiRecognitionSettings> getAiRecognitionSettings() async {
    final value = await _repository.get('ai_recognition_settings');
    if (value == null) {
      return const AiRecognitionSettings();
    }
    try {
      return AiRecognitionSettings.decode(value);
    } on FormatException catch (e) {
      debugPrint('[SettingsService] Failed to decode AI recognition settings: $e');
      return const AiRecognitionSettings();
    } catch (e) {
      debugPrint('[SettingsService] Unexpected error decoding AI recognition settings: $e');
      return const AiRecognitionSettings();
    }
  }
}
