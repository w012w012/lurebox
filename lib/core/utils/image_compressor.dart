import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// 图像压缩工具
///
/// 提供图像压缩功能，优化存储空间和加载性能。
/// 支持：
/// - 尺寸压缩：按比例缩小图像尺寸
/// - 质量压缩：降低图像质量以减小文件大小
/// - 格式转换：统一转换为JPEG格式
class ImageCompressor {
  // 默认压缩质量
  static const int defaultQuality = 85;

  // 最大图像尺寸
  static const int maxWidth = 1920;
  static const int maxHeight = 1920;

  // 缩略图尺寸
  static const int thumbnailWidth = 400;
  static const int thumbnailHeight = 400;

  /// 压缩图像
  ///
  /// [inputPath] 输入图像路径
  /// [outputPath] 输出图像路径
  /// [quality] 压缩质量 (1-100)
  /// [maxWidth] 最大宽度
  /// [maxHeight] 最大高度
  /// 返回压缩后的图像文件
  static Future<File> compressImage({
    required String inputPath,
    required String outputPath,
    int quality = defaultQuality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      final inputFile = File(inputPath);
      if (!await inputFile.exists()) {
        throw Exception('Input file does not exist: $inputPath');
      }

      final bytes = await inputFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image: $inputPath');
      }

      // 计算新的尺寸
      int newWidth = image.width;
      int newHeight = image.height;

      final targetMaxWidth = maxWidth ?? ImageCompressor.maxWidth;
      final targetMaxHeight = maxHeight ?? ImageCompressor.maxHeight;

      if (image.width > targetMaxWidth || image.height > targetMaxHeight) {
        final ratio = (targetMaxWidth / image.width).clamp(0.0, 1.0);
        final ratioHeight = (targetMaxHeight / image.height).clamp(0.0, 1.0);
        final finalRatio = ratio < ratioHeight ? ratio : ratioHeight;

        newWidth = (image.width * finalRatio).round();
        newHeight = (image.height * finalRatio).round();
      }

      // 调整图像尺寸
      final resizedImage = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // 编码为JPEG
      final compressedBytes = img.encodeJpg(resizedImage, quality: quality);

      // 保存压缩后的图像
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(compressedBytes);

      debugPrint('Image compressed: $inputPath -> $outputPath '
          '(${image.width}x${image.height} -> ${newWidth}x$newHeight), '
          'quality: $quality');

      return outputFile;
    } catch (e) {
      debugPrint('Image compression failed: $e');
      rethrow;
    }
  }

  /// 生成缩略图
  ///
  /// [inputPath] 输入图像路径
  /// [outputPath] 输出缩略图路径
  /// [width] 缩略图宽度
  /// [height] 缩略图高度
  /// 返回缩略图文件
  static Future<File> generateThumbnail({
    required String inputPath,
    required String outputPath,
    int width = thumbnailWidth,
    int height = thumbnailHeight,
  }) async {
    try {
      final inputFile = File(inputPath);
      if (!await inputFile.exists()) {
        throw Exception('Input file does not exist: $inputPath');
      }

      final bytes = await inputFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image: $inputPath');
      }

      // 计算保持宽高比的尺寸
      final ratio = (width / image.width).clamp(0.0, 1.0);
      final ratioHeight = (height / image.height).clamp(0.0, 1.0);
      final finalRatio = ratio < ratioHeight ? ratio : ratioHeight;

      final newWidth = (image.width * finalRatio).round();
      final newHeight = (image.height * finalRatio).round();

      // 调整图像尺寸
      final resizedImage = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // 编码为JPEG，使用较低的质量
      final compressedBytes = img.encodeJpg(resizedImage, quality: 70);

      // 保存缩略图
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(compressedBytes);

      debugPrint('Thumbnail generated: $inputPath -> $outputPath '
          '(${newWidth}x$newHeight)');

      return outputFile;
    } catch (e) {
      debugPrint('Thumbnail generation failed: $e');
      rethrow;
    }
  }

  /// 清理旧的图像文件
  ///
  /// [directory] 要清理的目录
  /// [daysToKeep] 保留最近多少天的文件
  /// 返回删除的文件数量
  static Future<int> cleanupOldImages({
    required Directory directory,
    int daysToKeep = 30,
  }) async {
    try {
      if (!await directory.exists()) {
        return 0;
      }

      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      int deletedCount = 0;

      await for (final entity in directory.list()) {
        if (entity is File && entity.path.endsWith('.jpg')) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
            deletedCount++;
            debugPrint('Deleted old image: ${entity.path}');
          }
        }
      }

      debugPrint('Cleaned up $deletedCount old images');
      return deletedCount;
    } catch (e) {
      debugPrint('Image cleanup failed: $e');
      return 0;
    }
  }
}
