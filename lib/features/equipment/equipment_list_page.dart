import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/models/equipment.dart';
import 'package:lurebox/core/providers/equipment_view_model.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/features/equipment/widgets/equipment_filter_bar.dart';
import 'package:lurebox/features/equipment/widgets/equipment_type_tabs.dart';
import 'package:lurebox/features/equipment/widgets/premium_equipment_card.dart';
import 'package:lurebox/widgets/common/premium_button.dart';

class EquipmentListPage extends ConsumerWidget {
  const EquipmentListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(equipmentListViewModelProvider);
    final strings = ref.watch(currentStringsProvider);
    final viewModel = ref.read(equipmentListViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.myEquipment),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              context.push('/equipment/overview');
            },
            tooltip: strings.equipmentOverview,
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 48, color: TeslaColors.electricBlue),
                      const SizedBox(height: 16),
                      Text('Error: ${state.errorMessage}'),
                      const SizedBox(height: 16),
                      PremiumButton(
                        onPressed: viewModel.refresh,
                        text: 'Retry',
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    EquipmentTypeTabs(
                      selectedType: state.selectedType,
                      rodCount: state.rodList.length,
                      reelCount: state.reelList.length,
                      lureCount: state.lureList.length,
                      onTypeChanged: viewModel.setSelectedType,
                    ),
                    EquipmentFilterBar(
                      allExpanded: state.allExpanded,
                      onToggleExpand: () =>
                          viewModel.setAllExpanded(!state.allExpanded),
                    ),
                    Expanded(
                      child: _buildList(
                        context,
                        ref,
                        state.selectedType,
                        state.currentList,
                        state.equipmentStats,
                        state.allExpanded,
                        strings,
                      ),
                    ),
                  ],
                ),
      floatingActionButton: PremiumFAB(
        onPressed: () => _navigateToEdit(context, ref, state.selectedType),
        icon: Icons.add,
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    String type,
    List<Equipment> list,
    Map<int, Map<String, int>> stats,
    bool allExpanded,
    AppStrings strings,
  ) {
    if (list.isEmpty) {
      return _buildEmptyState(context, ref, type, strings);
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(equipmentListViewModelProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final equipment = list[index];
          final id = equipment.id;
          return PremiumEquipmentCard(
            equipment: equipment.toMap(),
            stats: stats[id] ?? {},
            isExpanded: allExpanded,
            onTap: () => _navigateToEdit(context, ref, type, equipmentId: id),
            onSetDefault: () => _setDefault(context, ref, id, type),
            onDelete: () => _confirmDelete(context, ref, id, strings),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    String type,
    AppStrings strings,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hardware,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            strings.noEquipmentYet,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          PremiumButton(
            onPressed: () => _navigateToEdit(context, ref, type),
            text: strings.addEquipment,
            icon: Icons.add,
            variant: PremiumButtonVariant.text,
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToEdit(
    BuildContext context,
    WidgetRef ref,
    String type, {
    int? equipmentId,
  }) async {
    final result = await context.push<bool>(
      '/equipment/edit?type=$type${equipmentId != null ? '&id=$equipmentId' : ''}',
    );
    if (result ?? false) {
      ref.read(equipmentListViewModelProvider.notifier).refresh();
    }
  }

  Future<void> _setDefault(
    BuildContext context,
    WidgetRef ref,
    int id,
    String type,
  ) async {
    await ref
        .read(equipmentListViewModelProvider.notifier)
        .setDefaultEquipment(id, type);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int id,
    AppStrings strings,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.confirmDelete),
        content: Text(strings.confirmDeleteEquipment),
        actions: [
          PremiumButton(
            onPressed: () => Navigator.pop(context, false),
            text: strings.cancel,
            variant: PremiumButtonVariant.text,
          ),
          PremiumButton(
            onPressed: () => Navigator.pop(context, true),
            text: strings.delete,
            variant: PremiumButtonVariant.danger,
          ),
        ],
      ),
    );
    if (confirm ?? false) {
      await ref
          .read(equipmentListViewModelProvider.notifier)
          .deleteEquipment(id);
    }
  }
}
