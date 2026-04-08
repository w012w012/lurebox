import '../models/fish_catch.dart';
import '../utils/unit_converter.dart';

/// CSV 导出器 - 渔获数据转换为 CSV 格式
///
/// 将渔获记录转换为符合 RFC 4180 规范的 CSV 格式：
/// - 自动转义特殊字符（逗号、引号、换行）
/// - 支持完整字段：基本信息、位置、天气、装备、时间戳
/// - 使用 UTF-8 编码，确保中文等字符正确显示
///
/// CSV 字段（按顺序）：
/// ID, 品种, 长度(cm), 重量(kg), 命运, 钓点, 经度, 纬度,
/// 气温(°C), 气压(hPa), 天气, 装备ID, 鱼竿ID, 鱼轮ID, 鱼饵ID,
/// 图片路径, 水印图片路径, 创建时间, 更新时间, 捕获时间
class CsvExporter {
  static String _escapeCsvField(dynamic field) {
    if (field == null) return '';
    final str = field.toString();
    if (str.contains(',') || str.contains('"') || str.contains('\n')) {
      return '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  /// 获取天气描述
  static String _getWeatherDescription(int? weatherCode) {
    if (weatherCode == null) return '';
    // WMO Weather interpretation codes (WW)
    final weatherMap = {
      0: '晴',
      1: '多云',
      2: '多云',
      3: '阴天',
      45: '雾',
      48: '雾凇',
      51: '毛毛雨',
      53: '中雨',
      55: '大雨',
      61: '小雨',
      63: '中雨',
      65: '大雨',
      71: '小雪',
      73: '中雪',
      75: '大雪',
      80: '阵雨',
      81: '强阵雨',
      82: '暴雨',
      95: '雷雨',
      96: '雷暴伴冰雹',
      99: '雷暴伴大冰雹',
    };
    return weatherMap[weatherCode] ?? '未知';
  }

  static Future<String> exportFishCatches({
    required List<FishCatch> catches,
    bool includeImagePaths = true,
    String lengthUnit = 'cm',
    String weightUnit = 'kg',
    String temperatureUnit = 'C',
  }) async {
    final lengthSymbol = UnitConverter.getLengthSymbol(lengthUnit);
    final weightSymbol = UnitConverter.getWeightSymbol(weightUnit);
    final tempSymbol = UnitConverter.getTemperatureSymbol(temperatureUnit);

    // 完整的 CSV 表头
    final headers = [
      'ID',
      '品种',
      '长度($lengthSymbol)',
      '重量($weightSymbol)',
      '命运',
      '钓点',
      '经度',
      '纬度',
      '气温($tempSymbol)',
      '气压(hPa)',
      '天气',
      '装备ID',
      '鱼竿ID',
      '鱼轮ID',
      '鱼饵ID',
      if (includeImagePaths) ...['原始图片路径', '水印图片路径'],
      '创建时间',
      '更新时间',
      '捕获时间',
    ];

    final rows = <List<String>>[headers];

    for (final fish in catches) {
      // 待识别记录的品种显示为"待识别"
      final displaySpecies = fish.pendingRecognition ? '待识别' : fish.species;

      // Convert length to display unit
      final displayLength = fish.lengthUnit != null && fish.lengthUnit != lengthUnit
          ? UnitConverter.convertLength(fish.length, fish.lengthUnit!, lengthUnit)
          : fish.length;

      // Convert weight to display unit
      double? displayWeight;
      if (fish.weight != null) {
        displayWeight = fish.weightUnit != null && fish.weightUnit != weightUnit
            ? UnitConverter.convertWeight(fish.weight!, fish.weightUnit!, weightUnit)
            : fish.weight;
      }

      // Convert temperature to display unit
      double? displayTemp;
      if (fish.airTemperature != null) {
        displayTemp = temperatureUnit != 'C'
            ? UnitConverter.convertTemperature(fish.airTemperature!, 'C', temperatureUnit)
            : fish.airTemperature;
      }

      final row = <String>[
        // 基本信息
        fish.id.toString(),
        _escapeCsvField(displaySpecies),
        displayLength.toStringAsFixed(2),
        _escapeCsvField(displayWeight?.toStringAsFixed(2) ?? ''),
        _escapeCsvField(fish.fate.label),
        // 位置信息
        _escapeCsvField(fish.locationName ?? ''),
        _escapeCsvField(fish.longitude?.toString() ?? ''),
        _escapeCsvField(fish.latitude?.toString() ?? ''),
        // 天气信息
        _escapeCsvField(displayTemp?.toStringAsFixed(1) ?? ''),
        _escapeCsvField(fish.pressure?.toString() ?? ''),
        _escapeCsvField(_getWeatherDescription(fish.weatherCode)),
        // 装备信息
        _escapeCsvField(fish.equipmentId?.toString() ?? ''),
        _escapeCsvField(fish.rodId?.toString() ?? ''),
        _escapeCsvField(fish.reelId?.toString() ?? ''),
        _escapeCsvField(fish.lureId?.toString() ?? ''),
        // 图片路径
        if (includeImagePaths) ...[
          _escapeCsvField(fish.imagePath),
          _escapeCsvField(fish.watermarkedImagePath ?? ''),
        ],
        // 时间戳
        fish.createdAt.toIso8601String(),
        fish.updatedAt.toIso8601String(),
        fish.catchTime.toIso8601String(),
      ];

      rows.add(row);
    }

    final csvContent = rows.map((row) => row.join(',')).join('\n');

    return csvContent;
  }
}
