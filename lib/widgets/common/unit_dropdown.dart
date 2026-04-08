import 'package:flutter/material.dart';

/// 单位选择器组件
class UnitDropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final String label;
  final ValueChanged<String> onUnitChanged;

  const UnitDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.label,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: DropdownButtonFormField<String>(
        initialValue: options.contains(value) ? value : options.first,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: options
            .map(
              (unit) => DropdownMenuItem(
                value: unit,
                child: Text(unit, style: const TextStyle(fontSize: 14)),
              ),
            )
            .toList(),
        onChanged: (v) {
          if (v != null) {
            onUnitChanged(v);
          }
        },
      ),
    );
  }
}
