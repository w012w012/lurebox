/// 单位换算工具类
/// 以公制为基准进行换算：长度以 cm 为基准，重量以 kg 为基准
class UnitConverter {
  // ==================== 长度换算 ====================

  /// 将任意长度单位转换为厘米
  static double toBaseCm(double value, String fromUnit) {
    switch (fromUnit) {
      case 'cm':
        return value;
      case 'm':
        return value * 100;
      case 'mm':
        return value / 10;
      case 'inch':
        return value * 2.54;
      case 'ft':
        return value * 30.48;
      default:
        return value;
    }
  }

  /// 将厘米转换为目标长度单位
  static double fromBaseCm(double cmValue, String toUnit) {
    switch (toUnit) {
      case 'cm':
        return cmValue;
      case 'm':
        return cmValue / 100;
      case 'mm':
        return cmValue * 10;
      case 'inch':
        return cmValue / 2.54;
      case 'ft':
        return cmValue / 30.48;
      default:
        return cmValue;
    }
  }

  /// 通用长度换算
  static double convertLength(double value, String fromUnit, String toUnit) {
    final base = toBaseCm(value, fromUnit);
    return fromBaseCm(base, toUnit);
  }

  // ==================== 重量换算 ====================

  /// 将任意重量单位转换为千克
  static double toBaseKg(double value, String fromUnit) {
    switch (fromUnit) {
      case 'kg':
        return value;
      case 'lb':
        return value * 0.453592;
      case 'oz':
        return value * 0.0283495;
      case 'g':
        return value * 0.001;
      default:
        return value;
    }
  }

  /// 将千克转换为目标重量单位
  static double fromBaseKg(double kgValue, String toUnit) {
    switch (toUnit) {
      case 'kg':
        return kgValue;
      case 'lb':
        return kgValue / 0.453592;
      case 'oz':
        return kgValue / 0.0283495;
      case 'g':
        return kgValue / 0.001;
      default:
        return kgValue;
    }
  }

  /// 通用重量换算
  static double convertWeight(double value, String fromUnit, String toUnit) {
    final base = toBaseKg(value, fromUnit);
    return fromBaseKg(base, toUnit);
  }

  // ==================== 距离换算 ====================

  /// 将任意距离单位转换为米
  static double toBaseMeter(double value, String fromUnit) {
    switch (fromUnit) {
      case 'm':
        return value;
      case 'km':
        return value * 1000;
      case 'ft':
        return value * 0.3048;
      case 'mile':
        return value * 1609.344;
      default:
        return value;
    }
  }

  /// 将米转换为目标距离单位
  static double fromBaseMeter(double meterValue, String toUnit) {
    switch (toUnit) {
      case 'm':
        return meterValue;
      case 'km':
        return meterValue / 1000;
      case 'ft':
        return meterValue / 0.3048;
      case 'mile':
        return meterValue / 1609.344;
      default:
        return meterValue;
    }
  }

  /// 通用距离换算
  static double convertDistance(double value, String fromUnit, String toUnit) {
    final base = toBaseMeter(value, fromUnit);
    return fromBaseMeter(base, toUnit);
  }

  // ==================== 温度换算 ====================

  /// 将任意温度单位转换为摄氏度
  static double toBaseCelsius(double value, String fromUnit) {
    switch (fromUnit) {
      case 'C':
        return value;
      case 'F':
        return (value - 32) * 5 / 9;
      default:
        return value;
    }
  }

  /// 将摄氏度转换为目标温度单位
  static double fromBaseCelsius(double cValue, String toUnit) {
    switch (toUnit) {
      case 'C':
        return cValue;
      case 'F':
        return cValue * 9 / 5 + 32;
      default:
        return cValue;
    }
  }

  /// 通用温度换算
  static double convertTemperature(
    double value,
    String fromUnit,
    String toUnit,
  ) {
    final base = toBaseCelsius(value, fromUnit);
    return fromBaseCelsius(base, toUnit);
  }

  // ==================== 单位符号（统一格式：中文名（符号））====================

  static const _lengthSymbols = {
    'cm': '厘米（cm）',
    'm': '米（m）',
    'mm': '毫米（mm）',
    'inch': '英寸（in）',
    'ft': '英尺（ft）',
  };

  static const _weightSymbols = {
    'kg': '千克（kg）',
    'lb': '磅（lb）',
    'oz': '盎司（oz）',
    'g': '克（g）',
  };

  static const _distanceSymbols = {
    'm': '米（m）',
    'km': '千米（km）',
    'ft': '英尺（ft）',
    'mile': '英里（mi）',
  };

  static const _temperatureSymbols = {'C': '摄氏度（°C）', 'F': '华氏度（°F）'};

  /// 获取长度单位符号
  static String getLengthSymbol(String unit) => _lengthSymbols[unit] ?? unit;

  /// 获取重量单位符号
  static String getWeightSymbol(String unit) => _weightSymbols[unit] ?? unit;

  /// 获取距离单位符号
  static String getDistanceSymbol(String unit) =>
      _distanceSymbols[unit] ?? unit;

  /// 获取温度单位符号
  static String getTemperatureSymbol(String unit) =>
      _temperatureSymbols[unit] ?? unit;

  // ==================== 格式化显示 ====================

  /// 格式化长度显示
  static String formatLength(double value, String unit, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)} ${getLengthSymbol(unit)}';
  }

  /// 格式化重量显示
  static String formatWeight(double value, String unit, {int decimals = 2}) {
    return '${value.toStringAsFixed(decimals)} ${getWeightSymbol(unit)}';
  }

  /// 格式化距离显示
  static String formatDistance(double value, String unit, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)} ${getDistanceSymbol(unit)}';
  }

  /// 格式化温度显示
  static String formatTemperature(
    double value,
    String unit, {
    int decimals = 1,
  }) {
    return '${value.toStringAsFixed(decimals)}${getTemperatureSymbol(unit)}';
  }
}
