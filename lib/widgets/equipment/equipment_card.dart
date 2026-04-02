import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/theme/app_colors.dart';
import '../../../core/providers/language_provider.dart';

class EquipmentCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> equipment;
  final Map<String, int> stats;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const EquipmentCard({
    super.key,
    required this.equipment,
    required this.stats,
    required this.isExpanded,
    required this.onTap,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  ConsumerState<EquipmentCard> createState() => _EquipmentCardState();
}

class _EquipmentCardState extends ConsumerState<EquipmentCard> {
  bool _expanded = true;

  @override
  void didUpdateWidget(EquipmentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      _expanded = widget.isExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 使用select只监听需要的部分，避免不必要的重建
    final strings = ref.watch(
      currentStringsProvider.select((s) => s),
    );
    final isDefault = widget.equipment['is_default'] == 1;
    final type = widget.equipment['type'] as String;
    final brand = widget.equipment['brand'] as String? ?? '';
    final model = widget.equipment['model'] as String? ?? '';
    final total = widget.stats['_total'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Stack(
          children: [
            if (isDefault)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.amber,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        strings.defaultLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                isDefault ? 32 : 16,
                16,
                _expanded ? 16 : 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          brand.isNotEmpty || model.isNotEmpty
                              ? '$brand $model'.trim()
                              : strings.unnamed,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (type == 'lure' &&
                          widget.equipment['lure_quantity'] != null &&
                          widget.equipment['lure_quantity'] > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.blueLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${widget.equipment['lure_quantity']}${widget.equipment['lure_quantity_unit'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(width: 4),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'default') widget.onSetDefault();
                          if (v == 'delete') widget.onDelete();
                          if (v == 'edit') widget.onTap();
                        },
                        itemBuilder: (c) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(strings.edit),
                          ),
                          if (!isDefault)
                            PopupMenuItem(
                              value: 'default',
                              child: Text(strings.setDefault),
                            ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              strings.delete,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                        icon: const Icon(Icons.more_vert, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  if (widget.equipment['category'] != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getCategoryName(type, widget.equipment['category']),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.teal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  if (_expanded) ...[
                    const SizedBox(height: 10),
                    ..._buildInfoRows(type, widget.equipment),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    // 战绩统计（总记录数）
                    Row(
                      children: [
                        Icon(
                          Icons.sports,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${strings.record}: $total${strings.fishCountUnit}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    // 具体鱼种统计
                    if (widget.stats.entries
                        .where((e) => e.key != '_total')
                        .isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildStatsRow(widget.stats),
                    ],
                    if (widget.equipment['purchase_date'] != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.equipment['purchase_date'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(Map<String, int> stats) {
    final strings = ref.watch(currentStringsProvider);
    final entries = stats.entries.where((e) => e.key != '_total').toList();
    if (entries.isEmpty) return const SizedBox();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: entries.map((e) {
        // e.key is the species name, e.value is the count
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.blueLight,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${e.key}: ${e.value}${strings.fishCountUnit}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildInfoRows(String type, Map<String, dynamic> e) {
    final strings = ref.watch(currentStringsProvider);
    final items = <_InfoItem>[];
    if (type == 'rod') {
      if (e['length'] != null) {
        final lengthValue = double.tryParse(e['length'].toString()) ?? 0;
        final lengthUnit = e['length_unit'] ?? 'm';
        items.add(
          _InfoItem(
            strings.rodLength,
            '${lengthValue.toStringAsFixed(2)} $lengthUnit',
          ),
        );
      }
      if (e['sections'] != null) {
        items.add(_InfoItem(strings.sections, '${e['sections']}'));
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
        items.add(_InfoItem(strings.weightRange, e['weight_range']));
      }
    } else if (type == 'reel') {
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
        final lineParts = <String>[];
        if (e['reel_line'] != null) {
          lineParts.add(e['reel_line']);
        }
        if (e['reel_line_number'] != null) {
          lineParts.add(e['reel_line_number']);
        }
        if (e['reel_line_length'] != null) {
          lineParts.add(e['reel_line_length']);
        }
        items.add(_InfoItem(strings.line, lineParts.join(' · ')));
      }
      if (e['reel_line_date'] != null) {
        items.add(
          _InfoItem(strings.lineDate, _formatDate(e['reel_line_date'])),
        );
      }
    } else if (type == 'lure') {
      if (e['lure_quantity'] != null && e['lure_quantity'] > 0) {
        final qtyUnit = e['lure_quantity_unit'] as String? ?? '';
        items.add(_InfoItem(strings.quantity, '${e['lure_quantity']}$qtyUnit'));
      }
      if (e['lure_type'] != null) {
        items.add(_InfoItem(strings.lureType, e['lure_type']));
      }
      if (e['lure_weight'] != null) {
        String weightStr = e['lure_weight'].toString();
        if (!weightStr.endsWith('g')) {
          weightStr = '${weightStr}g';
        }
        items.add(_InfoItem(strings.lureWeight, weightStr));
      }
      if (e['lure_size'] != null) {
        String sizeStr = e['lure_size'].toString();
        if (!sizeStr.endsWith('cm')) {
          sizeStr = '${sizeStr}cm';
        }
        items.add(_InfoItem(strings.lureSize, sizeStr));
      }
      if (e['lure_color'] != null) {
        items.add(_InfoItem(strings.lureColor, e['lure_color']));
      }
    }
    return _buildInfoGrid(items);
  }

  List<Widget> _buildInfoGrid(List<_InfoItem> items) {
    if (items.isEmpty) return [];
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final item1 = items[i];
      final item2 = i + 1 < items.length ? items[i + 1] : null;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Expanded(child: _buildInfoItem(item1)),
              const SizedBox(width: 12),
              Expanded(
                child: item2 != null ? _buildInfoItem(item2) : const SizedBox(),
              ),
            ],
          ),
        ),
      );
    }
    return rows;
  }

  Widget _buildInfoItem(_InfoItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            item.label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            item.value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  String _getCategoryName(String type, String? category) {
    if (category == null || category.isEmpty) return '';
    if (category.contains('|')) {
      final parts = category.split('|');
      return parts.where((p) => p.isNotEmpty).join(' · ');
    }
    if (type == 'rod') return RodCategory.getName(category);
    if (type == 'reel') return ReelCategory.getName(category);
    return category;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}

class _InfoItem {
  final String label;
  final String value;
  _InfoItem(this.label, this.value);
}

class EquipmentCategory {
  static const rodNames = {
    '枪柄': 'Casting',
    '直柄': 'Spinning',
    '微物马口竿': 'Micro Trout Rod',
    '泛用综合竿': 'Versatile Rod',
    '远投翘嘴竿': 'Long Cast Pike Rod',
    '虫竿/鳜鱼竿': 'Soft bait/Crawler Rod',
    '鲈钓竿': 'Bass Rod',
    '雷强打黑竿': 'Heavy Pike Rod',
  };

  static const reelNames = {
    '水滴轮': 'Baitcasting Reel',
    '纺车轮': 'Spinning Reel',
    '远投': 'Long Cast',
    '泛用': 'Versatile',
    '微物': 'Micro',
    '雷强': 'Heavy',
    '铁板/慢摇': 'Iron Plate/Jigging',
  };

  static String getName(String type, String key) {
    final names = type == 'rod' ? rodNames : reelNames;
    return names[key] ?? key;
  }
}

class RodCategory {
  static String getName(String key) => EquipmentCategory.getName('rod', key);
}

class ReelCategory {
  static String getName(String key) => EquipmentCategory.getName('reel', key);
}
