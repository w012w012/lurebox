/// 应用设置仓储层
///
/// 管理应用配置和用户设置的键值对存储，包括：
/// - 字符串值的存取
/// - 整数、浮点数、布尔值的便捷存取方法
/// - 批量读取和写入设置
/// - 设置存在性检查

abstract class SettingsRepository {
  Future<String?> get(String key);

  Future<String> getOrDefault(String key, String defaultValue);

  Future<void> set(String key, String value);

  Future<void> delete(String key);

  Future<bool> exists(String key);

  Future<Map<String, String>> getAll();

  Future<void> setAll(Map<String, String> settings);

  Future<int> getInt(String key, {int defaultValue = 0});

  Future<double> getDouble(String key, {double defaultValue = 0.0});

  Future<bool> getBool(String key, {bool defaultValue = false});

  Future<void> setInt(String key, int value);

  Future<void> setDouble(String key, double value);

  Future<void> setBool(String key, bool value);
}
