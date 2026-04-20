import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 安全存储服务 - 用于敏感数据的加密存储
///
/// 使用平台安全存储（iOS Keychain, Android EncryptedSharedPreferences）
/// 存储 API keys 等敏感信息。
///
/// 注意：此服务仅用于存储真正的敏感数据，不应用于存储一般配置。

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// API Key 存储键名前缀
  static const _apiKeyPrefix = 'api_key_';

  /// 保存 API Key
  static Future<void> saveApiKey(String provider, String apiKey) async {
    await _storage.write(
      key: '$_apiKeyPrefix$provider',
      value: apiKey,
    );
  }

  /// 读取 API Key
  static Future<String?> getApiKey(String provider) async {
    return await _storage.read(key: '$_apiKeyPrefix$provider');
  }

  /// 删除 API Key
  static Future<void> deleteApiKey(String provider) async {
    await _storage.delete(key: '$_apiKeyPrefix$provider');
  }

  /// 检查是否存在 API Key
  static Future<bool> hasApiKey(String provider) async {
    final key = await getApiKey(provider);
    return key != null && key.isNotEmpty;
  }

  /// 删除所有 API Keys
  static Future<void> deleteAllApiKeys() async {
    final all = await _storage.readAll();
    for (final key in all.keys) {
      if (key.startsWith(_apiKeyPrefix)) {
        await _storage.delete(key: key);
      }
    }
  }
}
