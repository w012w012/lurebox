import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/models/watermark_settings.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/providers/watermark_provider.dart';
import 'package:lurebox/core/services/app_logger.dart';
import 'package:lurebox/features/common/watermarked_image.dart';
import 'package:lurebox/widgets/common/app_snack_bar.dart';
import 'package:share_plus/share_plus.dart';

/// 分享预览参数
class PreviewData {

  const PreviewData({
    required this.imagePath,
    required this.species,
    required this.length,
    required this.lengthUnit, required this.weightUnit, required this.catchTime, required this.displayLength, required this.displayLengthUnit, required this.displayWeightUnit, required this.displayTemperatureUnit, required this.shareText, this.weight,
    this.locationName,
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
    this.displayWeight,
  });
  final String imagePath;
  final String species;
  final double length;
  final double? weight;
  final String lengthUnit;
  final String weightUnit;
  final String? locationName;
  final DateTime catchTime;
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
  final double displayLength;
  final double? displayWeight;
  final String displayLengthUnit;
  final String displayWeightUnit;
  final String displayTemperatureUnit;
  final String shareText;
}

/// 水印分享预览页 — 可拖拽水印位置，确认后分享
class WatermarkSharePreviewPage extends ConsumerStatefulWidget {

  const WatermarkSharePreviewPage({required this.data, super.key});
  final PreviewData data;

  @override
  ConsumerState<WatermarkSharePreviewPage> createState() =>
      _WatermarkSharePreviewPageState();
}

