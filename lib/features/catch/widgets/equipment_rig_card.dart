import 'package:flutter/material.dart';
import 'package:lurebox/core/camera/camera_state.dart';
import 'package:lurebox/core/camera/camera_view_model.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/utils/unit_converter.dart';
import 'package:lurebox/widgets/common/premium_button.dart';

/// 装备卡片
///
/// 展示装备信息（鱼竿、鱼轮、鱼饵）
class EquipmentRigCard extends StatelessWidget {

  const EquipmentRigCard({
    required this.state, required this.vm, required this.strings, required this.onModifyPressed, super.key,
    this.isChinese = true,
  });
  final CameraState state;
  final CameraViewModel vm;
  final AppStrings strings;
  final VoidCallback onModifyPressed;
  final bool isChinese;

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
          initiallyExpanded: true,
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
                  _EquipmentRow(
                    label: strings.rod,
                    value: _buildRodDisplay(state.selectedRod),
                  ),
                  const SizedBox(height: 8),
                  _EquipmentRow(
                    label: strings.reel,
                    value: _buildReelDisplay(state.selectedReel),
                  ),
                  const SizedBox(height: 8),
                  _EquipmentRow(
                    label: strings.lure,
                    value: _buildLureDisplay(state.selectedLure),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildRodDisplay(Equipment? rod) {
    if (rod == null) return '-';
    final parts = <String>[];
    if (rod.brand?.isNotEmpty ?? false) parts.add(rod.brand!);
    if (rod.model?.isNotEmpty ?? false) parts.add(rod.model!);
    // 握柄类型
    if (rod.category != null && rod.category!.contains('|')) {
      parts.add(rod.category!.split('|')[0]);
    }
    if (rod.length?.isNotEmpty ?? false) {
      parts.add(
          '${rod.length}${UnitConverter.getLengthSymbol(rod.lengthUnit, isChinese: isChinese)}',);
    }
    if (rod.hardness?.isNotEmpty ?? false) parts.add(rod.hardness!);
    if (rod.rodAction?.isNotEmpty ?? false) parts.add(rod.rodAction!);
    return parts.isEmpty ? '-' : parts.join(' / ');
  }

  String _buildReelDisplay(Equipment? reel) {
    if (reel == null) return '-';
    final parts = <String>[];
    if (reel.brand?.isNotEmpty ?? false) parts.add(reel.brand!);
    if (reel.model?.isNotEmpty ?? false) parts.add(reel.model!);
    if (reel.reelRatio?.isNotEmpty ?? false) parts.add(reel.reelRatio!);
    return parts.isEmpty ? '-' : parts.join(' / ');
  }

  String _buildLureDisplay(Equipment? lure) {
    if (lure == null) return '-';
    final parts = <String>[];
    if (lure.brand?.isNotEmpty ?? false) parts.add(lure.brand!);
    if (lure.model?.isNotEmpty ?? false) parts.add(lure.model!);
    if (lure.lureSize?.isNotEmpty ?? false) {
      parts.add(
          '${lure.lureSize}${UnitConverter.getLengthSymbol(lure.lureSizeUnit, isChinese: isChinese)}',);
    }
    if (lure.lureColor?.isNotEmpty ?? false) parts.add(lure.lureColor!);
    return parts.isEmpty ? '-' : parts.join(' / ');
  }
}

/// 装备信息行
class _EquipmentRow extends StatelessWidget {

  const _EquipmentRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
