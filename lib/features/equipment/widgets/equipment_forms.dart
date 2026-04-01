import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/language_provider.dart';

/// 鱼竿表单组件
class RodForm extends ConsumerWidget {
  final TextEditingController lengthController;
  final TextEditingController sectionsController;
  final TextEditingController materialController;
  final TextEditingController hardnessController;
  final TextEditingController actionController;
  final TextEditingController weightRangeController;

  const RodForm({
    super.key,
    required this.lengthController,
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
        TextField(
          controller: lengthController,
          decoration: InputDecoration(
            labelText: strings.rodLength,
            hintText: strings.lengthHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: sectionsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: strings.sections,
            hintText: strings.sectionsHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: materialController,
          decoration: InputDecoration(
            labelText: strings.material,
            hintText: strings.materialHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: hardnessController,
          decoration: InputDecoration(
            labelText: strings.hardness,
            hintText: strings.hardnessHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: actionController,
          decoration: InputDecoration(
            labelText: strings.action,
            hintText: strings.actionHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: weightRangeController,
          decoration: InputDecoration(
            labelText: strings.weightRange,
            hintText: strings.weightRangeHint,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

/// 渔轮表单组件
class ReelForm extends ConsumerWidget {
  final TextEditingController bearingsController;
  final TextEditingController ratioController;
  final TextEditingController capacityController;
  final TextEditingController brakeTypeController;
  final TextEditingController lineController;
  final TextEditingController lineNumberController;
  final TextEditingController lineLengthController;
  final TextEditingController lineDateController;

  const ReelForm({
    super.key,
    required this.bearingsController,
    required this.ratioController,
    required this.capacityController,
    required this.brakeTypeController,
    required this.lineController,
    required this.lineNumberController,
    required this.lineLengthController,
    required this.lineDateController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: bearingsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: strings.bearings,
            hintText: strings.bearingsHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: ratioController,
          decoration: InputDecoration(
            labelText: strings.ratio,
            hintText: strings.ratioHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: capacityController,
          decoration: InputDecoration(
            labelText: strings.reelCapacity,
            hintText: strings.capacityHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: brakeTypeController,
          decoration: InputDecoration(
            labelText: strings.reelBrakeType,
            hintText: strings.brakeTypeHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          strings.lineInfo,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: lineController,
          decoration: InputDecoration(
            labelText: strings.lineType,
            hintText: strings.lineTypeHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: lineNumberController,
          decoration: InputDecoration(
            labelText: strings.lineNumber,
            hintText: strings.lineNumberHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: lineLengthController,
          decoration: InputDecoration(
            labelText: strings.lineLength,
            hintText: strings.lineLengthHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: lineDateController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: strings.lineDate,
            hintText: strings.tapToSelect,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              lineDateController.text =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            }
          },
        ),
      ],
    );
  }
}

/// 鱼饵表单组件
class LureForm extends ConsumerWidget {
  final TextEditingController typeController;
  final TextEditingController weightController;
  final TextEditingController sizeController;
  final TextEditingController colorController;

  const LureForm({
    super.key,
    required this.typeController,
    required this.weightController,
    required this.sizeController,
    required this.colorController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: typeController,
          decoration: InputDecoration(
            labelText: strings.type,
            hintText: strings.lureTypeHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: weightController,
          decoration: InputDecoration(
            labelText: strings.weight,
            hintText: strings.lureWeightHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: sizeController,
          decoration: InputDecoration(
            labelText: strings.size,
            hintText: strings.lureSizeHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: colorController,
          decoration: InputDecoration(
            labelText: strings.lureColor,
            hintText: strings.lureColorHint,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
