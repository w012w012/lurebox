import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/design/theme/tesla_theme.dart';
import '../../core/providers/fish_detail_view_model.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/app_settings_provider.dart';
import '../../core/providers/watermark_provider.dart';
import '../../core/services/app_logger.dart';
import '../../core/utils/unit_converter.dart';
import '../../widgets/common/app_snack_bar.dart';
import '../common/watermarked_image.dart';
import '../../widgets/common/premium_button.dart';
import '../../widgets/common/premium_card.dart';
import 'widgets/fish_action_buttons.dart';
import 'widgets/fish_info_card.dart';
import 'widgets/fish_image_gallery.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            strings.fishDetail,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: TeslaColors.electricBlue,
          ),
        ),
      );
    }

    if (state.errorMessage != null || state.fish == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            strings.fishDetail,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: TeslaColors.electricBlue,
              ),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? strings.fishNotFound,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final fish = state.fish!;
    final catchTime = DateTime.tryParse(_s(fish, 'catch_time') ?? '') ??
        DateTime.now();
    final rodName = _s(state.rodEquipment, 'model');
    final reelName = _s(state.reelEquipment, 'model');
    final lureName = _s(state.lureEquipment, 'model');

    // 获取用户设置的单位
    final appSettings = ref.watch(appSettingsProvider);
    final units = appSettings.units;

    // 获取渔获记录时的单位（用于换算显示）
    final fishLengthUnit =
        _s(fish, 'length_unit') ?? units.fishLengthUnit;
    final fishWeightUnit =
        _s(fish, 'weight_unit') ?? units.fishWeightUnit;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          strings.fishDetail,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
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
                            return _buildFishImageGallery(
                              fish, state, catchTime,
                              fishLengthUnit, fishWeightUnit,
                              rodName, reelName, lureName,
                            );
                          },
                        );
                      },
                      child: _buildFishImageGallery(
                        fish, state, catchTime,
                        fishLengthUnit, fishWeightUnit,
                        rodName, reelName, lureName,
                      ),
                    ),
                  ),
                  FishInfoCard(
                    species: _s(fish, 'species') ?? '',
                    length: _d(fish, 'length') ?? 0,
                    lengthUnit: fishLengthUnit,
                    weight: _d(fish, 'weight'),
                    weightUnit: fishWeightUnit,
                    fate: _i(fish, 'fate') ?? 0,
                    catchTime: catchTime,
                    locationName: _s(fish, 'location_name'),
                    rodEquipment: state.rodEquipment,
                    reelEquipment: state.reelEquipment,
                    lureEquipment: state.lureEquipment,
                    airTemperature: _d(fish, 'air_temperature'),
                    pressure: _d(fish, 'pressure'),
                    weatherCode: _i(fish, 'weather_code'),
                    strings: strings,
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
            ),
            child: SafeArea(
              top: false,
              child: FishActionButtons(
                strings: strings,
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

  /// 安全访问 Map 值，避免 `as` 强制转换崩溃
  static String? _s(Map<String, dynamic>? m, String k) =>
      m?[k]?.toString();
  static double? _d(Map<String, dynamic>? m, String k) {
    final v = m?[k];
    if (v is num) return v.toDouble();
    return null;
  }
  static int? _i(Map<String, dynamic>? m, String k) {
    final v = m?[k];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return null;
  }

  Widget _buildFishImageGallery(
    Map<String, dynamic> fish,
    FishDetailState state,
    DateTime catchTime,
    String fishLengthUnit,
    String fishWeightUnit,
    String? rodName,
    String? reelName,
    String? lureName,
  ) {
    final rod = state.rodEquipment;
    final reel = state.reelEquipment;
    final lure = state.lureEquipment;
    return FishImageGallery(
      imagePath: _s(fish, 'image_path') ?? '',
      species: _s(fish, 'species') ?? '',
      length: _d(fish, 'length') ?? 0,
      weight: _d(fish, 'weight'),
      lengthUnit: fishLengthUnit,
      weightUnit: fishWeightUnit,
      locationName: _s(fish, 'location_name'),
      catchTime: catchTime,
      rodName: rodName,
      reelName: reelName,
      lureName: lureName,
      rodBrand: _s(rod, 'brand'),
      rodModel: _s(rod, 'model'),
      rodMaterial: _s(rod, 'material'),
      rodLength: _s(rod, 'length'),
      rodLengthUnit: _s(rod, 'length_unit'),
      rodHardness: _s(rod, 'hardness'),
      rodAction: _s(rod, 'rod_action'),
      reelBrand: _s(reel, 'brand'),
      reelModel: _s(reel, 'model'),
      reelRatio: _s(reel, 'reel_ratio'),
      lureBrand: _s(lure, 'brand'),
      lureModel: _s(lure, 'model'),
      lureSize: _s(lure, 'lure_size'),
      lureSizeUnit: _s(lure, 'lure_size_unit'),
      lureColor: _s(lure, 'lure_color'),
      lureWeight: _s(lure, 'lure_weight'),
      lureWeightUnit: _s(lure, 'lure_weight_unit'),
      airTemperature: _d(fish, 'air_temperature'),
      pressure: _d(fish, 'pressure'),
      weatherCode: _i(fish, 'weather_code'),
    );
  }

  Future<void> _deleteFish(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) async {
    final dialogColorScheme = Theme.of(context).colorScheme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          strings.confirmDelete,
          style: TextStyle(
            color: dialogColorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          strings.confirmDeleteFish,
          style: TextStyle(
            color: dialogColorScheme.onSurfaceVariant,
          ),
        ),
        backgroundColor: dialogColorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
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
          AppSnackBar.showError(context, strings.takePhotoFirst);
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
        builder: (ctx) => Center(
          child: PremiumCard(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: TeslaColors.electricBlue,
                  ),
                  SizedBox(height: 16),
                  Text(
                    strings.sharing,
                    style: const TextStyle(
                      color: TeslaColors.carbonDark,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final watermarkedPath = await WatermarkExporter.exportWatermarkedImage(
        imagePath: fish['image_path'] as String,
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
        displayTemperatureUnit: units.temperatureUnit,
      );

      if (watermarkedPath == null) {
        if (context.mounted) {
          Navigator.of(context).pop();
          AppSnackBar.showError(context, strings.shareFailed);
        }
        return;
      }

      await Share.shareXFiles([
        XFile(watermarkedPath),
      ],
          text:
              '${fish['species']} - ${displayLength.toStringAsFixed(2)}${UnitConverter.getLengthSymbol(units.fishLengthUnit)}');

      await WatermarkExporter.deleteTempFile(watermarkedPath);

      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      AppLogger.e('FishDetailPage', '分享失败: $e');
      if (context.mounted) {
        Navigator.of(context).pop();
        AppSnackBar.showError(context, strings.shareFailed, debugError: e);
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
