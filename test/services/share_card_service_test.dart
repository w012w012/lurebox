import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurebox/core/services/share_card_service.dart';
import 'package:lurebox/core/services/share_template.dart';

void main() {
  group('ShareCardService', () {
    group('captureWidget', () {
      testWidgets('returns null when RenderObject is null',
          (WidgetTester tester) async {
        // Arrange
        final key = GlobalKey();

        // Act
        final result = await ShareCardService.captureWidget(key);

        // Assert
        expect(result, isNull);
      });

      // Note: captureWidget with actual rendering requires GPU and is tested in
      // integration tests. The method itself is a simple wrapper around
      // RenderRepaintBoundary.toImage() which requires display access.
    });

    group('generateShareText', () {
      test('returns empty string when showHashtags and showStats are false',
          () {
        // Arrange
        const config = ShareCardConfig(
          showHashtags: false,
          showStats: false,
        );

        // Act
        final result = ShareCardService.generateShareText(config);

        // Assert
        expect(result, isEmpty);
      });

      test(
          'uses defaultHashtags when customHashtags is empty with showHashtags=true',
          () {
        // Arrange
        const config = ShareCardConfig(
          showHashtags: true,
          showStats: false,
          customHashtags: [],
        );

        // Act
        final result = ShareCardService.generateShareText(config);

        // Assert
        expect(result, equals(ShareCardConfig.defaultHashtags.join(' ')));
      });

      test('uses customHashtags when provided with showHashtags=true', () {
        // Arrange
        const config = ShareCardConfig(
          showHashtags: true,
          showStats: false,
          customHashtags: ['#custom', '#tags'],
        );

        // Act
        final result = ShareCardService.generateShareText(config);

        // Assert
        expect(result, equals('#custom #tags'));
      });

      test('returns empty string when showStats is true but statsData is null',
          () {
        // Arrange
        const config = ShareCardConfig(
          showHashtags: false,
          showStats: true,
          statsData: null,
        );

        // Act
        final result = ShareCardService.generateShareText(config);

        // Assert
        expect(result, isEmpty);
      });

      test('includes stats when showStats is true and statsData is provided',
          () {
        // Arrange
        const config = ShareCardConfig(
          showHashtags: false,
          showStats: true,
          statsData: {
            'totalCatches': 42,
            'speciesCount': 5,
          },
        );

        // Act
        final result = ShareCardService.generateShareText(config);

        // Assert
        expect(result, contains('Total Catches: 42'));
        expect(result, contains('Species: 5'));
      });

      test('includes only available stats when some keys are missing', () {
        // Arrange
        const config = ShareCardConfig(
          showHashtags: false,
          showStats: true,
          statsData: {
            'totalCatches': 10,
            // 'speciesCount' is missing
          },
        );

        // Act
        final result = ShareCardService.generateShareText(config);

        // Assert
        expect(result, contains('Total Catches: 10'));
        expect(result, isNot(contains('Species:')));
      });

      test('combines hashtags and stats correctly', () {
        // Arrange
        const config = ShareCardConfig(
          showHashtags: true,
          showStats: true,
          customHashtags: ['#fishing'],
          statsData: {
            'totalCatches': 25,
          },
        );

        // Act
        final result = ShareCardService.generateShareText(config);

        // Assert
        expect(result, contains('#fishing'));
        expect(result, contains('Total Catches: 25'));
      });
    });

    group('generateShareCard', () {
      testWidgets('returns null when boundary is null',
          (WidgetTester tester) async {
        // Arrange
        final key = GlobalKey();

        // Act
        final result = await ShareCardService.generateShareCard(
          repaintBoundaryKey: key,
        );

        // Assert
        expect(result, isNull);
      });

      // Note: generateShareCard with actual rendering requires GPU and is tested
      // in integration tests. The method calls captureWidget which needs display.
    });

    // Note: shareImage() and shareText() require platform channels (share_plus)
    // and cannot be unit tested without mocking. They are tested in integration tests.
  });
}
