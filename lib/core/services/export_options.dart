/// 导出选项 - 导出功能的配置数据类
///
/// 定义数据导出的各种选项：
/// - 日期范围：可选的起始和结束日期
/// - 物种筛选：可选的物种白名单
/// - 导出格式：CSV 或 PDF
/// - 可选字段：图片路径、位置坐标
///
/// 作为数据传输对象（DTO）使用。

class ExportOptions {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? speciesFilter;
  final ExportFormat format;
  final bool includeImagePaths;
  final bool includeLocation;

  const ExportOptions({
    this.startDate,
    this.endDate,
    this.speciesFilter,
    this.format = ExportFormat.csv,
    this.includeImagePaths = false,
    this.includeLocation = true,
  });
}

enum ExportFormat { csv, pdf }
