import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/widgets/common/premium_input.dart';
import 'package:lurebox/widgets/common/unit_dropdown.dart';

class LureForm extends ConsumerWidget {

  const LureForm({
    required this.weightController, required this.weightUnit, required this.onWeightUnitChanged, required this.sizeController, required this.sizeUnit, required this.onSizeUnitChanged, required this.colorController, required this.quantityController, required this.quantityUnit, required this.onQuantityUnitChanged, super.key,
  });
  final TextEditingController weightController;
  final String weightUnit;
  final ValueChanged<String> onWeightUnitChanged;
  final TextEditingController sizeController;
  final String sizeUnit;
  final ValueChanged<String> onSizeUnitChanged;
  final TextEditingController colorController;
  final TextEditingController quantityController;
  final String? quantityUnit;
  final ValueChanged<String?> onQuantityUnitChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);
    final appSettings = ref.watch(appSettingsProvider);
    final units = appSettings.units;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 重量行
        Row(
          children: [
            Expanded(
              flex: 3,
              child: PremiumTextField(
                controller: weightController,
                label: strings.weight,
                hint: strings.lureWeightHint,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: UnitDropdown(
                value: weightUnit,
                options: const ['g', 'oz'],
                label: strings.unit,
                onUnitChanged: onWeightUnitChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // 尺寸行
        Row(
          children: [
            Expanded(
              flex: 3,
              child: PremiumTextField(
                controller: sizeController,
                label: strings.size,
                hint: strings.lureSizeHint,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: UnitDropdown(
                value: sizeUnit,
                options: const ['cm', 'mm', 'inch'],
                label: strings.unit,
                onUnitChanged: onSizeUnitChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        PremiumTextField(
          controller: colorController,
          label: strings.lureColor,
          hint: strings.lureColorHint,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: PremiumTextField(
                controller: quantityController,
                label: strings.quantity,
                hint: '1',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PremiumDropdown<String>(
                value: quantityUnit ?? units.lureQuantityUnit,
                items: [
                  PremiumDropdownItem(value: 'piece', label: strings.quantityUnitPiece),
                  PremiumDropdownItem(value: 'item', label: strings.quantityUnitItem),
                  PremiumDropdownItem(value: 'pack', label: strings.quantityUnitPack),
                  PremiumDropdownItem(value: 'box', label: strings.quantityUnitBox),
                  PremiumDropdownItem(value: 'carton', label: strings.quantityUnitCarton),
                ],
                onChanged: onQuantityUnitChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
