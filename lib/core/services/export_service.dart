import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/services/csv_exporter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// 导出服务 - 渔获数据导出与分享
///
/// 支持导出为 CSV 和 JSON 两种格式：
/// - CSV：通用电子表格格式，包含渔获详情、位置、装备信息
/// - JSON：完整备份格式，可用于数据恢复
///
/// 导出文件自动命名为 fish_catches_YYYYMMDD_HHmmss.ext
/// 导出完成后返回 XFile 供分享使用

enum ExportFormat { csv, json }

class ExportService {
  static Future<XFile> exportToFile({
    required List<FishCatch> catches,
    required ExportFormat format,
    DateTime? startDate,
    DateTime? endDate,
    bool includeImagePaths = false,
    bool includeLocation = true,
    String lengthUnit = 'cm',
    String weightUnit = 'kg',
    String temperatureUnit = 'C',
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final dateRange = _getDateRangeLabel(startDate, endDate);

    String filePath;
    XFile xFile;

    if (format == ExportFormat.csv) {
      filePath = '${directory.path}/fish_catches_$timestamp.csv';
      final content = await CsvExporter.exportFishCatches(
        catches: catches,
        includeImagePaths: includeImagePaths,
        lengthUnit: lengthUnit,
        weightUnit: weightUnit,
        temperatureUnit: temperatureUnit,
      );
      await File(filePath).writeAsString(content);
      xFile = XFile(filePath);
    } else {
      // JSON format
      filePath = '${directory.path}/fish_catches_$timestamp.json';
      final jsonData = {
        'version': 1,
        'exportTime': DateTime.now().toIso8601String(),
        'dateRange': dateRange,
        'fishCatches': catches.map((f) => f.toMap()).toList(),
      };
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      await File(filePath).writeAsString(jsonString);
      xFile = XFile(filePath);
    }

    return xFile;
  }

  static String _getDateRangeLabel(DateTime? start, DateTime? end) {
    if (start == null && end == null) return '全部记录';
    final dateFormat = DateFormat('yyyy-MM-dd');
    final startStr = start != null ? dateFormat.format(start) : '开始';
    final endStr = end != null ? dateFormat.format(end) : '现在';
    return '$startStr 至 $endStr';
  }
}
