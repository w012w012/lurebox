import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/language_provider.dart';
import '../common/premium_input.dart';
import '../common/unit_dropdown.dart';

class RodForm extends ConsumerWidget {
  final TextEditingController lengthController;
  final String lengthUnit;
  final ValueChanged<String> onLengthUnitChanged;
  final TextEditingController sectionsController;
  final TextEditingController materialController;
  final TextEditingController hardnessController;
  final TextEditingController actionController;
  final TextEditingController weightRangeController;

  const RodForm({
    super.key,
    required this.lengthController,
    required this.lengthUnit,
    required this.onLengthUnitChanged,
    required this.sectionsController,
    required this.materialController,
    required this.hardnessController,
    required this.actionController,
    required this.weightRangeController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);

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
        PremiumTextField(
          controller: sectionsController,
          keyboardType: TextInputType.number,
          label: strings.sections,
          hint: strings.sectionsHint,
        ),
        const SizedBox(height: 10),
        PremiumTextField(
          controller: materialController,
          label: strings.material,
          hint: strings.materialHint,
        ),
        const SizedBox(height: 10),
        PremiumTextField(
          controller: hardnessController,
          label: strings.hardness,
          hint: strings.hardnessHint,
        ),
        const SizedBox(height: 10),
        PremiumTextField(
          controller: actionController,
          label: strings.action,
          hint: strings.actionHint,
        ),
        const SizedBox(height: 10),
        PremiumTextField(
          controller: weightRangeController,
          label: strings.weightRange,
          hint: strings.weightRangeHint,
        ),
      ],
    );
  }
}
