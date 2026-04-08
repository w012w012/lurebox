import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/utils/unit_converter.dart';
import '../common/premium_input.dart';
import '../common/unit_dropdown.dart';

class RodForm extends ConsumerWidget {
  final TextEditingController lengthController;
  final String lengthUnit;
  final ValueChanged<String> onLengthUnitChanged;
  final TextEditingController sectionsController;
  final String jointType;
  final ValueChanged<String> onJointTypeChanged;
  final TextEditingController materialController;
  final String hardness;
  final ValueChanged<String> onHardnessChanged;
  final String action;
  final ValueChanged<String> onActionChanged;
  final TextEditingController weightRangeMinController;
  final TextEditingController weightRangeMaxController;

  const RodForm({
    super.key,
    required this.lengthController,
    required this.lengthUnit,
    required this.onLengthUnitChanged,
    required this.sectionsController,
    required this.jointType,
    required this.onJointTypeChanged,
    required this.materialController,
    required this.hardness,
    required this.onHardnessChanged,
    required this.action,
    required this.onActionChanged,
    required this.weightRangeMinController,
    required this.weightRangeMaxController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);
    final displayUnits = ref.watch(appSettingsProvider).units;
    final weightUnitSymbol = UnitConverter.getWeightSymbol(displayUnits.lureWeightUnit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 长度输入行：数值 + 单位
        Row(
          children: [
            Expanded(
              flex: 3,
              child: PremiumTextField(
                controller: lengthController,
                label: strings.rodLength,
                hint: strings.lengthHint,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: UnitDropdown(
                value: lengthUnit,
                options: const ['m', 'cm', 'ft', 'inch'],
                label: '单位',
                onUnitChanged: onLengthUnitChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // 节数：预选词
        PremiumDropdown<String>(
          label: strings.sections,
          value:
              sectionsController.text.isEmpty ? null : sectionsController.text,
          items: const [
            PremiumDropdownItem(value: '1节', label: '1节'),
            PremiumDropdownItem(value: '2节', label: '2节'),
            PremiumDropdownItem(value: '3节', label: '3节'),
            PremiumDropdownItem(value: '多节', label: '多节'),
          ],
          onChanged: (value) {
            if (value != null) {
              sectionsController.text = value;
            }
          },
        ),
        const SizedBox(height: 10),
        // 插节方式：预选词
        PremiumDropdown<String>(
          label: '插节方式',
          value: jointType.isEmpty ? null : jointType,
          items: const [
            PremiumDropdownItem(value: '正并继', label: '正并继'),
            PremiumDropdownItem(value: '逆并继', label: '逆并继'),
            PremiumDropdownItem(value: '印龙继', label: '印龙继'),
            PremiumDropdownItem(value: '伸缩', label: '伸缩'),
          ],
          onChanged: (value) {
            if (value != null) {
              onJointTypeChanged(value);
            }
          },
        ),
        const SizedBox(height: 10),
        PremiumTextField(
          controller: materialController,
          label: strings.material,
          hint: strings.materialHint,
        ),
        const SizedBox(height: 10),
        // 硬度：预选词
        PremiumDropdown<String>(
          label: strings.hardness,
          value: hardness.isEmpty ? null : hardness,
          items: const [
            PremiumDropdownItem(value: 'XUL', label: 'XUL'),
            PremiumDropdownItem(value: 'UL', label: 'UL'),
            PremiumDropdownItem(value: 'L', label: 'L'),
            PremiumDropdownItem(value: 'ML', label: 'ML'),
            PremiumDropdownItem(value: 'M', label: 'M'),
            PremiumDropdownItem(value: 'MH', label: 'MH'),
            PremiumDropdownItem(value: 'H', label: 'H'),
            PremiumDropdownItem(value: 'XH', label: 'XH'),
            PremiumDropdownItem(value: 'XXH', label: 'XXH'),
          ],
          onChanged: (value) {
            if (value != null) {
              onHardnessChanged(value);
            }
          },
        ),
        const SizedBox(height: 10),
        // 调性：预选词
        PremiumDropdown<String>(
          label: strings.action,
          value: action.isEmpty ? null : action,
          items: const [
            PremiumDropdownItem(value: 'SS调（超慢调）', label: 'SS调（超慢调）'),
            PremiumDropdownItem(value: 'S调（慢调）', label: 'S调（慢调）'),
            PremiumDropdownItem(value: 'MR调（中慢调）', label: 'MR调（中慢调）'),
            PremiumDropdownItem(value: 'R调（中调）', label: 'R调（中调）'),
            PremiumDropdownItem(value: 'RF调（中快调）', label: 'RF调（中快调）'),
            PremiumDropdownItem(value: 'F调（快调）', label: 'F调（快调）'),
            PremiumDropdownItem(value: 'FF调（超快调）', label: 'FF调（超快调）'),
            PremiumDropdownItem(value: 'XF调（极快调）', label: 'XF调（极快调）'),
          ],
          onChanged: (value) {
            if (value != null) {
              onActionChanged(value);
            }
          },
        ),
        const SizedBox(height: 10),
        // 适合饵重：a-b克模板
        Row(
          children: [
            Expanded(
              child: PremiumTextField(
                controller: weightRangeMinController,
                label: '适合饵重',
                hint: '最小值',
                keyboardType: TextInputType.number,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('-', style: TextStyle(fontSize: 18)),
            ),
            Expanded(
              child: PremiumTextField(
                controller: weightRangeMaxController,
                label: '',
                hint: '最大值',
                keyboardType: TextInputType.number,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(weightUnitSymbol, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ],
    );
  }
}
