import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../widgets/common/premium_input.dart';
import '../../../widgets/common/unit_dropdown.dart';

class ReelForm extends ConsumerWidget {
  final TextEditingController bearingsController;
  final TextEditingController ratioAController;
  final TextEditingController ratioBController;
  final TextEditingController capacityNumberController;
  final TextEditingController capacityLengthController;
  final TextEditingController weightController;
  final String weightUnit;
  final ValueChanged<String> onWeightUnitChanged;
  final String brakeType;
  final ValueChanged<String> onBrakeTypeChanged;

  const ReelForm({
    super.key,
    required this.bearingsController,
    required this.ratioAController,
    required this.ratioBController,
    required this.capacityNumberController,
    required this.capacityLengthController,
    required this.weightController,
    required this.weightUnit,
    required this.onWeightUnitChanged,
    required this.brakeType,
    required this.onBrakeTypeChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);
    final displayUnits = ref.watch(appSettingsProvider).units;
    final lineLengthSymbol =
        UnitConverter.getLengthSymbol(displayUnits.lineLengthUnit);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumTextField(
          controller: bearingsController,
          keyboardType: TextInputType.number,
          label: strings.bearings,
          hint: strings.bearingsHint,
        ),
        const SizedBox(height: 10),
        // 速比：a:b模板
        Row(
          children: [
            Expanded(
              child: PremiumTextField(
                controller: ratioAController,
                label: strings.ratio,
                hint: strings.ratioFront,
                keyboardType: TextInputType.number,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(':', style: TextStyle(fontSize: 18)),
            ),
            Expanded(
              child: PremiumTextField(
                controller: ratioBController,
                label: '',
                hint: strings.ratioBack,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // 线杯容量：a号/b米模板
        Row(
          children: [
            Expanded(
              child: PremiumTextField(
                controller: capacityNumberController,
                label: strings.reelCapacity,
                hint: strings.lineLabel,
                keyboardType: TextInputType.number,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(strings.capacityLineUnit, style: const TextStyle(fontSize: 14)),
            ),
            Expanded(
              child: PremiumTextField(
                controller: capacityLengthController,
                label: '',
                hint: strings.lineCapacity,
                keyboardType: TextInputType.number,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child:
                  Text(lineLengthSymbol, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // 刹车类型：预选词
        PremiumDropdown<String>(
          label: strings.reelBrakeType,
          value: brakeType.isEmpty ? null : brakeType,
          items: [
            PremiumDropdownItem(value: 'traditional_magnetic', label: strings.brakeTypeTraditionalMagnetic),
            PremiumDropdownItem(value: 'centrifugal', label: strings.brakeTypeCentrifugal),
            PremiumDropdownItem(value: 'dc', label: strings.brakeTypeDC),
            PremiumDropdownItem(value: 'floating_magnetic', label: strings.brakeTypeFloatingMagnetic),
            PremiumDropdownItem(value: 'innovative', label: strings.brakeTypeInnovative),
          ],
          onChanged: (value) {
            if (value != null) {
              onBrakeTypeChanged(value);
            }
          },
        ),
        const SizedBox(height: 10),
        // 渔轮重量
        Row(
          children: [
            Expanded(
              flex: 3,
              child: PremiumTextField(
                controller: weightController,
                label: strings.reelWeight,
                hint: strings.reelWeightHint,
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
      ],
    );
  }
}
