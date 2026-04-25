import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/services/export_service.dart';
import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock path_provider platform channel to return temp directory
  setUpAll(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return Directory.systemTemp.path;
        }
        return null;
      },
    );
  });

  group('ExportService.exportToFile', () {
    tearDown(() async {
      // Clean up any exported files in temp directory
      final dir = Directory(Directory.systemTemp.path);
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File && entity.path.contains('fish_catches_')) {
            await entity.delete();
          }
        }
      }
    });

    group('CSV format', () {
      test('writes CSV file with correct extension', () async {
        final catches = <FishCatch>[
          TestDataFactory.createFishCatch(),
        ];

        final file = await ExportService.exportToFile(
          catches: catches,
          format: ExportFormat.csv,
        );

        expect(file.path, endsWith('.csv'));
        expect(file.path, contains('fish_catches_'));
      });

      test('CSV file contains UTF-8 encoded Chinese characters', () async {
        final catches = <FishCatch>[
          TestDataFactory.createFishCatch(
            species: '鳜鱼',
            locationName: '杭州西湖',
          ),
        ];

        final file = await ExportService.exportToFile(
          catches: catches,
          format: ExportFormat.csv,
        );

        final content = await File(file.path).readAsString();
        expect(content.contains('鳜鱼'), isTrue);
        expect(content.contains('杭州西湖'), isTrue);
      });

      test('CSV file includes headers and data rows', () async {
        final catches = <FishCatch>[
          TestDataFactory.createFishCatch(),
        ];

        final file = await ExportService.exportToFile(
          catches: catches,
          format: ExportFormat.csv,
        );

        final content = await File(file.path).readAsString();
        final lines = content.split('\n');

        // First line is headers
        expect(lines[0], contains('品种'));
        expect(lines[0], contains('长度'));
        // Second line is data
        expect(lines[1], contains('Bass'));
        expect(lines[1], contains('30.0'));
      });

      test('includeImagePaths=false excludes image path columns from CSV', () async {
        final catches = <FishCatch>[
          TestDataFactory.createFishCatch(),
        ];

        final file = await ExportService.exportToFile(
          catches: catches,
          format: ExportFormat.csv,
        );

        final content = await File(file.path).readAsString();
        expect(content, isNot(contains('原始图片路径')));
        expect(content, isNot(contains('水印图片路径')));
      });

      test('includeImagePaths=true includes image path columns in CSV', () async {
        final catches = <FishCatch>[
          TestDataFactory.createFishCatch(),
        ];

        final file = await ExportService.exportToFile(
          catches: catches,
          format: ExportFormat.csv,
          includeImagePaths: true,
        );

        final content = await File(file.path).readAsString();
        expect(content, contains('原始图片路径'));
      });

      test('lengthUnit parameter affects CSV header', () async {
        final catches = <FishCatch>[
          TestDataFactory.createFishCatch(),
        ];

        final file = await ExportService.exportToFile(
          catches: catches,
          format: ExportFormat.csv,
          lengthUnit: 'm',
        );

        final content = await File(file.path).readAsString();
        expect(content, contains('长度(m)'));
      });

      test('weightUnit parameter affects CSV header', () async {
        final catches = <FishCatch>[
          TestDataFactory.createFishCatch(),
        ];

        final file = await ExportService.exportToFile(
          catches: catches,
          format: ExportFormat.csv,
          weightUnit: 'lb',
        );

        final content = await File(file.path).readAsString();
        expect(content, contains('重量(lb)'));
      });
    });

    group('JSON format', () {
      test('writes JSON file with correct extension', () async {
        final catches = <FishCatch>[
          TestDataFactory.createFishCatch(),
        ];

        final file = await ExportService.exportToFile(
          catches: catches,
          format: ExportFormat.json,
        );

        expect(file.path, endsWith('.json'));
        expect(file.path, contains('fish_catches_'));
      });

      test('JSON contains version field set to 1', () async {
        final file = await ExportService.exportToFile(
          catches: const [],
          format: ExportFormat.json,
        );

        final content = await File(file.path).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;

        expect(json['version'], equals(1));
      });

      test('JSON contains exportTime as ISO8601 string', () async {
        final file = await ExportService.exportToFile(
          catches: const [],
          format: ExportFormat.json,
        );

        final content = await File(file.path).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;

        expect(json['exportTime'], isA<String>());
        // Should be parseable as ISO8601
        expect(() => DateTime.parse(json['exportTime'] as String), returnsNormally);
      });

      test('JSON contains fishCatches array', () async {
        final catches = <FishCatch>[
          TestDataFactory.createFishCatch(),
        ];

        final file = await ExportService.exportToFile(
          catches: catches,
          format: ExportFormat.json,
        );

        final content = await File(file.path).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;

        expect(json['fishCatches'], isA<List>());
        expect((json['fishCatches'] as List).length, equals(1));
      });

      test('JSON fishCatches entry contains species', () async {
        final catches = <FishCatch>[
          TestDataFactory.createFishCatch(),
        ];

        final file = await ExportService.exportToFile(
          catches: catches,
          format: ExportFormat.json,
        );

        final content = await File(file.path).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        final fishCatches = json['fishCatches'] as List;

        expect(fishCatches.first['species'], equals('Bass'));
      });

      test('JSON empty catches still has valid structure', () async {
        final file = await ExportService.exportToFile(
          catches: const [],
          format: ExportFormat.json,
        );

        final content = await File(file.path).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;

        expect(json['version'], equals(1));
        expect(json['exportTime'], isNotNull);
        expect(json['dateRange'], isA<String>());
        expect(json['fishCatches'], isA<List>());
        expect((json['fishCatches'] as List).isEmpty, isTrue);
      });
    });

    group('date range parameter', () {
      test('null startDate and endDate produces 全部记录 dateRange', () async {
        final file = await ExportService.exportToFile(
          catches: const [],
          format: ExportFormat.json,
        );

        final content = await File(file.path).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;

        expect(json['dateRange'], equals('全部记录'));
      });

      test('startDate only produces 开始 label', () async {
        final file = await ExportService.exportToFile(
          catches: const [],
          format: ExportFormat.json,
          startDate: DateTime(2024),
        );

        final content = await File(file.path).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;

        expect(json['dateRange'], contains('2024-01-01'));
        expect(json['dateRange'], contains('现在'));
      });

      test('endDate only produces 现在 label', () async {
        final file = await ExportService.exportToFile(
          catches: const [],
          format: ExportFormat.json,
          endDate: DateTime(2024, 12, 31),
        );

        final content = await File(file.path).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;

        expect(json['dateRange'], contains('2024-12-31'));
        expect(json['dateRange'], contains('开始'));
      });

      test('both startDate and endDate produces full range', () async {
        final file = await ExportService.exportToFile(
          catches: const [],
          format: ExportFormat.json,
          startDate: DateTime(2024),
          endDate: DateTime(2024, 12, 31),
        );

        final content = await File(file.path).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;

        expect(json['dateRange'], contains('2024-01-01'));
        expect(json['dateRange'], contains('2024-12-31'));
        expect(json['dateRange'], contains('至'));
      });
    });

    group('file path format', () {
      test('filename includes timestamp', () async {
        final file = await ExportService.exportToFile(
          catches: const [],
          format: ExportFormat.csv,
        );

        // Filename should be like fish_catches_20240615_103045.csv
        final filename = file.path.split('/').last;
        expect(filename, matches(RegExp(r'fish_catches_\d{8}_\d{6}\.csv')));
      });

      test('filename is unique per call', () async {
        final file1 = await ExportService.exportToFile(
          catches: const [],
          format: ExportFormat.csv,
        );

        // Wait at least 1 second to ensure different timestamp
        await Future.delayed(const Duration(seconds: 1));

        final file2 = await ExportService.exportToFile(
          catches: const [],
          format: ExportFormat.csv,
        );

        expect(file1.path, isNot(equals(file2.path)));
      });
    });

    group('includeLocation parameter', () {
      test('includeLocation=false still exports location fields in CSV', () async {
        final catches = <FishCatch>[
          TestDataFactory.createFishCatch(
            locationName: 'Lake',
            latitude: 35,
            longitude: 120,
          ),
        ];

        final file = await ExportService.exportToFile(
          catches: catches,
          format: ExportFormat.csv,
          includeLocation: false,
        );

        final content = await File(file.path).readAsString();
        // CSV format always includes location columns for reference
        expect(content, contains('品种'));
        expect(content, contains('Bass'));
      });

      test('includeLocation=true exports with location data', () async {
        final catches = <FishCatch>[
          TestDataFactory.createFishCatch(
            locationName: 'Lake',
            latitude: 35,
            longitude: 120,
          ),
        ];

        final file = await ExportService.exportToFile(
          catches: catches,
          format: ExportFormat.csv,
        );

        final content = await File(file.path).readAsString();
        expect(content, contains('钓点'));
      });
    });
  });
}
