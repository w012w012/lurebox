import 'package:flutter/material.dart';

class SettingsCard extends StatelessWidget {

  const SettingsCard({
    required this.children, super.key,
    this.margin,
    this.padding,
  });
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

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

  const SettingsSection({
    required this.children, super.key,
    this.title,
    this.spacing = 8,
  });
  final String? title;
  final List<Widget> children;
  final double spacing;

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
