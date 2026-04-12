import 'package:flutter/material.dart';
import '../../common/watermarked_image.dart';

class FishImageGallery extends StatelessWidget {
  final String imagePath;
  final String species;
  final double length;
  final double? weight;
  final String? lengthUnit;
  final String? weightUnit;
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
  final VoidCallback? onTap;

  const FishImageGallery({
    super.key,
    required this.imagePath,
    required this.species,
    required this.length,
    required this.weight,
    this.lengthUnit,
    this.weightUnit,
    required this.locationName,
    required this.catchTime,
    required this.rodName,
    required this.reelName,
    required this.lureName,
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
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _showFullImage(context),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: WatermarkedImage(
          imagePath: imagePath,
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
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.image,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: WatermarkedImage(
                imagePath: imagePath,
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
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
