import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/utils/date_utils.dart';

void main() {
  group('DatePeriod', () {
    group('constructor', () {
      test('stores start and end dates', () {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 1, 31);
        final period = DatePeriod(start, end);

        expect(period.start, start);
        expect(period.end, end);
      });
    });

    group('DatePeriod.today', () {
      test('start is at midnight of today', () {
        final period = DatePeriod.today;
        final now = DateTime.now();

        expect(period.start.year, now.year);
        expect(period.start.month, now.month);
        expect(period.start.day, now.day);
        expect(period.start.hour, 0);
        expect(period.start.minute, 0);
        expect(period.start.second, 0);
        expect(period.start.millisecond, 0);
      });

      test('end is at midnight of tomorrow', () {
        final period = DatePeriod.today;
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        expect(period.end.year, tomorrow.year);
        expect(period.end.month, tomorrow.month);
        expect(period.end.day, tomorrow.day);
        expect(period.end.hour, 0);
        expect(period.end.minute, 0);
        expect(period.end.second, 0);
        expect(period.end.millisecond, 0);
      });

      test('duration is exactly one day', () {
        final period = DatePeriod.today;
        final duration = period.end.difference(period.start);

        expect(duration.inDays, 1);
        expect(duration.inHours, 24);
      });
    });

    group('DatePeriod.month', () {
      test('start is the first day of current month', () {
        final period = DatePeriod.month;
        final now = DateTime.now();

        expect(period.start.year, now.year);
        expect(period.start.month, now.month);
        expect(period.start.day, 1);
        expect(period.start.hour, 0);
        expect(period.start.minute, 0);
        expect(period.start.second, 0);
        expect(period.start.millisecond, 0);
      });

      test('end is the first day of next month', () {
        final period = DatePeriod.month;
        final now = DateTime.now();
        final nextMonth = DateTime(now.year, now.month + 1);

        expect(period.end.year, nextMonth.year);
        expect(period.end.month, nextMonth.month);
        expect(period.end.day, 1);
        expect(period.end.hour, 0);
        expect(period.end.minute, 0);
        expect(period.end.second, 0);
        expect(period.end.millisecond, 0);
      });

      test('end is first day of January next year when current month is December', () {
        final period = DatePeriod.month;
        // December case: next month is January of next year
        final now = DateTime.now();
        if (now.month == 12) {
          expect(period.end.year, now.year + 1);
          expect(period.end.month, 1);
        }
      });
    });

    group('DatePeriod.year', () {
      test('start is January 1st of current year', () {
        final period = DatePeriod.year;
        final now = DateTime.now();

        expect(period.start.year, now.year);
        expect(period.start.month, 1);
        expect(period.start.day, 1);
        expect(period.start.hour, 0);
        expect(period.start.minute, 0);
        expect(period.start.second, 0);
        expect(period.start.millisecond, 0);
      });

      test('end is January 1st of next year', () {
        final period = DatePeriod.year;
        final now = DateTime.now();

        expect(period.end.year, now.year + 1);
        expect(period.end.month, 1);
        expect(period.end.day, 1);
        expect(period.end.hour, 0);
        expect(period.end.minute, 0);
        expect(period.end.second, 0);
        expect(period.end.millisecond, 0);
      });
    });

    group('DatePeriod.all', () {
      test('start is year 2000', () {
        final period = DatePeriod.all;

        expect(period.start.year, 2000);
        expect(period.start.month, 1);
        expect(period.start.day, 1);
      });

      test('end is tomorrow at midnight', () {
        final period = DatePeriod.all;
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        expect(period.end.year, tomorrow.year);
        expect(period.end.month, tomorrow.month);
        expect(period.end.day, tomorrow.day);
        expect(period.end.hour, 0);
        expect(period.end.minute, 0);
        expect(period.end.second, 0);
        expect(period.end.millisecond, 0);
      });
    });
  });
}
