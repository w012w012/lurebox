import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/features/stats/stats_detail_page.dart';

void main() {
  // ─── FIX F: 12 个月趋势按日历月递推（无漂移/冲突） ───
  group('last12MonthKeys (FIX F)', () {
    test('produces exactly 12 keys', () {
      final keys = last12MonthKeys(DateTime(2024, 6, 15), '月');
      expect(keys.length, equals(12));
    });

    test('produces 12 distinct buckets across a year boundary', () {
      // 2024-02 起算：跨年回退到 2023 年的月份。
      final keys = last12MonthKeys(DateTime(2024, 2, 10), '月');
      expect(keys.length, equals(12));
      // 连续 12 个日历月的月份数字互不相同 → 无桶冲突。
      expect(keys.toSet().length, equals(12));
    });

    test('keys are ordered oldest to current month', () {
      // 当前 2024-06，最早桶为 2023-07（'7月'），末桶为当前月（'6月'）。
      final keys = last12MonthKeys(DateTime(2024, 6, 1), '月');
      expect(keys.first, equals('7月'));
      expect(keys.last, equals('6月'));
    });

    test('handles January correctly (rolls into previous year)', () {
      // 当前 2024-01：最早桶为 2023-02（'2月'），末桶为 '1月'。
      final keys = last12MonthKeys(DateTime(2024), '月');
      expect(keys.length, equals(12));
      expect(keys.toSet().length, equals(12));
      expect(keys.last, equals('1月'));
      expect(keys.first, equals('2月'));
    });

    test('uses the provided month unit suffix', () {
      final keys = last12MonthKeys(DateTime(2024, 6), 'mo');
      expect(keys.last, equals('6mo'));
    });
  });

  // ─── FIX G: 显式 periodType 贯穿到详情页 ───
  group('StatsDetailPage periodType (FIX G)', () {
    test('stores explicit periodType passed via constructor', () {
      final page = StatsDetailPage(
        title: 'Today',
        startDate: DateTime(2024, 6, 15),
        endDate: DateTime(2024, 6, 16),
        periodType: 'today',
      );
      expect(page.periodType, equals('today'));
    });

    test('periodType defaults to null for back-compat', () {
      final page = StatsDetailPage(
        title: 'Today',
        startDate: DateTime(2024, 6, 15),
        endDate: DateTime(2024, 6, 16),
      );
      expect(page.periodType, isNull);
    });
  });
}
