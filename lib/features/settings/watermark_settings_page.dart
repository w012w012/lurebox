import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/models/watermark_settings.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/watermark_provider.dart';
import '../../widgets/common/premium_card.dart';

/// 水印设置页面
class WatermarkSettingsPage extends ConsumerWidget {
  const WatermarkSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(watermarkSettingsProvider);
    final strings = ref.watch(currentStringsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.watermarkSettings), centerTitle: true),
      body: ListView(
        children: [
          _buildEnableSwitch(context, ref, settings, strings),
          const SizedBox(height: 8),
          if (settings.enabled) ...[
            _buildInfoSection(context, ref, settings, strings),
            const SizedBox(height: 16),
            _buildPreviewInfo(context, strings),
          ],
        ],
      ),
    );
  }

  Widget _buildEnableSwitch(
    BuildContext context,
    WidgetRef ref,
    WatermarkSettings settings,
    AppStrings strings,
  ) {
    return PremiumCard(
      child: Row(
        children: [
          Icon(
            settings.enabled
                ? Icons.branding_watermark
                : Icons.branding_watermark_outlined,
            color: settings.enabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.enableWatermark,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  settings.enabled
                      ? strings.watermarkPosition
                      : strings.watermarkDisabled,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: settings.enabled,
            onChanged: (value) {
              ref.read(watermarkSettingsProvider.notifier).updateEnabled(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    WidgetRef ref,
    WatermarkSettings settings,
    AppStrings strings,
  ) {
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
              const SizedBox(width: 8),
              Text(
                strings.displayInfo,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            strings.selectWatermarkInfo,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.secondaryLight),
          ),
          const SizedBox(height: 12),
          Text(
            '长按拖拽可排序',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderedTypes.length,
            onReorder: (oldIndex, newIndex) {
              ref
                  .read(watermarkSettingsProvider.notifier)
                  .reorderInfoTypes(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final typeInfo = orderedTypes[index];
              final isRequired = typeInfo.type == WatermarkInfoType.appName;

              return _WatermarkInfoTile(
                key: ValueKey(typeInfo.type),
                typeInfo: typeInfo,
                isRequired: isRequired,
                isSelected: true,
                strings: strings,
                onToggle: isRequired
                    ? null
                    : () {
                        ref
                            .read(watermarkSettingsProvider.notifier)
                            .toggleInfoType(typeInfo.type);
                      },
              );
            },
          ),
          if (unselectedTypes.isNotEmpty) ...[
            const Divider(height: 24),
            Text(
              '未启用',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.secondaryLight),
            ),
            const SizedBox(height: 8),
            ...unselectedTypes.map((typeInfo) {
              return _WatermarkInfoTile(
                key: ValueKey(typeInfo.type),
                typeInfo: typeInfo,
                isRequired: false,
                isSelected: false,
                strings: strings,
                onToggle: () {
                  ref
                      .read(watermarkSettingsProvider.notifier)
                      .toggleInfoType(typeInfo.type);
                },
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewInfo(BuildContext context, AppStrings strings) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                strings.watermarkPreview,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🐟 ${strings.species}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${strings.length}: 52.0cm',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '📍 ${strings.location}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  strings.fromLureBox,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryLight,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.watermarkPositionDesc,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.secondaryLight),
          ),
        ],
      ),
    );
  }
}

class _WatermarkInfoTile extends StatelessWidget {
  final WatermarkInfoTypeInfo typeInfo;
  final bool isRequired;
  final bool isSelected;
  final AppStrings strings;
  final VoidCallback? onToggle;

  const _WatermarkInfoTile({
    super.key,
    required this.typeInfo,
    required this.isRequired,
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
              ).colorScheme.primaryContainer.withOpacity(0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: ListTile(
        leading: isSelected
            ? const Icon(Icons.drag_handle, color: AppColors.secondaryLight)
            : Checkbox(value: false, onChanged: (_) => onToggle?.call()),
        title: Row(
          children: [
            Text(typeInfo.icon),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                typeInfo.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? null : AppColors.secondaryLight,
                    ),
              ),
            ),
            if (isRequired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  strings.defaultLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.secondaryLight,
                      ),
                ),
              ),
          ],
        ),
        trailing: isSelected
            ? IconButton(
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: isRequired
                      ? AppColors.secondaryLight
                      : Theme.of(context).colorScheme.error,
                ),
                onPressed: isRequired ? null : onToggle,
              )
            : null,
        onTap: onToggle,
        dense: true,
      ),
    );
  }
}
