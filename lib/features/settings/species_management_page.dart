import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/strings.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/pending_recognition_providers.dart';
import '../../core/providers/ai_recognition_provider.dart';
import '../../core/di/di.dart' hide aiRecognitionSettingsProvider;
import '../../core/services/fish_recognition_service.dart';
import '../../core/models/fish_catch.dart';
import '../../widgets/common/image_cache_helper.dart';

/// AI 识别结果选项
class AiRecognitionOption {
  final String speciesName;
  final double confidence;
  final String providerName;

  const AiRecognitionOption({
    required this.speciesName,
    required this.confidence,
    required this.providerName,
  });
}

/// 单条识别状态
class SingleRecognitionState {
  final bool isRecognizing;
  final List<AiRecognitionOption> options;
  final String? error;

  const SingleRecognitionState({
    this.isRecognizing = false,
    this.options = const [],
    this.error,
  });

  SingleRecognitionState copyWith({
    bool? isRecognizing,
    List<AiRecognitionOption>? options,
    String? error,
  }) {
    return SingleRecognitionState(
      isRecognizing: isRecognizing ?? this.isRecognizing,
      options: options ?? this.options,
      error: error,
    );
  }
}

/// 物种计数 Provider
final speciesCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(fishCatchRepositoryProvider);
  return repository.getSpeciesCounts();
});

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
        title: const Text('品种管理'),
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
          error: (e, _) => Center(child: Text('加载失败: $e')),
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
      padding: const EdgeInsets.all(16),
      children: [
        _buildPendingQueue(context, pendingCatches),
        const SizedBox(height: 24),
        _buildSpeciesList(context, strings),
      ],
    );
  }

  Widget _buildPendingQueue(
    BuildContext context,
    List<FishCatch> pendingCatches,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.list_alt, size: 20),
            const SizedBox(width: 8),
            Text(
              '待识别列表',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${pendingCatches.length}条',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (pendingCatches.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 48,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '暂无待识别鱼获',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          ...pendingCatches.take(10).map((fish) => _buildPendingItem(fish)),
          if (pendingCatches.length > 10)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '... 还有 ${pendingCatches.length - 10} 条',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          const SizedBox(height: 12),
          _buildBatchRecognizeButton(pendingCatches),
        ],
      ],
    );
  }

  Widget _buildPendingItem(FishCatch fish) {
    final recState =
        _recognitionStates[fish.id] ?? const SingleRecognitionState();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Image(
                      image: ImageCacheHelper.getCachedThumbnailProvider(
                        fish.imagePath,
                        width: 100,
                      ),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: const Icon(Icons.image, size: 24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${fish.catchTime.year}-${fish.catchTime.month.toString().padLeft(2, '0')}-${fish.catchTime.day.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${fish.catchTime.hour.toString().padLeft(2, '0')}:${fish.catchTime.minute.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 64,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: recState.isRecognizing
                        ? null
                        : () => _recognizeSingle(fish),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    child: const Text(
                      'AI识别',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 64,
                  height: 32,
                  child: OutlinedButton(
                    onPressed: () => _manualIdentify(fish),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: const Text(
                      '手动',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // 识别中进度条
            if (recState.isRecognizing) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
              const SizedBox(height: 4),
              Text(
                '正在识别中...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            // 识别结果选项
            if (recState.options.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...recState.options.map(
                (option) => _buildRecognitionOption(fish, option),
              ),
            ],
            // 错误信息
            if (recState.error != null) ...[
              const SizedBox(height: 8),
              Text(
                recState.error!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecognitionOption(FishCatch fish, AiRecognitionOption option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => _showConfirmDialog(fish, option),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.speciesName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      option.providerName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      _getConfidenceColor(option.confidence).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(option.confidence * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getConfidenceColor(option.confidence),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.6) return AppColors.success;
    if (confidence >= 0.3) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildBatchRecognizeButton(List<FishCatch> pendingCatches) {
    if (_isBatchRecognizing) {
      return Column(
        children: [
          LinearProgressIndicator(
              value: _batchTotal > 0 ? _batchProgress / _batchTotal : 0),
          const SizedBox(height: 8),
          Text(
            '识别中: $_batchProgress/$_batchTotal (成功: $_batchSuccess, 失败: $_batchFailed)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }

    return ElevatedButton.icon(
      onPressed:
          pendingCatches.isEmpty ? null : () => _batchRecognize(pendingCatches),
      icon: const Icon(Icons.auto_awesome),
      label: const Text('🤖 批量AI识别'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  Widget _buildSpeciesList(BuildContext context, AppStrings strings) {
    final speciesCountsAsync = ref.watch(speciesCountsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.category, size: 20),
            const SizedBox(width: 8),
            Text(
              '已保存品种',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        speciesCountsAsync.when(
          data: (speciesCounts) {
            if (speciesCounts.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '暂无品种记录',
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

            return Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedSpecies.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final entry = sortedSpecies[index];
                  final speciesName = entry.key;
                  final count = entry.value;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(speciesName),
                    subtitle: Text('$count 条渔获记录'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () =>
                              _showRenameDialog(context, speciesName),
                          tooltip: '重命名',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              size: 20, color: AppColors.error),
                          onPressed: () =>
                              _showDeleteDialog(context, speciesName, count),
                          tooltip: '删除',
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '加载失败: $e',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _manualIdentify(FishCatch fish) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('手动识别'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('为以下鱼获指定品种：'),
            Text(
              '${fish.catchTime.year}-${fish.catchTime.month.toString().padLeft(2, '0')}-${fish.catchTime.day.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '品种名称',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
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

    if (confirmed == true && mounted) {
      final speciesName = controller.text.trim();
      if (speciesName.isNotEmpty) {
        try {
          final repository = ref.read(fishCatchRepositoryProvider);
          await repository.updateSpecies(fish.id, speciesName);
          ref.invalidate(pendingRecognitionCountProvider);
          ref.invalidate(pendingRecognitionCatchesProvider);
          setState(() {
            _recognitionStates.remove(fish.id);
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('已更新品种: $speciesName')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('更新失败: $e')),
            );
          }
        }
      }
    }
    controller.dispose();
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
          _recognitionStates[fish.id] = const SingleRecognitionState(
            error: '图片不存在',
          );
        });
        return;
      }

      final file = File(fishCatch.imagePath);
      if (!await file.exists()) {
        setState(() {
          _recognitionStates[fish.id] = const SingleRecognitionState(
            error: '图片文件不存在',
          );
        });
        return;
      }

      final settings = ref.read(aiRecognitionSettingsProvider);
      final currentConfig = settings.providerConfigs[settings.currentProvider];
      if (currentConfig == null || currentConfig.apiKey.isEmpty) {
        setState(() {
          _recognitionStates[fish.id] = const SingleRecognitionState(
            error: '请先配置 AI 识别 API Key',
          );
        });
        return;
      }

      final service = FishRecognitionService();
      final result = await service.identifySpecies(file, settings);

      // 构建多选项列表
      final options = <AiRecognitionOption>[];

      if (result.primarySpecies.chineseName.isNotEmpty) {
        options.add(AiRecognitionOption(
          speciesName: result.primarySpecies.chineseName,
          confidence: result.primarySpecies.confidence / 100.0,
          providerName: 'AI 识别结果',
        ));
      }

      // 添加备选结果
      if (result.alternatives.isNotEmpty) {
        for (final alt in result.alternatives.take(2)) {
          if (alt.chineseName.isNotEmpty) {
            options.add(AiRecognitionOption(
              speciesName: alt.chineseName,
              confidence: alt.confidence / 100.0,
              providerName: '备选',
            ));
          }
        }
      }

      // 如果没有结果
      if (options.isEmpty) {
        setState(() {
          _recognitionStates[fish.id] = const SingleRecognitionState(
            error: '未能识别出结果',
          );
        });
        return;
      }

      setState(() {
        _recognitionStates[fish.id] = SingleRecognitionState(
          isRecognizing: false,
          options: options,
        );
      });
    } catch (e) {
      setState(() {
        _recognitionStates[fish.id] = SingleRecognitionState(
          isRecognizing: false,
          error: '识别失败: $e',
        );
      });
    }
  }

  Future<void> _showConfirmDialog(
      FishCatch fish, AiRecognitionOption option) async {
    final controller = TextEditingController(text: option.speciesName);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认品种'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI 识别结果：${option.speciesName}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              '置信度：${(option.confidence * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '品种名称（可修改）',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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

    if (confirmed == true && mounted) {
      final speciesName = controller.text.trim();
      if (speciesName.isNotEmpty) {
        try {
          final repository = ref.read(fishCatchRepositoryProvider);
          await repository.updateSpecies(fish.id, speciesName);
          ref.invalidate(pendingRecognitionCountProvider);
          ref.invalidate(pendingRecognitionCatchesProvider);
          setState(() {
            _recognitionStates.remove(fish.id);
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('已更新品种: $speciesName')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('更新失败: $e')),
            );
          }
        }
      }
    }
    controller.dispose();
  }

  Future<void> _showRenameDialog(BuildContext context, String oldName) async {
    final controller = TextEditingController(text: oldName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名品种'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '新名称',
            hintText: '输入新物种名称',
            border: OutlineInputBorder(),
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

    if (result != null && context.mounted) {
      try {
        final repository = ref.read(fishCatchRepositoryProvider);
        await repository.renameSpecies(oldName, result);
        ref.invalidate(speciesCountsProvider);
        ref.invalidate(pendingRecognitionCountProvider);
        ref.invalidate(pendingRecognitionCatchesProvider);
        setState(() {});
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已将 "$oldName" 重命名为 "$result"')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('重命名失败: $e')),
        );
      }
    }
    controller.dispose();
  }

  Future<void> _showDeleteDialog(
      BuildContext context, String speciesName, int count) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text(
          '确定要删除品种 "$speciesName" 吗？\n\n这将同时删除 $count 条渔获记录，此操作不可恢复！',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final repository = ref.read(fishCatchRepositoryProvider);
        await repository.deleteSpecies(speciesName);
        ref.invalidate(speciesCountsProvider);
        ref.invalidate(pendingRecognitionCountProvider);
        ref.invalidate(pendingRecognitionCatchesProvider);
        setState(() {});
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已删除品种 "$speciesName" ($count 条记录)')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
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
                fish.id, result.primarySpecies.chineseName);
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('识别完成: $_batchSuccess 条成功, $_batchFailed 条失败'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() => _isBatchRecognizing = false);
    }
  }
}
