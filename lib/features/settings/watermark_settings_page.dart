import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/design/theme/tesla_theme.dart';
import '../../core/models/watermark_settings.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/watermark_provider.dart';
import '../../widgets/common/premium_card.dart';
import '../common/watermarked_image.dart';

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
          const SizedBox(height: TeslaTheme.spacingMicro),
          if (settings.enabled) ...[
            _buildInfoSection(context, ref, settings, strings),
            const SizedBox(height: TeslaTheme.spacingMd),
            _buildStyleSection(context, ref, settings, strings),
            const SizedBox(height: TeslaTheme.spacingMd),
            _buildPreviewInfo(context, settings, strings),
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
          const SizedBox(width: TeslaTheme.spacingMd),
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
            '长按拖拽可排序',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: TeslaTheme.spacingSm),
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

              return _WatermarkInfoTile(
                key: ValueKey(typeInfo.type),
                typeInfo: typeInfo,
                isSelected: true,
                strings: strings,
                onToggle: () {
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
              ).textTheme.bodySmall?.copyWith(color: TeslaColors.graphite),
            ),
            const SizedBox(height: TeslaTheme.spacingSm),
            ...unselectedTypes.map((typeInfo) {
              return _WatermarkInfoTile(
                key: ValueKey(typeInfo.type),
                typeInfo: typeInfo,
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
              const SizedBox(width: TeslaTheme.spacingSm),
              Text(
                '水印样式',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: TeslaTheme.spacingMd),
          // 预设样式选择
          _buildStyleSelector(context, ref, settings),
          const SizedBox(height: TeslaTheme.spacingMd),
          // 水印位置
          _buildPositionSelector(context, ref, settings),
          const SizedBox(height: TeslaTheme.spacingMd),
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
          const SizedBox(height: TeslaTheme.spacingSm),
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
          const SizedBox(height: TeslaTheme.spacingSm),
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
          const SizedBox(height: TeslaTheme.spacingMd),
          // 字体颜色
          _buildColorSelector(context, ref, settings),
          const SizedBox(height: TeslaTheme.spacingSm),
          // 自定义文字
          _CustomTextFieldBuilder(settings: settings),
        ],
      ),
    );
  }

  Widget _buildStyleSelector(
    BuildContext context,
    WidgetRef ref,
    WatermarkSettings settings,
  ) {
    final styles = [
      (WatermarkStyle.minimal, '简约', '左下角简洁呈现'),
      (WatermarkStyle.elegant, '优雅', '右下角深色磨砂'),
      (WatermarkStyle.bold, '大字', '居中醒目高对比'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '模板',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: TeslaTheme.spacingSm),
        Row(
          children: styles.map((s) {
            final isSelected = settings.style == s.$1;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  ref
                      .read(watermarkSettingsProvider.notifier)
                      .updateStyle(s.$1);
                },
                child: Container(
                  margin: EdgeInsets.only(
                    right: s != styles.last ? TeslaTheme.spacingSm : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.15)
                        : Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        s.$2,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.$3,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: TeslaColors.graphite,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
        const SizedBox(height: TeslaTheme.spacingSm),
        Wrap(
          spacing: TeslaTheme.spacingSm,
          runSpacing: TeslaTheme.spacingSm,
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
                  borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
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
        const SizedBox(height: TeslaTheme.spacingSm),
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
                padding: const EdgeInsets.all(TeslaTheme.spacingSm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
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

  Widget _buildPreviewInfo(
    BuildContext context,
    WatermarkSettings settings,
    AppStrings strings,
  ) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: TeslaTheme.spacingSm),
              Text(
                strings.watermarkPreview,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: TeslaTheme.spacingSm),
          _LiveWatermarkPreview(settings: settings, strings: strings),
          const SizedBox(height: TeslaTheme.spacingSm),
          Text(
            _getPositionDesc(settings.position, strings),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: TeslaColors.graphite),
          ),
        ],
      ),
    );
  }

  String _getPositionDesc(WatermarkPosition position, AppStrings strings) {
    return switch (position) {
      WatermarkPosition.topLeft => strings.watermarkPositionTopLeft,
      WatermarkPosition.topRight => strings.watermarkPositionTopRight,
      WatermarkPosition.bottomLeft => strings.watermarkPositionBottomLeft,
      WatermarkPosition.bottomRight => strings.watermarkPositionBottomRight,
      WatermarkPosition.center => strings.watermarkPositionCenter,
    };
  }
}

