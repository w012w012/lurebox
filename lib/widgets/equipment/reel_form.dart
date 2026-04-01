import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/language_provider.dart';
import '../common/premium_input.dart';

class ReelForm extends ConsumerWidget {
  final TextEditingController bearingsController;
  final TextEditingController ratioController;
  final TextEditingController capacityController;
  final TextEditingController brakeTypeController;

  const ReelForm({
    super.key,
    required this.bearingsController,
    required this.ratioController,
    required this.capacityController,
    required this.brakeTypeController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(currentStringsProvider);
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
        PremiumTextField(
          controller: ratioController,
          label: strings.ratio,
          hint: strings.ratioHint,
        ),
        const SizedBox(height: 10),
        PremiumTextField(
          controller: capacityController,
          label: strings.reelCapacity,
          hint: strings.capacityHint,
        ),
        const SizedBox(height: 10),
        PremiumTextField(
          controller: brakeTypeController,
          label: strings.reelBrakeType,
          hint: strings.brakeTypeHint,
        ),
      ],
    );
  }
}