class _WatermarkSharePreviewPageState
    extends ConsumerState<WatermarkSharePreviewPage> {
  Offset? _watermarkOffset;
  bool _isSharing = false;
  double _watermarkScale = 1;
  double _baseScale = 1;

  Rect _imageRect = Rect.zero;
  Size _imageSize = Size.zero;

  PreviewData get _data => widget.data;

  @override
  void initState() {
    super.initState();
    _loadImageSize();
  }

  Future<void> _loadImageSize() async {
    final bytes = await File(_data.imagePath).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    if (!mounted) return;
    setState(() {
      _imageSize = Size(
        frame.image.width.toDouble(),
        frame.image.height.toDouble(),
      );
    });
    frame.image.dispose();
  }

  /// 计算 BoxFit.contain 下图片的实际显示区域
  Rect _computeImageRect(Size container, Size image) {
    if (container == Size.zero || image == Size.zero) return Rect.zero;
    final containerAspect = container.width / container.height;
    final imageAspect = image.width / image.height;
    double displayWidth;
    double displayHeight;
    if (imageAspect > containerAspect) {
      displayWidth = container.width;
      displayHeight = container.width / imageAspect;
    } else {
      displayHeight = container.height;
      displayWidth = container.height * imageAspect;
    }
    return Rect.fromLTWH(
      (container.width - displayWidth) / 2,
      (container.height - displayHeight) / 2,
      displayWidth,
      displayHeight,
    );
  }

  void _resetPosition() {
    if (_imageSize == Size.zero) return;
    final container = MediaQuery.of(context).size;
    final rect = _computeImageRect(container, _imageSize);
    final watermarkSize = _estimateWatermarkSize();
    setState(() {
      _imageRect = rect;
      _watermarkScale = 1.0;
      _watermarkOffset = Offset(
        rect.left + rect.width * 0.03,
        rect.bottom - rect.height * 0.05 - watermarkSize.height,
      );
    });
  }

  /// 估算水印区域大小（用于初始定位）
  Size _estimateWatermarkSize() {
    final settings = ref.read(watermarkSettingsProvider);
    final lines = settings.infoTypes
        .where((t) => t != WatermarkInfoType.appName)
        .length +
        1;
    final fontSize =
        (settings.fontSize > 0 ? settings.fontSize : 14.0) * _watermarkScale;
    final lineHeight = fontSize * 1.5;
    return Size(200 * _watermarkScale, lines * lineHeight + 16);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(watermarkSettingsProvider);
    final strings = ref.watch(currentStringsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(strings.sharePreview),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(child: _buildPreview(settings)),
          _buildToolbar(strings),
        ],
      ),
    );
  }

  Widget _buildPreview(WatermarkSettings settings) {
    if (_imageSize == Size.zero) {
      return const Center(
        child: CircularProgressIndicator(color: TeslaColors.electricBlue),
      );
    }

    // 仅在首次加载后计算 imageRect，拖拽时不再重新计算
    if (_imageRect == Rect.zero) {
      final container = MediaQuery.of(context).size;
      _imageRect = _computeImageRect(container, _imageSize);

      if (_watermarkOffset == null) {
        final wmSize = _estimateWatermarkSize();
        _watermarkOffset = Offset(
          _imageRect.left + _imageRect.width * 0.03,
          _imageRect.bottom - _imageRect.height * 0.05 - wmSize.height,
        );
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      child: Stack(
        children: [
          Positioned.fromRect(
            rect: _imageRect,
            child: Image.file(
              File(_data.imagePath),
              fit: BoxFit.contain,
            ),
          ),
          if (settings.enabled && _watermarkOffset != null)
            CustomPaint(

              size: Size(_imageRect.right, _imageRect.bottom),
              painter: WatermarkPainter(
                species: _data.species,
                length: _data.length,
                weight: _data.weight,
                lengthUnit: _data.lengthUnit,
                weightUnit: _data.weightUnit,
                locationName: _data.locationName,
                catchTime: _data.catchTime,
                rodName: _data.rodName,
                reelName: _data.reelName,
                lureName: _data.lureName,
                rodBrand: _data.rodBrand,
                rodModel: _data.rodModel,
                rodMaterial: _data.rodMaterial,
                rodLength: _data.rodLength,
                rodLengthUnit: _data.rodLengthUnit,
                rodHardness: _data.rodHardness,
                rodAction: _data.rodAction,
                reelBrand: _data.reelBrand,
                reelModel: _data.reelModel,
                reelRatio: _data.reelRatio,
                lureBrand: _data.lureBrand,
                lureModel: _data.lureModel,
                lureSize: _data.lureSize,
                lureSizeUnit: _data.lureSizeUnit,
                lureColor: _data.lureColor,
                lureWeight: _data.lureWeight,
                lureWeightUnit: _data.lureWeightUnit,
                airTemperature: _data.airTemperature,
                pressure: _data.pressure,
                weatherCode: _data.weatherCode,
                settings: settings,
                strings: ref.read(currentStringsProvider),
                displayLength: _data.displayLength,
                displayWeight: _data.displayWeight,
                displayLengthUnit: _data.displayLengthUnit,
                displayWeightUnit: _data.displayWeightUnit,
                displayTemperatureUnit: _data.displayTemperatureUnit,
                dragOffset: _watermarkOffset,
                watermarkScale: _watermarkScale,
              ),
            ),
        ],
      ),
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _baseScale = _watermarkScale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_watermarkOffset == null) return;
    final newOffset = _watermarkOffset! + details.focalPointDelta;
    final newScale = (_baseScale * details.scale).clamp(0.3, 5.0);
    setState(() {
      _watermarkScale = newScale;
      _watermarkOffset = newOffset;
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {}

  Widget _buildToolbar(AppStrings strings) {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${strings.dragToAdjustWatermark}  |  ${strings.pinchToZoomWatermark}',
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetPosition,
                  icon: const Icon(Icons.refresh),
                  label: Text(strings.resetPosition),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isSharing ? null : _confirmShare,
                  icon: _isSharing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.share),
                  label: Text(strings.confirmShare),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TeslaColors.electricBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmShare() async {
    if (_isSharing || _watermarkOffset == null) return;
    setState(() => _isSharing = true);

    final strings = ref.read(currentStringsProvider);

    try {
      final settings = ref.read(watermarkSettingsProvider);

      // 计算偏移量到原图坐标系的缩放比例
      final scaleX = _imageSize.width / _imageRect.width;
      final scaleY = _imageSize.height / _imageRect.height;
      final scaledOffset = Offset(
        (_watermarkOffset!.dx - _imageRect.left) * scaleX,
        (_watermarkOffset!.dy - _imageRect.top) * scaleY,
      );

      final watermarkedPath = await WatermarkExporter.exportWatermarkedImage(
        imagePath: _data.imagePath,
        species: _data.species,
        length: _data.length,
        weight: _data.weight,
        lengthUnit: _data.lengthUnit,
        weightUnit: _data.weightUnit,
        locationName: _data.locationName,
        catchTime: _data.catchTime,
        rodName: _data.rodName,
        reelName: _data.reelName,
        lureName: _data.lureName,
        rodBrand: _data.rodBrand,
        rodModel: _data.rodModel,
        rodMaterial: _data.rodMaterial,
        rodLength: _data.rodLength,
        rodLengthUnit: _data.rodLengthUnit,
        rodHardness: _data.rodHardness,
        rodAction: _data.rodAction,
        reelBrand: _data.reelBrand,
        reelModel: _data.reelModel,
        reelRatio: _data.reelRatio,
        lureBrand: _data.lureBrand,
        lureModel: _data.lureModel,
        lureSize: _data.lureSize,
        lureSizeUnit: _data.lureSizeUnit,
        lureColor: _data.lureColor,
        lureWeight: _data.lureWeight,
        lureWeightUnit: _data.lureWeightUnit,
        airTemperature: _data.airTemperature,
        pressure: _data.pressure,
        weatherCode: _data.weatherCode,
        settings: settings,
        strings: strings,
        displayLength: _data.displayLength,
        displayWeight: _data.displayWeight,
        displayLengthUnit: _data.displayLengthUnit,
        displayWeightUnit: _data.displayWeightUnit,
        displayTemperatureUnit: _data.displayTemperatureUnit,
        dragOffset: scaledOffset,
        watermarkScale: _watermarkScale,
      );

      if (watermarkedPath == null) {
        if (mounted) {
          AppSnackBar.showError(context, strings.shareFailed);
        }
        return;
      }

      await Share.shareXFiles(
        [XFile(watermarkedPath)],
        text: _data.shareText,
      );

      await WatermarkExporter.deleteTempFile(watermarkedPath);

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      AppLogger.e('WatermarkSharePreview', '分享失败: $e');
      if (mounted) {
        AppSnackBar.showError(context, strings.shareFailed);
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }
}
