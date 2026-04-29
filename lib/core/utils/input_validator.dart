/// 输入验证工具类
///
/// 在 Service 层入口处验证用户输入，防止无效数据写入数据库。
/// 验证规则：
/// - 去除首尾空白
/// - 拒绝 null 字节
/// - 限制最大长度
class InputValidator {
  InputValidator._();

  static const int _maxNameLength = 200;
  static const int _maxDescriptionLength = 2000;

  /// 验证并清理名称类字段（物种名、装备名、地名等）
  ///
  /// 返回清理后的字符串，如果无效则抛出 [ValidationException]。
  static String validateName(String? value, {String fieldName = 'name'}) {
    if (value == null || value.trim().isEmpty) {
      throw ValidationException('$fieldName cannot be empty');
    }
    final cleaned = _sanitize(value.trim());
    if (cleaned.length > _maxNameLength) {
      throw ValidationException(
        '$fieldName exceeds maximum length of $_maxNameLength characters',
      );
    }
    return cleaned;
  }

  /// 验证并清理可选名称字段
  ///
  /// 如果值为 null 或空，返回 null。否则验证并返回清理后的字符串。
  static String? validateOptionalName(
    String? value, {
    String fieldName = 'name',
  }) {
    if (value == null || value.trim().isEmpty) return null;
    return validateName(value, fieldName: fieldName);
  }

  /// 验证描述类字段
  static String? validateDescription(
    String? value, {
    String fieldName = 'description',
  }) {
    if (value == null || value.trim().isEmpty) return null;
    final cleaned = _sanitize(value.trim());
    if (cleaned.length > _maxDescriptionLength) {
      throw ValidationException(
        '$fieldName exceeds maximum length of $_maxDescriptionLength characters',
      );
    }
    return cleaned;
  }

  /// 去除控制字符和 Unicode 格式字符（保留换行和制表符）
  static String _sanitize(String value) {
    // 移除 ASCII 控制字符（保留 \n \r \t）
    // 和 Unicode 格式字符（Cf 类别）：
    // U+200B-U+200F 零宽字符
    // U+2028-U+2029 行/段落分隔符
    // U+202A-U+202E 方向格式字符
    // U+2060-U+2069 词连接符及不可见运算符
    // U+FEFF        BOM
    return value.replaceAll(
      RegExp(
        '[\\x00-\\x08\\x0B\\x0C\\x0E-\\x1F\\x7F'
        '\\u200B-\\u200F\\u2028-\\u2029'
        '\\u202A-\\u202E\\u2060-\\u2069\\uFEFF]',
      ),
      '',
    );
  }
}

/// 输入验证异常
class ValidationException implements Exception {
  const ValidationException(this.message);
  final String message;

  @override
  String toString() => 'ValidationException: $message';
}
