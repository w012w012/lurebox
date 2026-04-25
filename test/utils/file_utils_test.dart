import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/utils/file_utils.dart';

void main() {
  group('FileUtils', () {
    group('generateUniqueFileName', () {
      test('returns filename with prefix and extension', () {
        final result = FileUtils.generateUniqueFileName('photo', 'jpg');

        expect(result, contains('photo'));
        expect(result, contains('jpg'));
        expect(result.split('.').length, 2);
      });

      test('includes timestamp in filename', () {
        final before = DateTime.now().millisecondsSinceEpoch;
        final result = FileUtils.generateUniqueFileName('photo', 'jpg');
        final after = DateTime.now().millisecondsSinceEpoch;

        // Extract timestamp from filename
        final lastDot = result.lastIndexOf('.');
        final timestampStr = result.substring('photo_'.length, lastDot);
        final timestamp = int.parse(timestampStr);

        expect(timestamp, greaterThanOrEqualTo(before));
        expect(timestamp, lessThanOrEqualTo(after));
      });

      test('generates unique names across different prefixes', () {
        final result1 = FileUtils.generateUniqueFileName('photo', 'jpg');
        final result2 = FileUtils.generateUniqueFileName('video', 'jpg');

        expect(result1, isNot(equals(result2)));
        expect(result1.startsWith('photo_'), isTrue);
        expect(result2.startsWith('video_'), isTrue);
      });
    });

    group('generateTimestampFileName', () {
      test('returns filename with extension', () {
        final result = FileUtils.generateTimestampFileName('png');

        expect(result, contains('png'));
        expect(result.split('.').length, 2);
        // Filename should be just timestamp.extension with no prefix
        expect(result.startsWith('png'), isFalse);
      });

      test('includes timestamp in filename', () {
        final before = DateTime.now().millisecondsSinceEpoch;
        final result = FileUtils.generateTimestampFileName('png');
        final after = DateTime.now().millisecondsSinceEpoch;

        // Extract timestamp from filename (before the dot)
        final lastDot = result.lastIndexOf('.');
        final timestampStr = result.substring(0, lastDot);
        final timestamp = int.parse(timestampStr);

        expect(timestamp, greaterThanOrEqualTo(before));
        expect(timestamp, lessThanOrEqualTo(after));
      });

      test('generates unique names across different extensions', () {
        final result1 = FileUtils.generateTimestampFileName('png');
        final result2 = FileUtils.generateTimestampFileName('jpg');

        expect(result1, isNot(equals(result2)));
      });

      test('filename format is timestamp.extension without prefix', () {
        final result = FileUtils.generateTimestampFileName('jpg');

        // Should be just numbers then dot then extension
        final lastDot = result.lastIndexOf('.');
        final timestampPart = result.substring(0, lastDot);
        final extensionPart = result.substring(lastDot + 1);

        expect(int.tryParse(timestampPart), isNotNull);
        expect(extensionPart, 'jpg');
      });
    });
  });
}
