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
            _buildStyleSection(context, ref, settings, strings),
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

  Widget _buildStyleSection(
    BuildContext context,
    WidgetRef ref,
    WatermarkSettings settings,
    AppStrings strings,
  ) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.style,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '水印样式',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 水印位置
          _buildPositionSelector(context, ref, settings),
          const SizedBox(height: 16),
          // 背景圆角程度
          _buildSliderSetting(
            context: context,
            label: '背景圆角',
            value: settings.blurRadius,
            min: 0,
            max: 20,
            onChanged: (value) {
              ref
                  .read(watermarkSettingsProvider.notifier)
                  .updateBlurRadius(value);
            },
          ),
          const SizedBox(height: 12),
          // 背景透明度
          _buildSliderSetting(
            context: context,
            label: '背景透明度',
            value: settings.backgroundOpacity * 100,
            min: 0,
            max: 100,
            onChanged: (value) {
              ref
                  .read(watermarkSettingsProvider.notifier)
                  .updateBackgroundOpacity(value / 100);
            },
            valueFormatter: (v) => '${v.toInt()}%',
          ),
          const SizedBox(height: 12),
          // 字体大小
          _buildSliderSetting(
            context: context,
            label: '字体大小',
            value: settings.fontSize,
            min: 10,
            max: 24,
            onChanged: (value) {
              ref
                  .read(watermarkSettingsProvider.notifier)
                  .updateFontSize(value);
            },
          ),
          const SizedBox(height: 16),
          // 字体颜色
          _buildColorSelector(context, ref, settings),
        ],
      ),
    );
  }

  Widget _buildColorSelector(
    BuildContext context,
    WidgetRef ref,
    WatermarkSettings settings,
  ) {
    final colors = [
      (0xFFFFFFFF, '白色'),
      (0xFF000000, '黑色'),
      (0xFFFF0000, '红色'),
      (0xFF00FF00, '绿色'),
      (0xFF0000FF, '蓝色'),
      (0xFFFFFF00, '黄色'),
      (0xFFFF00FF, '紫色'),
      (0xFF00FFFF, '青色'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '字体颜色',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            final isSelected = settings.textColor == color.$1;
            return GestureDetector(
              onTap: () {
                ref
                    .read(watermarkSettingsProvider.notifier)
                    .updateTextColor(color.$1);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(color.$1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.3),
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: color.$1 == 0xFF000000
                            ? Colors.white
                            : Colors.black,
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPositionSelector(
    BuildContext context,
    WidgetRef ref,
    WatermarkSettings settings,
  ) {
    const positions = [
      (WatermarkPosition.topLeft, '左上', Icons.north_west),
      (WatermarkPosition.topRight, '右上', Icons.north_east),
      (WatermarkPosition.bottomLeft, '左下', Icons.south_west),
      (WatermarkPosition.bottomRight, '右下', Icons.south_east),
      (WatermarkPosition.center, '居中', Icons.center_focus_strong),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '水印位置',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: positions.map((pos) {
            final isSelected = settings.position == pos.$1;
            return GestureDetector(
              onTap: () {
                ref
                    .read(watermarkSettingsProvider.notifier)
                    .updatePosition(pos.$1);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      pos.$3,
                      size: 20,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pos.$2,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSliderSetting({
    required BuildContext context,
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    String Function(double)? valueFormatter,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              valueFormatter != null
                  ? valueFormatter(value)
                  : value.toStringAsFixed(1),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
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
