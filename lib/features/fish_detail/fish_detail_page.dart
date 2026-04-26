import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/providers/fish_detail_view_model.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/utils/unit_converter.dart';
import 'package:lurebox/features/fish_detail/widgets/fish_action_buttons.dart';
import 'package:lurebox/features/fish_detail/widgets/fish_image_gallery.dart';
import 'package:lurebox/features/fish_detail/widgets/fish_info_card.dart';
import 'package:lurebox/features/share/watermark_share_preview_page.dart';
import 'package:lurebox/widgets/common/app_snack_bar.dart';
import 'package:lurebox/widgets/common/premium_button.dart';

class FishDetailPage extends ConsumerStatefulWidget {
  const FishDetailPage({required this.fishId, super.key});
  final int fishId;

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
    final catchTime = fish.catchTime;
    final rodName = state.rodEquipment?.model;
    final reelName = state.reelEquipment?.model;
    final lureName = state.lureEquipment?.model;

    // 获取用户设置的单位
    final appSettings = ref.watch(appSettingsProvider);
    final units = appSettings.units;

    // 获取渔获记录时的单位（用于换算显示）
    final fishLengthUnit = fish.lengthUnit;
    final fishWeightUnit = fish.weightUnit;

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
                              fish,
                              state,
                              catchTime,
                              fishLengthUnit,
                              fishWeightUnit,
                              rodName,
                              reelName,
                              lureName,
                            );
                          },
                        );
                      },
                      child: _buildFishImageGallery(
                        fish,
                        state,
                        catchTime,
                        fishLengthUnit,
                        fishWeightUnit,
                        rodName,
                        reelName,
                        lureName,
                      ),
                    ),
                  ),
                  FishInfoCard(
                    species: fish.species,
                    length: fish.length,
                    lengthUnit: fishLengthUnit,
                    weight: fish.weight,
                    weightUnit: fishWeightUnit,
                    fate: fish.fate.value,
                    catchTime: catchTime,
                    locationName: fish.locationName,
                    rodEquipment: state.rodEquipment,
                    reelEquipment: state.reelEquipment,
                    lureEquipment: state.lureEquipment,
                    airTemperature: fish.airTemperature,
                    pressure: fish.pressure,
                    weatherCode: fish.weatherCode,
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

  Widget _buildFishImageGallery(
    FishCatch fish,
    FishDetailState state,
    DateTime catchTime,
    String fishLengthUnit,
    String fishWeightUnit,
    String? rodName,
    String? reelName,
    String? lureName,
  ) {
    return FishImageGallery(
      imagePath: fish.imagePath ?? '',
      species: fish.species,
      length: fish.length,
      weight: fish.weight,
      lengthUnit: fishLengthUnit,
      weightUnit: fishWeightUnit,
      locationName: fish.locationName,
      catchTime: catchTime,
      rodName: rodName,
      reelName: reelName,
      lureName: lureName,
      rodBrand: state.rodEquipment?.brand,
      rodModel: state.rodEquipment?.model,
      rodMaterial: state.rodEquipment?.material,
      rodLength: state.rodEquipment?.length,
      rodLengthUnit: state.rodEquipment?.lengthUnit,
      rodHardness: state.rodEquipment?.hardness,
      rodAction: state.rodEquipment?.rodAction,
      reelBrand: state.reelEquipment?.brand,
      reelModel: state.reelEquipment?.model,
      reelRatio: state.reelEquipment?.reelRatio,
      lureBrand: state.lureEquipment?.brand,
      lureModel: state.lureEquipment?.model,
      lureSize: state.lureEquipment?.lureSize,
      lureSizeUnit: state.lureEquipment?.lureSizeUnit,
      lureColor: state.lureEquipment?.lureColor,
      lureWeight: state.lureEquipment?.lureWeight,
      lureWeightUnit: state.lureEquipment?.lureWeightUnit,
      airTemperature: fish.airTemperature,
      pressure: fish.pressure,
      weatherCode: fish.weatherCode,
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

    if (confirm ?? false) {
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
    FishCatch fish,
    FishDetailState state,
    String? rodName,
    String? reelName,
    String? lureName,
    DateTime catchTime,
  ) async {
    final imagePath = fish.imagePath;
    if (imagePath == null || imagePath.isEmpty) {
      AppSnackBar.showError(context, strings.takePhotoFirst);
      return;
    }

    final appSettings = ref.read(appSettingsProvider);
    final units = appSettings.units;
    final fishLengthUnit = fish.lengthUnit;
    final fishWeightUnit = fish.weightUnit;
    final fishLength = fish.length;
    final fishWeight = fish.weight;

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

    final shareText =
        '${fish.species} - ${displayLength.toStringAsFixed(2)}${UnitConverter.getLengthSymbol(units.fishLengthUnit)}';

    final previewData = PreviewData(
      imagePath: imagePath,
      species: fish.species,
      length: fishLength,
      weight: fishWeight,
      lengthUnit: fishLengthUnit,
      weightUnit: fishWeightUnit,
      locationName: fish.locationName,
      catchTime: catchTime,
      rodName: rodName,
      reelName: reelName,
      lureName: lureName,
      rodBrand: state.rodEquipment?.brand,
      rodModel: state.rodEquipment?.model,
      rodMaterial: state.rodEquipment?.material,
      rodLength: state.rodEquipment?.length,
      rodLengthUnit: state.rodEquipment?.lengthUnit,
      rodHardness: state.rodEquipment?.hardness,
      rodAction: state.rodEquipment?.rodAction,
      reelBrand: state.reelEquipment?.brand,
      reelModel: state.reelEquipment?.model,
      reelRatio: state.reelEquipment?.reelRatio,
      lureBrand: state.lureEquipment?.brand,
      lureModel: state.lureEquipment?.model,
      lureSize: state.lureEquipment?.lureSize,
      lureSizeUnit: state.lureEquipment?.lureSizeUnit,
      lureColor: state.lureEquipment?.lureColor,
      lureWeight: state.lureEquipment?.lureWeight,
      lureWeightUnit: state.lureEquipment?.lureWeightUnit,
      airTemperature: fish.airTemperature,
      pressure: fish.pressure,
      weatherCode: fish.weatherCode,
      displayLength: displayLength,
      displayWeight: displayWeight,
      displayLengthUnit: units.fishLengthUnit,
      displayWeightUnit: units.fishWeightUnit,
      displayTemperatureUnit: units.temperatureUnit,
      shareText: shareText,
    );

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => WatermarkSharePreviewPage(data: previewData),
        ),
      );
    }
  }

  Future<void> _editFish(
    BuildContext context,
    FishCatch fish,
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
