import 'package:flutter/material.dart';

class SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const SettingsCard({
    super.key,
    required this.children,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16),
      child: padding != null
          ? Padding(
              padding: padding!,
              child: Column(children: children),
            )
          : Column(children: children),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final double spacing;

  const SettingsSection({
    super.key,
    this.title,
    required this.children,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Text(
              title!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
        ...children.map(
          (child) => Padding(
            padding: EdgeInsets.only(bottom: spacing),
            child: child,
          ),
        ),
      ],
    );
  }
}
