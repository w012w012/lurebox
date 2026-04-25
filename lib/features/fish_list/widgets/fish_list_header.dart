import 'package:flutter/material.dart';
import 'package:lurebox/core/constants/strings.dart';

class FishListHeader extends StatelessWidget {

  const FishListHeader({
    required this.strings, required this.hasFilters, required this.filterLabel, required this.onSearchTap, required this.onFilterTap, super.key,
    this.onClearFilters,
  });
  final AppStrings strings;
  final bool hasFilters;
  final String filterLabel;
  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onSearchTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        strings.searchHint,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasFilters
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 18,
                    color: hasFilters
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  if (hasFilters && filterLabel.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      filterLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
