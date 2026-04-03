import 'package:flutter/material.dart';

/// 可复用的信息行组件
class AppInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const AppInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
          ],
        ),
      ),
    );
  }
}
