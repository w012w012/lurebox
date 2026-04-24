import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../widgets/common/premium_input.dart';
import '../../../widgets/common/unit_dropdown.dart';

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
    final weightUnitSymbol =
        UnitConverter.getWeightSymbol(displayUnits.lureWeightUnit);

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
                label: strings.unit,
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
          items: [
            PremiumDropdownItem(value: '1', label: strings.rodSection1),
            PremiumDropdownItem(value: '2', label: strings.rodSection2),
            PremiumDropdownItem(value: '3', label: strings.rodSection3),
            PremiumDropdownItem(value: 'multi', label: strings.rodSectionMulti),
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
          label: strings.jointMethod,
          value: jointType.isEmpty ? null : jointType,
          items: [
            PremiumDropdownItem(value: 'spigot', label: strings.jointTypeSpigot),
            PremiumDropdownItem(value: 'reverse_spigot', label: strings.jointTypeReverseSpigot),
            PremiumDropdownItem(value: 'dragon_spigot', label: strings.jointTypeDragonSpigot),
            PremiumDropdownItem(value: 'telescopic', label: strings.jointTypeTelescopic),
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
          items: [
            PremiumDropdownItem(value: 'SS', label: strings.rodActionSS),
            PremiumDropdownItem(value: 'S', label: strings.rodActionS),
            PremiumDropdownItem(value: 'MR', label: strings.rodActionMR),
            PremiumDropdownItem(value: 'R', label: strings.rodActionR),
            PremiumDropdownItem(value: 'RF', label: strings.rodActionRF),
            PremiumDropdownItem(value: 'F', label: strings.rodActionF),
            PremiumDropdownItem(value: 'FF', label: strings.rodActionFF),
            PremiumDropdownItem(value: 'XF', label: strings.rodActionXF),
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
                label: strings.baitWeightLabel,
                hint: strings.minValue,
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
                hint: strings.maxValue,
                keyboardType: TextInputType.number,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child:
                  Text(weightUnitSymbol, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ],
    );
  }
}
