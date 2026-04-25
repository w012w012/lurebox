import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/database/database.dart' as db_helper;

void main() {
  group('DatabaseHelper - currentTimestamp', () {
    test('currentTimestamp returns ISO 8601 parseable string', () {
      final timestamp = db_helper.DatabaseHelper.currentTimestamp();
      expect(timestamp, isNotEmpty);
      expect(() => DateTime.parse(timestamp), returnsNormally);
    });
  });
}
