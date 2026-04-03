import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../../core/models/equipment.dart';
import '../../core/camera/camera_state.dart';
import '../../core/camera/camera_view_model.dart';
import '../rig/rig_config_card.dart';
import '../common/premium_button.dart';

/// 装备与钓组组合卡片
///
/// 统一展示装备信息（鱼竿、鱼轮、鱼饵）和钓组配置
/// 包含可展开的 RigConfigCard
class EquipmentRigCard extends StatelessWidget {
  final CameraState state;
  final CameraViewModel vm;
  final AppStrings strings;
  final VoidCallback onModifyPressed;

  const EquipmentRigCard({
    super.key,
    required this.state,
    required this.vm,
    required this.strings,
    required this.onModifyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: state.selectedLure?.lureType == '软虫',
          onExpansionChanged: (expanded) {},
          leading: Icon(
            Icons.hardware,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            strings.useEquipment,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PremiumButton(
                text: strings.modify,
                onPressed: onModifyPressed,
                variant: PremiumButtonVariant.text,
              ),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Equipment rows with emoji icons
                  _EquipmentInfoRow(
                    label: '🎣 ${strings.rod}',
                    equipment: state.selectedRod,
                  ),
                  const SizedBox(height: 8),
                  _EquipmentInfoRow(
                    label: '⚙️ ${strings.reel}',
                    equipment: state.selectedReel,
                  ),
                  const SizedBox(height: 8),
                  _EquipmentInfoRow(
                    label: '🪝 ${strings.lure}',
                    equipment: state.selectedLure,
                  ),
                  const SizedBox(height: 16),
                  // Embedded RigConfigCard
                  RigConfigCard(
                    config: state.rigConfig,
                    onChanged: (config) => vm.setRigConfig(config),
                    initiallyExpanded: state.selectedLure?.lureType == '软虫',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 装备信息行组件
class _EquipmentInfoRow extends StatelessWidget {
  final String label;
  final Equipment? equipment;

  const _EquipmentInfoRow({
    required this.label,
    this.equipment,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const Spacer(),
        Text(
          equipment?.displayName ?? '-',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
