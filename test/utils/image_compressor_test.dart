import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:lurebox/core/services/error_service.dart';
import 'package:lurebox/core/utils/image_compressor.dart';

/// Replicates the dimension-calculation algorithm from ImageCompressor
/// so we can unit-test the pure math without touching platform I/O.
(List<int> newDimensions, double ratio) _calculateDimensions({
  required int imageWidth,
  required int imageHeight,
  required int targetMaxWidth,
  required int targetMaxHeight,
}) {
  var newWidth = imageWidth;
  var newHeight = imageHeight;

  if (imageWidth > targetMaxWidth || imageHeight > targetMaxHeight) {
    final ratio = (targetMaxWidth / imageWidth).clamp(0.0, 1.0);
    final ratioHeight = (targetMaxHeight / imageHeight).clamp(0.0, 1.0);
    final finalRatio = min(ratio, ratioHeight);

    newWidth = (imageWidth * finalRatio).round();
    newHeight = (imageHeight * finalRatio).round();
    return ([newWidth, newHeight], finalRatio);
  }

  return ([newWidth, newHeight], 1.0);
}

/// Encodes a solid-color image to JPEG bytes for I/O-based tests.
List<int> _encodeTestJpeg(int width, int height) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(255, 0, 0));
  return img.encodeJpg(image, quality: 95);
}

