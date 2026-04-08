import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/providers/fish_detail_view_model.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/app_settings_provider.dart';
import '../../core/providers/watermark_provider.dart';
import '../../core/utils/unit_converter.dart';
import '../../features/common/watermarked_image.dart';
import '../../widgets/common/premium_button.dart';
import '../../widgets/common/premium_card.dart';
import '../../widgets/fish_detail/fish_action_buttons.dart';
import '../../widgets/fish_detail/fish_info_card.dart';
import '../../widgets/fish_detail/fish_image_gallery.dart';

class FishDetailPage extends ConsumerStatefulWidget {
  final int fishId;

  const FishDetailPage({super.key, required this.fishId});

  @override
  ConsumerState<FishDetailPage> createState() => _FishDetailPageState();
}

class _FishDetailPageState extends ConsumerState<FishDetailPage> {
  final GlobalKey _imageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fishDetailViewModelProvider(widget.fishId));
    final strings = ref.watch(currentStringsProvider);

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text(
            strings.fishDetail,
            style: const TextStyle(
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.surfaceLight,
          foregroundColor: AppColors.textPrimaryLight,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.accentLight,
          ),
        ),
      );
    }

    if (state.errorMessage != null || state.fish == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text(
            strings.fishDetail,
            style: const TextStyle(
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.surfaceLight,
          foregroundColor: AppColors.textPrimaryLight,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'Fish not found',
                style: const TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final fish = state.fish!;
    final catchTime = DateTime.parse(fish['catch_time'] as String);
    final rodName = state.rodEquipment?['model'] as String?;
    final reelName = state.reelEquipment?['model'] as String?;
    final lureName = state.lureEquipment?['model'] as String?;

    // 获取用户设置的单位
    final appSettings = ref.watch(appSettingsProvider);
    final units = appSettings.units;

    // 获取渔获记录时的单位（用于换算显示）
    final fishLengthUnit =
        fish['length_unit'] as String? ?? units.fishLengthUnit;
    final fishWeightUnit =
        fish['weight_unit'] as String? ?? units.fishWeightUnit;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          strings.fishDetail,
          style: const TextStyle(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  RepaintBoundary(
                    key: _imageKey,
                    child: Hero(
                      tag: 'fish_image_${widget.fishId}',
                      flightShuttleBuilder: (
                        BuildContext flightContext,
                        Animation<double> animation,
                        HeroFlightDirection flightDirection,
                        BuildContext fromHeroContext,
                        BuildContext toHeroContext,
                      ) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            return FishImageGallery(
                              imagePath: fish['image_path'] as String,
                              species: fish['species'] as String,
                              length: fish['length'] as double,
                              weight: fish['weight'] as double?,
                              lengthUnit: fishLengthUnit,
                              weightUnit: fishWeightUnit,
                              locationName: fish['location_name'] as String?,
                              catchTime: catchTime,
                              rodName: rodName,
                              reelName: reelName,
                              lureName: lureName,
                              rodBrand: state.rodEquipment?['brand'] as String?,
                              rodModel: state.rodEquipment?['model'] as String?,
                              rodMaterial:
                                  state.rodEquipment?['material'] as String?,
                              rodLength:
                                  state.rodEquipment?['length'] as String?,
                              rodLengthUnit:
                                  state.rodEquipment?['length_unit'] as String?,
                              rodHardness:
                                  state.rodEquipment?['hardness'] as String?,
                              rodAction:
                                  state.rodEquipment?['rod_action'] as String?,
                              reelBrand:
                                  state.reelEquipment?['brand'] as String?,
                              reelModel:
                                  state.reelEquipment?['model'] as String?,
                              reelRatio:
                                  state.reelEquipment?['reel_ratio'] as String?,
                              lureBrand:
                                  state.lureEquipment?['brand'] as String?,
                              lureModel:
                                  state.lureEquipment?['model'] as String?,
                              lureSize:
                                  state.lureEquipment?['lure_size'] as String?,
                              lureSizeUnit: state
                                  .lureEquipment?['lure_size_unit'] as String?,
                              lureColor:
                                  state.lureEquipment?['lure_color'] as String?,
                              lureWeight: state.lureEquipment?['lure_weight']
                                  as String?,
                              lureWeightUnit:
                                  state.lureEquipment?['lure_weight_unit']
                                      as String?,
                              airTemperature:
                                  fish['air_temperature'] as double?,
                              pressure: fish['pressure'] as double?,
                              weatherCode: fish['weather_code'] as int?,
                            );
                          },
                        );
                      },
                      child: FishImageGallery(
                        imagePath: fish['image_path'] as String,
                        species: fish['species'] as String,
                        length: fish['length'] as double,
                        weight: fish['weight'] as double?,
                        lengthUnit: fishLengthUnit,
                        weightUnit: fishWeightUnit,
                        locationName: fish['location_name'] as String?,
                        catchTime: catchTime,
                        rodName: rodName,
                        reelName: reelName,
                        lureName: lureName,
                        rodBrand: state.rodEquipment?['brand'] as String?,
                        rodModel: state.rodEquipment?['model'] as String?,
                        rodMaterial: state.rodEquipment?['material'] as String?,
                        rodLength: state.rodEquipment?['length'] as String?,
                        rodLengthUnit:
                            state.rodEquipment?['length_unit'] as String?,
                        rodHardness: state.rodEquipment?['hardness'] as String?,
                        rodAction: state.rodEquipment?['rod_action'] as String?,
                        reelBrand: state.reelEquipment?['brand'] as String?,
                        reelModel: state.reelEquipment?['model'] as String?,
                        reelRatio:
                            state.reelEquipment?['reel_ratio'] as String?,
                        lureBrand: state.lureEquipment?['brand'] as String?,
                        lureModel: state.lureEquipment?['model'] as String?,
                        lureSize: state.lureEquipment?['lure_size'] as String?,
                        lureSizeUnit:
                            state.lureEquipment?['lure_size_unit'] as String?,
                        lureColor:
                            state.lureEquipment?['lure_color'] as String?,
                        lureWeight:
                            state.lureEquipment?['lure_weight'] as String?,
                        lureWeightUnit:
                            state.lureEquipment?['lure_weight_unit'] as String?,
                        airTemperature: fish['air_temperature'] as double?,
                        pressure: fish['pressure'] as double?,
                        weatherCode: fish['weather_code'] as int?,
                      ),
                    ),
                  ),
                  FishInfoCard(
                    species: fish['species'] as String,
                    length: fish['length'] as double,
                    lengthUnit: fishLengthUnit,
                    weight: fish['weight'] as double?,
                    weightUnit: fishWeightUnit,
                    fate: fish['fate'] as int,
                    catchTime: catchTime,
                    locationName: fish['location_name'] as String?,
                    rodEquipment: state.rodEquipment,
                    reelEquipment: state.reelEquipment,
                    lureEquipment: state.lureEquipment,
                    airTemperature: fish['air_temperature'] as double?,
                    pressure: fish['pressure'] as double?,
                    weatherCode: fish['weather_code'] as int?,
                    strings: strings,
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: FishActionButtons(
                onEdit: () => _editFish(context, fish, strings),
                onShare: () => _shareFish(
                  context,
                  ref,
                  strings,
                  fish,
                  state,
                  rodName,
                  reelName,
                  lureName,
                  catchTime,
                ),
                onDelete: () => _deleteFish(context, ref, strings),
                isDeleting: state.isDeleting,
                isSharing: state.isSharing,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFish(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          strings.confirmDelete,
          style: const TextStyle(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          strings.confirmDeleteFish,
          style: const TextStyle(
            color: AppColors.textSecondaryLight,
          ),
        ),
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        actions: [
          PremiumButton(
            text: strings.cancel,
            onPressed: () => Navigator.pop(context, false),
            variant: PremiumButtonVariant.text,
          ),
          PremiumButton(
            text: strings.delete,
            onPressed: () => Navigator.pop(context, true),
            variant: PremiumButtonVariant.danger,
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref
          .read(fishDetailViewModelProvider(widget.fishId).notifier)
          .deleteFish();
      if (success && context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _shareFish(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    Map<String, dynamic> fish,
    FishDetailState state,
    String? rodName,
    String? reelName,
    String? lureName,
    DateTime catchTime,
  ) async {
    if (state.isSharing) return;

    ref
        .read(fishDetailViewModelProvider(widget.fishId).notifier)
        .setSharing(true);

    try {
      final imagePath = fish['image_path'] as String?;
      if (imagePath == null || imagePath.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(strings.takePhotoFirst)));
        }
        return;
      }

      final appSettings = ref.read(appSettingsProvider);
      final units = appSettings.units;
      final fishLengthUnit =
          fish['length_unit'] as String? ?? units.fishLengthUnit;
      final fishWeightUnit =
          fish['weight_unit'] as String? ?? units.fishWeightUnit;
      final fishLength = fish['length'] as double;
      final fishWeight = fish['weight'] as double?;

      final displayLength = UnitConverter.convertLength(
        fishLength,
        fishLengthUnit,
        units.fishLengthUnit,
      );
      final displayWeight = fishWeight != null
          ? UnitConverter.convertWeight(
              fishWeight,
              fishWeightUnit,
              units.fishWeightUnit,
            )
          : null;

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: PremiumCard(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.accentLight,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '正在分享...',
                    style: TextStyle(
                      color: AppColors.textPrimaryLight,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..isAntiAlias = true;

      canvas.drawImage(frame.image, Offset.zero, paint);

      final watermarkPainter = WatermarkPainter(
        species: fish['species'] as String,
        length: fishLength,
        weight: fishWeight,
        lengthUnit: fishLengthUnit,
        weightUnit: fishWeightUnit,
        locationName: fish['location_name'] as String?,
        catchTime: catchTime,
        rodName: rodName,
        reelName: reelName,
        lureName: lureName,
        rodBrand: state.rodEquipment?['brand'] as String?,
        rodModel: state.rodEquipment?['model'] as String?,
        rodMaterial: state.rodEquipment?['material'] as String?,
        rodLength: state.rodEquipment?['length'] as String?,
        rodLengthUnit: state.rodEquipment?['length_unit'] as String?,
        rodHardness: state.rodEquipment?['hardness'] as String?,
        rodAction: state.rodEquipment?['rod_action'] as String?,
        reelBrand: state.reelEquipment?['brand'] as String?,
        reelModel: state.reelEquipment?['model'] as String?,
        reelRatio: state.reelEquipment?['reel_ratio'] as String?,
        lureBrand: state.lureEquipment?['brand'] as String?,
        lureModel: state.lureEquipment?['model'] as String?,
        lureSize: state.lureEquipment?['lure_size'] as String?,
        lureSizeUnit: state.lureEquipment?['lure_size_unit'] as String?,
        lureColor: state.lureEquipment?['lure_color'] as String?,
        lureWeight: state.lureEquipment?['lure_weight'] as String?,
        lureWeightUnit: state.lureEquipment?['lure_weight_unit'] as String?,
        airTemperature: fish['air_temperature'] as double?,
        pressure: fish['pressure'] as double?,
        weatherCode: fish['weather_code'] as int?,
        settings: ref.read(watermarkSettingsProvider),
        strings: strings,
        displayLength: displayLength,
        displayWeight: displayWeight,
        displayLengthUnit: units.fishLengthUnit,
        displayWeightUnit: units.fishWeightUnit,
      );

      watermarkPainter.paint(
        canvas,
        Size(frame.image.width.toDouble(), frame.image.height.toDouble()),
      );

      final picture = recorder.endRecording();
      final watermarkedImage = await picture.toImage(
        frame.image.width,
        frame.image.height,
      );
      final byteData = await watermarkedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final watermarkedBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/lurebox_share_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await tempFile.writeAsBytes(watermarkedBytes);

      await Share.shareXFiles([
        XFile(tempFile.path),
      ], text: '${fish['species']} - ${fish['length']}cm');

      try {
        await tempFile.delete();
      } catch (_) {}

      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint('分享失败: $e');
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${strings.shareFailed}: $e')));
      }
    } finally {
      ref
          .read(fishDetailViewModelProvider(widget.fishId).notifier)
          .setSharing(false);
    }
  }

  Future<void> _editFish(
    BuildContext context,
    Map<String, dynamic> fish,
    AppStrings strings,
  ) async {
    final result = await context.push<Map<String, dynamic>>(
      '/fish/${widget.fishId}/edit',
    );
    if (result != null) {
      ref.read(fishDetailViewModelProvider(widget.fishId).notifier).refresh();
    }
  }
}
