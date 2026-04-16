import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings.dart';
import '../../core/design/theme/animation_constants.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/models/fish_catch.dart';
import '../../core/providers/app_settings_provider.dart';
import '../../core/providers/fish_list_view_model.dart';
import '../../core/providers/language_provider.dart';
import '../../core/widgets/error_view.dart';
import '../../widgets/common/premium_button.dart';
import 'widgets/fish_filter_panel.dart';
import 'widgets/fish_list_item.dart';
import 'widgets/fish_search_delegate.dart';

class FishListPage extends ConsumerStatefulWidget {
  const FishListPage({super.key});

  @override
  ConsumerState<FishListPage> createState() => _FishListPageState();
}

class _FishListPageState extends ConsumerState<FishListPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _lastScrollOffset = 0;

  // Animation controllers for staggered list items
  // 限制同时运行的动画控制器数量，防止长列表内存问题
  static const int _maxActiveAnimations = 10;
  final Map<int, AnimationController> _itemAnimationControllers = {};
  final Map<int, Animation<double>> _itemAnimations = {};

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
    _disposeAllAnimationControllers();
    super.dispose();
  }

  void _disposeAllAnimationControllers() {
    for (final controller in _itemAnimationControllers.values) {
      controller.dispose();
    }
    _itemAnimationControllers.clear();
    _itemAnimations.clear();
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
                  primary: Theme.of(context).colorScheme.tertiary,
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
          await context.push('/fish/${fish.id}');
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
    context.push('/species');
  }

  void _onFishTap(FishCatch fish) {
    final state = ref.read(fishListViewModelProvider);
    if (state.isSelectionMode) {
      ref.read(fishListViewModelProvider.notifier).toggleSelection(fish.id);
    } else {
      context.push('/fish/${fish.id}').then(
            (_) => ref.read(fishListViewModelProvider.notifier).loadCatches(),
          );
    }
  }

  void _onFishLongPress(FishCatch fish) {
    final state = ref.read(fishListViewModelProvider);
    if (!state.isSelectionMode) {
      ref.read(fishListViewModelProvider.notifier).toggleSelectionMode();
    }
    ref.read(fishListViewModelProvider.notifier).toggleSelection(fish.id);
  }

  Animation<double> _getItemAnimation(int index) {
    // 如果已有动画，直接返回
    if (_itemAnimations.containsKey(index)) {
      return _itemAnimations[index]!;
    }

    // 如果超过最大动画数量，跳过动画（返回已完成动画）
    if (_itemAnimationControllers.length >= _maxActiveAnimations) {
      return const AlwaysStoppedAnimation(1.0);
    }

    final controller = AnimationController(
      duration: const Duration(milliseconds: 330),
      vsync: this,
    );

    final delay = AnimationConstants.staggerDelay * index;
    final delayFraction = delay.inMilliseconds / 330;

    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        delayFraction.clamp(0.0, 0.6),
        1.0,
        curve: TeslaAnimation.teslaCurve,
      ),
    );

    _itemAnimationControllers[index] = controller;
    _itemAnimations[index] = animation;

    controller.forward();
    return _itemAnimations[index]!;
  }

  void _resetAnimations() {
    _disposeAllAnimationControllers();
    if (mounted) setState(() {});
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
              style: const TextStyle(
                color: TeslaColors.carbonDark,
                fontWeight: FontWeight.w500,
              ),
            )
          : const Text(
              '鱼获列表',
              style: TextStyle(
                color: TeslaColors.carbonDark,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.3,
              ),
            ),
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
      return const Center(
        child: CircularProgressIndicator(
          color: TeslaColors.electricBlue,
        ),
      );
    }

    if (state.errorMessage != null) {
      return ErrorView(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(fishListViewModelProvider.notifier).loadCatches(),
        strings: strings,
      );
    }

    // Empty state check
    if (state.filteredCatches.isEmpty && !state.isLoading) {
      final hasFilters = state.hasFilters;
      if (hasFilters) {
        // Has filters but no results
        return EmptyView(
          message: strings.noMatchFound,
          icon: Icons.search_off,
          action: PremiumButton(
            text: strings.clearFilters,
            onPressed: () =>
                ref.read(fishListViewModelProvider.notifier).clearFilters(),
          ),
        );
      } else {
        // No catches at all
        return EmptyView(
          message: strings.noFishFound,
          icon: Icons.photo_camera_outlined,
          action: PremiumButton(
            text: strings.recordCatch,
            onPressed: () => context.push('/camera'),
          ),
        );
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;

        return RefreshIndicator(
          onRefresh: () async {
            _resetAnimations();
            await ref
                .read(fishListViewModelProvider.notifier)
                .loadCatches(reset: true);
          },
          child: isTablet
              ? _buildTabletGridView(constraints, state, strings)
              : _buildMobileListView(state, strings),
        );
      },
    );
  }

  Widget _buildMobileListView(FishListState state, AppStrings strings) {
    return Column(
      children: [
        // Filter panel and sort bar are built once outside the list
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
        Expanded(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            itemCount: state.filteredCatches.length + (state.hasMore ? 1 : 0),
            itemBuilder: (context, index) =>
                _buildListItem(index, state, strings),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletGridView(
      BoxConstraints constraints, FishListState state, AppStrings strings) {
    final crossAxisCount = constraints.maxWidth >= 900 ? 3 : 2;
    final itemWidth = (constraints.maxWidth - 32 - (crossAxisCount - 1) * 16) /
        crossAxisCount;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: state.filterExpanded
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
        ),
        SliverToBoxAdapter(
          child: _buildSortBar(state, strings),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: itemWidth / 100,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= state.filteredCatches.length) {
                  if (state.isLoading && state.filteredCatches.isNotEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: TeslaColors.electricBlue,
                      ),
                    );
                  }
                  return null;
                }
                final fish = state.filteredCatches[index];
                return _AnimatedListItem(
                  animation: _getItemAnimation(index),
                  child: FishListItem(
                    fish: fish,
                    strings: strings,
                    isSelected: state.selectedIds.contains(fish.id),
                    isSelectionMode: state.isSelectionMode,
                    onTap: () => _onFishTap(fish),
                    onLongPress: () => _onFishLongPress(fish),
                    onQuickIdentify: fish.pendingRecognition
                        ? () => _onQuickIdentify(fish)
                        : null,
                  ),
                );
              },
              childCount:
                  state.filteredCatches.length + (state.hasMore ? 1 : 0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListItem(int index, FishListState state, AppStrings strings) {
    // 加载更多时的 loading indicator
    if (index >= state.filteredCatches.length) {
      if (state.isLoading && state.filteredCatches.isNotEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(
              color: TeslaColors.electricBlue,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    final fish = state.filteredCatches[index];
    return _AnimatedListItem(
      animation: _getItemAnimation(index),
      child: FishListItem(
        fish: fish,
        strings: strings,
        isSelected: state.selectedIds.contains(fish.id),
        isSelectionMode: state.isSelectionMode,
        onTap: () => _onFishTap(fish),
        onLongPress: () => _onFishLongPress(fish),
        onQuickIdentify:
            fish.pendingRecognition ? () => _onQuickIdentify(fish) : null,
      ),
    );
  }

  // Track constraints for tablet grid view
  BoxConstraints get constraints => const BoxConstraints();

  Widget _buildSortBar(FishListState state, AppStrings strings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: TeslaColors.white,
        border: Border(
          bottom: BorderSide(
            color: TeslaColors.cloudGray.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.sort,
            size: 18,
            color: TeslaColors.electricBlue,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: TeslaColors.electricBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${strings.total} ${state.filteredCatches.length} ${strings.fishCountUnit}',
              style: const TextStyle(
                fontSize: 12,
                color: TeslaColors.electricBlue,
                fontWeight: FontWeight.w500,
              ),
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
      child: AnimatedContainer(
        duration: TeslaAnimation.colorTransition,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? TeslaColors.electricBlue.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected
                    ? TeslaColors.electricBlue
                    : TeslaColors.graphite,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 2),
              Icon(
                isAsc ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: TeslaColors.electricBlue,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Animated wrapper for list items with staggered fade + slide effect
class _AnimatedListItem extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _AnimatedListItem({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
