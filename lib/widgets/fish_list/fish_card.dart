import 'package:flutter/material.dart';
import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/models/fish_catch.dart';
import '../../core/utils/unit_converter.dart';
import '../common/image_cache_helper.dart';

class FishCard extends StatelessWidget {
  final Map<String, dynamic> fish;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final AppStrings strings;
  final String lengthUnit;
  final String weightUnit;

  const FishCard({
    super.key,
    required this.fish,
    this.isSelected = false,
    this.isSelectionMode = false,
    required this.onTap,
    this.onLongPress,
    required this.strings,
    this.lengthUnit = 'cm',
    this.weightUnit = 'kg',
  });

  @override
  Widget build(BuildContext context) {
    final fate = fish['fate'] as int;
    final catchTime = DateTime.parse(fish['catch_time'] as String);
    final locationName = fish['location_name'] as String?;
    final length = fish['length'] as double? ?? 0;
    final weight = fish['weight'] as double?;
    final species = fish['species'] as String;
    final imagePath = fish['image_path'] as String?;

    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              _buildThumbnail(context, imagePath),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfo(
                  context,
                  species,
                  length,
                  weight,
                  locationName,
                ),
              ),
              _buildFateAndTime(context, fate, catchTime),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, String? imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 70,
        height: 70,
        child: imagePath != null && imagePath.isNotEmpty
            ? Image(
                image: ImageCacheHelper.getCachedThumbnailProvider(
                  imagePath,
                  width: 140,
                ),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(context),
              )
            : _buildPlaceholder(context),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildInfo(
    BuildContext context,
    String species,
    double length,
    double? weight,
    String? locationName,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          species,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '${length.toStringAsFixed(1)} ${UnitConverter.getLengthSymbol(lengthUnit)}',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (weight != null) ...[
              const SizedBox(width: 12),
              Text(
                '${weight.toStringAsFixed(2)} ${UnitConverter.getWeightSymbol(weightUnit)}',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        if (locationName != null && locationName.isNotEmpty) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 12,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  locationName,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFateAndTime(BuildContext context, int fate, DateTime catchTime) {
    final isRelease = fate == FishFateType.release.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isRelease
                ? AppColors.releaseBackground
                : AppColors.keepBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isRelease ? strings.release : strings.keep,
            style: TextStyle(
              fontSize: 12,
              color: isRelease ? AppColors.release : AppColors.keep,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${catchTime.month}-${catchTime.day} ${catchTime.hour.toString().padLeft(2, '0')}:${catchTime.minute.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
