import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/providers/language_provider.dart';
import '../equipment/equipment_list_page.dart';

/// 装备选择器组件
class EquipmentSelector extends ConsumerWidget {
  final List<Map<String, dynamic>> rodList;
  final List<Map<String, dynamic>> reelList;
  final List<Map<String, dynamic>> lureList;
  final Map<String, dynamic>? selectedRod;
  final Map<String, dynamic>? selectedReel;
  final Map<String, dynamic>? selectedLure;
  final ValueChanged<Map<String, dynamic>?> onRodSelected;
  final ValueChanged<Map<String, dynamic>?> onReelSelected;
  final ValueChanged<Map<String, dynamic>?> onLureSelected;
  final VoidCallback onManageEquipment;

  const EquipmentSelector({
    super.key,
    required this.rodList,
    required this.reelList,
    required this.lureList,
    required this.selectedRod,
    required this.selectedReel,
    required this.selectedLure,
    required this.onRodSelected,
    required this.onReelSelected,
    required this.onLureSelected,
    required this.onManageEquipment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);

    return IconButton(
      onPressed: () => _showSelector(context, strings),
      icon: const Icon(Icons.hardware, size: 32),
      color: Theme.of(context).colorScheme.primary,
    );
  }

  void _showSelector(BuildContext context, AppStrings strings) {
    Map<String, dynamic>? tempSelectedRod = selectedRod;
    Map<String, dynamic>? tempSelectedReel = selectedReel;
    Map<String, dynamic>? tempSelectedLure = selectedLure;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        strings.selectEquipment,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EquipmentListPage(),
                            ),
                          ).then((result) {
                            if (result == true) {
                              onManageEquipment();
                            }
                          });
                        },
                        icon: const Icon(Icons.settings),
                        label: Text(strings.manageEquipment),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        _buildEquipmentSection(
                          context,
                          title: '🎣 ${strings.rod}',
                          items: rodList,
                          selectedItem: tempSelectedRod,
                          onItemSelected: (item) {
                            setModalState(() {
                              tempSelectedRod = item;
                            });
                          },
                          color: Theme.of(context).colorScheme.primary,
                          itemBuilder: (item) =>
                              '${item['brand'] ?? ''} ${item['model'] ?? ''}',
                          subtitleBuilder: (item) {
                            // 显示：长度 / 硬度 / 调性
                            final parts = <String>[];
                            final length = item['length'] as String?;
                            final lengthUnit =
                                item['length_unit'] as String? ?? 'm';
                            if (length != null && length.isNotEmpty) {
                              final lengthValue =
                                  double.tryParse(length) ?? 0.0;
                              parts.add(
                                  '${lengthValue.toStringAsFixed(2)}$lengthUnit');
                            }
                            final hardness = item['hardness'] as String?;
                            if (hardness != null && hardness.isNotEmpty) {
                              parts.add(hardness);
                            }
                            final action = item['rod_action'] as String?;
                            if (action != null && action.isNotEmpty) {
                              parts.add(action);
                            }
                            final jointType = item['joint_type'] as String?;
                            if (jointType != null && jointType.isNotEmpty) {
                              parts.add(jointType);
                            }
                            final defaultLabel = item['is_default'] == 1
                                ? '⭐${strings.defaultLabel}'
                                : '';
                            return parts.isNotEmpty
                                ? '${parts.join(' / ')}$defaultLabel'
                                : defaultLabel;
                          },
                          strings: strings,
                        ),
                        const SizedBox(height: 16),
                        _buildEquipmentSection(
                          context,
                          title: '⚙️ ${strings.reel}',
                          items: reelList,
                          selectedItem: tempSelectedReel,
                          onItemSelected: (item) {
                            setModalState(() {
                              tempSelectedReel = item;
                            });
                          },
                          color: TeslaColors.electricBlue,
                          itemBuilder: (item) =>
                              '${item['brand'] ?? ''} ${item['model'] ?? ''}',
                          subtitleBuilder: (item) {
                            // 显示：齿轮比 / 轴承数 / 刹车类型
                            final parts = <String>[];
                            final ratio = item['reel_ratio'] as String?;
                            if (ratio != null && ratio.isNotEmpty) {
                              parts.add(ratio);
                            }
                            final bearings = item['reel_bearings'] as String?;
                            if (bearings != null && bearings.isNotEmpty) {
                              parts.add(bearings);
                            }
                            final brakeType =
                                item['reel_brake_type'] as String?;
                            if (brakeType != null && brakeType.isNotEmpty) {
                              parts.add(brakeType);
                            }
                            final weight = item['reel_weight'] as String?;
                            if (weight != null && weight.isNotEmpty) {
                              parts.add(weight);
                            }
                            final defaultLabel = item['is_default'] == 1
                                ? '⭐${strings.defaultLabel}'
                                : '';
                            return parts.isNotEmpty
                                ? '${parts.join(' / ')}$defaultLabel'
                                : defaultLabel;
                          },
                          strings: strings,
                        ),
                        const SizedBox(height: 16),
                        _buildEquipmentSection(
                          context,
                          title: '🪝 ${strings.lure}',
                          items: lureList,
                          selectedItem: tempSelectedLure,
                          onItemSelected: (item) {
                            setModalState(() {
                              tempSelectedLure = item;
                            });
                          },
                          color: Colors.purple,
                          itemBuilder: (item) =>
                              '${item['brand'] ?? ''} ${item['model'] ?? ''}',
                          subtitleBuilder: (item) {
                            // 显示：类型 / 尺寸 / 重量 / 颜色
                            final parts = <String>[];
                            final lureType = item['lure_type'] as String?;
                            if (lureType != null && lureType.isNotEmpty) {
                              parts.add(lureType);
                            }
                            final size = item['lure_size'] as String?;
                            final sizeUnit =
                                item['lure_size_unit'] as String? ?? 'cm';
                            if (size != null && size.isNotEmpty) {
                              parts.add('$size$sizeUnit');
                            }
                            final weight = item['lure_weight'] as String?;
                            final weightUnit =
                                item['lure_weight_unit'] as String? ?? 'g';
                            if (weight != null && weight.isNotEmpty) {
                              parts.add('$weight$weightUnit');
                            }
                            final color = item['lure_color'] as String?;
                            if (color != null && color.isNotEmpty) {
                              parts.add(color);
                            }
                            final defaultLabel = item['is_default'] == 1
                                ? '⭐${strings.defaultLabel}'
                                : '';
                            return parts.isNotEmpty
                                ? '${parts.join(' / ')}$defaultLabel'
                                : defaultLabel;
                          },
                          strings: strings,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        onRodSelected(tempSelectedRod);
                        onReelSelected(tempSelectedReel);
                        onLureSelected(tempSelectedLure);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        strings.confirm,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEquipmentSection(
    BuildContext context, {
    required String title,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic>? selectedItem,
    required ValueChanged<Map<String, dynamic>?> onItemSelected,
    required Color color,
    required String Function(Map<String, dynamic>) itemBuilder,
    required String Function(Map<String, dynamic>) subtitleBuilder,
    required AppStrings strings,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '${strings.noEquipmentYet}${title.substring(2)}${strings.noEquipmentAddHint}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ...items.map((item) {
          final isSelected =
              selectedItem != null && selectedItem['id'] == item['id'];
          return Card(
            color: isSelected ? color.withValues(alpha: 0.15) : null,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: isSelected
                  ? Icon(Icons.check_circle, color: color)
                  : Icon(
                      Icons.radio_button_unchecked,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              title: Text(itemBuilder(item)),
              subtitle: Text(subtitleBuilder(item)),
              onTap: () {
                onItemSelected(isSelected ? null : item);
              },
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// 装备信息行组件 - 显示完整装备参数
class EquipmentInfoRow extends ConsumerWidget {
  final String label;
  final Map<String, dynamic>? equipment;

  const EquipmentInfoRow({super.key, required this.label, this.equipment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);

    if (equipment == null) {
      return Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(
            strings.notSelected,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    // 构建完整的装备信息字符串
    final info = _buildEquipmentInfo(equipment!, label, strings);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            info,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  /// 构建装备信息字符串，格式与水印一致
  String _buildEquipmentInfo(
      Map<String, dynamic> eq, String label, AppStrings strings) {
    final parts = <String>[];

    // 品牌和型号
    final brand = eq['brand'] as String?;
    final model = eq['model'] as String?;
    if (brand != null && brand.isNotEmpty) parts.add(brand);
    if (model != null && model.isNotEmpty) parts.add(model);

    if (label.contains(strings.rod) || label.contains('Rod')) {
      // 鱼竿：长度、硬度、调性、材质、节数、插接方式、适用饵重
      final length = eq['length'] as String?;
      final lengthUnit = eq['length_unit'] as String? ?? 'm';
      if (length != null && length.isNotEmpty) {
        final lengthValue = double.tryParse(length) ?? 0.0;
        parts.add('${lengthValue.toStringAsFixed(2)} $lengthUnit');
      }

      final hardness = eq['hardness'] as String?;
      if (hardness != null && hardness.isNotEmpty) parts.add(hardness);

      final action = eq['rod_action'] as String?;
      if (action != null && action.isNotEmpty) parts.add(action);

      final material = eq['material'] as String?;
      if (material != null && material.isNotEmpty) parts.add(material);

      final sections = eq['sections'] as String?;
      if (sections != null && sections.isNotEmpty) {
        parts.add('${strings.sections}:$sections');
      }

      final jointType = eq['joint_type'] as String?;
      if (jointType != null && jointType.isNotEmpty) parts.add(jointType);

      final weightRange = eq['weight_range'] as String?;
      if (weightRange != null && weightRange.isNotEmpty) {
        parts.add('${strings.weightRange}:$weightRange');
      }
    } else if (label.contains(strings.reel) || label.contains('Reel')) {
      // 渔轮：齿轮比、轴承数、线杯容量、刹车类型、重量
      final ratio = eq['reel_ratio'] as String?;
      if (ratio != null && ratio.isNotEmpty) parts.add(ratio);

      final bearings = eq['reel_bearings'] as String?;
      if (bearings != null && bearings.isNotEmpty) {
        parts.add('${strings.bearings}:$bearings');
      }

      final capacity = eq['reel_capacity'] as String?;
      if (capacity != null && capacity.isNotEmpty) {
        parts.add('${strings.reelCapacity}:$capacity');
      }

      final brakeType = eq['reel_brake_type'] as String?;
      if (brakeType != null && brakeType.isNotEmpty) parts.add(brakeType);

      final weight = eq['reel_weight'] as String?;
      if (weight != null && weight.isNotEmpty) parts.add(weight);
    } else if (label.contains(strings.lure) || label.contains('Lure')) {
      // 鱼饵：类型、尺寸、重量、颜色、数量
      final lureType = eq['lure_type'] as String?;
      if (lureType != null && lureType.isNotEmpty) parts.add(lureType);

      final size = eq['lure_size'] as String?;
      final sizeUnit = eq['lure_size_unit'] as String? ?? 'cm';
      if (size != null && size.isNotEmpty) {
        parts.add('$size $sizeUnit');
      }

      final weight = eq['lure_weight'] as String?;
      final weightUnit = eq['lure_weight_unit'] as String? ?? 'g';
      if (weight != null && weight.isNotEmpty) {
        parts.add('$weight $weightUnit');
      }

      final color = eq['lure_color'] as String?;
      if (color != null && color.isNotEmpty) parts.add(color);

      final quantity = eq['lure_quantity'] as String?;
      if (quantity != null && quantity.isNotEmpty) {
        parts.add('x$quantity');
      }
    }

    return parts.join(' / ');
  }
}
