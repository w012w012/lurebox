import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/core/providers/ai_recognition_provider.dart';
import 'package:lurebox/core/providers/language_provider.dart';
import 'package:lurebox/core/providers/pending_recognition_providers.dart';
import 'package:lurebox/core/services/fish_recognition_service.dart';
import 'package:lurebox/features/settings/widgets/pending_queue_widget.dart';
import 'package:lurebox/features/settings/widgets/species_management_helpers.dart';
import 'package:lurebox/widgets/common/app_snack_bar.dart';
import 'package:lurebox/widgets/common/premium_button.dart';
import 'package:lurebox/widgets/common/premium_card.dart';

/// 品种管理页面 — 待识别列表 + 品种列表 + 批量识别
class SpeciesManagementPage extends ConsumerStatefulWidget {
  const SpeciesManagementPage({super.key});

  @override
  ConsumerState<SpeciesManagementPage> createState() =>
      _SpeciesManagementPageState();
}

class _SpeciesManagementPageState extends ConsumerState<SpeciesManagementPage> {
  bool _isBatchRecognizing = false;
  int _batchProgress = 0;
  int _batchTotal = 0;
  int _batchSuccess = 0;
  int _batchFailed = 0;

  // 单条识别状态追踪
  final Map<int, SingleRecognitionState> _recognitionStates = {};

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(currentStringsProvider);
    final pendingCatchesAsync = ref.watch(pendingRecognitionCatchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.speciesManagement),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pendingRecognitionCatchesProvider);
          ref.invalidate(pendingRecognitionCountProvider);
          ref.invalidate(speciesCountsProvider);
          // 等待重新加载完成
          await ref.read(pendingRecognitionCatchesProvider.future).catchError(
                (_) => <FishCatch>[],
              );
        },
        child: pendingCatchesAsync.when(
          data: (catches) => _buildContent(context, catches, strings),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('${strings.errorLoadFailed}: $e')),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<FishCatch> pendingCatches,
    AppStrings strings,
  ) {
    return ListView(
      padding: const EdgeInsets.all(TeslaTheme.spacingLg),
      children: [
        PendingQueueWidget(
          pendingCatches: pendingCatches,
          recognitionStates: _recognitionStates,
          isBatchRecognizing: _isBatchRecognizing,
          batchProgress: _batchProgress,
          batchTotal: _batchTotal,
          batchSuccess: _batchSuccess,
          batchFailed: _batchFailed,
          onRecognize: _recognizeSingle,
          onManualIdentify: _manualIdentify,
          onConfirmOption: _showConfirmDialog,
          onBatchRecognize: () => _batchRecognize(pendingCatches),
          strings: strings,
        ),
        const SizedBox(height: TeslaTheme.spacingXl),
        _SpeciesListSection(
          onRename: _showRenameDialog,
          onDelete: _showDeleteDialog,
        ),
      ],
    );
  }

  Future<void> _manualIdentify(FishCatch fish) async {
    final strings = ref.read(currentStringsProvider);
    final speciesName = await SpeciesManagementDialogs.showManualIdentifyDialog(
      context,
      fish,
      strings,
    );

    if (speciesName != null && speciesName.isNotEmpty && mounted) {
      try {
        final repository = ref.read(fishCatchRepositoryProvider);
        await repository.updateSpecies(fish.id, speciesName);
        ref.invalidate(pendingRecognitionCountProvider);
        ref.invalidate(pendingRecognitionCatchesProvider);
        setState(() {
          _recognitionStates.remove(fish.id);
        });
        if (mounted) {
          final s = ref.read(currentStringsProvider);
          AppSnackBar.showSuccess(context, s.speciesUpdated.replaceFirst('%s', speciesName));
        }
      } catch (e) {
        if (mounted) {
          final s = ref.read(currentStringsProvider);
          AppSnackBar.showError(context, s.speciesUpdateFailed, debugError: e);
        }
      }
    }
  }

  Future<void> _recognizeSingle(FishCatch fish) async {
    setState(() {
      _recognitionStates[fish.id] = const SingleRecognitionState(
        isRecognizing: true,
      );
    });

    try {
      final repository = ref.read(fishCatchRepositoryProvider);
      final fishCatch = await repository.getById(fish.id);
      if (fishCatch == null || fishCatch.imagePath.isEmpty) {
        setState(() {
          _recognitionStates[fish.id] = SingleRecognitionState(
            error: ref.read(currentStringsProvider).speciesImageNotFound,
          );
        });
        return;
      }

      final file = File(fishCatch.imagePath);
      if (!await file.exists()) {
        setState(() {
          _recognitionStates[fish.id] = SingleRecognitionState(
            error: ref.read(currentStringsProvider).errorImageNotFound,
          );
        });
        return;
      }

      final settings = ref.read(aiRecognitionSettingsProvider);
      final currentConfig =
          settings.providerConfigs[settings.currentProvider];
      if (currentConfig == null || currentConfig.apiKey.isEmpty) {
        setState(() {
          _recognitionStates[fish.id] = SingleRecognitionState(
            error: ref.read(currentStringsProvider).speciesConfigureApiKey,
          );
        });
        return;
      }

      final service = FishRecognitionService();
      final result = await service.identifySpecies(file, settings);

      // 构建多选项列表
      final options = <AiRecognitionOption>[];

      final s = ref.read(currentStringsProvider);
      if (result.primarySpecies.chineseName.isNotEmpty) {
        options.add(AiRecognitionOption(
          speciesName: result.primarySpecies.chineseName,
          confidence: result.primarySpecies.confidence / 100.0,
          providerName: s.speciesAiResultTitle,
        ),);
      }

      // 添加备选结果
      if (result.alternatives.isNotEmpty) {
        for (final alt in result.alternatives.take(2)) {
          if (alt.chineseName.isNotEmpty) {
            options.add(AiRecognitionOption(
              speciesName: alt.chineseName,
              confidence: alt.confidence / 100.0,
              providerName: s.speciesAlternative,
            ),);
          }
        }
      }

      // 如果没有结果
      if (options.isEmpty) {
        setState(() {
          _recognitionStates[fish.id] = SingleRecognitionState(
            error: ref.read(currentStringsProvider).speciesNoResult,
          );
        });
        return;
      }

      setState(() {
        _recognitionStates[fish.id] = SingleRecognitionState(
          options: options,
        );
      });
    } catch (e) {
      setState(() {
        _recognitionStates[fish.id] = SingleRecognitionState(
          error: ref.read(currentStringsProvider).speciesRecognitionFailed.replaceFirst('%s', '$e'),
        );
      });
    }
  }

  Future<void> _showConfirmDialog(
      FishCatch fish, AiRecognitionOption option,) async {
    final strings = ref.read(currentStringsProvider);
    final speciesName =
        await SpeciesManagementDialogs.showConfirmRecognitionDialog(
      context,
      option,
      strings,
    );

    if (speciesName != null && mounted) {
      try {
        final repository = ref.read(fishCatchRepositoryProvider);
        await repository.updateSpecies(fish.id, speciesName);
        ref.invalidate(pendingRecognitionCountProvider);
        ref.invalidate(pendingRecognitionCatchesProvider);
        setState(() {
          _recognitionStates.remove(fish.id);
        });
        if (mounted) {
          final s = ref.read(currentStringsProvider);
          AppSnackBar.showSuccess(context, s.speciesUpdated.replaceFirst('%s', speciesName));
        }
      } catch (e) {
        if (mounted) {
          final s = ref.read(currentStringsProvider);
          AppSnackBar.showError(context, s.speciesUpdateFailed, debugError: e);
        }
      }
    }
  }

  Future<void> _showRenameDialog(BuildContext context, String oldName) async {
    final strings = ref.read(currentStringsProvider);
    final result = await SpeciesManagementDialogs.showRenameDialog(
      context,
      oldName,
      strings,
    );

    if (result != null && context.mounted) {
      try {
        final speciesManagementService =
            ref.read(speciesManagementServiceProvider);
        await speciesManagementService.renameSpecies(oldName, result);
        ref.invalidate(speciesCountsProvider);
        ref.invalidate(pendingRecognitionCountProvider);
        ref.invalidate(pendingRecognitionCatchesProvider);
        setState(() {});
        if (!context.mounted) return;
        final s = ref.read(currentStringsProvider);
        AppSnackBar.showSuccess(context, s.speciesRenamed.replaceFirst('%s', oldName).replaceFirst('%s', result));
      } catch (e) {
        if (!context.mounted) return;
        final s = ref.read(currentStringsProvider);
        AppSnackBar.showError(context, s.speciesRenameFailed, debugError: e);
      }
    }
  }

  Future<void> _showDeleteDialog(
      BuildContext context, String speciesName, int count,) async {
    final strings = ref.read(currentStringsProvider);
    final confirmed = await SpeciesManagementDialogs.showDeleteDialog(
      context,
      speciesName,
      count,
      strings,
    );

    if (confirmed && context.mounted) {
      try {
        final repository = ref.read(fishCatchRepositoryProvider);
        await repository.deleteSpecies(speciesName);
        ref.invalidate(speciesCountsProvider);
        ref.invalidate(pendingRecognitionCountProvider);
        ref.invalidate(pendingRecognitionCatchesProvider);
        setState(() {});
        if (!context.mounted) return;
        final s = ref.read(currentStringsProvider);
        AppSnackBar.showSuccess(
            context, s.speciesDeleted.replaceFirst('%s', speciesName).replaceFirst('%d', '$count'),);
      } catch (e) {
        if (!context.mounted) return;
        final s = ref.read(currentStringsProvider);
        AppSnackBar.showError(context, s.speciesDeleteFailed, debugError: e);
      }
    }
  }

  Future<void> _batchRecognize(List<FishCatch> pendingCatches) async {
    setState(() {
      _isBatchRecognizing = true;
      _batchTotal = pendingCatches.length;
      _batchProgress = 0;
      _batchSuccess = 0;
      _batchFailed = 0;
    });

    try {
      final repository = ref.read(fishCatchRepositoryProvider);
      final settings = ref.read(aiRecognitionSettingsProvider);
      final service = FishRecognitionService();

      for (final fish in pendingCatches) {
        try {
          final fishCatch = await repository.getById(fish.id);
          if (fishCatch == null || fishCatch.imagePath.isEmpty) {
            setState(() => _batchFailed++);
            continue;
          }

          final file = File(fishCatch.imagePath);
          if (!await file.exists()) {
            setState(() => _batchFailed++);
            continue;
          }

          final currentConfig =
              settings.providerConfigs[settings.currentProvider];
          if (currentConfig == null || currentConfig.apiKey.isEmpty) {
            setState(() => _batchFailed++);
            continue;
          }

          final result = await service.identifySpecies(file, settings);

          if (result.primarySpecies.chineseName.isNotEmpty) {
            await repository.updateSpecies(
                fish.id, result.primarySpecies.chineseName,);
            setState(() => _batchSuccess++);
          } else {
            setState(() => _batchFailed++);
          }
        } catch (e) {
          setState(() => _batchFailed++);
        } finally {
          setState(() => _batchProgress++);
        }
      }

      ref.invalidate(pendingRecognitionCountProvider);
      ref.invalidate(pendingRecognitionCatchesProvider);

      if (mounted) {
        final s = ref.read(currentStringsProvider);
        AppSnackBar.showInfo(
            context, s.speciesRecognitionComplete.replaceFirst('%d', '$_batchSuccess').replaceFirst('%d', '$_batchFailed'),);
      }
    } finally {
      setState(() => _isBatchRecognizing = false);
    }
  }
}

