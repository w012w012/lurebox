import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/services/csv_exporter.dart';
import 'package:lurebox/core/services/weather_service.dart';

void main() {
  group('CsvExporter', () {
    group('CsvExporter.escapeCsvField', () {
      test('returns empty string for null', () {
        expect(CsvExporter.escapeCsvField(null), equals(''));
      });

      test('returns field as-is when no special characters', () {
        expect(
            CsvExporter.escapeCsvField('simple text'), equals('simple text'),);
      });

      test('wraps field in quotes when it contains a comma', () {
        expect(CsvExporter.escapeCsvField('a, b'), equals('"a, b"'));
      });

      test('wraps field in quotes and doubles embedded double quotes', () {
        expect(CsvExporter.escapeCsvField('say "hello"'),
            equals('"say ""hello"""'),);
      });

      test('wraps field in quotes when it contains a newline', () {
        expect(CsvExporter.escapeCsvField('line1\nline2'),
            equals('"line1\nline2"'),);
      });

      test('handles integer input', () {
        expect(CsvExporter.escapeCsvField(42), equals('42'));
      });

      test('handles numeric string input', () {
        expect(CsvExporter.escapeCsvField('30.5'), equals('30.5'));
      });

      test('handles comma, double quote, and newline together', () {
        expect(
          CsvExporter.escapeCsvField('a, "b"\nc'),
          equals('"a, ""b""\nc"'),
        );
      });

      test('returns empty string for empty string input', () {
        expect(CsvExporter.escapeCsvField(''), equals(''));
      });

      test('handles double input without quotes', () {
        expect(CsvExporter.escapeCsvField(3.14), equals('3.14'));
      });
    });

    group('exportFishCatches', () {
      test('exports empty list with headers only', () async {
        final csv = await CsvExporter.exportFishCatches(catches: []);

        expect(csv, isNotEmpty);
        // First line should be headers
        final lines = csv.split('\n');
        expect(lines[0], contains('ID'));
        expect(lines[0], contains('品种'));
        expect(lines[0], contains('长度(cm)'));
      });

      test('exports basic fish catch data', () async {
        final catches = [
          FishCatch(
            id: 1,
            imagePath: '/test/fish.jpg',
            species: '鳜鱼',
            length: 35.5,
            weight: 1.2,
            fate: FishFateType.release,
            catchTime: DateTime(2024, 6, 15, 10, 30),
            locationName: '西湖',
            latitude: 30.25,
            longitude: 120.15,
            createdAt: DateTime(2024, 6, 15),
            updatedAt: DateTime(2024, 6, 15),
          ),
        ];

        final csv = await CsvExporter.exportFishCatches(catches: catches);
        final lines = csv.split('\n');

        // Should have header + 1 data row = 2 lines
        expect(lines.length, equals(2));

        // Data row should contain fish info
        expect(lines[1], contains('1')); // ID
        expect(lines[1], contains('鳜鱼')); // species
        expect(lines[1], contains('35.5')); // length
        expect(lines[1], contains('1.2')); // weight
        expect(lines[1], contains('放流')); // fate label
        expect(lines[1], contains('西湖')); // location
      });

      test('escapes commas in text fields', () async {
        final catches = [
          FishCatch(
            id: 1,
            imagePath: '/test/fish.jpg',
            species: '测试鱼种',
            length: 30,
            fate: FishFateType.keep,
            catchTime: DateTime(2024, 6, 15),
            locationName: '测试,地点', // Comma in location
            createdAt: DateTime(2024, 6, 15),
            updatedAt: DateTime(2024, 6, 15),
          ),
        ];

        final csv = await CsvExporter.exportFishCatches(catches: catches);
        final lines = csv.split('\n');

        // The location with comma should be quoted
        expect(lines[1], contains('"测试,地点"'));
      });

      test('escapes double quotes in text fields', () async {
        final catches = [
          FishCatch(
            id: 1,
            imagePath: '/test/fish.jpg',
            species: '测试"鱼', // Double quote in species
            length: 30,
            fate: FishFateType.release,
            catchTime: DateTime(2024, 6, 15),
            createdAt: DateTime(2024, 6, 15),
            updatedAt: DateTime(2024, 6, 15),
          ),
        ];

        final csv = await CsvExporter.exportFishCatches(catches: catches);
        final lines = csv.split('\n');

        // Double quotes should be escaped as ""
        expect(lines[1], contains('"测试""鱼"'));
      });

      test('escapes newlines in text fields', () async {
        final catches = [
          FishCatch(
            id: 1,
            imagePath: '/test/fish.jpg',
            species: '测试\n鱼', // Newline in species
            length: 30,
            fate: FishFateType.release,
            catchTime: DateTime(2024, 6, 15),
            createdAt: DateTime(2024, 6, 15),
            updatedAt: DateTime(2024, 6, 15),
          ),
        ];

        final csv = await CsvExporter.exportFishCatches(catches: catches);

        // Field with newline should be quoted and the newline escaped
        // The field value becomes "测试\n鱼"
        // When joining, there will still be row separators
        expect(csv.contains('"测试\n鱼"'), isTrue);
      });

      test('exports multiple catches correctly', () async {
        final catches = [
          FishCatch(
            id: 1,
            imagePath: '/test/1.jpg',
            species: '鳜鱼',
            length: 35,
            fate: FishFateType.release,
            catchTime: DateTime(2024, 6, 15),
            createdAt: DateTime(2024, 6, 15),
            updatedAt: DateTime(2024, 6, 15),
          ),
          FishCatch(
            id: 2,
            imagePath: '/test/2.jpg',
            species: '黑鱼',
            length: 40,
            fate: FishFateType.keep,
            catchTime: DateTime(2024, 6, 16),
            createdAt: DateTime(2024, 6, 16),
            updatedAt: DateTime(2024, 6, 16),
          ),
        ];

        final csv = await CsvExporter.exportFishCatches(catches: catches);
        final lines = csv.split('\n');

        // Header + 2 data rows
        expect(lines.length, equals(3));
        expect(lines[1], contains('鳜鱼'));
        expect(lines[2], contains('黑鱼'));
      });

      test('handles null optional fields', () async {
        final catches = [
          FishCatch(
            id: 1,
            imagePath: '/test/fish.jpg',
            species: '鳜鱼',
            length: 35,
            // weight is null
            fate: FishFateType.release,
            catchTime: DateTime(2024, 6, 15),
            // locationName is null
            // latitude/longitude are null
            createdAt: DateTime(2024, 6, 15),
            updatedAt: DateTime(2024, 6, 15),
          ),
        ];

        final csv = await CsvExporter.exportFishCatches(catches: catches);
        final lines = csv.split('\n');

        // Should not throw, should handle nulls gracefully
        expect(lines.length, equals(2));
      });

      test('excludes image paths when includeImagePaths is false', () async {
        final catches = [
          FishCatch(
            id: 1,
            imagePath: '/test/fish.jpg',
            species: '鳜鱼',
            length: 35,
            fate: FishFateType.release,
            catchTime: DateTime(2024, 6, 15),
            createdAt: DateTime(2024, 6, 15),
            updatedAt: DateTime(2024, 6, 15),
          ),
        ];

        final csv = await CsvExporter.exportFishCatches(
          catches: catches,
          includeImagePaths: false,
        );
        final lines = csv.split('\n');

        // Header should not contain image path columns
        expect(lines[0], isNot(contains('原始图片路径')));
        expect(lines[0], isNot(contains('水印图片路径')));
      });

      test('includes image paths by default', () async {
        final catches = [
          FishCatch(
            id: 1,
            imagePath: '/test/fish.jpg',
            watermarkedImagePath: '/test/fish_wm.jpg',
            species: '鳜鱼',
            length: 35,
            fate: FishFateType.release,
            catchTime: DateTime(2024, 6, 15),
            createdAt: DateTime(2024, 6, 15),
            updatedAt: DateTime(2024, 6, 15),
          ),
        ];

        final csv = await CsvExporter.exportFishCatches(catches: catches);
        final lines = csv.split('\n');

        expect(lines[0], contains('原始图片路径'));
        expect(lines[0], contains('水印图片路径'));
        expect(lines[1], contains('/test/fish.jpg'));
        expect(lines[1], contains('/test/fish_wm.jpg'));
      });

      test('marks pending recognition fish as 待识别', () async {
        final catches = [
          FishCatch(
            id: 1,
            imagePath: '/test/fish.jpg',
            species: 'Pending Species',
            length: 35,
            fate: FishFateType.release,
            catchTime: DateTime(2024, 6, 15),
            pendingRecognition: true,
            createdAt: DateTime(2024, 6, 15),
            updatedAt: DateTime(2024, 6, 15),
          ),
        ];

        final csv = await CsvExporter.exportFishCatches(catches: catches);
        final lines = csv.split('\n');

        expect(lines[1], contains('待识别'));
        expect(lines[1], isNot(contains('Pending Species')));
      });

      test('displays fate as 放流 for release', () async {
        final catches = [
          FishCatch(
            id: 1,
            imagePath: '/test/fish.jpg',
            species: '鳜鱼',
            length: 35,
            fate: FishFateType.release,
            catchTime: DateTime(2024, 6, 15),
            createdAt: DateTime(2024, 6, 15),
            updatedAt: DateTime(2024, 6, 15),
          ),
        ];

        final csv = await CsvExporter.exportFishCatches(catches: catches);
        expect(csv, contains('放流'));
      });

      test('displays fate as 保留 for keep', () async {
        final catches = [
          FishCatch(
            id: 1,
            imagePath: '/test/fish.jpg',
            species: '鳜鱼',
            length: 35,
            fate: FishFateType.keep,
            catchTime: DateTime(2024, 6, 15),
            createdAt: DateTime(2024, 6, 15),
            updatedAt: DateTime(2024, 6, 15),
          ),
        ];

        final csv = await CsvExporter.exportFishCatches(catches: catches);
        expect(csv, contains('保留'));
      });

      test('exports weather information correctly', () async {
        final catches = [
          FishCatch(
            id: 1,
            imagePath: '/test/fish.jpg',
            species: '鳜鱼',
            length: 35,
            fate: FishFateType.release,
            catchTime: DateTime(2024, 6, 15),
            weatherCode: 0, // Clear sky
            airTemperature: 25,
            pressure: 1013.25,
            createdAt: DateTime(2024, 6, 15),
            updatedAt: DateTime(2024, 6, 15),
          ),
        ];

        final csv = await CsvExporter.exportFishCatches(catches: catches);
        expect(csv, contains('晴'));
        expect(csv, contains('25'));
        expect(csv, contains('1013.25'));
      });

      test('exports equipment IDs correctly', () async {
        final catches = [
          FishCatch(
            id: 1,
            imagePath: '/test/fish.jpg',
            species: '鳜鱼',
            length: 35,
            fate: FishFateType.release,
            catchTime: DateTime(2024, 6, 15),
            equipmentId: 5,
            rodId: 10,
            reelId: 20,
            lureId: 30,
            createdAt: DateTime(2024, 6, 15),
            updatedAt: DateTime(2024, 6, 15),
          ),
        ];

        final csv = await CsvExporter.exportFishCatches(catches: catches);
        expect(csv, contains('5')); // equipmentId
        expect(csv, contains('10')); // rodId
        expect(csv, contains('20')); // reelId
        expect(csv, contains('30')); // lureId
      });

      test('handles unknown weather code', () async {
        final catches = [
          FishCatch(
            id: 1,
            imagePath: '/test/fish.jpg',
            species: '鳜鱼',
            length: 35,
            fate: FishFateType.release,
            catchTime: DateTime(2024, 6, 15),
            weatherCode: 999, // Unknown code
            createdAt: DateTime(2024, 6, 15),
            updatedAt: DateTime(2024, 6, 15),
          ),
        ];

        final csv = await CsvExporter.exportFishCatches(catches: catches);
        expect(csv, contains('未知'));
      });

      test('outputs UTF-8 encoded CSV', () async {
        final catches = [
          FishCatch(
            id: 1,
            imagePath: '/test/fish.jpg',
            species: '鳜鱼',
            length: 35,
            fate: FishFateType.release,
            catchTime: DateTime(2024, 6, 15),
            locationName: '杭州西湖',
            createdAt: DateTime(2024, 6, 15),
            updatedAt: DateTime(2024, 6, 15),
          ),
        ];

        final csv = await CsvExporter.exportFishCatches(catches: catches);

        // UTF-8 characters should be preserved
        expect(csv.contains('鳜鱼'), isTrue);
        expect(csv.contains('杭州西湖'), isTrue);
      });
    });

    group('weather code mapping', () {
      test('maps WMO weather codes correctly', () async {
        final testCodes = [
          0, 1, 2, 3, 45, 48, 51, 53, 55, 61, 63, 65, 71, 73, 75, 77, 80, 81,
          82, 85, 86, 95, 96, 99,
        ];

        for (final code in testCodes) {
          final expected = getWeatherDescription(code);
          final catches = [
            FishCatch(
              id: 1,
              imagePath: '/test/fish.jpg',
              species: 'Test',
              length: 30,
              fate: FishFateType.release,
              catchTime: DateTime(2024),
              weatherCode: code,
              createdAt: DateTime(2024),
              updatedAt: DateTime(2024),
            ),
          ];

          final csv = await CsvExporter.exportFishCatches(catches: catches);
          expect(csv, contains(expected),
              reason: 'Weather code $code should map to $expected',);
        }
      });

      test('maps unknown code to 未知', () async {
        final catches = [
          FishCatch(
            id: 1,
            imagePath: '/test/fish.jpg',
            species: 'Test',
            length: 30,
            fate: FishFateType.release,
            catchTime: DateTime(2024),
            weatherCode: 999,
            createdAt: DateTime(2024),
            updatedAt: DateTime(2024),
          ),
        ];

        final csv = await CsvExporter.exportFishCatches(catches: catches);
        expect(csv, contains('未知'));
      });
    });

    group('unit conversion in exportFishCatches', () {
      test('converts length from cm to m when lengthUnit is m', () async {
        // Fish stored in cm, display in m
        final catches = [
          FishCatch(
            id: 1,
            imagePath: '/test/fish.jpg',
            species: 'Bass',
            length: 100, // 100 cm stored
            fate: FishFateType.release,
            catchTime: DateTime(2024, 6, 15),
            createdAt: DateTime(2024, 6, 15),
            updatedAt: DateTime(2024, 6, 15),
          ),
        ];

        final csv = await CsvExporter.exportFishCatches(
          catches: catches,
          lengthUnit: 'm',
        );

        // 100 cm → 1.00 m
        expect(csv, contains('1.00'));
        expect(csv, contains('长度(m)'));
      });

      test('converts weight from kg to lb when weightUnit is lb', () async {
        final catches = [
          FishCatch(
            id: 1,
            imagePath: '/test/fish.jpg',
            species: 'Bass',
            length: 30,
            weight: 1, // 1 kg stored
            fate: FishFateType.release,
            catchTime: DateTime(2024, 6, 15),
            createdAt: DateTime(2024, 6, 15),
            updatedAt: DateTime(2024, 6, 15),
          ),
        ];

        final csv = await CsvExporter.exportFishCatches(
          catches: catches,
          weightUnit: 'lb',
        );

        // 1 kg ≈ 2.20 lb
        expect(csv, contains('2.20'));
        expect(csv, contains('重量(lb)'));
      });

      test('converts temperature from C to F when temperatureUnit is F',
          () async {
        final catches = [
          FishCatch(
            id: 1,
            imagePath: '/test/fish.jpg',
            species: 'Bass',
            length: 30,
            airTemperature: 20, // 20°C stored
            fate: FishFateType.release,
            catchTime: DateTime(2024, 6, 15),
            createdAt: DateTime(2024, 6, 15),
            updatedAt: DateTime(2024, 6, 15),
          ),
        ];

        final csv = await CsvExporter.exportFishCatches(
          catches: catches,
          temperatureUnit: 'F',
        );

        // 20°C → 68°F
        expect(csv, contains('68.0'));
        expect(csv, contains('气温(°F)'));
      });

      test('uses chinese unit symbols when isChinese is true', () async {
        final catches = [
          FishCatch(
            id: 1,
            imagePath: '/test/fish.jpg',
            species: 'Bass',
            length: 30,
            fate: FishFateType.release,
            catchTime: DateTime(2024, 6, 15),
            createdAt: DateTime(2024, 6, 15),
            updatedAt: DateTime(2024, 6, 15),
          ),
        ];

        final csv = await CsvExporter.exportFishCatches(
          catches: catches,
          isChinese: true,
        );

        expect(csv, contains('厘米'));
        expect(csv, contains('千克'));
      });

      test('converts latitude and longitude correctly', () async {
        final catches = [
          FishCatch(
            id: 1,
            imagePath: '/test/fish.jpg',
            species: 'Bass',
            length: 30,
            latitude: 30.123456,
            longitude: 120.654321,
            fate: FishFateType.release,
            catchTime: DateTime(2024, 6, 15),
            createdAt: DateTime(2024, 6, 15),
            updatedAt: DateTime(2024, 6, 15),
          ),
        ];

        final csv = await CsvExporter.exportFishCatches(catches: catches);

        expect(csv, contains('30.123456'));
        expect(csv, contains('120.654321'));
      });
    });
  });
}
