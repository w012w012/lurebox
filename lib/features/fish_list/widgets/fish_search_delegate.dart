import 'package:flutter/material.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/widgets/common/image_cache_helper.dart';

class FishSearchDelegate extends SearchDelegate<FishCatch> {

  FishSearchDelegate(this.allCatches, this.strings, this.onTap);
  final List<FishCatch> allCatches;
  final AppStrings strings;
  final void Function(FishCatch) onTap;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, allCatches.first),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Text(
          strings.searchHint,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final searchLower = query.toLowerCase();
    final results = allCatches.where((f) {
      final species = f.species.toLowerCase();
      final location = f.locationName?.toLowerCase() ?? '';
      return species.contains(searchLower) || location.contains(searchLower);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          strings.noMatchFound,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final fish = results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 50,
                height: 50,
                child: Image(
                  image: ImageCacheHelper.getCachedThumbnailProvider(
                    fish.imagePath,
                    width: 100,
                    height: 100,
                  ),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            title: Text(fish.species),
            subtitle: Text(
              '${fish.length.toStringAsFixed(1)}cm • ${fish.locationName ?? ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              fish.fate == FishFateType.release ? '🐟' : '🍳',
              style: const TextStyle(fontSize: 18),
            ),
            onTap: () {
              close(context, fish);
              onTap(fish);
            },
          ),
        );
      },
    );
  }
}
