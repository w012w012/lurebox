import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/models/fish_catch.dart';
import '../../core/providers/app_settings_provider.dart';
import '../../core/providers/fish_list_view_model.dart';
import '../../core/providers/language_provider.dart';
import '../../core/widgets/error_view.dart';
import '../../widgets/common/premium_button.dart';
import '../../widgets/fish_list/fish_filter_panel.dart';
import '../../widgets/fish_list/fish_list_item.dart';
import '../../widgets/fish_list/fish_search_delegate.dart';
import '../fish_detail/fish_detail_page.dart';
import '../settings/species_management_page.dart';

class FishListPage extends ConsumerStatefulWidget {
  const FishListPage({super.key});

  @override
  ConsumerState<FishListPage> createState() => _FishListPageState();
}

class _FishListPageState extends ConsumerState<FishListPage> {
  final ScrollController _scrollController = ScrollController();
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final units = ref.read(appSettingsProvider).units;
      ref.read(fishListViewModelProvider.notifier).loadCatches(units: units);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.position.pixels;
    final maxExtent = _scrollController.position.maxScrollExtent;

    ref
        .read(fishListViewModelProvider.notifier)
        .onScroll(offset, _lastScrollOffset);
    _lastScrollOffset = offset;

    if (maxExtent - offset < 200) {
      ref.read(fishListViewModelProvider.notifier).loadMore();
    }
  }

  Future<void> _showDateRangePicker() async {
    final strings = ref.read(currentStringsProvider);
    final state = ref.read(fishListViewModelProvider);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: state.filter.customStartDate != null &&
              state.filter.customEndDate != null
          ? DateTimeRange(
              start: state.filter.customStartDate!,
              end: state.filter.customEndDate!,
            )
          : null,
      helpText: strings.selectDateRange,
      cancelText: strings.cancel,
      confirmText: strings.confirm,
      saveText: strings.confirm,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(fishListViewModelProvider.notifier).setCustomDateRange(
            picked.start,
            DateTime(
              picked.end.year,
              picked.end.month,
              picked.end.day,
            ).add(const Duration(days: 1)),
          );
    }
  }

  void _onSearchTap() {
    final state = ref.read(fishListViewModelProvider);
    showSearch(
      context: context,
      delegate: FishSearchDelegate(
        state.catches,
        ref.read(currentStringsProvider),
        (fish) async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FishDetailPage(fishId: fish.id),
            ),
          );
          ref.read(fishListViewModelProvider.notifier).loadCatches();
        },
      ),
    );
  }

  Future<void> _onDeleteSelected() async {
    final strings = ref.read(currentStringsProvider);
    final state = ref.read(fishListViewModelProvider);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.confirmDelete),
        content: Text(
          '${strings.confirmDeleteSelected} ${state.selectedIds.length} ${strings.records}',
        ),
        actions: [
          PremiumButton(
            text: strings.cancel,
            variant: PremiumButtonVariant.text,
            onPressed: () => Navigator.pop(context, false),
          ),
          PremiumButton(
            text: strings.delete,
            variant: PremiumButtonVariant.danger,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(fishListViewModelProvider.notifier).deleteSelected();
    }
  }

  void _onQuickIdentify(FishCatch fish) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SpeciesManagementPage(),
      ),
    );
  }

  void _onFishTap(FishCatch fish) {
    final state = ref.read(fishListViewModelProvider);
    if (state.isSelectionMode) {
      ref.read(fishListViewModelProvider.notifier).toggleSelection(fish.id);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FishDetailPage(fishId: fish.id),
        ),
      ).then((_) => ref.read(fishListViewModelProvider.notifier).loadCatches());
    }
  }

  void _onFishLongPress(FishCatch fish) {
    final state = ref.read(fishListViewModelProvider);
    if (!state.isSelectionMode) {
      ref.read(fishListViewModelProvider.notifier).toggleSelectionMode();
    }
    ref.read(fishListViewModelProvider.notifier).toggleSelection(fish.id);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fishListViewModelProvider);
    final strings = ref.watch(currentStringsProvider);

    return Scaffold(
      appBar: _buildAppBar(state, strings),
      body: _buildBody(state, strings),
    );
  }

  PreferredSizeWidget _buildAppBar(FishListState state, AppStrings strings) {
    return AppBar(
      title: state.isSelectionMode
          ? Text(
              '${strings.selected} ${state.selectedIds.length} ${strings.items}',
            )
          : Text(strings.fishList),
      centerTitle: true,
      leading: state.isSelectionMode
          ? PremiumIconButton(
              icon: Icons.close,
              onPressed: () => ref
                  .read(fishListViewModelProvider.notifier)
                  .toggleSelectionMode(),
            )
          : null,
      actions: state.isSelectionMode
          ? [
              PremiumIconButton(
                icon: Icons.select_all,
                onPressed: () =>
                    ref.read(fishListViewModelProvider.notifier).selectAll(),
                tooltip: strings.selectAll,
              ),
              PremiumIconButton(
                icon: Icons.delete,
                onPressed:
                    state.selectedIds.isNotEmpty ? _onDeleteSelected : null,
                tooltip: strings.delete,
              ),
            ]
          : [
              PremiumIconButton(
                icon: Icons.search,
                onPressed: _onSearchTap,
                tooltip: strings.search,
              ),
            ],
    );
  }

  Widget _buildBody(FishListState state, AppStrings strings) {
    if (state.isLoading && state.filteredCatches.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return ErrorView(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(fishListViewModelProvider.notifier).loadCatches(),
        strings: strings,
      );
    }

    return RefreshIndicator(
      onRefresh: () async =>
          ref.read(fishListViewModelProvider.notifier).loadCatches(reset: true),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        itemCount: state.filteredCatches.length + (state.hasMore ? 2 : 1),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              children: [
                state.filterExpanded
                    ? FishFilterPanel(
                        strings: strings,
                        timeFilter: state.filter.timeFilter,
                        fateFilter: state.filter.fateFilter,
                        speciesFilter: state.filter.speciesFilter,
                        speciesList: state.uniqueSpecies,
                        customDateLabel: state.getCustomDateLabel(
                          () => strings.custom,
                        ),
                        onShowDateRangePicker: _showDateRangePicker,
                        onTimeFilterChanged: (filter) => ref
                            .read(fishListViewModelProvider.notifier)
                            .setTimeFilter(filter),
                        onFateFilterChanged: (fate) => ref
                            .read(fishListViewModelProvider.notifier)
                            .setFateFilter(fate),
                        onSpeciesFilterChanged: (species) => ref
                            .read(fishListViewModelProvider.notifier)
                            .setSpeciesFilter(species),
                      )
                    : FishFilterCollapsed(
                        hasFilters: state.hasFilters,
                        filterLabel: strings.filterActive,
                        expandLabel: strings.expandFilter,
                        onTap: () => ref
                            .read(fishListViewModelProvider.notifier)
                            .toggleFilterExpanded(),
                        onClear: state.hasFilters
                            ? () => ref
                                .read(fishListViewModelProvider.notifier)
                                .clearFilters()
                            : null,
                      ),
                _buildSortBar(state, strings),
              ],
            );
          }

          if (index > state.filteredCatches.length) {
            if (state.isLoading && state.filteredCatches.isNotEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return const SizedBox.shrink();
          }

          final fish = state.filteredCatches[index - 1];
          return FishListItem(
            fish: fish,
            strings: strings,
            isSelected: state.selectedIds.contains(fish.id),
            isSelectionMode: state.isSelectionMode,
            onTap: () => _onFishTap(fish),
            onLongPress: () => _onFishLongPress(fish),
            onQuickIdentify:
                fish.pendingRecognition ? () => _onQuickIdentify(fish) : null,
          );
        },
      ),
    );
  }

  Widget _buildSortBar(FishListState state, AppStrings strings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.sort,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          _SortButton(
            label: strings.time,
            isSelected: state.filter.sortBy == 'time',
            isAsc: state.filter.sortAsc,
            onTap: () =>
                ref.read(fishListViewModelProvider.notifier).setSortBy('time'),
          ),
          const SizedBox(width: 8),
          _SortButton(
            label: strings.size,
            isSelected: state.filter.sortBy == 'length',
            isAsc: state.filter.sortAsc,
            onTap: () => ref
                .read(fishListViewModelProvider.notifier)
                .setSortBy('length'),
          ),
          const SizedBox(width: 8),
          _SortButton(
            label: strings.weight,
            isSelected: state.filter.sortBy == 'weight',
            isAsc: state.filter.sortAsc,
            onTap: () => ref
                .read(fishListViewModelProvider.notifier)
                .setSortBy('weight'),
          ),
          const Spacer(),
          Text(
            '${strings.total} ${state.filteredCatches.length} ${strings.fishCountUnit}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isAsc;
  final VoidCallback onTap;

  const _SortButton({
    required this.label,
    required this.isSelected,
    required this.isAsc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 2),
            Icon(
              isAsc ? Icons.arrow_upward : Icons.arrow_downward,
              size: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ],
      ),
    );
  }
}