/// 物种计数 Provider
final speciesCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(fishCatchRepositoryProvider);
  return repository.getSpeciesCounts();
});

/// 已保存品种列表 Widget
class _SpeciesListSection extends ConsumerWidget {

  const _SpeciesListSection({
    required this.onRename,
    required this.onDelete,
  });
  final void Function(BuildContext, String) onRename;
  final void Function(BuildContext, String, int) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speciesCountsAsync = ref.watch(speciesCountsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accentColor = TeslaColors.electricBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category, size: 20, color: accentColor),
            const SizedBox(width: TeslaTheme.spacingSm),
            Text(
              ref.read(currentStringsProvider).speciesSaved,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: TeslaTheme.spacingMd),
        speciesCountsAsync.when(
          data: (speciesCounts) {
            if (speciesCounts.isEmpty) {
              return PremiumCard(
                variant: PremiumCardVariant.flat,
                child: Center(
                  child: Text(
                    ref.read(currentStringsProvider).speciesNoRecords,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              );
            }

            // Sort by count descending (most caught first), filter out invalid names
            final sortedSpecies = speciesCounts.entries
                .where((e) => e.key != '待识别' && e.key.isNotEmpty)
                .toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            return PremiumCard(
              variant: PremiumCardVariant.flat,
              padding: EdgeInsets.zero,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedSpecies.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: isDark
                      ? const Color(0xFF2A2D30)
                      : TeslaColors.cloudGray,
                ),
                itemBuilder: (context, index) {
                  final entry = sortedSpecies[index];
                  final speciesName = entry.key;
                  final count = entry.value;

                  final strings = ref.read(currentStringsProvider);
                  final countLabel = strings.fishCountSuffix.replaceFirst('%d', '$count');
                  return _SpeciesListItem(
                    speciesName: speciesName,
                    count: count,
                    countLabel: countLabel,
                    onRename: () => onRename(context, speciesName),
                    onDelete: () => onDelete(context, speciesName, count),
                  );
                },
              ),
            );
          },
          loading: () => PremiumCard(
            variant: PremiumCardVariant.flat,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(TeslaTheme.spacingXl),
                child: const CircularProgressIndicator(),
              ),
            ),
          ),
          error: (e, _) => PremiumCard(
            variant: PremiumCardVariant.flat,
            child: Center(
              child: Text(
                '${ref.read(currentStringsProvider).errorLoadFailed}: $e',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 品种列表单项 Widget
class _SpeciesListItem extends StatelessWidget {

  const _SpeciesListItem({
    required this.speciesName,
    required this.count,
    required this.countLabel,
    required this.onRename,
    required this.onDelete,
  });
  final String speciesName;
  final int count;
  final String countLabel;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    const accentColor = TeslaColors.electricBlue;

    return InkWell(
      onTap: () {}, // Placeholder for future expansion
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TeslaTheme.spacingMd,
          vertical: TeslaTheme.spacingSm,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: TeslaTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    speciesName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    countLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            PremiumIconButton(
              icon: Icons.edit,
              onPressed: onRename,
              size: 44,
              color: accentColor,
            ),
            PremiumIconButton(
              icon: Icons.delete,
              onPressed: onDelete,
              size: 44,
              color: TeslaColors.electricBlue,
            ),
          ],
        ),
      ),
    );
  }
}
