import 'package:flutter/material.dart';
import '../../core/providers/location_view_model.dart';

/// 相似钓点分组卡片
class LocationGroupCard extends StatelessWidget {
  final LocationGroup group;
  final Map<String, int> locationFishCounts;
  final VoidCallback? onAutoMerge;

  const LocationGroupCard({
    super.key,
    required this.group,
    required this.locationFishCounts,
    this.onAutoMerge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(Icons.merge_type, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              '相似钓点：${group.representative}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        subtitle: Text(
          '包含 ${group.locations.length} 个相似钓点',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onAutoMerge != null)
              TextButton(onPressed: onAutoMerge, child: Text('合并')),
            Icon(Icons.expand_more, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
        children: group.locations.map((location) {
          final fishCount = locationFishCounts[location] ?? 0;
          return ListTile(
            title: Text(location),
            subtitle: Text('$fishCount 条渔获'),
            dense: true,
          );
        }).toList(),
      ),
    );
  }
}
