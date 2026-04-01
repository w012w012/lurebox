import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/providers/settings_view_model.dart';

class SettingsStatsCard extends ConsumerWidget {
  const SettingsStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsViewModelProvider);
    final strings = ref.watch(currentStringsProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        leading: Icon(
          Icons.analytics_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(strings.fishCount),
        trailing: Text(
          '${settingsState.totalCount} ${strings.fishCountUnit}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
