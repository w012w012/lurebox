import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/utils/unit_converter.dart';
import 'package:lurebox/widgets/common/premium_card.dart';

/// 高级极简设备卡片
class PremiumEquipmentCard extends ConsumerStatefulWidget {

  const PremiumEquipmentCard({
    required this.equipment, required this.stats, required this.isExpanded, required this.onTap, required this.onSetDefault, required this.onDelete, super.key,
  });
  final Map<String, dynamic> equipment;
  final Map<String, int> stats;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  @override
  ConsumerState<PremiumEquipmentCard> createState() =>
      _PremiumEquipmentCardState();
}

class _PremiumEquipmentCardState extends ConsumerState<PremiumEquipmentCard> {
  bool _expanded = true;

  @override
  void didUpdateWidget(PremiumEquipmentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      _expanded = widget.isExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(currentStringsProvider);
    final isDefault = widget.equipment['is_default'] == 1;
    final type = widget.equipment['type'] as String;
    final brand = widget.equipment['brand'] as String? ?? '';
    final model = widget.equipment['model'] as String? ?? '';
    final total = widget.stats['_total'] ?? 0;

    // 获取类型图标和颜色
    final typeInfo = _getEquipmentTypeInfo(type);

    return PremiumCard(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部：图标、标题和操作
          Row(
            children: [
              // 类型图标
              Container(
                padding: const EdgeInsets.all(TeslaTheme.spacingSm),
                decoration: BoxDecoration(
                  color: typeInfo.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
                ),
                child: Icon(typeInfo.icon, color: typeInfo.color, size: 24),
              ),
              const SizedBox(width: TeslaTheme.spacingMicro),

              // 标题区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 品牌/型号
                    Text(
                      brand.isNotEmpty || model.isNotEmpty
                          ? '$brand $model'.trim()
                          : strings.unnamed,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // 类型标签
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TeslaTheme.spacingSm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: typeInfo.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
                      ),
                      child: Text(
                        typeInfo.label,
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: typeInfo.color),
                      ),
                    ),
                  ],
                ),
              ),

              // 右侧信息
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 默认标记
                  if (isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TeslaTheme.spacingSm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.gold,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            strings.defaultLabel,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppColors.gold),
                          ),
                        ],
                      ),
                    ),

                  // 渔获数量
                  if (total > 0) ...[
                    if (isDefault) const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TeslaTheme.spacingSm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: TeslaColors.electricBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
                      ),
                      child: Text(
                        '$total${strings.fishCountUnit}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: TeslaColors.electricBlue,
                            ),
                      ),
                    ),
                  ],
                ],
              ),

              // 展开/收起图标
              Icon(
                _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),

              // 菜单按钮
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'default') widget.onSetDefault();
                  if (v == 'delete') widget.onDelete();
                  if (v == 'edit') widget.onTap();
                },
                itemBuilder: (c) => [
                  PopupMenuItem(value: 'edit', child: Text(strings.edit)),
                  if (!isDefault)
                    PopupMenuItem(
                      value: 'default',
                      child: Text(strings.setDefault),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      strings.delete,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          // 分类标签（如果有）
          if (widget.equipment['category'] != null) ...[
            const SizedBox(height: TeslaTheme.spacingSm),
            _buildCategoryChip(
              context,
              _getCategoryName(type, widget.equipment['category'] as String),
            ),
          ],

          // 展开的详细信息
          if (_expanded) ...[
            const SizedBox(height: TeslaTheme.spacingMicro),
            const Divider(height: 1),
            const SizedBox(height: TeslaTheme.spacingMicro),

            // 信息行
            ..._buildInfoRows(type, widget.equipment),

            // 统计信息
            if (total > 0) ...[
              const SizedBox(height: TeslaTheme.spacingSm),
              _buildStatsSection(context, widget.stats),
            ],

            // 购买日期
            if (widget.equipment['purchase_date'] != null) ...[
              const SizedBox(height: TeslaTheme.spacingSm),
              _buildPurchaseDate(context, widget.equipment['purchase_date'] as String),
            ],
          ],
        ],
      ),
    );
  }

  String _parseWeightRange(String rangeStr, String displayUnit) {
    if (rangeStr.isEmpty) return '';

    // Remove all whitespace and convert to lowercase for parsing
    final cleanStr = rangeStr.toLowerCase().replaceAll(' ', '');

    // Extract unit from the string (g, gv, oz, lb)
    var unit = 'g';
    var numericStr = cleanStr;

    // Check for known units at the end
    final unitPattern = RegExp(r'(g|gv|oz|lb)$');
    final unitMatch = unitPattern.firstMatch(cleanStr);
    if (unitMatch != null) {
      unit = unitMatch.group(1)!;
      numericStr = cleanStr.substring(0, unitMatch.start);
    }

    // Parse the numeric range (e.g., "5-20" or "5~20" or "5to20")
    double? minValue;
    double? maxValue;

    final dashIndex = numericStr.indexOf('-');
    final tildeIndex = numericStr.indexOf('~');
    final toIndex = numericStr.indexOf('to');

    if (dashIndex > 0) {
      minValue = double.tryParse(numericStr.substring(0, dashIndex));
      maxValue = double.tryParse(numericStr.substring(dashIndex + 1));
    } else if (tildeIndex > 0) {
      minValue = double.tryParse(numericStr.substring(0, tildeIndex));
      maxValue = double.tryParse(numericStr.substring(tildeIndex + 1));
    } else if (toIndex > 0) {
      minValue = double.tryParse(numericStr.substring(0, toIndex));
      maxValue = double.tryParse(numericStr.substring(toIndex + 2));
    } else {
      // Single value, not a range
      minValue = double.tryParse(numericStr);
      maxValue = minValue;
    }

    if (minValue == null && maxValue == null) {
      return rangeStr; // Could not parse numbers
    }

    minValue ??= 0;
    maxValue ??= minValue;

    // Convert to display unit
    final convertedMin =
        UnitConverter.convertWeight(minValue, unit, displayUnit);
    final convertedMax =
        UnitConverter.convertWeight(maxValue, unit, displayUnit);

    // Get display unit symbol
    final symbol = UnitConverter.getWeightSymbol(displayUnit);

    // Format: "5-20g" or "5g" if both values are equal
    if (minValue == maxValue) {
      return '${convertedMin.toStringAsFixed(1)}$symbol';
    }
    return '${convertedMin.toStringAsFixed(1)}-${convertedMax.toStringAsFixed(1)}$symbol';
  }

  Widget _buildCategoryChip(BuildContext context, String category) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TeslaTheme.spacingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: TeslaColors.electricBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
      ),
      child: Text(
        category,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: TeslaColors.electricBlue,
            ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, Map<String, int> stats) {
    final entries = stats.entries.where((e) => e.key != '_total').toList();
    if (entries.isEmpty) return const SizedBox();

    return Wrap(
      spacing: TeslaTheme.spacingSm,
      runSpacing: 4,
      children: entries.map((e) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TeslaTheme.spacingSm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: TeslaColors.electricBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
          ),
          child: Text(
            '${e.key}: ${e.value}',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: TeslaColors.electricBlue),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPurchaseDate(BuildContext context, String date) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today_rounded,
          size: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: TeslaTheme.spacingSm),
        Text(date, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  List<Widget> _buildInfoRows(String type, Map<String, dynamic> e) {
    final strings = ref.watch(currentStringsProvider);
    final displayUnits = ref.watch(appSettingsProvider).units;

    final result = switch (type) {
      'rod' => _buildRodItems(e, strings, displayUnits),
      'reel' => _buildReelItems(e, strings, displayUnits),
      'lure' => _buildLureItems(e, strings, displayUnits),
      'line' => _buildLineItems(e, strings),
      _ => (items: <_InfoItem>[], extra: <_InfoItem>[]),
    };

    final items = result.items;
    final reelLineItem = result.extra.isNotEmpty ? result.extra.first : null;

    if (items.isEmpty && reelLineItem == null) return [];

    final row = Wrap(
      spacing: TeslaTheme.spacingMicro,
      runSpacing: TeslaTheme.spacingSm,
      children: items.map((item) => _buildInfoItem(context, item)).toList(),
    );

    if (type == 'lure' && e['lure_quantity'] != null) {
      final quantity = e['lure_quantity'] as int;
      final unit = e['lure_quantity_unit'] as String? ?? '条';
      return [
        row,
        const SizedBox(height: TeslaTheme.spacingSm),
        _buildQuantityBadge(context, quantity, unit, strings),
      ];
    }

    if (type == 'reel' && reelLineItem != null) {
      return [
        row,
        const SizedBox(height: TeslaTheme.spacingSm),
        _buildInfoItemFullWidth(context, reelLineItem),
      ];
    }

    return [row];
  }

  ({List<_InfoItem> items, List<_InfoItem> extra}) _buildRodItems(
    Map<String, dynamic> e,
    AppStrings strings,
    UnitSettings displayUnits,
  ) {
    final items = <_InfoItem>[];
    if (e['length'] != null) {
      final lengthValue = double.tryParse(e['length'].toString()) ?? 0;
      final lengthUnit = (e['length_unit'] as String?) ?? 'm';
      final displayLength = UnitConverter.convertLength(
        lengthValue, lengthUnit, displayUnits.rodLengthUnit,
      );
      items.add(_InfoItem(
        strings.rodLength,
        '${displayLength.toStringAsFixed(2)} ${UnitConverter.getLengthSymbol(displayUnits.rodLengthUnit)}',
      ),);
    }
    if (e['sections'] != null) {
      items.add(_InfoItem(strings.sections, '${e['sections']}'));
    }
    if (e['joint_type'] != null) {
      items.add(_InfoItem(strings.cardJointMethod, _getJointTypeLabel(e['joint_type'] as String, strings)));
    }
    if (e['hardness'] != null) {
      items.add(_InfoItem(strings.hardness, e['hardness'] as String));
    }
    if (e['rod_action'] != null) {
      items.add(_InfoItem(strings.rodAction, e['rod_action'] as String));
    }
    if (e['material'] != null) {
      items.add(_InfoItem(strings.material, e['material'] as String));
    }
    if (e['weight_range'] != null) {
      final displayWeight = _parseWeightRange(
        e['weight_range'].toString(), displayUnits.lureWeightUnit,
      );
      if (displayWeight.isNotEmpty) {
        items.add(_InfoItem(strings.weightRange, displayWeight));
      }
    }
    return (items: items, extra: <_InfoItem>[]);
  }

  ({List<_InfoItem> items, List<_InfoItem> extra}) _buildReelItems(
    Map<String, dynamic> e,
    AppStrings strings,
    UnitSettings displayUnits,
  ) {
    final items = <_InfoItem>[];
    final extra = <_InfoItem>[];
    if (e['reel_weight'] != null) {
      final weightValue = double.tryParse(e['reel_weight'].toString()) ?? 0;
      final weightUnit = (e['reel_weight_unit'] as String?) ?? 'g';
      final displayWeight = UnitConverter.convertWeight(
        weightValue, weightUnit, displayUnits.lureWeightUnit,
      );
      items.add(_InfoItem(
        strings.reelWeight,
        '${displayWeight.toStringAsFixed(1)} ${UnitConverter.getWeightSymbol(displayUnits.lureWeightUnit)}',
      ),);
    }
    if (e['reel_ratio'] != null) {
      items.add(_InfoItem(strings.reelRatio, e['reel_ratio'] as String));
    }
    if (e['reel_capacity'] != null) {
      items.add(_InfoItem(strings.reelCapacity, e['reel_capacity'] as String));
    }
    if (e['reel_brake_type'] != null) {
      items.add(_InfoItem(strings.reelBrakeType, _getBrakeTypeLabel(e['reel_brake_type'] as String, strings)));
    }
    if (e['reel_line'] != null) {
      final lineBrand = e['reel_line'] as String? ?? '';
      final lineNumber = e['reel_line_number'] as String? ?? '';
      final lineLength = e['reel_line_length'] as String? ?? '';
      final lineDate = e['reel_line_date'];
      var lineInfo = lineBrand;
      if (lineNumber.isNotEmpty) lineInfo += ' / $lineNumber';
      if (lineLength.isNotEmpty) lineInfo += ' / $lineLength';
      if (lineDate != null) {
        final dateStr = lineDate.toString().split(RegExp('[ T]'))[0];
        lineInfo += ' / $dateStr';
      }
      extra.add(_InfoItem(strings.line, lineInfo));
    }
    return (items: items, extra: extra);
  }

  ({List<_InfoItem> items, List<_InfoItem> extra}) _buildLureItems(
    Map<String, dynamic> e,
    AppStrings strings,
    UnitSettings displayUnits,
  ) {
    final items = <_InfoItem>[];
    if (e['lure_type'] != null) {
      items.add(_InfoItem(strings.lureType, e['lure_type'] as String));
    }
    if (e['lure_weight'] != null) {
      final weightValue = double.tryParse(e['lure_weight'].toString()) ?? 0;
      final weightUnit = (e['lure_weight_unit'] as String?) ?? 'g';
      final displayWeight = UnitConverter.convertWeight(
        weightValue, weightUnit, displayUnits.lureWeightUnit,
      );
      items.add(_InfoItem(
        strings.lureWeight,
        '${displayWeight.toStringAsFixed(1)} ${UnitConverter.getWeightSymbol(displayUnits.lureWeightUnit)}',
      ),);
    }
    if (e['lure_size'] != null) {
      final sizeValue = double.tryParse(e['lure_size'].toString()) ?? 0;
      final sizeUnit = (e['lure_size_unit'] as String?) ?? 'cm';
      final displaySize = UnitConverter.convertLength(
        sizeValue, sizeUnit, displayUnits.lureLengthUnit,
      );
      items.add(_InfoItem(
        strings.lureSize,
        '${displaySize.toStringAsFixed(1)} ${UnitConverter.getLengthSymbol(displayUnits.lureLengthUnit)}',
      ),);
    }
    if (e['lure_color'] != null) {
      items.add(_InfoItem(strings.lureColor, e['lure_color'] as String));
    }
    if (e['lure_action'] != null) {
      items.add(_InfoItem(strings.cardAction, e['lure_action'] as String));
    }
    return (items: items, extra: <_InfoItem>[]);
  }

  ({List<_InfoItem> items, List<_InfoItem> extra}) _buildLineItems(
    Map<String, dynamic> e,
    AppStrings strings,
  ) {
    final items = <_InfoItem>[];
    if (e['line_type'] != null) {
      items.add(_InfoItem(strings.lineType, e['line_type'] as String));
    }
    if (e['line_length'] != null) {
      items.add(_InfoItem(strings.lineLength, e['line_length'] as String));
    }
    if (e['line_strength'] != null) {
      items.add(_InfoItem(strings.cardStrength, e['line_strength'] as String));
    }
    if (e['line_color'] != null) {
      items.add(_InfoItem(strings.cardColor, e['line_color'] as String));
    }
    return (items: items, extra: <_InfoItem>[]);
  }

  Widget _buildInfoItem(BuildContext context, _InfoItem item) {
    return SizedBox(
      width: 140,
      child: Row(
        children: [
          Text(
            '${item.label}: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Expanded(
            child: Text(
              item.value,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItemFullWidth(BuildContext context, _InfoItem item) {
    return Row(
      children: [
        Text(
          '${item.label}: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Expanded(
          child: Text(
            item.value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityBadge(BuildContext context, int quantity, String unit, AppStrings strings) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TeslaTheme.spacingMicro,
        vertical: TeslaTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: TeslaColors.electricBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
        border: Border.all(
          color: TeslaColors.electricBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inventory_2_rounded,
            size: 18,
            color: TeslaColors.electricBlue,
          ),
          const SizedBox(width: TeslaTheme.spacingSm),
          Text(
            strings.quantityPrefix,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TeslaColors.electricBlue,
                ),
          ),
          Text(
            '$quantity$unit',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: TeslaColors.electricBlue,
                ),
          ),
        ],
      ),
    );
  }

  String _getBrakeTypeLabel(String key, AppStrings strings) {
    return switch (key) {
      'traditional_magnetic' => strings.brakeTypeTraditionalMagnetic,
      'centrifugal'          => strings.brakeTypeCentrifugal,
      'dc'                   => strings.brakeTypeDC,
      'floating_magnetic'    => strings.brakeTypeFloatingMagnetic,
      'innovative'           => strings.brakeTypeInnovative,
      _                      => key,
    };
  }

  String _getJointTypeLabel(String key, AppStrings strings) {
    return switch (key) {
      'spigot'         => strings.jointTypeSpigot,
      'reverse_spigot' => strings.jointTypeReverseSpigot,
      'dragon_spigot'  => strings.jointTypeDragonSpigot,
      'telescopic'     => strings.jointTypeTelescopic,
      _                => key,
    };
  }

  String _getCategoryName(String type, String category) {
    // 简化版本：直接返回分类名称
    final strings = ref.read(currentStringsProvider);
    final categoryMap = {
      // 鱼竿类型
      'spinning': strings.typeSpinningRod,
      'baitcasting': strings.typeBaitcastingRod,
      'fly': strings.typeFlyRod,
      'trolling': strings.typeTrollingRod,
      // 渔轮类型
      'spinning_reel': strings.typeSpinningReel,
      'baitcasting_reel': strings.typeBaitcastingReel,
      'fly_reel': strings.typeFlyReel,
      'trolling_reel': strings.typeTrollingReel,
      // 假饵类型
      'hard_bait': strings.typeHardBait,
      'soft_bait': strings.typeSoftBait,
      'spinner': '亮片',
      'spoon': strings.typeSpoon,
      'jig': strings.typeJigHead,
      // 鱼线类型
      'monofilament': strings.typeNylonLine,
      'braided': strings.typePELine,
      'fluorocarbon': strings.typeFluorocarbonLine,
    };
    return categoryMap[category] ?? category;
  }

  _EquipmentTypeInfo _getEquipmentTypeInfo(String type) {
    final strings = ref.read(currentStringsProvider);
    switch (type) {
      case 'rod':
        return _EquipmentTypeInfo(
          icon: Icons.straighten_rounded,
          color: TeslaColors.electricBlue,
          label: strings.rod,
        );
      case 'reel':
        return _EquipmentTypeInfo(
          icon: Icons.settings_rounded,
          color: TeslaColors.electricBlue,
          label: strings.reel,
        );
      case 'lure':
        return _EquipmentTypeInfo(
          icon: Icons.phishing_rounded,
          color: TeslaColors.electricBlue,
          label: strings.lure,
        );
      case 'line':
        return _EquipmentTypeInfo(
          icon: Icons.timeline_rounded,
          color: TeslaColors.electricBlue,
          label: strings.line,
        );
      default:
        return _EquipmentTypeInfo(
          icon: Icons.hardware_rounded,
          color: TeslaColors.electricBlue,
          label: type,
        );
    }
  }
}

class _InfoItem {

  _InfoItem(this.label, this.value);
  final String label;
  final String value;
}

class _EquipmentTypeInfo {

  _EquipmentTypeInfo({
    required this.icon,
    required this.color,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String label;
}
