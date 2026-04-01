import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/strings.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/location_view_model.dart';
import '../../widgets/location/location_list_tile.dart';
import '../../widgets/location/location_group_card.dart';

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
              onPressed: () => viewModel.clearSelection(),
              tooltip: '取消选择',
            ),
          if (state.selectedLocations.isEmpty)
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: () => viewModel.selectAll(),
              tooltip: '全选',
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.locations.isEmpty
              ? _buildEmptyState(strings)
              : _buildContent(state, viewModel),
      bottomNavigationBar: state.selectedLocations.length >= 2
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _mergeTargetController,
                      decoration: InputDecoration(
                        labelText: '合并到',
                        hintText: '输入目标名称',
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(
              hintText: '搜索钓点',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        // 统计信息
        _buildStatsCard(state),
        // 相似钓点分组
        if (state.locationGroups.isNotEmpty)
          _buildSimilarGroupsSection(state, viewModel),
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

  Widget _buildStatsCard(LocationManagementState state) {
    final totalLocations = state.locations.length;
    final totalFish = state.locations.fold<int>(
      0,
      (sum, loc) => sum + (loc['fish_count'] as int? ?? 0),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  const SizedBox(height: 4),
                  Text('钓点数量'),
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
                  const SizedBox(height: 4),
                  Text('总渔获数'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarGroupsSection(
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
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          child: Row(
            children: [
              Icon(
                Icons.merge_type,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '智能合并建议',
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
          const SizedBox(height: 16),
          Text('暂无钓点记录', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            '开始记录您的钓鱼活动吧',
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
    final controller = TextEditingController(text: oldName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改钓点名称'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: '新名称',
            hintText: '输入新的钓点名称',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != oldName) {
                Navigator.pop(context, newName);
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      final success = await viewModel.renameLocation(oldName, result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '修改成功' : '修改失败'),
          ),
        );
      }
    }
    controller.dispose();
  }

  Future<void> _confirmMerge(
    LocationManagementViewModel viewModel,
    LocationManagementState state,
  ) async {
    final targetName = _mergeTargetController.text.trim().isEmpty
        ? state.selectedLocations.first
        : _mergeTargetController.text.trim();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认合并'),
        content: Text(
          '将 ${state.selectedLocations.length} 个钓点合并为 "$targetName"，合并后所有渔获记录将使用新名称。是否继续？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await viewModel.mergeLocations(targetName);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(success ? '合并成功' : '合并失败')));
      }
    }
  }

  Future<void> _confirmAutoMerge(
    LocationManagementViewModel viewModel,
    dynamic group,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认自动合并'),
        content: Text(
          '将 ${group.locations.length} 个相似钓点合并为 "${group.representative}"。是否继续？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await viewModel.autoMergeGroup(group);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(success ? '合并成功' : '合并失败')));
      }
    }
  }
}
