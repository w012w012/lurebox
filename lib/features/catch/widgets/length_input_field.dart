import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/camera/camera_state.dart';
import 'package:lurebox/core/camera/camera_view_model.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/widgets/common/premium_input.dart';

/// Length input field with unit dropdown.
class LengthInputField extends ConsumerWidget {

  const LengthInputField({
    required this.state, required this.vm, required this.strings, required this.controller, super.key,
  });
  final CameraState state;
  final CameraViewModel vm;
  final AppStrings strings;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: PremiumTextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            label: strings.length,
            hint: strings.enterLength,
            prefixIcon: const Icon(Icons.straighten),
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: state.lengthUnit,
          items: [
            DropdownMenuItem(value: 'cm', child: Text(strings.centimeter)),
            DropdownMenuItem(value: 'm', child: Text(strings.meter)),
            DropdownMenuItem(value: 'inch', child: Text(strings.inch)),
            DropdownMenuItem(value: 'ft', child: Text(strings.foot)),
          ],
          onChanged: (value) {
            if (value != null) {
              vm.setLengthUnit(value);
            }
          },
        ),
      ],
    );
  }
}
