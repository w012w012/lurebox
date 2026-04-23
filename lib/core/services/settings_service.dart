import 'package:flutter/foundation.dart';
import '../models/watermark_settings.dart';
import '../models/app_settings.dart';
import '../models/ai_recognition_settings.dart';
import '../repositories/settings_repository.dart';
import 'error_service.dart';
import 'secure_storage_service.dart';

/// 设置服务 - 应用配置的持久化管理
///
/// 负责管理三类设置：
/// - 水印设置 [WatermarkSettings]：图片水印的样式、位置、透明度等
/// - 应用设置 [AppSettings]：应用的整体配置选项
/// - AI 识别设置 [AiRecognitionSettings]：AI 服务配置
///
/// 安全存储：
/// - API keys 存储在 SecureStorageService (Keychain/EncryptedSharedPreferences)
/// - 其他配置存储在 SQLite
///
/// 向后兼容：
/// - 自动从旧的 SQLite 存储迁移 API keys 到安全存储

class SettingsService {
  final SettingsRepository _repository;
  final SecureStorageService _secureStorage;

  SettingsService(
    this._repository, {
    SecureStorageService? secureStorage,
  }) : _secureStorage = secureStorage ?? SecureStorageService.instance;

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
      throw SettingsCorruptedException(
        'Watermark settings corrupted: $e',
        originalError: e,
      );
    } catch (e) {
      throw SettingsCorruptedException(
        'Unexpected error decoding watermark settings: $e',
        originalError: e,
      );
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
      throw SettingsCorruptedException(
        'App settings corrupted: $e',
        originalError: e,
      );
    } catch (e) {
      throw SettingsCorruptedException(
        'Unexpected error decoding app settings: $e',
        originalError: e,
      );
    }
  }

  /// 保存 AI 识别设置
  ///
  /// API keys 会自动分离并存储到安全存储
  Future<void> saveAiRecognitionSettings(AiRecognitionSettings settings) async {
    // 1. 提取并保存 API keys 到安全存储
    await _saveApiKeysToSecureStorage(settings);

    // 2. 清理后的设置（不含 API keys）保存到 SQLite
    final cleanedSettings = _removeApiKeysFromSettings(settings);
    await _repository.set('ai_recognition_settings', cleanedSettings.encode());

    // 3. 标记已迁移
    await _repository.set('_ai_keys_migrated', 'true');
  }

  /// 读取 AI 识别设置
  ///
  /// API keys 会自动从安全存储填充
  Future<AiRecognitionSettings> getAiRecognitionSettings() async {
    var value = await _repository.get('ai_recognition_settings');
    if (value == null) {
      return const AiRecognitionSettings();
    }

    try {
      // 1. 检查是否需要迁移旧数据
      final needsMigration = await _needsMigration(value);
      if (needsMigration) {
        // 关键修复：先标记迁移开始，再执行可能失败的操作
        await _repository.set('_ai_keys_migrated', 'in_progress');

        final migratedJson =
            await _secureStorage.migrateApiKeysFromJson(value);
        await _repository.set('ai_recognition_settings', migratedJson);
        await _repository.set('_ai_keys_migrated', 'true');
        debugPrint('[SettingsService] API keys migrated to secure storage');
        value = migratedJson;
      }

      // 2. 解析设置
      final settings = AiRecognitionSettings.decode(value);

      // 3. 从安全存储加载 API keys
      final settingsWithApiKeys =
          await _injectApiKeysFromSecureStorage(settings);

      return settingsWithApiKeys;
    } on FormatException catch (e) {
      throw SettingsCorruptedException(
        'AI recognition settings corrupted: $e',
        originalError: e,
      );
    } catch (e) {
      throw SettingsCorruptedException(
        'Unexpected error decoding AI recognition settings: $e',
        originalError: e,
      );
    }
  }

  /// 检查是否需要从旧格式迁移
  Future<bool> _needsMigration(String jsonValue) async {
    // 检查迁移标记
    final migrated = await _repository.get('_ai_keys_migrated');
    if (migrated == 'true') {
      return false;
    }

    // 检查 JSON 中是否包含 API keys（旧格式）
    return jsonValue.contains('"apiKey"');
  }

  /// 将 API keys 保存到安全存储
  Future<void> _saveApiKeysToSecureStorage(AiRecognitionSettings settings) async {
    for (final entry in settings.providerConfigs.entries) {
      final providerKey = entry.key.value.toString();
      final apiKey = entry.value.apiKey;

      if (apiKey.isNotEmpty) {
        await _secureStorage.saveProviderApiKey(providerKey, apiKey);
      } else {
        // API key 为空时，删除安全存储中的旧值
        await _secureStorage.deleteProviderApiKey(providerKey);
      }
    }
  }

  /// 从安全存储获取 API keys 并注入到设置
  Future<AiRecognitionSettings> _injectApiKeysFromSecureStorage(
    AiRecognitionSettings settings,
  ) async {
    final updatedConfigs = <AiRecognitionProvider, AiProviderConfig>{};

    for (final entry in settings.providerConfigs.entries) {
      final providerKey = entry.key.value.toString();
      final existingConfig = entry.value;

      // 从安全存储获取 API key
      final secureApiKey = await _secureStorage.getProviderApiKey(providerKey);

      // 优先使用安全存储中的 API key，如果不存在则使用设置中的值
      final apiKey = (secureApiKey != null && secureApiKey.isNotEmpty)
          ? secureApiKey
          : existingConfig.apiKey;

      updatedConfigs[entry.key] = existingConfig.copyWith(apiKey: apiKey);
    }

    return settings.copyWith(providerConfigs: updatedConfigs);
  }

  /// 从设置中移除 API keys（用于 SQLite 存储）
  AiRecognitionSettings _removeApiKeysFromSettings(AiRecognitionSettings settings) {
    final cleanedConfigs = <AiRecognitionProvider, AiProviderConfig>{};

    for (final entry in settings.providerConfigs.entries) {
      // 保留除 apiKey 外的所有配置
      cleanedConfigs[entry.key] = AiProviderConfig(
        provider: entry.value.provider,
        apiKey: '', // 清除 API key
        baseUrl: entry.value.baseUrl,
        modelName: entry.value.modelName,
        enabled: entry.value.enabled,
      );
    }

    return settings.copyWith(providerConfigs: cleanedConfigs);
  }

  /// 删除所有 AI 识别设置（包括安全存储中的 API keys）
  Future<void> deleteAiRecognitionSettings() async {
    // 1. 删除 SQLite 中的设置
    await _repository.delete('ai_recognition_settings');
    await _repository.delete('_ai_keys_migrated');

    // 2. 删除安全存储中的 API keys
    await _secureStorage.deleteAllProviderApiKeys();
  }
}
