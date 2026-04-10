/// 分页结果数据模型
///
/// 泛型包装类，用于包装分页查询的结果。
/// 适用于所有需要分页的数据列表。
///
/// 类型参数：
/// - T: 列表中元素的类型
///
/// 字段说明：
/// - items: 当前页的数据列表
/// - totalCount: 总记录数（所有页的总数）
/// - page: 当前页码（从1开始）
/// - pageSize: 每页大小
/// - hasMore: 是否还有更多数据（用于判断是否需要继续加载）
///
/// 使用场景：
/// - 渔获记录分页加载
/// - 钓具列表分页加载
/// - 钓点列表分页加载
/// - 任何需要分页展示的数据
///
/// 设计特点：
/// - 泛型设计，支持任意数据类型
/// - 简洁的数据结构，易于理解和解析
/// - hasMore 字段简化了"是否还有更多"的判断逻辑
library;

class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final bool hasMore;

  const PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  PaginatedResult<T> copyWith({
    List<T>? items,
    int? totalCount,
    int? page,
    int? pageSize,
    bool? hasMore,
  }) {
    return PaginatedResult<T>(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginatedResult<T> &&
        other.totalCount == totalCount &&
        other.page == page &&
        other.pageSize == pageSize &&
        other.hasMore == hasMore &&
        _listEquals(other.items, items);
  }

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(totalCount, page, pageSize, hasMore);
}
