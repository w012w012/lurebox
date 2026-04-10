import 'package:flutter/material.dart';
import '../../../core/design/theme/app_colors.dart';
import '../../../core/design/theme/app_theme.dart';
import '../../../core/models/fish_catch.dart';
import '../common/premium_card.dart';
import '../common/premium_button.dart';
import '../common/image_cache_helper.dart';

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

/// 待识别队列 Widget
///
/// 显示待识别鱼获列表，支持单条AI识别、手动识别、批量识别功能
class PendingQueueWidget extends StatelessWidget {
  final List<FishCatch> pendingCatches;
  final Map<int, SingleRecognitionState> recognitionStates;
  final bool isBatchRecognizing;
  final int batchProgress;
  final int batchTotal;
  final int batchSuccess;
  final int batchFailed;
  final Function(FishCatch) onRecognize;
  final Function(FishCatch) onManualIdentify;
  final Function(FishCatch, AiRecognitionOption) onConfirmOption;
  final VoidCallback onBatchRecognize;

  const PendingQueueWidget({
    super.key,
    required this.pendingCatches,
    required this.recognitionStates,
    required this.isBatchRecognizing,
    required this.batchProgress,
    required this.batchTotal,
    required this.batchSuccess,
    required this.batchFailed,
    required this.onRecognize,
    required this.onManualIdentify,
    required this.onConfirmOption,
    required this.onBatchRecognize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list_alt, size: 20, color: accentColor),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              '待识别列表',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
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
        const SizedBox(height: AppTheme.spacingMd),
        if (pendingCatches.isEmpty)
          PremiumCard(
            variant: PremiumCardVariant.flat,
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 48,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
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
          ...pendingCatches
              .take(10)
              .map((fish) => _buildPendingItem(context, fish)),
          if (pendingCatches.length > 10)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
              child: Text(
                '... 还有 ${pendingCatches.length - 10} 条',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          const SizedBox(height: AppTheme.spacingMd),
          _buildBatchRecognizeButton(context, pendingCatches),
        ],
      ],
    );
  }

  Widget _buildPendingItem(BuildContext context, FishCatch fish) {
    final recState =
        recognitionStates[fish.id] ?? const SingleRecognitionState();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: PremiumCard(
        variant: PremiumCardVariant.flat,
        onTap: () => _showPendingItemActions(fish),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
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
                        child: Icon(
                          Icons.image,
                          size: 24,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
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
                PremiumButton(
                  text: 'AI识别',
                  onPressed:
                      recState.isRecognizing ? null : () => onRecognize(fish),
                  variant: PremiumButtonVariant.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                PremiumButton(
                  text: '手动',
                  onPressed: () => onManualIdentify(fish),
                  variant: PremiumButtonVariant.outline,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm,
                  ),
                ),
              ],
            ),
            // 识别中进度条
            if (recState.isRecognizing) ...[
              const SizedBox(height: AppTheme.spacingMd),
              LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                '正在识别中...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            // 识别结果选项
            if (recState.options.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingMd),
              ...recState.options.map(
                (option) => _buildRecognitionOption(context, fish, option),
              ),
            ],
            // 错误信息
            if (recState.error != null) ...[
              const SizedBox(height: AppTheme.spacingSm),
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

  void _showPendingItemActions(FishCatch fish) {
    // Placeholder for future expansion
  }

  Widget _buildRecognitionOption(
      BuildContext context, FishCatch fish, AiRecognitionOption option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: InkWell(
        onTap: () => onConfirmOption(fish, option),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(option.confidence)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
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

  Widget _buildBatchRecognizeButton(
      BuildContext context, List<FishCatch> pendingCatches) {
    if (isBatchRecognizing) {
      return PremiumCard(
        variant: PremiumCardVariant.flat,
        child: Column(
          children: [
            LinearProgressIndicator(
              value: batchTotal > 0 ? batchProgress / batchTotal : 0,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              '识别中: $batchProgress/$batchTotal (成功: $batchSuccess, 失败: $batchFailed)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return PremiumButton(
      text: '批量AI识别',
      icon: Icons.auto_awesome,
      onPressed: pendingCatches.isEmpty ? null : onBatchRecognize,
      variant: PremiumButtonVariant.primary,
      isFullWidth: true,
    );
  }
}
