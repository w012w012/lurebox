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
                hint: '前',
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
                hint: '后',
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
                hint: '线号',
                keyboardType: TextInputType.number,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('号/', style: TextStyle(fontSize: 14)),
            ),
            Expanded(
              child: PremiumTextField(
                controller: capacityLengthController,
                label: '',
                hint: '长度',
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
          items: const [
            PremiumDropdownItem(value: '传统磁力刹车', label: '传统磁力刹车'),
            PremiumDropdownItem(value: '离心刹车', label: '离心刹车'),
            PremiumDropdownItem(value: 'DC刹车', label: 'DC刹车'),
            PremiumDropdownItem(value: '浮动磁力刹车', label: '浮动磁力刹车'),
            PremiumDropdownItem(value: '创新组合刹车', label: '创新组合刹车'),
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
                label: '单位',
                onUnitChanged: onWeightUnitChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
