import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/providers/location_view_model.dart';
import 'package:lurebox/features/location/widgets/location_group_card.dart';
import 'package:lurebox/features/location/widgets/location_list_tile.dart';
import 'package:lurebox/widgets/common/app_snack_bar.dart';

/// 钓点管理页面
class LocationManagementPage extends ConsumerStatefulWidget {
  const LocationManagementPage({super.key});

  @override
  ConsumerState<LocationManagementPage> createState() =>
      _LocationManagementPageState();
}

class _LocationManagementPageState
    extends ConsumerState<LocationManagementPage> {
  final TextEditingController _mergeTargetController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _mergeTargetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(currentStringsProvider);
    final viewModel = ref.watch(locationManagementViewModelProvider.notifier);
    final state = ref.watch(locationManagementViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.locationManagement),
        centerTitle: true,
        actions: [
          if (state.selectedLocations.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: viewModel.clearSelection,
              tooltip: strings.locationCancelSelect,
            ),
          if (state.selectedLocations.isEmpty)
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: viewModel.selectAll,
              tooltip: strings.selectAll,
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.locations.isEmpty
              ? _buildEmptyState(strings)
              : _buildContent(strings, state, viewModel),
      bottomNavigationBar: state.selectedLocations.length >= 2
          ? Padding(
              padding: const EdgeInsets.all(TeslaTheme.spacingMd),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _mergeTargetController,
                      decoration: InputDecoration(
                        labelText: strings.locationMergeTo,
                        hintText: strings.locationEnterTargetName,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: TeslaTheme.spacingSm),
                  ElevatedButton(
                    onPressed: state.isMerging
                        ? null
                        : () => _confirmMerge(viewModel, state),
                    child: Text('合并 (${state.selectedLocations.length})'),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildContent(
    AppStrings strings,
    LocationManagementState state,
    LocationManagementViewModel viewModel,
  ) {
    // 过滤搜索结果
    final filteredLocations = state.locations.where((loc) {
      final name = loc['location_name'] as String;
      return name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        // 搜索框
        Padding(
          padding: const EdgeInsets.all(TeslaTheme.spacingSm),
          child: TextField(
            decoration: InputDecoration(
              hintText: strings.locationSearchHint,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: TeslaTheme.spacingSm,
                vertical: TeslaTheme.spacingSm,
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        // 统计信息
        _buildStatsCard(strings, state),
        // 相似钓点分组
        if (state.locationGroups.isNotEmpty)
          _buildSimilarGroupsSection(strings, state, viewModel),
        // 全部钓点列表
        Expanded(
          child: ListView.builder(
            itemCount: filteredLocations.length,
            itemBuilder: (context, index) {
              final loc = filteredLocations[index];
              final name = loc['location_name'] as String;
              final fishCount = loc['fish_count'] as int? ?? 0;
              final firstTimeStr = loc['first_time'] as String?;
              final lastTimeStr = loc['last_time'] as String?;

              return LocationListTile(
                name: name,
                fishCount: fishCount,
                fishCountSuffix: strings.fishCountSuffix,
                firstCatchTime: firstTimeStr != null
                    ? DateTime.tryParse(firstTimeStr)
                    : null,
                lastCatchTime:
                    lastTimeStr != null ? DateTime.tryParse(lastTimeStr) : null,
                isSelected: state.selectedLocations.contains(name),
                onToggleSelect: () => viewModel.toggleSelection(name),
                onTap: () =>
                    _showRenameLocationDialog(context, viewModel, name),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(AppStrings strings, LocationManagementState state) {
    final totalLocations = state.locations.length;
    final totalFish = state.locations.fold<int>(
      0,
      (sum, loc) => sum + (loc['fish_count'] as int? ?? 0),
    );

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: TeslaTheme.spacingSm,
        vertical: TeslaTheme.spacingMicro,
      ),
      child: Padding(
        padding: const EdgeInsets.all(TeslaTheme.spacingMd),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$totalLocations',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: TeslaTheme.spacingMicro),
                  Text(strings.locationCount),
                ],
              ),
            ),
            const Divider(height: 32, indent: 8, endIndent: 8),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$totalFish',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: TeslaTheme.spacingMicro),
                  Text(strings.locationTotalFishCount),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarGroupsSection(
    AppStrings strings,
    LocationManagementState state,
    LocationManagementViewModel viewModel,
  ) {
    // 构建鱼获数映射
    final locationFishCounts = Map<String, int>.fromEntries(
      state.locations.map(
        (loc) => MapEntry(
          loc['location_name'] as String,
          loc['fish_count'] as int? ?? 0,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            TeslaTheme.spacingSm,
            TeslaTheme.spacingMd,
            TeslaTheme.spacingSm,
            TeslaTheme.spacingSm,
          ),
          child: Row(
            children: [
              Icon(
                Icons.merge_type,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: TeslaTheme.spacingSm),
              Text(
                strings.locationSmartMergeSuggestion,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        ...state.locationGroups.map(
          (group) => LocationGroupCard(
            group: group,
            locationFishCounts: locationFishCounts,
            strings: strings,
            onAutoMerge: () => _confirmAutoMerge(viewModel, group),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppStrings strings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.place,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: TeslaTheme.spacingMd),
          Text(strings.noLocationRecords, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: TeslaTheme.spacingSm),
          Text(
            strings.locationStartFishing,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameLocationDialog(
    BuildContext context,
    LocationManagementViewModel viewModel,
    String oldName,
  ) async {
    final strings = ref.read(currentStringsProvider);
    final controller = TextEditingController(text: oldName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.locationEditName),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: strings.locationNewName,
            hintText: strings.locationEnterNewName,
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != oldName) {
                Navigator.pop(context, newName);
              }
            },
            child: Text(strings.confirm),
          ),
        ],
      ),
    );

    if (result != null && context.mounted) {
      final success = await viewModel.renameLocation(oldName, result);
      if (!context.mounted) return;
      AppSnackBar.showInfo(
          context, success ? strings.locationEditSuccess : strings.locationEditFailed,);
    }
    controller.dispose();
  }

  Future<void> _confirmMerge(
    LocationManagementViewModel viewModel,
    LocationManagementState state,
  ) async {
    final strings = ref.read(currentStringsProvider);
    final targetName = _mergeTargetController.text.trim().isEmpty
        ? state.selectedLocations.first
        : _mergeTargetController.text.trim();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.locationMergeConfirm),
        content: Text(
          '将 ${state.selectedLocations.length} 个钓点合并为 "$targetName"，合并后所有渔获记录将使用新名称。是否继续？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.confirm),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final success = await viewModel.mergeLocations(targetName);
      if (!mounted) return;
      AppSnackBar.showInfo(
          context, success ? strings.mergeSuccess : strings.mergeFailed,);
    }
  }

  Future<void> _confirmAutoMerge(
    LocationManagementViewModel viewModel,
    LocationGroup group,
  ) async {
    final strings = ref.read(currentStringsProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.locationConfirmAutoMerge),
        content: Text(
          '将 ${group.locations.length} 个相似钓点合并为 "${group.representative}"。是否继续？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.confirm),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final success = await viewModel.autoMergeGroup(group);
      if (!mounted) return;
      AppSnackBar.showInfo(
          context, success ? strings.mergeSuccess : strings.mergeFailed,);
    }
  }
}
