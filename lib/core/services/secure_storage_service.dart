import 'dart:convert' as convert;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/ai_recognition_settings.dart';

/// API 密钥存储服务接口
///
/// 用于依赖注入，方便测试时替换为 mock
abstract interface class ApiKeyStorage {
  Future<void> save(String providerKey, String apiKey);
  Future<String?> get(String providerKey);
  Future<void> delete(String providerKey);
  Future<bool> has(String providerKey);
  Future<void> deleteAll();
}

/// 生产环境实现：使用 FlutterSecureStorage
class SecureApiKeyStorage implements ApiKeyStorage {
  final FlutterSecureStorage _storage;

  SecureApiKeyStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  @override
  Future<void> save(String providerKey, String apiKey) async {
    if (providerKey.isEmpty || apiKey.isEmpty) {
      debugPrint('[SecureApiKeyStorage] Skipping empty provider or API key');
      return;
    }
    await _storage.write(key: _getKeyName(providerKey), value: apiKey);
    debugPrint('[SecureApiKeyStorage] Saved API key for provider: $providerKey');
  }

  @override
  Future<String?> get(String providerKey) async {
    if (providerKey.isEmpty) return null;
    return await _storage.read(key: _getKeyName(providerKey));
  }

  @override
  Future<void> delete(String providerKey) async {
    if (providerKey.isEmpty) return;
    await _storage.delete(key: _getKeyName(providerKey));
    debugPrint('[SecureApiKeyStorage] Deleted API key for provider: $providerKey');
  }

  @override
  Future<bool> has(String providerKey) async {
    final key = await get(providerKey);
    return key != null && key.isNotEmpty;
  }

  @override
  Future<void> deleteAll() async {
    final all = await _storage.readAll();
    for (final key in all.keys) {
      if (key.startsWith(_keyPrefix)) {
        await _storage.delete(key: key);
      }
    }
    debugPrint('[SecureApiKeyStorage] Deleted all provider API keys');
  }

  String _getKeyName(String providerKey) => '$_keyPrefix$providerKey';
  static const _keyPrefix = 'ai_api_key_';
}

/// 内存实现：用于测试
class InMemoryApiKeyStorage implements ApiKeyStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> save(String providerKey, String apiKey) async {
    if (providerKey.isEmpty || apiKey.isEmpty) return;
    _storage[providerKey] = apiKey;
  }

  @override
  Future<String?> get(String providerKey) async {
    return _storage[providerKey];
  }

  @override
  Future<void> delete(String providerKey) async {
    _storage.remove(providerKey);
  }

  @override
  Future<bool> has(String providerKey) async {
    final key = _storage[providerKey];
    return key != null && key.isNotEmpty;
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }
}

/// 安全存储服务 - 安全的敏感数据存储
///
/// 使用平台安全存储（iOS Keychain, Android EncryptedSharedPreferences）
/// 存储 API keys 等敏感信息。
///
/// 与 SQLite 存储分离，用于安全存储：
/// - AI 服务提供商 API keys
///
/// 使用方式：
/// ```dart
/// // 使用默认存储
/// await SecureStorageService.instance.saveProviderApiKey('openai', 'sk-xxx');
/// final key = await SecureStorageService.instance.getProviderApiKey('openai');
///
/// // 使用自定义存储（测试时）
/// final service = SecureStorageService(storage: InMemoryApiKeyStorage());
/// await service.saveProviderApiKey('openai', 'sk-xxx');
/// ```
class SecureStorageService {
  static SecureStorageService? _instance;
  static ApiKeyStorage? _defaultStorage;

  final ApiKeyStorage _storage;

  SecureStorageService({ApiKeyStorage? storage})
      : _storage = storage ?? _defaultStorage ?? SecureApiKeyStorage();

  /// 单例获取（使用默认存储）
  static SecureStorageService get instance =>
      _instance ??= SecureStorageService();

  /// 设置默认存储（用于全局配置）
  static void setDefaultStorage(ApiKeyStorage storage) {
    _defaultStorage = storage;
    _instance = SecureStorageService(storage: storage);
  }

  /// 重置为默认实现
  static void resetDefault() {
    _defaultStorage = null;
    _instance = null;
  }

  /// 保存提供商 API Key
  ///
  /// [providerKey] 提供商标识符（如 "openai", "gemini", "claude"）
  /// [apiKey] API 密钥
  Future<void> saveProviderApiKey(String providerKey, String apiKey) async {
    await _storage.save(providerKey, apiKey);
  }

  /// 读取提供商 API Key
  ///
  /// [providerKey] 提供商标识符
  /// 返回 API 密钥，如果不存在则返回 null
  Future<String?> getProviderApiKey(String providerKey) async {
    return await _storage.get(providerKey);
  }

  /// 删除提供商 API Key
  Future<void> deleteProviderApiKey(String providerKey) async {
    await _storage.delete(providerKey);
  }

  /// 批量保存提供商 API Keys
  Future<void> saveAllProviderApiKeys(Map<String, String> keys) async {
    for (final entry in keys.entries) {
      await saveProviderApiKey(entry.key, entry.value);
    }
  }

  /// 批量读取所有 API Keys
  Future<Map<String, String>> getAllProviderApiKeys() async {
    // 遍历所有可能的提供商
    final result = <String, String>{};
    for (final provider in AiRecognitionProvider.values) {
      final key = await getProviderApiKey(provider.value.toString());
      if (key != null && key.isNotEmpty) {
        result[provider.value.toString()] = key;
      }
    }
    return result;
  }

  /// 检查提供商是否存在 API Key
  Future<bool> hasProviderApiKey(String providerKey) async {
    return await _storage.has(providerKey);
  }

  /// 删除所有 API Keys
  Future<void> deleteAllProviderApiKeys() async {
    await _storage.deleteAll();
  }

  /// 从旧的 JSON 格式数据中提取并迁移 API keys
  ///
  /// [legacyJson] 旧的 JSON 格式数据
  /// 返回清理后的 JSON（不含 API keys）
  Future<String> migrateApiKeysFromJson(String legacyJson) async {
    try {
      final Map<String, dynamic> json =
          Map<String, dynamic>.from(convert.jsonDecode(legacyJson) as Map);

      final configs = json['providerConfigs'] as Map<String, dynamic>?;
      if (configs == null) return legacyJson;

      // 提取并迁移每个提供商的 API key
      for (final entry in configs.entries) {
        final config = entry.value as Map<String, dynamic>?;
        if (config != null && config.containsKey('apiKey')) {
          final apiKey = config['apiKey'] as String?;
          if (apiKey != null && apiKey.isNotEmpty) {
            await saveProviderApiKey(entry.key, apiKey);
            debugPrint(
                '[SecureStorageService] Migrated API key for provider: ${entry.key}');
          }
        }
      }

      // 返回清理后的 JSON
      final cleanedConfigs = <String, dynamic>{};
      for (final entry in configs.entries) {
        final config = Map<String, dynamic>.from(entry.value as Map);
        config.remove('apiKey');
        cleanedConfigs[entry.key] = config;
      }
      json['providerConfigs'] = cleanedConfigs;

      return convert.jsonEncode(json);
    } catch (e) {
      debugPrint('[SecureStorageService] Migration failed: $e');
      return legacyJson;
    }
  }
}
