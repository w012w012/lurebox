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
                          subtitleBuilder: (item) =>
                              '${item['length'] ?? ''} ${item['is_default'] == 1 ? '⭐${strings.defaultLabel}' : ''}',
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
                          color: AppColors.keep,
                          itemBuilder: (item) =>
                              '${item['brand'] ?? ''} ${item['model'] ?? ''}',
                          subtitleBuilder: (item) =>
                              '${item['reel_ratio'] ?? ''} ${item['is_default'] == 1 ? '⭐${strings.defaultLabel}' : ''}',
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
                              '${item['lure_type'] ?? ''} ${item['lure_weight'] ?? ''}',
                          subtitleBuilder: (item) =>
                              '${item['brand'] ?? ''} ${item['is_default'] == 1 ? '⭐${strings.defaultLabel}' : ''}',
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
            color: isSelected ? color.withOpacity(0.15) : null,
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

/// 装备信息行组件
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

    String detail = '';
    if (label.contains(strings.rod) || label.contains('Rod')) {
      detail = '${equipment!['length'] ?? ''} ${equipment!['hardness'] ?? ''}';
    } else if (label.contains(strings.reel) || label.contains('Reel')) {
      detail =
          '${equipment!['reel_ratio'] ?? ''} ${equipment!['reel_line'] ?? ''}';
    } else if (label.contains(strings.lure) || label.contains('Lure')) {
      detail = '${equipment!['lure_weight'] ?? ''}';
    }

    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${equipment!['brand'] ?? ''} ${equipment!['model'] ?? ''} ${detail.isNotEmpty ? '($detail)' : ''}',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
