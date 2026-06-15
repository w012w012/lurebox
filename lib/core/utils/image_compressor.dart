import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:lurebox/core/services/app_logger.dart';
import 'package:lurebox/core/services/error_service.dart';

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
        throw FileException('Input file does not exist: $inputPath');
      }

      final bytes = await inputFile.readAsBytes();

      // 解码/缩放/编码是纯 Dart CPU 密集操作（package:image），放在主 isolate
      // 会在保存点击时冻结 UI 数百毫秒。这里搬到后台 isolate 执行，
      // 文件 I/O 仍在主 isolate。Isolate.run 在 flutter_test 下同样可用。
      final compressedBytes = await Isolate.run(
        () => _resizeAndEncode(
          bytes: bytes,
          targetMaxWidth: maxWidth ?? ImageCompressor.maxWidth,
          targetMaxHeight: maxHeight ?? ImageCompressor.maxHeight,
          quality: quality,
        ),
      );

      if (compressedBytes == null) {
        throw FileException('Failed to decode image: $inputPath');
      }

      // 保存压缩后的图像
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(compressedBytes);

      AppLogger.i(
        'ImageCompressor',
        'Compressed: $inputPath -> $outputPath (quality: $quality)',
      );

      return outputFile;
    } catch (e) {
      AppLogger.e('ImageCompressor', 'Compression failed', e);
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
        throw FileException('Input file does not exist: $inputPath');
      }

      final bytes = await inputFile.readAsBytes();

      // 同 compressImage：解码/缩放/编码搬到后台 isolate，避免阻塞 UI。
      final compressedBytes = await Isolate.run(
        () => _resizeAndEncode(
          bytes: bytes,
          targetMaxWidth: width,
          targetMaxHeight: height,
          quality: 70,
        ),
      );

      if (compressedBytes == null) {
        throw FileException('Failed to decode image: $inputPath');
      }

      // 保存缩略图
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(compressedBytes);

      AppLogger.i(
        'ImageCompressor',
        'Thumbnail: $inputPath -> $outputPath',
      );

      return outputFile;
    } catch (e) {
      AppLogger.e('ImageCompressor', 'Thumbnail generation failed', e);
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
      var deletedCount = 0;

      await for (final entity in directory.list()) {
        if (entity is File && entity.path.endsWith('.jpg')) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
            deletedCount++;
            AppLogger.d('ImageCompressor', 'Deleted old image: ${entity.path}');
          }
        }
      }

      AppLogger.i('ImageCompressor', 'Cleaned up $deletedCount old images');
      return deletedCount;
    } catch (e) {
      AppLogger.e('ImageCompressor', 'Cleanup failed', e);
      return 0;
    }
  }
}

/// 在后台 isolate 中解码、按比例缩放并编码为 JPEG。
///
/// 纯 CPU 操作，不触碰文件系统——通过 [Isolate.run] 调用，入参为原始字节，
/// 返回编码后的字节。解码失败返回 null（由调用方转换为 [FileException]）。
/// 缩放只缩小不放大（ratio 上限 1.0），与原同步实现行为一致。
Uint8List? _resizeAndEncode({
  required Uint8List bytes,
  required int targetMaxWidth,
  required int targetMaxHeight,
  required int quality,
}) {
  final image = img.decodeImage(bytes);
  if (image == null) return null;

  var newWidth = image.width;
  var newHeight = image.height;

  if (image.width > targetMaxWidth || image.height > targetMaxHeight) {
    final ratio = (targetMaxWidth / image.width).clamp(0.0, 1.0);
    final ratioHeight = (targetMaxHeight / image.height).clamp(0.0, 1.0);
    final finalRatio = ratio < ratioHeight ? ratio : ratioHeight;

    newWidth = (image.width * finalRatio).round();
    newHeight = (image.height * finalRatio).round();
  }

  final resizedImage = img.copyResize(
    image,
    width: newWidth,
    height: newHeight,
    interpolation: img.Interpolation.linear,
  );

  return img.encodeJpg(resizedImage, quality: quality);
}
