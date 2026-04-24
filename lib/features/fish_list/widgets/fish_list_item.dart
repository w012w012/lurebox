import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/strings.dart';
import '../../../core/design/theme/app_colors.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/models/fish_catch.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../widgets/common/image_cache_helper.dart';

class FishListItem extends ConsumerWidget {
  final FishCatch fish;
  final AppStrings strings;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onQuickIdentify;

  const FishListItem({
    super.key,
    required this.fish,
    required this.strings,
    this.isSelected = false,
    this.isSelectionMode = false,
    required this.onTap,
    this.onLongPress,
    this.onQuickIdentify,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayUnits = ref.watch(
      appSettingsProvider.select((settings) => settings.units),
    );
    final isChinese = ref.watch(
      appSettingsProvider
          .select((settings) => settings.language == AppLanguage.chinese),
    );

    final displayLength = UnitConverter.convertLength(
      fish.length,
      fish.lengthUnit,
      displayUnits.fishLengthUnit,
    );
    final displayWeight = fish.weight != null
        ? UnitConverter.convertWeight(
            fish.weight!,
            fish.weightUnit,
            displayUnits.fishWeightUnit,
          )
        : null;

    final fate = fish.fate;
    final locationName = fish.locationName;

    final a11yLabel =
        '${fish.species}, ${displayLength.toStringAsFixed(1)} ${UnitConverter.getLengthSymbol(displayUnits.fishLengthUnit, isChinese: isChinese)}';

    return Semantics(
      label: a11yLabel,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color:
            isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
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
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: Image(
                      image: ImageCacheHelper.getCachedThumbnailProvider(
                        fish.imagePath,
                        width: 140,
                      ),
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Shimmer.fromColors(
                          baseColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          highlightColor: Theme.of(context).colorScheme.surface,
                          child: Container(
                            width: 70,
                            height: 70,
                            color: Colors.white,
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fish.species,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (fish.pendingRecognition) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⚠️', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 2),
                              Text(
                                strings.pendingRecognition,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${displayLength.toStringAsFixed(1)} ${UnitConverter.getLengthSymbol(displayUnits.fishLengthUnit, isChinese: isChinese)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (displayWeight != null) ...[
                            const SizedBox(width: 12),
                            Text(
                              '${displayWeight.toStringAsFixed(2)} ${UnitConverter.getWeightSymbol(displayUnits.fishWeightUnit, isChinese: isChinese)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
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
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                locationName,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: fate == FishFateType.release
                            ? AppColors.releaseBackground
                            : AppColors.keepBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        fate == FishFateType.release
                            ? strings.release
                            : strings.keep,
                        style: TextStyle(
                          fontSize: 12,
                          color: fate == FishFateType.release
                              ? AppColors.release
                              : AppColors.keep,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (fish.pendingRecognition && onQuickIdentify != null) ...[
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: onQuickIdentify,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🤖', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 2),
                              Text(
                                strings.recognize,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '${fish.catchTime.month}-${fish.catchTime.day} ${fish.catchTime.hour.toString().padLeft(2, '0')}:${fish.catchTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
