/// 价格区间配置
class PriceRanges {
  /// 最大价格限制
  static const double maxPrice = 1000000;

  /// 价格区间定义
  static const List<PriceRange> ranges = [
    PriceRange(label: '<100', min: 0, max: 100),
    PriceRange(label: '100-300', min: 100, max: 300),
    PriceRange(label: '300-500', min: 300, max: 500),
    PriceRange(label: '500-1000', min: 500, max: 1000),
    PriceRange(label: '>1000', min: 1000, max: double.infinity),
  ];

  /// 获取价格区间标签
  static String getLabel(double price) {
    for (final range in ranges) {
      if (price < range.max) {
        return range.label;
      }
    }
    return ranges.last.label;
  }
}

/// 价格区间
class PriceRange {
  final String label;
  final double min;
  final double max;

  const PriceRange({required this.label, required this.min, required this.max});
}