/// 管理 TextEditingController 生命周期的 StatefulWidget
class _CustomTextFieldBuilder extends ConsumerStatefulWidget {
  final WatermarkSettings settings;

  const _CustomTextFieldBuilder({required this.settings});

  @override
  ConsumerState<_CustomTextFieldBuilder> createState() =>
      _CustomTextFieldBuilderState();
}

class _CustomTextFieldBuilderState
    extends ConsumerState<_CustomTextFieldBuilder> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.settings.customText ?? '');
  }

  @override
  void didUpdateWidget(covariant _CustomTextFieldBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部重置（如切换预设模板）时同步控制器
    if (widget.settings.customText != oldWidget.settings.customText &&
        _controller.text != (widget.settings.customText ?? '')) {
      _controller.text = widget.settings.customText ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '自定义文字',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: TeslaTheme.spacingMicro),
        Text(
          '显示在水印底部（如个人签名）',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: TeslaColors.graphite,
              ),
        ),
        const SizedBox(height: TeslaTheme.spacingSm),
        TextField(
          decoration: InputDecoration(
            hintText: '选填，例如：个性签名',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: TeslaTheme.spacingSm,
              vertical: 10,
            ),
            isDense: true,
          ),
          controller: _controller,
          onChanged: (value) {
            ref
                .read(watermarkSettingsProvider.notifier)
                .updateCustomText(value.isEmpty ? null : value);
          },
        ),
      ],
    );
  }
}

class _LiveWatermarkPreview extends StatelessWidget {
  final WatermarkSettings settings;
  final AppStrings strings;

  const _LiveWatermarkPreview({
    required this.settings,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CustomPaint(
          painter: _WatermarkPreviewPainter(
            settings: settings,
            strings: strings,
          ),
          child: Container(),
        ),
      ),
    );
  }
}

/// 实时预览用的水印绘制器，直接渲染文字不依赖图片
class _WatermarkPreviewPainter extends CustomPainter {
  final WatermarkSettings settings;
  final AppStrings strings;

  _WatermarkPreviewPainter({
    required this.settings,
    required this.strings,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制渐变背景（模拟水面）
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2E7D6A),
          Color(0xFF1565C0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    if (!settings.enabled) return;

    final painter = _buildWatermarkPainter(size, strings);
    painter.paint(canvas, size);
  }

  WatermarkPainter _buildWatermarkPainter(Size size, AppStrings strings) {
    // 模拟的渔获数据
    const species = '鳜鱼';
    const length = 52.0;
    const locationName = '杭州西湖';
    const airTemperature = 25.0;
    const pressure = 1013.0;
    const weatherCode = 0;
    const displayLength = 52.0;
    const displayWeight = 1.2;
    const displayLengthUnit = 'cm';
    const displayWeightUnit = 'kg';
    const displayTemperatureUnit = 'C';

    // 根据预览尺寸缩放字号
    final previewSettings = WatermarkSettings(
      enabled: true,
      style: settings.style,
      infoTypes: settings.infoTypes,
      blurRadius: settings.blurRadius,
      backgroundOpacity: settings.backgroundOpacity,
      backgroundColor: settings.backgroundColor,
      fontSize: settings.fontSize * (size.width / 400).clamp(0.5, 1.5),
      textColor: settings.textColor,
      position: settings.position,
      customText: settings.customText,
    );

    return WatermarkPainter(
      species: species,
      length: length,
      locationName: locationName,
      airTemperature: airTemperature,
      pressure: pressure,
      weatherCode: weatherCode,
      settings: previewSettings,
      strings: strings,
      displayLength: displayLength,
      displayWeight: displayWeight,
      displayLengthUnit: displayLengthUnit,
      displayWeightUnit: displayWeightUnit,
      displayTemperatureUnit: displayTemperatureUnit,
    );
  }

  @override
  bool shouldRepaint(covariant _WatermarkPreviewPainter oldDelegate) {
    return settings != oldDelegate.settings ||
        strings != oldDelegate.strings;
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
