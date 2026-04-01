/// 日期范围工具类
class DatePeriod {
  final DateTime start;
  final DateTime end;

  const DatePeriod(this.start, this.end);

  /// 今日
  static DatePeriod get today {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return DatePeriod(start, end);
  }

  /// 本月
  static DatePeriod get month {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    return DatePeriod(start, end);
  }

  /// 本年
  static DatePeriod get year {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year + 1, 1, 1);
    return DatePeriod(start, end);
  }

  /// 全部（最早日期到今天）
  static DatePeriod get all {
    final now = DateTime.now();
    final end = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    return DatePeriod(DateTime(2000, 1, 1), end);
  }
}
