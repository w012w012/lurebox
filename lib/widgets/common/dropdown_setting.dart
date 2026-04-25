import 'package:flutter/material.dart';

class DropdownSetting<T> extends StatelessWidget {

  const DropdownSetting({
    required this.icon, required this.title, required this.value, required this.items, required this.onChanged, super.key,
    this.iconColor,
  });
  final IconData icon;
  final String title;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      trailing: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        underline: const SizedBox.shrink(),
      ),
    );
  }
}

class SwitchSetting extends StatelessWidget {

  const SwitchSetting({
    required this.icon, required this.title, required this.value, required this.onChanged, super.key,
    this.subtitle,
    this.iconColor,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(
        icon,
        color: iconColor ?? Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      value: value,
      onChanged: onChanged,
    );
  }
}
