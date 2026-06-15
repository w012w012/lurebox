import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/services/weather_service.dart'
    show getWeatherDescription;
import 'package:lurebox/core/utils/unit_converter.dart';

/// CSV 导出器 - 渔获数据转换为 CSV 格式
///
/// 将渔获记录转换为符合 RFC 4180 规范的 CSV 格式：
/// - 自动转义特殊字符（逗号、引号、换行 \n、回车 \r）
/// - 内容前置 UTF-8 BOM，确保 Excel 正确识别中文（避免乱码）
/// - 支持完整字段：基本信息、位置、天气、装备、钓组/钩信息、备注、时间戳
/// - 使用 UTF-8 编码，确保中文等字符正确显示
///
/// CSV 字段（按顺序）：
/// ID, 品种, 长度(cm), 重量(kg), 命运, 钓点, 经度, 纬度,
/// 气温(°C), 气压(hPa), 天气, 装备ID, 鱼竿ID, 鱼轮ID, 鱼饵ID,
/// 钓组类型, 铅坠重量, 铅坠位置, 钩型, 钩号, 钩重, 备注,
/// 图片路径, 水印图片路径, 创建时间, 更新时间, 捕获时间
class CsvExporter {
  /// UTF-8 字节顺序标记（BOM, U+FEFF）。
  ///
  /// Excel 默认按本地编码（如 GBK）打开 CSV，导致 UTF-8 中文乱码；
  /// 前置 BOM 可让 Excel 正确识别为 UTF-8。
  static const String _utf8Bom = '﻿';

  /// RFC 4180 compliant CSV field escaping.
  ///
  /// Handles: null → '', plain text → as-is,
  /// fields containing comma/double-quote/newline/carriage-return →
  /// double-quote wrapped（\r 也必须转义，否则 Excel 会把单元格内的回车
  /// 当作行分隔符而错位）。
  static String escapeCsvField(dynamic field) {
    if (field == null) return '';
    final str = field.toString();
    if (str.contains(',') ||
        str.contains('"') ||
        str.contains('\n') ||
        str.contains('\r')) {
      return '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  /// 获取天气描述
  static String _getWeatherDescription(int? weatherCode) {
    return getWeatherDescription(weatherCode);
  }

  static Future<String> exportFishCatches({
    required List<FishCatch> catches,
    bool includeImagePaths = true,
    bool includeLocation = true,
    String lengthUnit = 'cm',
    String weightUnit = 'kg',
    String temperatureUnit = 'C',
    bool isChinese = false,
  }) async {
    final lengthSymbol =
        UnitConverter.getLengthSymbol(lengthUnit, isChinese: isChinese);
    final weightSymbol =
        UnitConverter.getWeightSymbol(weightUnit, isChinese: isChinese);
    final tempSymbol = UnitConverter.getTemperatureSymbol(
      temperatureUnit,
      isChinese: isChinese,
    );

    // 完整的 CSV 表头
    final headers = [
      'ID',
      '品种',
      '长度($lengthSymbol)',
      '重量($weightSymbol)',
      '命运',
      if (includeLocation) ...['钓点', '经度', '纬度'],
      '气温($tempSymbol)',
      '气压(hPa)',
      '天气',
      '装备ID',
      '鱼竿ID',
      '鱼轮ID',
      '鱼饵ID',
      // 钓组/钩信息
      '钓组类型',
      '铅坠重量',
      '铅坠位置',
      '钩型',
      '钩号',
      '钩重',
      '备注',
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
      final displayLength = fish.lengthUnit != lengthUnit
          ? UnitConverter.convertLength(
              fish.length,
              fish.lengthUnit,
              lengthUnit,
            )
          : fish.length;

      // Convert weight to display unit
      final fishWeight = fish.weight;
      double? displayWeight;
      if (fishWeight != null) {
        displayWeight = fish.weightUnit != weightUnit
            ? UnitConverter.convertWeight(
                fishWeight,
                fish.weightUnit,
                weightUnit,
              )
            : fishWeight;
      }

      // Convert temperature to display unit
      final fishTemp = fish.airTemperature;
      double? displayTemp;
      if (fishTemp != null) {
        displayTemp = temperatureUnit != 'C'
            ? UnitConverter.convertTemperature(
                fishTemp,
                'C',
                temperatureUnit,
              )
            : fishTemp;
      }

      final row = <String>[
        // 基本信息
        fish.id.toString(),
        escapeCsvField(displaySpecies),
        displayLength.toStringAsFixed(2),
        escapeCsvField(displayWeight?.toStringAsFixed(2) ?? ''),
        escapeCsvField(fish.fate.label),
        // 位置信息
        if (includeLocation) ...[
          escapeCsvField(fish.locationName ?? ''),
          escapeCsvField(fish.longitude?.toString() ?? ''),
          escapeCsvField(fish.latitude?.toString() ?? ''),
        ],
        // 天气信息
        escapeCsvField(displayTemp?.toStringAsFixed(1) ?? ''),
        escapeCsvField(fish.pressure?.toString() ?? ''),
        escapeCsvField(_getWeatherDescription(fish.weatherCode)),
        // 装备信息
        escapeCsvField(fish.equipmentId?.toString() ?? ''),
        escapeCsvField(fish.rodId?.toString() ?? ''),
        escapeCsvField(fish.reelId?.toString() ?? ''),
        escapeCsvField(fish.lureId?.toString() ?? ''),
        // 钓组/钩信息
        escapeCsvField(fish.rigType ?? ''),
        escapeCsvField(fish.sinkerWeight ?? ''),
        escapeCsvField(fish.sinkerPosition ?? ''),
        escapeCsvField(fish.hookType ?? ''),
        escapeCsvField(fish.hookSize ?? ''),
        escapeCsvField(fish.hookWeight ?? ''),
        escapeCsvField(fish.notes ?? ''),
        // 图片路径
        if (includeImagePaths) ...[
          escapeCsvField(fish.imagePath),
          escapeCsvField(fish.watermarkedImagePath ?? ''),
        ],
        // 时间戳
        fish.createdAt.toIso8601String(),
        fish.updatedAt.toIso8601String(),
        fish.catchTime.toIso8601String(),
      ];

      rows.add(row);
    }

    final csvContent = rows.map((row) => row.join(',')).join('\n');

    // 前置 UTF-8 BOM，确保 Excel 以 UTF-8 打开（中文不乱码）。
    return '$_utf8Bom$csvContent';
  }
}
