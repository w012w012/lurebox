import 'package:flutter/material.dart';

import '../../../core/constants/strings.dart';
import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/tesla_theme.dart';
import '../../../core/models/watermark_settings.dart';
import '../../../widgets/common/premium_card.dart';

class WatermarkInfoSection extends StatelessWidget {
  final WatermarkSettings settings;
  final AppStrings strings;
  final void Function(WatermarkInfoType) onToggle;
  final void Function(int, int) onReorder;

  const WatermarkInfoSection({
    super.key,
    required this.settings,
    required this.strings,
    required this.onToggle,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final orderedTypes = settings.infoTypes
        .map(
          (type) => WatermarkInfoTypeInfo.allTypes.firstWhere(
            (info) => info.type == type,
          ),
        )
        .toList();

    final unselectedTypes = WatermarkInfoTypeInfo.allTypes
        .where((info) => !settings.infoTypes.contains(info.type))
        .toList();

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: TeslaTheme.spacingSm),
              Text(
                strings.displayInfo,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: TeslaTheme.spacingSm),
          Text(
            strings.selectWatermarkInfo,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: TeslaColors.graphite),
          ),
          const SizedBox(height: TeslaTheme.spacingSm),
          Text(
            strings.watermarkDragToSort,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: TeslaTheme.spacingSm),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderedTypes.length,
            onReorder: onReorder,
            itemBuilder: (context, index) {
              final typeInfo = orderedTypes[index];

              return _WatermarkInfoTile(
                key: ValueKey(typeInfo.type),
                typeInfo: typeInfo,
                isSelected: true,
                strings: strings,
                onToggle: () => onToggle(typeInfo.type),
              );
            },
          ),
          if (unselectedTypes.isNotEmpty) ...[
            const Divider(height: 24),
            Text(
              strings.watermarkNotEnabled,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: TeslaColors.graphite),
            ),
            const SizedBox(height: TeslaTheme.spacingSm),
            ...unselectedTypes.map((typeInfo) {
              return _WatermarkInfoTile(
                key: ValueKey(typeInfo.type),
                typeInfo: typeInfo,
                isSelected: false,
                strings: strings,
                onToggle: () => onToggle(typeInfo.type),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _WatermarkInfoTile extends StatelessWidget {
  final WatermarkInfoTypeInfo typeInfo;
  final bool isSelected;
  final AppStrings strings;
  final VoidCallback? onToggle;

  const _WatermarkInfoTile({
    super.key,
    required this.typeInfo,
    required this.isSelected,
    required this.strings,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: ListTile(
        leading: isSelected
            ? const Icon(Icons.drag_handle, color: TeslaColors.graphite)
            : Checkbox(value: false, onChanged: (_) => onToggle?.call()),
        title: Row(
          children: [
            Text(typeInfo.icon),
            const SizedBox(width: TeslaTheme.spacingSm),
            Expanded(
              child: Text(
                typeInfo.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? null : TeslaColors.graphite,
                    ),
              ),
            ),
          ],
        ),
        trailing: isSelected
            ? IconButton(
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                onPressed: onToggle,
              )
            : null,
        onTap: onToggle,
        dense: true,
      ),
    );
  }
}
