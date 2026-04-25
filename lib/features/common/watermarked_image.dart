import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/services/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/models/watermark_settings.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/app_settings_provider.dart';
import '../../core/providers/watermark_provider.dart';
import '../../core/utils/unit_converter.dart';
import '../../core/services/weather_service.dart' show getLocalizedWeatherDescription;
import '../../widgets/common/image_cache_helper.dart';

/// 带水印的图片 Widget
class WatermarkedImage extends ConsumerWidget {
  final String imagePath;
  final String species;
  final double length;
  final double? weight;
  final String? lengthUnit;
  final String? weightUnit;
  final String? locationName;
  final DateTime? catchTime;
  final String? rodName;
  final String? reelName;
  final String? lureName;
  final String? rodBrand;
  final String? rodModel;
  final String? rodMaterial;
  final String? rodLength;
  final String? rodLengthUnit;
  final String? rodHardness;
  final String? rodAction;
  final String? reelBrand;
  final String? reelModel;
  final String? reelRatio;
  final String? lureBrand;
  final String? lureModel;
  final String? lureSize;
  final String? lureSizeUnit;
  final String? lureColor;
  final String? lureWeight;
  final String? lureWeightUnit;
  final double? airTemperature;
  final double? pressure;
  final int? weatherCode;
  final BoxFit fit;
  final int? cacheWidth;
  final int? cacheHeight;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final bool showWatermark;

