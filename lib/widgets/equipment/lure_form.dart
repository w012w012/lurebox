import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_settings_provider.dart';
import '../../../core/providers/language_provider.dart';
import '../common/premium_input.dart';
import '../common/unit_dropdown.dart';

class LureForm extends ConsumerWidget {
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

  const LureForm({
    super.key,
    required this.weightController,
    required this.weightUnit,
    required this.onWeightUnitChanged,
    required this.sizeController,
    required this.sizeUnit,
    required this.onSizeUnitChanged,
    required this.colorController,
    required this.quantityController,
    required this.quantityUnit,
    required this.onQuantityUnitChanged,
  });

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
                options: ['g', 'oz'],
                label: '单位',
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
                options: ['cm', 'mm', 'inch'],
                label: '单位',
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
                items: const [
                  PremiumDropdownItem(value: '条', label: '条'),
                  PremiumDropdownItem(value: '只', label: '只'),
                  PremiumDropdownItem(value: '个', label: '个'),
                  PremiumDropdownItem(value: '包', label: '包'),
                  PremiumDropdownItem(value: '盒', label: '盒'),
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
