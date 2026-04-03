import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings.dart';
import '../../core/models/equipment.dart';
import '../../core/camera/camera_state.dart';
import '../../core/camera/camera_view_model.dart';
import '../../widgets/common/premium_button.dart';

/// Equipment selection sheet - modal bottom sheet for selecting rod, reel, lure.
class EquipmentSelectionSheet extends StatelessWidget {
  final CameraState state;
  final CameraViewModel vm;
  final AppStrings strings;

  const EquipmentSelectionSheet({
    super.key,
    required this.state,
    required this.vm,
    required this.strings,
  });

  /// Show the equipment selection bottom sheet.
  static Future<void> show(
    BuildContext context,
    CameraState state,
    CameraViewModel vm,
    AppStrings strings,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => EquipmentSelectionSheet(
        state: state,
        vm: vm,
        strings: strings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _EquipmentSelectionContent(
      state: state,
      vm: vm,
      strings: strings,
    );
  }
}

class _EquipmentSelectionContent extends StatefulWidget {
  final CameraState state;
  final CameraViewModel vm;
  final AppStrings strings;

  const _EquipmentSelectionContent({
    required this.state,
    required this.vm,
    required this.strings,
  });

  @override
  State<_EquipmentSelectionContent> createState() =>
      _EquipmentSelectionContentState();
}

class _EquipmentSelectionContentState
    extends State<_EquipmentSelectionContent> {
  late Equipment? _tempSelectedRod;
  late Equipment? _tempSelectedReel;
  late Equipment? _tempSelectedLure;

  @override
  void initState() {
    super.initState();
    _tempSelectedRod = widget.state.selectedRod;
    _tempSelectedReel = widget.state.selectedReel;
    _tempSelectedLure = widget.state.selectedLure;
  }

  @override
  Widget build(BuildContext context) {
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
                widget.strings.selectEquipment,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              PremiumButton(
                text: widget.strings.addEquipment,
                icon: Icons.add,
                onPressed: () {
                  context
                      .push('/equipment')
                      .then((_) => widget.vm.loadEquipments());
                },
                variant: PremiumButtonVariant.text,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEquipmentSection(
            context: context,
            title: '🎣 ${widget.strings.rod}',
            items: widget.state.rods,
            selected: _tempSelectedRod,
            onSelected: (equipment) {
              setState(() => _tempSelectedRod = equipment);
              widget.vm.setSelectedRod(equipment);
            },
          ),
          _buildEquipmentSection(
            context: context,
            title: '⚙️ ${widget.strings.reel}',
            items: widget.state.reels,
            selected: _tempSelectedReel,
            onSelected: (equipment) {
              setState(() => _tempSelectedReel = equipment);
              widget.vm.setSelectedReel(equipment);
            },
          ),
          _buildEquipmentSection(
            context: context,
            title: '🪝 ${widget.strings.lure}',
            items: widget.state.lures,
            selected: _tempSelectedLure,
            onSelected: (equipment) {
              setState(() => _tempSelectedLure = equipment);
              widget.vm.setSelectedLure(equipment);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentSection({
    required BuildContext context,
    required String title,
    required List<Equipment> items,
    required Equipment? selected,
    required ValueChanged<Equipment?> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const Text('暂无装备')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((equipment) {
              final isSelected = selected?.id == equipment.id;
              return FilterChip(
                label: Text(equipment.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  onSelected(selected ? equipment : null);
                },
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
              );
            }).toList(),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