  const WatermarkedImage({
    super.key,
    required this.imagePath,
    required this.species,
    required this.length,
    this.weight,
    this.lengthUnit,
    this.weightUnit,
    this.locationName,
    this.catchTime,
    this.rodName,
    this.reelName,
    this.lureName,
    this.rodBrand,
    this.rodModel,
    this.rodMaterial,
    this.rodLength,
    this.rodLengthUnit,
    this.rodHardness,
    this.rodAction,
    this.reelBrand,
    this.reelModel,
    this.reelRatio,
    this.lureBrand,
    this.lureModel,
    this.lureSize,
    this.lureSizeUnit,
    this.lureColor,
    this.lureWeight,
    this.lureWeightUnit,
    this.airTemperature,
    this.pressure,
    this.weatherCode,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.cacheHeight,
    this.errorBuilder,
    this.showWatermark = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(watermarkSettingsProvider);
    final strings = ref.watch(currentStringsProvider);
    final appSettings = ref.watch(appSettingsProvider);
    final displayUnits = appSettings.units;

    // 转换长度和重量到当前显示单位
    final double displayLength = lengthUnit != null
        ? UnitConverter.convertLength(
            length,
            lengthUnit!,
            displayUnits.fishLengthUnit,
          )
        : length;
    final double? displayWeight = weight != null && weightUnit != null
        ? UnitConverter.convertWeight(
            weight!,
            weightUnit!,
            displayUnits.fishWeightUnit,
          )
        : weight;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // 原图
            Image(
              image: ImageCacheHelper.getCachedThumbnailProvider(
                imagePath,
                width: cacheWidth,
                height: cacheHeight,
              ),
              fit: fit,
              errorBuilder: errorBuilder,
            ),
            // 水印层
            if (settings.enabled && showWatermark)
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: WatermarkPainter(
                  species: species,
                  length: length,
                  weight: weight,
                  lengthUnit: lengthUnit,
                  weightUnit: weightUnit,
                  locationName: locationName,
                  catchTime: catchTime,
                  rodName: rodName,
                  reelName: reelName,
                  lureName: lureName,
                  rodBrand: rodBrand,
                  rodModel: rodModel,
                  rodMaterial: rodMaterial,
                  rodLength: rodLength,
                  rodLengthUnit: rodLengthUnit,
                  rodHardness: rodHardness,
                  rodAction: rodAction,
                  reelBrand: reelBrand,
                  reelModel: reelModel,
                  reelRatio: reelRatio,
                  lureBrand: lureBrand,
                  lureModel: lureModel,
                  lureSize: lureSize,
                  lureSizeUnit: lureSizeUnit,
                  lureColor: lureColor,
                  lureWeight: lureWeight,
                  lureWeightUnit: lureWeightUnit,
                  airTemperature: airTemperature,
                  pressure: pressure,
                  weatherCode: weatherCode,
                  settings: settings,
                  strings: strings,
                  displayLength: displayLength,
                  displayWeight: displayWeight,
                  displayLengthUnit: displayUnits.fishLengthUnit,
                  displayWeightUnit: displayUnits.fishWeightUnit,
                  displayTemperatureUnit: displayUnits.temperatureUnit,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// 水印绘制器
class WatermarkPainter extends CustomPainter {
  final String species;
  final double length;
  final double? weight;
  final String? lengthUnit;
  final String? weightUnit;
  final String? locationName;
  final DateTime? catchTime;
  final String? rodName;
  final String? reelName;
  final String? lureName;
  final String? rodBrand;
  final String? rodModel;
  final String? rodMaterial;
  final String? rodLength;
  final String? rodLengthUnit;
  final String? rodHardness;
  final String? rodAction;
  final String? reelBrand;
  final String? reelModel;
  final String? reelRatio;
  final String? lureBrand;
  final String? lureModel;
  final String? lureSize;
  final String? lureSizeUnit;
  final String? lureColor;
  final String? lureWeight;
  final String? lureWeightUnit;
  final double? airTemperature;
  final double? pressure;
  final int? weatherCode;
  final WatermarkSettings settings;
  final AppStrings strings;
  final double displayLength;
  final double? displayWeight;
  final String displayLengthUnit;
  final String displayWeightUnit;
  final String displayTemperatureUnit;
  final double? referenceWidth;
  final Offset? dragOffset;
  final double watermarkScale;

  WatermarkPainter({
    required this.species,
    required this.length,
    this.weight,
    this.lengthUnit,
    this.weightUnit,
    this.locationName,
    this.catchTime,
    this.rodName,
    this.reelName,
    this.lureName,
    this.rodBrand,
    this.rodModel,
    this.rodMaterial,
    this.rodLength,
    this.rodLengthUnit,
    this.rodHardness,
    this.rodAction,
    this.reelBrand,
    this.reelModel,
    this.reelRatio,
    this.lureBrand,
    this.lureModel,
    this.lureSize,
    this.lureSizeUnit,
    this.lureColor,
    this.lureWeight,
    this.lureWeightUnit,
    this.airTemperature,
    this.pressure,
    this.weatherCode,
    required this.settings,
    required this.strings,
    required this.displayLength,
    this.displayWeight,
    required this.displayLengthUnit,
    required this.displayWeightUnit,
    required this.displayTemperatureUnit,
    this.referenceWidth,
    this.dragOffset,
    this.watermarkScale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 构建水印文本列表
    final waterLines = _buildWatermarkLines();
    if (waterLines.isEmpty) return;

    // 使用简约左下样式绘制水印
    _drawMinimal(canvas, size, waterLines);
  }

  List<String> _buildWatermarkLines() {
    final List<String> lines = [];

    for (final type in settings.infoTypes) {
      if (type == WatermarkInfoType.appName) continue; // App名称最后处理

      switch (type) {
        case WatermarkInfoType.species:
          if (species.isNotEmpty) lines.add('${strings.species}：$species');
          break;
        case WatermarkInfoType.length:
          lines.add(
            '${strings.length}：${displayLength.toStringAsFixed(1)} ${UnitConverter.getLengthSymbol(displayLengthUnit)}',
          );
          break;
        case WatermarkInfoType.weight:
          if (displayWeight != null) {
            lines.add(
              '${strings.weight}：${displayWeight!.toStringAsFixed(2)} ${UnitConverter.getWeightSymbol(displayWeightUnit)}',
            );
          }
          break;
        case WatermarkInfoType.location:
          if (locationName != null && locationName!.isNotEmpty) {
            lines.add('${strings.location}：$locationName');
          }
          break;
        case WatermarkInfoType.rod:
          if (rodBrand != null && rodBrand!.isNotEmpty) {
            final rodParts = <String>[];
            rodParts.add(rodBrand!);
            if (rodModel != null && rodModel!.isNotEmpty) {
              rodParts.add(rodModel!);
            }
            if (rodLength != null && rodLength!.isNotEmpty) {
              final lengthValue = double.tryParse(rodLength!) ?? 0.0;
              final lengthUnit = rodLengthUnit ?? 'm';
              rodParts.add(
                  '${lengthValue.toStringAsFixed(2)} ${UnitConverter.getLengthSymbol(lengthUnit)}');
            }
            if (rodHardness != null && rodHardness!.isNotEmpty) {
              rodParts.add(rodHardness!);
            }
            if (rodAction != null && rodAction!.isNotEmpty) {
              rodParts.add(rodAction!);
            }
            if (rodParts.isNotEmpty) {
              lines.add('${strings.rod}：${rodParts.join(' / ')}');
            }
          } else if (rodName != null && rodName!.isNotEmpty) {
            lines.add('${strings.rod}：$rodName');
          }
          break;
        case WatermarkInfoType.reel:
          if (reelBrand != null && reelBrand!.isNotEmpty) {
            final reelParts = <String>[];
            reelParts.add(reelBrand!);
            if (reelModel != null && reelModel!.isNotEmpty) {
              reelParts.add(reelModel!);
            }
            if (reelRatio != null && reelRatio!.isNotEmpty) {
              reelParts.add(reelRatio!);
            }
            if (reelParts.isNotEmpty) {
              lines.add('${strings.reel}：${reelParts.join(' / ')}');
            }
          } else if (reelName != null && reelName!.isNotEmpty) {
            lines.add('${strings.reel}：$reelName');
          }
          break;
        case WatermarkInfoType.lure:
          if (lureBrand != null && lureBrand!.isNotEmpty) {
            final lureParts = <String>[];
            lureParts.add(lureBrand!);
            if (lureModel != null && lureModel!.isNotEmpty) {
              lureParts.add(lureModel!);
            }
            if (lureSize != null && lureSize!.isNotEmpty) {
              final sizeUnit = lureSizeUnit ?? 'cm';
              lureParts
                  .add('$lureSize ${UnitConverter.getLengthSymbol(sizeUnit)}');
            }
            if (lureWeight != null && lureWeight!.isNotEmpty) {
              final weightUnit = lureWeightUnit ?? 'g';
              lureParts.add(
                  '$lureWeight ${UnitConverter.getWeightSymbol(weightUnit)}');
            }
            if (lureColor != null && lureColor!.isNotEmpty) {
              lureParts.add(lureColor!);
            }
            if (lureParts.isNotEmpty) {
              lines.add('${strings.lure}：${lureParts.join(' / ')}');
            }
          } else if (lureName != null && lureName!.isNotEmpty) {
            lines.add('${strings.lure}：$lureName');
          }
          break;
        case WatermarkInfoType.time:
          if (catchTime != null) {
            final timeStr =
                '${catchTime!.year}-${catchTime!.month.toString().padLeft(2, '0')}-${catchTime!.day.toString().padLeft(2, '0')} ${catchTime!.hour.toString().padLeft(2, '0')}:${catchTime!.minute.toString().padLeft(2, '0')}';
            lines.add('${strings.time}：$timeStr');
          }
          break;
        case WatermarkInfoType.airTemperature:
          if (airTemperature != null) {
            final displayTemp = UnitConverter.convertTemperature(
              airTemperature!,
              'C',
              displayTemperatureUnit,
            );
            lines.add(
              '${strings.airTemperature}：${UnitConverter.formatTemperature(displayTemp, displayTemperatureUnit)}',
            );
          }
          break;
        case WatermarkInfoType.pressure:
          if (pressure != null) {
            lines.add('${strings.pressure}：${pressure!.toStringAsFixed(0)}hPa');
          }
          break;
        case WatermarkInfoType.weather:
          if (weatherCode != null) {
            final weatherDesc = getLocalizedWeatherDescription(weatherCode, strings);
            if (weatherDesc.isNotEmpty) {
              lines.add('${strings.weather}：$weatherDesc');
            }
          }
          break;
        case WatermarkInfoType.appName:
          // 已在上面处理
          break;
      }
    }

    // 自定义文字（倒数第二行）
    if (settings.customText != null && settings.customText!.isNotEmpty) {
      lines.add(settings.customText!);
    }

    // App名称放在最后
    if (settings.infoTypes.contains(WatermarkInfoType.appName)) {
      lines.add(strings.fromLureBox);
    }

    return lines;
  }

  /// 简约左下水印（逐行显示）
  void _drawMinimal(Canvas canvas, Size size, List<String> lines) {
    // 根据 referenceWidth 缩放字号，确保不同画布尺寸下视觉比例一致
    final double scale = referenceWidth != null && referenceWidth! > 0
        ? size.width / referenceWidth!
        : 1.0;
    final baseFontSize =
        (settings.fontSize > 0 ? settings.fontSize : 14.0) * scale * watermarkScale;
    final lineHeight = baseFontSize * 1.5;

    // 如果有 dragOffset，直接使用偏移量绘制，忽略 preset position
    if (dragOffset != null) {
      _drawAtOffset(canvas, size, lines, dragOffset!, baseFontSize, lineHeight);
      return;
    }

    // 根据位置设置计算padding
    double paddingBottom, paddingLeft, paddingRight, paddingTop;
    switch (settings.position) {
      case WatermarkPosition.topLeft:
        paddingTop = size.height * 0.05;
        paddingLeft = size.width * 0.03;
        paddingBottom = 0;
        paddingRight = 0;
        break;
      case WatermarkPosition.topRight:
        paddingTop = size.height * 0.05;
        paddingRight = size.width * 0.03;
        paddingBottom = 0;
        paddingLeft = 0;
        break;
      case WatermarkPosition.bottomLeft:
        paddingBottom = size.height * 0.05;
        paddingLeft = size.width * 0.03;
        paddingTop = 0;
        paddingRight = 0;
        break;
      case WatermarkPosition.bottomRight:
        paddingBottom = size.height * 0.05;
        paddingRight = size.width * 0.03;
        paddingTop = 0;
        paddingLeft = 0;
        break;
      case WatermarkPosition.center:
        paddingTop = size.height * 0.5 - (lines.length * lineHeight / 2);
        paddingLeft = size.width * 0.5;
        paddingBottom = 0;
        paddingRight = 0;
        break;
    }

    // 计算起始位置
    double y;
    if (settings.position == WatermarkPosition.topLeft ||
        settings.position == WatermarkPosition.topRight) {
      y = paddingTop;
    } else if (settings.position == WatermarkPosition.center) {
      y = paddingTop;
    } else {
      y = size.height - paddingBottom - lineHeight;
    }

    // 绘制背景（半透明矩形）
    if (settings.blurRadius > 0 || settings.backgroundOpacity > 0) {
      final bgColor = Color(settings.backgroundColor)
          .withValues(alpha: settings.backgroundOpacity);
      final paint = Paint()
        ..color = bgColor
        ..style = PaintingStyle.fill;

      // 先计算文字区域大小
      double bgWidth = 0;
      for (final line in lines) {
        final textPainter = TextPainter(
          text: TextSpan(text: line, style: TextStyle(fontSize: baseFontSize)),
          textDirection: TextDirection.ltr,
        )..layout();
        bgWidth = bgWidth > textPainter.width ? bgWidth : textPainter.width;
      }

      final bgHeight = lines.length * lineHeight + 16;
      double bgX, bgY;

      // 根据位置计算背景位置
      switch (settings.position) {
        case WatermarkPosition.topLeft:
          bgX = paddingLeft - 8;
          bgY = paddingTop - 8;
          break;
        case WatermarkPosition.topRight:
          bgX = size.width - paddingRight - bgWidth - 8;
          bgY = paddingTop - 8;
          break;
        case WatermarkPosition.bottomLeft:
          bgX = paddingLeft - 8;
          bgY = size.height - paddingBottom - bgHeight + 8;
          break;
        case WatermarkPosition.bottomRight:
          bgX = size.width - paddingRight - bgWidth - 8;
          bgY = size.height - paddingBottom - bgHeight + 8;
          break;
        case WatermarkPosition.center:
          bgX = paddingLeft - bgWidth / 2 - 8;
          bgY = paddingTop - 8;
          break;
      }

      // 使用 blurRadius 作为圆角半径
      final borderRadius = settings.blurRadius;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(bgX, bgY, bgWidth + 16, bgHeight),
        Radius.circular(borderRadius),
      );
      canvas.drawRRect(rrect, paint);
    }

    // 绘制文字
    final textColor = Color(settings.textColor);
    final drawLines = settings.position == WatermarkPosition.topLeft ||
            settings.position == WatermarkPosition.topRight ||
            settings.position == WatermarkPosition.center
        ? lines
        : lines.reversed.toList();

    for (int i = 0; i < drawLines.length; i++) {
      final line = drawLines[i];
      final isAppName = line.startsWith('\u200B');
      final textPainter = TextPainter(
        text: TextSpan(
          text: line,
          style: TextStyle(
            color: textColor.withValues(alpha: 0.9),
            fontSize: isAppName ? baseFontSize * 0.85 : baseFontSize,
            fontWeight: isAppName ? FontWeight.normal : FontWeight.w500,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: size.width * 0.01,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      double x = paddingLeft;
      if (settings.position == WatermarkPosition.topRight ||
          settings.position == WatermarkPosition.bottomRight) {
        x = size.width - paddingRight - textPainter.width;
      } else if (settings.position == WatermarkPosition.center) {
        x = paddingLeft - textPainter.width / 2;
      }

      textPainter.paint(canvas, Offset(x, y));

      if (settings.position == WatermarkPosition.topLeft ||
          settings.position == WatermarkPosition.topRight ||
          settings.position == WatermarkPosition.center) {
        y += lineHeight;
      } else {
        y -= lineHeight;
      }
    }
  }

  /// 在指定偏移位置绘制水印（用于拖拽定位）
  void _drawAtOffset(Canvas canvas, Size size, List<String> lines,
      Offset offset, double baseFontSize, double lineHeight) {
    if (lines.isEmpty) return;

    final textColor = Color(settings.textColor);
    final textStyle = TextStyle(
      color: textColor,
      fontSize: baseFontSize,
      fontWeight: FontWeight.w500,
      shadows: [
        Shadow(
          color: Colors.black.withValues(alpha: 0.6),
          blurRadius: size.width * 0.01,
        ),
      ],
    );

    // 计算文字区域大小
    double bgWidth = 0;
    for (final line in lines) {
      final tp = TextPainter(
        text: TextSpan(text: line, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      bgWidth = bgWidth > tp.width ? bgWidth : tp.width;
    }
    final bgHeight = lines.length * lineHeight + 16;

    // 绘制背景
    if (settings.blurRadius > 0 || settings.backgroundOpacity > 0) {
      final bgColor = Color(settings.backgroundColor)
          .withValues(alpha: settings.backgroundOpacity);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(offset.dx - 8, offset.dy - 8, bgWidth + 16, bgHeight),
          Radius.circular(settings.blurRadius),
        ),
        Paint()..color = bgColor,
      );
    }

    // 绘制文字
    double y = offset.dy;
    for (final line in lines) {
      final tp = TextPainter(
        text: TextSpan(text: line, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(offset.dx, y));
      y += lineHeight;
    }
  }

  @override
  bool shouldRepaint(covariant WatermarkPainter oldDelegate) {
    return settings != oldDelegate.settings ||
        species != oldDelegate.species ||
        length != oldDelegate.length ||
        weight != oldDelegate.weight ||
        locationName != oldDelegate.locationName ||
        catchTime != oldDelegate.catchTime ||
        rodName != oldDelegate.rodName ||
        reelName != oldDelegate.reelName ||
        lureName != oldDelegate.lureName ||
        strings != oldDelegate.strings ||
        displayTemperatureUnit != oldDelegate.displayTemperatureUnit ||
        displayLengthUnit != oldDelegate.displayLengthUnit ||
        displayWeightUnit != oldDelegate.displayWeightUnit ||
        dragOffset != oldDelegate.dragOffset ||
        referenceWidth != oldDelegate.referenceWidth ||
        watermarkScale != oldDelegate.watermarkScale;
  }
}

/// 用于导出带水印图片的工具类
class WatermarkExporter {
  /// 生成带水印的临时图片
  static Future<String?> exportWatermarkedImage({
    required String imagePath,
    required String species,
    required double length,
    double? weight,
    String? lengthUnit,
    String? weightUnit,
    String? locationName,
    DateTime? catchTime,
    String? rodName,
    String? reelName,
    String? lureName,
    String? rodBrand,
    String? rodModel,
    String? rodMaterial,
    String? rodLength,
    String? rodLengthUnit,
    String? rodHardness,
    String? rodAction,
    String? reelBrand,
    String? reelModel,
    String? reelRatio,
    String? lureBrand,
    String? lureModel,
    String? lureSize,
    String? lureSizeUnit,
    String? lureColor,
    String? lureWeight,
    String? lureWeightUnit,
    double? airTemperature,
    double? pressure,
    int? weatherCode,
    required WatermarkSettings settings,
    required AppStrings strings,
    required double displayLength,
    required double? displayWeight,
    required String displayLengthUnit,
    required String displayWeightUnit,
    required String displayTemperatureUnit,
    double referenceWidth = 400.0,
    Offset? dragOffset,
    double watermarkScale = 1.0,
  }) async {
    try {
      // 读取原图
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      // 创建画布
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = Size(image.width.toDouble(), image.height.toDouble());

      // 绘制原图
      canvas.drawImage(image, Offset.zero, Paint());

      // 绘制水印
      final painter = WatermarkPainter(
        species: species,
        length: length,
        weight: weight,
        lengthUnit: lengthUnit,
        weightUnit: weightUnit,
        locationName: locationName,
        catchTime: catchTime,
        rodName: rodName,
        reelName: reelName,
        lureName: lureName,
        rodBrand: rodBrand,
        rodModel: rodModel,
        rodMaterial: rodMaterial,
        rodLength: rodLength,
        rodLengthUnit: rodLengthUnit,
        rodHardness: rodHardness,
        rodAction: rodAction,
        reelBrand: reelBrand,
        reelModel: reelModel,
        reelRatio: reelRatio,
        lureBrand: lureBrand,
        lureModel: lureModel,
        lureSize: lureSize,
        lureSizeUnit: lureSizeUnit,
        lureColor: lureColor,
        lureWeight: lureWeight,
        lureWeightUnit: lureWeightUnit,
        airTemperature: airTemperature,
        pressure: pressure,
        weatherCode: weatherCode,
        settings: settings,
        strings: strings,
        displayLength: displayLength,
        displayWeight: displayWeight,
        displayLengthUnit: displayLengthUnit,
        displayWeightUnit: displayWeightUnit,
        displayTemperatureUnit: displayTemperatureUnit,
        referenceWidth: referenceWidth,
        dragOffset: dragOffset,
        watermarkScale: watermarkScale,
      );
      painter.paint(canvas, size);

      // 转换为图片
      final picture = recorder.endRecording();
      final img = await picture.toImage(image.width, image.height);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // 保存临时文件
      final tempDir = await Directory.systemTemp.createTemp('watermark');
      final tempFile = File(
        '${tempDir.path}/watermarked_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await tempFile.writeAsBytes(pngBytes);

      return tempFile.path;
    } catch (e) {
      AppLogger.e('WatermarkExporter', '导出水印图片失败: $e');
      return null;
    }
  }

  /// 删除临时水印图片
  static Future<void> deleteTempFile(String? path) async {
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      // 删除临时目录
      final dir = file.parent;
      if (await dir.exists()) {
        final isEmpty = await dir.list().isEmpty;
        if (isEmpty) {
          await dir.delete();
        }
      }
    } catch (e) {
      AppLogger.w('WatermarkExporter', '删除临时文件失败: $e');
    }
  }
}
