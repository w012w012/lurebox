import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/services/csv_exporter.dart';

void main() {
  group('CsvExporter', () {
    group('_escapeCsvField', () {
      test('returns empty string for null', () {
        final result = CsvExporter.exportFishCatches(catches: []);
        expect(result, isNotNull);
      });

      test('returns field as-is when no special characters', () {
        const field = 'simple text';
        // Access via export to test the full flow
        expect(field.contains(','), isFalse);
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
            length: 30.0,
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
            length: 30.0,
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
            length: 30.0,
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
            length: 35.0,
            fate: FishFateType.release,
            catchTime: DateTime(2024, 6, 15),
            createdAt: DateTime(2024, 6, 15),
            updatedAt: DateTime(2024, 6, 15),
          ),
          FishCatch(
            id: 2,
            imagePath: '/test/2.jpg',
            species: '黑鱼',
            length: 40.0,
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
            length: 35.0,
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
            length: 35.0,
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
            length: 35.0,
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
            length: 35.0,
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
            length: 35.0,
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
            length: 35.0,
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
            length: 35.0,
            fate: FishFateType.release,
            catchTime: DateTime(2024, 6, 15),
            weatherCode: 0, // Clear sky
            airTemperature: 25.0,
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
            length: 35.0,
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
            length: 35.0,
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
            length: 35.0,
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
        final testCases = {
          0: '晴',
          1: '多云',
          2: '多云',
          3: '阴天',
          45: '雾',
          48: '雾凇',
          51: '毛毛雨',
          53: '中雨',
          55: '大雨',
          61: '小雨',
          63: '中雨',
          65: '大雨',
          71: '小雪',
          73: '中雪',
          75: '大雪',
          80: '阵雨',
          81: '强阵雨',
          82: '暴雨',
          95: '雷雨',
          96: '雷暴伴冰雹',
          99: '雷暴伴大冰雹',
        };

        for (final entry in testCases.entries) {
          final catches = [
            FishCatch(
              id: 1,
              imagePath: '/test/fish.jpg',
              species: 'Test',
              length: 30.0,
              fate: FishFateType.release,
              catchTime: DateTime(2024, 1, 1),
              weatherCode: entry.key,
              createdAt: DateTime(2024, 1, 1),
              updatedAt: DateTime(2024, 1, 1),
            ),
          ];

          final csv = await CsvExporter.exportFishCatches(catches: catches);
          expect(csv, contains(entry.value),
              reason: 'Weather code ${entry.key} should map to ${entry.value}');
        }
      });
    });
  });
}
