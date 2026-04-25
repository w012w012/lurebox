import 'package:flutter/material.dart';

class ListTileAction extends StatelessWidget {

  const ListTileAction({
    required this.icon, required this.title, super.key,
    this.iconColor,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class ListTileDivider extends StatelessWidget {

  const ListTileDivider({required this.children, super.key});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) const Divider(height: 1),
        ],
      ],
    );
  }
}
