import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/features/camera/services/camera_state.dart';
import 'package:lurebox/features/camera/services/camera_view_model.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/widgets/common/premium_input.dart';

/// Species input card with text field, pending recognition toggle, and history chips.
class SpeciesInputCard extends ConsumerWidget {
  const SpeciesInputCard({
    required this.state,
    required this.vm,
    required this.strings,
    required this.controller,
    super.key,
  });
  final CameraState state;
  final CameraViewModel vm;
  final AppStrings strings;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 过滤空字符串；待识别记录已不再把占位文案写入鱼种历史
    final validHistory =
        state.speciesHistory.where((s) => s.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PremiumTextField(
                controller: controller,
                label: strings.species,
                hint: strings.enterSpeciesName,
                prefixIcon: const Icon(Icons.set_meal),
                enabled: !state.pendingRecognition,
                onChanged: vm.setSpecies,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: () {
                  if (state.pendingRecognition) {
                    // Switch back to normal mode
                    vm.setPendingRecognition(false);
                  } else {
                    controller.text = '';
                    vm.setSpecies('');
                    vm.setPendingRecognition(true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: state.pendingRecognition
                      ? TeslaColors.electricBlue.withValues(alpha: 0.3)
                      : Theme.of(context).colorScheme.secondary,
                  foregroundColor: state.pendingRecognition
                      ? TeslaColors.electricBlue
                      : Theme.of(context).colorScheme.onSecondary,
                ),
                child: Text(
                  state.pendingRecognition
                      ? strings.cancelPendingRecognition
                      : strings.addToPendingRecognition,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
        ),
        if (validHistory.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: validHistory.map((species) {
                return Material(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: state.pendingRecognition
                        ? null
                        : () {
                            controller.text = species;
                            vm.setSpecies(species);
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        species,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