void main() {
  group('ImageCompressor', () {
    group('constants', () {
      test('default quality is 85', () {
        expect(ImageCompressor.defaultQuality, 85);
      });

      test('max dimensions are 1920x1920', () {
        expect(ImageCompressor.maxWidth, 1920);
        expect(ImageCompressor.maxHeight, 1920);
      });

      test('thumbnail dimensions are 400x400', () {
        expect(ImageCompressor.thumbnailWidth, 400);
        expect(ImageCompressor.thumbnailHeight, 400);
      });
    });

    group('dimension calculation (pure logic)', () {
      test(
        'keeps original dimensions when both are within max',
        () {
          final (dims, ratio) = _calculateDimensions(
            imageWidth: 800,
            imageHeight: 600,
            targetMaxWidth: 1920,
            targetMaxHeight: 1920,
          );
          expect(dims, [800, 600]);
          expect(ratio, 1.0);
        },
      );

      test(
        'scales down proportionally when width exceeds max',
        () {
          // 3840x1080 → width clamped to 1920, height scales by 0.5
          final (dims, ratio) = _calculateDimensions(
            imageWidth: 3840,
            imageHeight: 1080,
            targetMaxWidth: 1920,
            targetMaxHeight: 1920,
          );
          expect(dims[0], 1920);
          expect(dims[1], 540);
          expect(ratio, closeTo(0.5, 0.001));
        },
      );

      test(
        'scales down proportionally when height exceeds max',
        () {
          // 1080x3840 → height clamped to 1920, width scales by 0.5
          final (dims, ratio) = _calculateDimensions(
            imageWidth: 1080,
            imageHeight: 3840,
            targetMaxWidth: 1920,
            targetMaxHeight: 1920,
          );
          expect(dims[0], 540);
          expect(dims[1], 1920);
          expect(ratio, closeTo(0.5, 0.001));
        },
      );

      test(
        'uses the smaller ratio when both dimensions exceed max',
        () {
          // 3840x2160 (16:9) → limit by width: ratio = 1920/3840 = 0.5
          final (dims, _) = _calculateDimensions(
            imageWidth: 3840,
            imageHeight: 2160,
            targetMaxWidth: 1920,
            targetMaxHeight: 1920,
          );
          // Width-limited: 0.5 < 0.889 (1920/2160)
          expect(dims[0], 1920);
          expect(dims[1], 1080);
        },
      );

      test(
        'handles very wide aspect ratio (banner image)',
        () {
          // 4000x200 → ratioW = 1920/4000 = 0.48, ratioH = 1920/200 = 9.6 → clamped to 1.0
          // min(0.48, 1.0) = 0.48
          final (dims, ratio) = _calculateDimensions(
            imageWidth: 4000,
            imageHeight: 200,
            targetMaxWidth: 1920,
            targetMaxHeight: 1920,
          );
          expect(dims[0], 1920);
          expect(dims[1], closeTo(96, 1)); // 200 * 0.48 ≈ 96
          expect(ratio, closeTo(0.48, 0.001));
        },
      );

      test(
        'handles very tall aspect ratio (portrait banner)',
        () {
          // 200x4000 → ratioW = 1920/200 = 9.6 → clamped to 1.0, ratioH = 1920/4000 = 0.48
          // min(1.0, 0.48) = 0.48
          final (dims, ratio) = _calculateDimensions(
            imageWidth: 200,
            imageHeight: 4000,
            targetMaxWidth: 1920,
            targetMaxHeight: 1920,
          );
          expect(dims[0], closeTo(96, 1)); // 200 * 0.48 ≈ 96
          expect(dims[1], 1920);
          expect(ratio, closeTo(0.48, 0.001));
        },
      );

      test('handles square image exactly at max dimensions', () {
        final (dims, ratio) = _calculateDimensions(
          imageWidth: 1920,
          imageHeight: 1920,
          targetMaxWidth: 1920,
          targetMaxHeight: 1920,
        );
        expect(dims, [1920, 1920]);
        expect(ratio, 1.0);
      });

      test('scales down square image when one pixel over max', () {
        final (dims, _) = _calculateDimensions(
          imageWidth: 1921,
          imageHeight: 1921,
          targetMaxWidth: 1920,
          targetMaxHeight: 1920,
        );
        expect(dims[0], lessThanOrEqualTo(1920));
        expect(dims[1], lessThanOrEqualTo(1920));
      });

      test('accepts custom max dimensions', () {
        final (dims, _) = _calculateDimensions(
          imageWidth: 2000,
          imageHeight: 1500,
          targetMaxWidth: 1000,
          targetMaxHeight: 800,
        );
        // ratioW = 1000/2000 = 0.5, ratioH = 800/1500 ≈ 0.533
        // min(0.5, 0.533) = 0.5 → width limited
        expect(dims[0], 1000);
        expect(dims[1], 750);
      });
    });

    group('compressImage error handling', () {
      test(
        'throws FileException when input file does not exist',
        () async {
          expect(
            () => ImageCompressor.compressImage(
              inputPath: '/nonexistent/path/image.jpg',
              outputPath: '/tmp/output.jpg',
            ),
            throwsA(isA<FileException>()),
          );
        },
      );

      test(
        'exception message contains the missing path',
        () async {
          const missingPath = '/nonexistent/path/image.jpg';
          try {
            await ImageCompressor.compressImage(
              inputPath: missingPath,
              outputPath: '/tmp/output.jpg',
            );
            fail('Expected FileException to be thrown');
          } on FileException catch (e) {
            expect(e.message, contains(missingPath));
          }
        },
      );
    });

    group('generateThumbnail error handling', () {
      test(
        'throws FileException when input file does not exist',
        () async {
          expect(
            () => ImageCompressor.generateThumbnail(
              inputPath: '/nonexistent/path/image.jpg',
              outputPath: '/tmp/thumb.jpg',
            ),
            throwsA(isA<FileException>()),
          );
        },
      );
    });

    group('cleanupOldImages', () {
      late Directory tempDir;

      setUp(() async {
        tempDir = await Directory.systemTemp.createTemp(
          'image_compressor_test_',
        );
      });

      tearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      test('returns 0 for non-existent directory', () async {
        final missingDir = Directory('/tmp/nonexistent_dir_${DateTime.now().microsecondsSinceEpoch}');
        final count = await ImageCompressor.cleanupOldImages(
          directory: missingDir,
        );
        expect(count, 0);
      });

      test('returns 0 for empty directory', () async {
        final count = await ImageCompressor.cleanupOldImages(
          directory: tempDir,
        );
        expect(count, 0);
      });

      test('returns 0 when no .jpg files exist', () async {
        // Create non-jpg files
        await File('${tempDir.path}/readme.txt').writeAsString('hello');
        await File('${tempDir.path}/photo.png').writeAsBytes([0, 1, 2]);

        final count = await ImageCompressor.cleanupOldImages(
          directory: tempDir,
        );
        expect(count, 0);
      });

      test(
        'deletes .jpg files older than daysToKeep threshold',
        () async {
          final oldDate = DateTime.now().subtract(const Duration(days: 60));
          final recentDate = DateTime.now().subtract(const Duration(days: 5));

          final oldFile = File('${tempDir.path}/old_photo.jpg');
          await oldFile.writeAsBytes([0]);
          await oldFile.setLastModified(oldDate);

          final recentFile = File('${tempDir.path}/recent_photo.jpg');
          await recentFile.writeAsBytes([0]);
          await recentFile.setLastModified(recentDate);

          final count = await ImageCompressor.cleanupOldImages(
            directory: tempDir,
            daysToKeep: 30,
          );

          expect(count, 1);
          expect(await oldFile.exists(), isFalse);
          expect(await recentFile.exists(), isTrue);
        },
      );

      test(
        'preserves file modified 1 second after cutoff, deletes 1 second before',
        () async {
          // Compute a stable cutoff, then test both sides of it.
          final now = DateTime.now();
          final cutoff = now.subtract(const Duration(days: 30));

          // File modified 1 second AFTER the cutoff → should be preserved.
          final safeFile = File('${tempDir.path}/safe.jpg');
          await safeFile.writeAsBytes([0]);
          await safeFile.setLastModified(
            cutoff.add(const Duration(seconds: 1)),
          );

          // File modified 1 second BEFORE the cutoff → should be deleted.
          final oldFile = File('${tempDir.path}/old.jpg');
          await oldFile.writeAsBytes([0]);
          await oldFile.setLastModified(
            cutoff.subtract(const Duration(seconds: 1)),
          );

          final count = await ImageCompressor.cleanupOldImages(
            directory: tempDir,
            daysToKeep: 30,
          );

          expect(count, 1);
          expect(await safeFile.exists(), isTrue);
          expect(await oldFile.exists(), isFalse);
        },
      );

      test('only deletes .jpg files, ignores other extensions', () async {
        final oldDate = DateTime.now().subtract(const Duration(days: 60));

        final jpgFile = File('${tempDir.path}/old.jpg');
        await jpgFile.writeAsBytes([0]);
        await jpgFile.setLastModified(oldDate);

        final jpegFile = File('${tempDir.path}/old.jpeg');
        await jpegFile.writeAsBytes([0]);
        await jpegFile.setLastModified(oldDate);

        final pngFile = File('${tempDir.path}/old.png');
        await pngFile.writeAsBytes([0]);
        await pngFile.setLastModified(oldDate);

        final count = await ImageCompressor.cleanupOldImages(
          directory: tempDir,
          daysToKeep: 30,
        );

        // Only the .jpg file should be deleted
        expect(count, 1);
        expect(await jpgFile.exists(), isFalse);
        expect(await jpegFile.exists(), isTrue);
        expect(await pngFile.exists(), isTrue);
      });

      test(
        'deletes multiple old .jpg files',
        () async {
          final oldDate = DateTime.now().subtract(const Duration(days: 90));

          for (var i = 0; i < 5; i++) {
            final file = File('${tempDir.path}/photo_$i.jpg');
            await file.writeAsBytes([i]);
            await file.setLastModified(oldDate);
          }

          final count = await ImageCompressor.cleanupOldImages(
            directory: tempDir,
            daysToKeep: 30,
          );

          expect(count, 5);
          final remaining = await tempDir.list().length;
          expect(remaining, 0);
        },
      );

      test('respects custom daysToKeep value', () async {
        final fiveDaysAgo = DateTime.now().subtract(const Duration(days: 5));

        final file = File('${tempDir.path}/photo.jpg');
        await file.writeAsBytes([0]);
        await file.setLastModified(fiveDaysAgo);

        // With 7 days to keep, 5-day-old file should be preserved
        final countLong = await ImageCompressor.cleanupOldImages(
          directory: tempDir,
          daysToKeep: 7,
        );
        expect(countLong, 0);
        expect(await file.exists(), isTrue);

        // With 3 days to keep, 5-day-old file should be deleted
        final countShort = await ImageCompressor.cleanupOldImages(
          directory: tempDir,
          daysToKeep: 3,
        );
        expect(countShort, 1);
        expect(await file.exists(), isFalse);
      });
    });

    group('compressImage with valid JPEG', () {
      late Directory tempDir;

      setUp(() async {
        tempDir = await Directory.systemTemp.createTemp(
          'compress_test_',
        );
      });

      tearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      test('compresses image and writes output file', () async {
        final inputPath = '${tempDir.path}/input.jpg';
        final outputPath = '${tempDir.path}/output.jpg';
        await File(inputPath).writeAsBytes(_encodeTestJpeg(400, 300));

        final result = await ImageCompressor.compressImage(
          inputPath: inputPath,
          outputPath: outputPath,
        );

        expect(await result.exists(), isTrue);
        final outputBytes = await result.readAsBytes();
        expect(outputBytes.isNotEmpty, isTrue);
      });

      test(
        'resizes image when dimensions exceed max',
        () async {
          final inputPath = '${tempDir.path}/large.jpg';
          final outputPath = '${tempDir.path}/compressed.jpg';
          await File(inputPath).writeAsBytes(_encodeTestJpeg(4000, 3000));

          await ImageCompressor.compressImage(
            inputPath: inputPath,
            outputPath: outputPath,
          );

          final outputBytes = await File(outputPath).readAsBytes();
          final decoded = img.decodeImage(outputBytes);
          expect(decoded, isNotNull);
          expect(decoded!.width, lessThanOrEqualTo(1920));
          expect(decoded.height, lessThanOrEqualTo(1920));
        },
      );

      test(
        'uses custom maxWidth and maxHeight',
        () async {
          final inputPath = '${tempDir.path}/large.jpg';
          final outputPath = '${tempDir.path}/compressed.jpg';
          await File(inputPath).writeAsBytes(_encodeTestJpeg(2000, 1500));

          await ImageCompressor.compressImage(
            inputPath: inputPath,
            outputPath: outputPath,
            maxWidth: 500,
            maxHeight: 500,
          );

          final outputBytes = await File(outputPath).readAsBytes();
          final decoded = img.decodeImage(outputBytes);
          expect(decoded, isNotNull);
          expect(decoded!.width, lessThanOrEqualTo(500));
          expect(decoded.height, lessThanOrEqualTo(500));
        },
      );
    });

    group('generateThumbnail with valid JPEG', () {
      late Directory tempDir;

      setUp(() async {
        tempDir = await Directory.systemTemp.createTemp(
          'thumbnail_test_',
        );
      });

      tearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      test('generates thumbnail within default dimensions', () async {
        final inputPath = '${tempDir.path}/input.jpg';
        final outputPath = '${tempDir.path}/thumb.jpg';
        await File(inputPath).writeAsBytes(_encodeTestJpeg(1200, 900));

        final result = await ImageCompressor.generateThumbnail(
          inputPath: inputPath,
          outputPath: outputPath,
        );

        expect(await result.exists(), isTrue);
        final outputBytes = await result.readAsBytes();
        final decoded = img.decodeImage(outputBytes);
        expect(decoded, isNotNull);
        expect(decoded!.width, lessThanOrEqualTo(400));
        expect(decoded.height, lessThanOrEqualTo(400));
      });

      test(
        'does not upscale small images',
        () async {
          final inputPath = '${tempDir.path}/small.jpg';
          final outputPath = '${tempDir.path}/thumb.jpg';
          await File(inputPath).writeAsBytes(_encodeTestJpeg(100, 80));

          await ImageCompressor.generateThumbnail(
            inputPath: inputPath,
            outputPath: outputPath,
          );

          final outputBytes = await File(outputPath).readAsBytes();
          final decoded = img.decodeImage(outputBytes);
          expect(decoded, isNotNull);
          // Should not exceed original size due to clamping
          expect(decoded!.width, lessThanOrEqualTo(100));
          expect(decoded.height, lessThanOrEqualTo(80));
        },
      );
    });
  });
}
