import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/camera/camera_state.dart';
import 'package:lurebox/core/camera/camera_view_model.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/models/app_settings.dart';
import 'package:lurebox/core/providers/app_settings_provider.dart';
import 'package:lurebox/core/utils/unit_converter.dart';
import 'package:lurebox/widgets/common/premium_input.dart';

/// Weight input field with unit dropdown and estimated weight display.
class WeightInputField extends ConsumerWidget {

  const WeightInputField({
    required this.state, required this.vm, required this.strings, required this.controller, super.key,
  });
  final CameraState state;
  final CameraViewModel vm;
  final AppStrings strings;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isChinese = ref.watch(
      appSettingsProvider.select((s) => s.language == AppLanguage.chinese),
    );

    double? displayEstimatedWeight;
    if (state.estimatedWeight != null) {
      final lengthInCm = UnitConverter.toBaseCm(state.length, state.lengthUnit);
      final weightInGrams =
          lengthInCm * lengthInCm * lengthInCm * CameraState.weightCoefficient;
      final weightInKg = weightInGrams / 1000;
      displayEstimatedWeight = UnitConverter.convertWeight(
        weightInKg,
        'kg',
        state.weightUnit,
      );
    }

    final unitSymbol =
        UnitConverter.getWeightSymbol(state.weightUnit, isChinese: isChinese);

    return Row(
      children: [
        Expanded(
          child: PremiumTextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            label: '${strings.weight} (${strings.optional})',
            hint: displayEstimatedWeight != null
                ? '${strings.estimated}: ${displayEstimatedWeight.toStringAsFixed(2)} $unitSymbol'
                : strings.enterActualWeight,
            prefixIcon: const Icon(Icons.scale),
            onChanged: (value) {
              final weight = double.tryParse(value);
              ref.read(cameraViewModelProvider.notifier).setWeight(weight);
            },
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: state.weightUnit,
          items: [
            DropdownMenuItem(value: 'kg', child: Text(strings.kilogram)),
            DropdownMenuItem(value: 'g', child: Text(strings.gram)),
            DropdownMenuItem(value: 'lb', child: Text(strings.pound)),
            DropdownMenuItem(value: 'oz', child: Text(strings.ounce)),
          ],
          onChanged: (value) {
            if (value != null) {
              vm.setWeightUnit(value);
            }
          },
        ),
      ],
    );
  }
}
