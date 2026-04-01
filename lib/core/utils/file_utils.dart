/// 文件工具类
class FileUtils {
  /// 生成唯一文件名
  /// [prefix] 文件名前缀
  /// [extension] 文件扩展名（不带点）
  static String generateUniqueFileName(String prefix, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_$timestamp.$extension';
  }

  /// 生成时间戳文件名
  /// [extension] 文件扩展名（不带点）
  static String generateTimestampFileName(String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$timestamp.$extension';
  }
}
