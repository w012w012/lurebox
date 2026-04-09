import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/design/theme/app_theme.dart';
import '../../../core/design/theme/app_colors.dart';
import '../../../core/utils/unit_converter.dart';
import '../common/premium_card.dart';

/// 高级极简设备卡片
class PremiumEquipmentCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> equipment;
  final Map<String, int> stats;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const PremiumEquipmentCard({
    super.key,
    required this.equipment,
    required this.stats,
    required this.isExpanded,
    required this.onTap,
    required this.onSetDefault,
    required this.onDelete,
  });

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
      variant: PremiumCardVariant.standard,
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部：图标、标题和操作
          Row(
            children: [
              // 类型图标
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: typeInfo.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(typeInfo.icon, color: typeInfo.color, size: 24),
              ),
              const SizedBox(width: AppTheme.spacingMd),

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
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // 类型标签
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: typeInfo.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
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
                        horizontal: AppTheme.spacingSm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
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
                        horizontal: AppTheme.spacingSm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Text(
                        '$total${strings.fishCountUnit}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.success,
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
            const SizedBox(height: AppTheme.spacingSm),
            _buildCategoryChip(
              context,
              _getCategoryName(type, widget.equipment['category']),
            ),
          ],

          // 展开的详细信息
          if (_expanded) ...[
            const SizedBox(height: AppTheme.spacingMd),
            const Divider(height: 1),
            const SizedBox(height: AppTheme.spacingMd),

            // 信息行
            ..._buildInfoRows(type, widget.equipment),

            // 统计信息
            if (total > 0) ...[
              const SizedBox(height: AppTheme.spacingSm),
              _buildStatsSection(context, widget.stats),
            ],

            // 购买日期
            if (widget.equipment['purchase_date'] != null) ...[
              const SizedBox(height: AppTheme.spacingSm),
              _buildPurchaseDate(context, widget.equipment['purchase_date']),
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
    String unit = 'g';
    String numericStr = cleanStr;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        category,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isDark ? AppColors.accentDark : AppColors.accentLight,
            ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, Map<String, int> stats) {
    final entries = stats.entries.where((e) => e.key != '_total').toList();
    if (entries.isEmpty) return const SizedBox();

    return Wrap(
      spacing: AppTheme.spacingSm,
      runSpacing: 4,
      children: entries.map((e) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingSm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Text(
            '${e.key}: ${e.value}',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.success),
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
        const SizedBox(width: AppTheme.spacingSm),
        Text(date, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  List<Widget> _buildInfoRows(String type, Map<String, dynamic> e) {
    final strings = ref.watch(currentStringsProvider);
    final displayUnits = ref.watch(appSettingsProvider).units;
    final items = <_InfoItem>[];
    _InfoItem? reelLineItem; // Store reel line info separately for its own row

    if (type == 'rod') {
      if (e['length'] != null) {
        final lengthValue = double.tryParse(e['length'].toString()) ?? 0;
        final lengthUnit = e['length_unit'] ?? 'm';
        final displayLength = UnitConverter.convertLength(
          lengthValue,
          lengthUnit,
          displayUnits.rodLengthUnit,
        );
        items.add(
          _InfoItem(
            strings.rodLength,
            '${displayLength.toStringAsFixed(2)} ${UnitConverter.getLengthSymbol(displayUnits.rodLengthUnit)}',
          ),
        );
      }
      if (e['sections'] != null) {
        items.add(_InfoItem(strings.sections, '${e['sections']}'));
      }
      if (e['joint_type'] != null) {
        items.add(_InfoItem('插节方式', e['joint_type']));
      }
      if (e['hardness'] != null) {
        items.add(_InfoItem(strings.hardness, e['hardness']));
      }
      if (e['rod_action'] != null) {
        items.add(_InfoItem(strings.rodAction, e['rod_action']));
      }
      if (e['material'] != null) {
        items.add(_InfoItem(strings.material, e['material']));
      }
      if (e['weight_range'] != null) {
        final rangeStr = e['weight_range'].toString();
        final displayWeight =
            _parseWeightRange(rangeStr, displayUnits.lureWeightUnit);
        if (displayWeight.isNotEmpty) {
          items.add(
            _InfoItem(
              strings.weightRange,
              displayWeight,
            ),
          );
        }
      }
    } else if (type == 'reel') {
      if (e['reel_weight'] != null) {
        final weightValue = double.tryParse(e['reel_weight'].toString()) ?? 0;
        final weightUnit = e['reel_weight_unit'] ?? 'g';
        final displayWeight = UnitConverter.convertWeight(
          weightValue,
          weightUnit,
          displayUnits.lureWeightUnit,
        );
        items.add(
          _InfoItem(
            strings.reelWeight,
            '${displayWeight.toStringAsFixed(1)} ${UnitConverter.getWeightSymbol(displayUnits.lureWeightUnit)}',
          ),
        );
      }
      if (e['reel_ratio'] != null) {
        items.add(_InfoItem(strings.reelRatio, e['reel_ratio']));
      }
      if (e['reel_capacity'] != null) {
        items.add(_InfoItem(strings.reelCapacity, e['reel_capacity']));
      }
      if (e['reel_brake_type'] != null) {
        items.add(_InfoItem(strings.reelBrakeType, e['reel_brake_type']));
      }
      if (e['reel_line'] != null) {
        final lineBrand = e['reel_line'] as String? ?? '';
        final lineNumber = e['reel_line_number'] as String? ?? '';
        final lineLength = e['reel_line_length'] as String? ?? '';
        final lineDate = e['reel_line_date'];
        String lineInfo = lineBrand;
        if (lineNumber.isNotEmpty) lineInfo += ' / $lineNumber';
        if (lineLength.isNotEmpty) lineInfo += ' / $lineLength';
        if (lineDate != null) {
          final dateStr = lineDate.toString().split(' ')[0];
          lineInfo += ' / $dateStr';
        }
        reelLineItem = _InfoItem(strings.line, lineInfo);
      }
    } else if (type == 'lure') {
      if (e['lure_type'] != null) {
        items.add(_InfoItem(strings.lureType, e['lure_type']));
      }
      if (e['lure_weight'] != null) {
        final weightValue = double.tryParse(e['lure_weight'].toString()) ?? 0;
        final weightUnit = e['lure_weight_unit'] ?? 'g';
        final displayWeight = UnitConverter.convertWeight(
          weightValue,
          weightUnit,
          displayUnits.lureWeightUnit,
        );
        items.add(
          _InfoItem(
            strings.lureWeight,
            '${displayWeight.toStringAsFixed(1)} ${UnitConverter.getWeightSymbol(displayUnits.lureWeightUnit)}',
          ),
        );
      }
      if (e['lure_size'] != null) {
        final sizeValue = double.tryParse(e['lure_size'].toString()) ?? 0;
        final sizeUnit = e['lure_size_unit'] ?? 'cm';
        final displaySize = UnitConverter.convertLength(
          sizeValue,
          sizeUnit,
          displayUnits.lureLengthUnit,
        );
        items.add(
          _InfoItem(
            strings.lureSize,
            '${displaySize.toStringAsFixed(1)} ${UnitConverter.getLengthSymbol(displayUnits.lureLengthUnit)}',
          ),
        );
      }
      if (e['lure_color'] != null) {
        items.add(_InfoItem(strings.lureColor, e['lure_color']));
      }
      if (e['lure_action'] != null) {
        items.add(_InfoItem('动作', e['lure_action']));
      }
    } else if (type == 'line') {
      if (e['line_type'] != null) {
        items.add(_InfoItem(strings.lineType, e['line_type']));
      }
      if (e['line_length'] != null) {
        items.add(_InfoItem(strings.lineLength, e['line_length']));
      }
      if (e['line_strength'] != null) {
        items.add(_InfoItem('强度', e['line_strength']));
      }
      if (e['line_color'] != null) {
        items.add(_InfoItem('颜色', e['line_color']));
      }
    }

    if (items.isEmpty && reelLineItem == null) return [];

    final row = Wrap(
      spacing: AppTheme.spacingMd,
      runSpacing: AppTheme.spacingSm,
      children: items.map((item) => _buildInfoItem(context, item)).toList(),
    );

    // 添加数量显示（仅针对 lure）
    if (type == 'lure' && e['lure_quantity'] != null) {
      final quantity = e['lure_quantity'] as int;
      final unit = e['lure_quantity_unit'] as String? ?? '条';
      return [
        row,
        const SizedBox(height: AppTheme.spacingSm),
        _buildQuantityBadge(context, quantity, unit),
      ];
    }

    // 渔轮鱼线信息单独一行展示
    if (type == 'reel' && reelLineItem != null) {
      return [
        row,
        const SizedBox(height: AppTheme.spacingSm),
        _buildInfoItemFullWidth(context, reelLineItem),
      ];
    }

    return [row];
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

  Widget _buildQuantityBadge(BuildContext context, int quantity, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentLight.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppColors.accentLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inventory_2_rounded,
            size: 18,
            color: AppColors.accentLight,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            '数量: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.accentLight,
                ),
          ),
          Text(
            '$quantity$unit',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentLight,
                ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String type, String category) {
    // 简化版本：直接返回分类名称
    final categoryMap = {
      // 鱼竿类型
      'spinning': '纺车竿',
      'baitcasting': '水滴竿',
      'fly': '飞蝇竿',
      'trolling': '拖钓竿',
      // 渔轮类型
      'spinning_reel': '纺车轮',
      'baitcasting_reel': '水滴轮',
      'fly_reel': '飞蝇轮',
      'trolling_reel': '拖钓轮',
      // 假饵类型
      'hard_bait': '硬饵',
      'soft_bait': '软饵',
      'spinner': '亮片',
      'spoon': '汤匙',
      'jig': '铅头钩',
      // 鱼线类型
      'monofilament': '尼龙线',
      'braided': 'PE线',
      'fluorocarbon': '碳线',
    };
    return categoryMap[category] ?? category;
  }

  _EquipmentTypeInfo _getEquipmentTypeInfo(String type) {
    final strings = ref.read(currentStringsProvider);
    switch (type) {
      case 'rod':
        return _EquipmentTypeInfo(
          icon: Icons.straighten_rounded,
          color: AppColors.chartColors[0],
          label: strings.rod,
        );
      case 'reel':
        return _EquipmentTypeInfo(
          icon: Icons.settings_rounded,
          color: AppColors.chartColors[1],
          label: strings.reel,
        );
      case 'lure':
        return _EquipmentTypeInfo(
          icon: Icons.phishing_rounded,
          color: AppColors.chartColors[2],
          label: strings.lure,
        );
      case 'line':
        return _EquipmentTypeInfo(
          icon: Icons.timeline_rounded,
          color: AppColors.chartColors[3],
          label: strings.line,
        );
      default:
        return _EquipmentTypeInfo(
          icon: Icons.hardware_rounded,
          color: AppColors.secondaryLight,
          label: type,
        );
    }
  }
}

class _InfoItem {
  final String label;
  final String value;

  _InfoItem(this.label, this.value);
}

class _EquipmentTypeInfo {
  final IconData icon;
  final Color color;
  final String label;

  _EquipmentTypeInfo({
    required this.icon,
    required this.color,
    required this.label,
  });
}
