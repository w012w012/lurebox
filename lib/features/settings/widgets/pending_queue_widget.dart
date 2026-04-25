import 'package:flutter/material.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';
import 'package:lurebox/core/models/fish_catch.dart';
import 'package:lurebox/widgets/common/image_cache_helper.dart';
import 'package:lurebox/widgets/common/premium_button.dart';
import 'package:lurebox/widgets/common/premium_card.dart';

/// AI 识别结果选项
class AiRecognitionOption {

  const AiRecognitionOption({
    required this.speciesName,
    required this.confidence,
    required this.providerName,
  });
  final String speciesName;
  final double confidence;
  final String providerName;
}

/// 单条识别状态
class SingleRecognitionState {

  const SingleRecognitionState({
    this.isRecognizing = false,
    this.options = const [],
    this.error,
  });
  final bool isRecognizing;
  final List<AiRecognitionOption> options;
  final String? error;

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

  const PendingQueueWidget({
    required this.pendingCatches, required this.recognitionStates, required this.isBatchRecognizing, required this.batchProgress, required this.batchTotal, required this.batchSuccess, required this.batchFailed, required this.onRecognize, required this.onManualIdentify, required this.onConfirmOption, required this.onBatchRecognize, required this.strings, super.key,
  });
  final List<FishCatch> pendingCatches;
  final Map<int, SingleRecognitionState> recognitionStates;
  final bool isBatchRecognizing;
  final int batchProgress;
  final int batchTotal;
  final int batchSuccess;
  final int batchFailed;
  final void Function(FishCatch) onRecognize;
  final void Function(FishCatch) onManualIdentify;
  final void Function(FishCatch, AiRecognitionOption) onConfirmOption;
  final VoidCallback onBatchRecognize;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    const accentColor = TeslaColors.electricBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list_alt, size: 20, color: accentColor),
            const SizedBox(width: TeslaTheme.spacingSm),
            Text(
              strings.pendingRecognitionList,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: TeslaTheme.spacingSm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: TeslaTheme.spacingSm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: TeslaColors.electricBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
              ),
              child: Text(
                '${pendingCatches.length}条',
                style: const TextStyle(
                  fontSize: 12,
                  color: TeslaColors.electricBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: TeslaTheme.spacingMd),
        if (pendingCatches.isEmpty)
          PremiumCard(
            variant: PremiumCardVariant.flat,
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 48,
                    color: TeslaColors.electricBlue,
                  ),
                  const SizedBox(height: TeslaTheme.spacingSm),
                  Text(
                    strings.pendingNoFish,
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
              padding: const EdgeInsets.symmetric(
                vertical: TeslaTheme.spacingSm,
              ),
              child: Text(
                '... 还有 ${pendingCatches.length - 10} 条',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          const SizedBox(height: TeslaTheme.spacingMd),
          _buildBatchRecognizeButton(context, pendingCatches),
        ],
      ],
    );
  }

  Widget _buildPendingItem(BuildContext context, FishCatch fish) {
    final recState =
        recognitionStates[fish.id] ?? const SingleRecognitionState();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accentColor = TeslaColors.electricBlue;

    return Padding(
      padding: const EdgeInsets.only(bottom: TeslaTheme.spacingSm),
      child: PremiumCard(
        variant: PremiumCardVariant.flat,
        onTap: () => _showPendingItemActions(fish),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Image(
                      image: ImageCacheHelper.getCachedThumbnailProvider(
                        fish.imagePath,
                        width: 100,
                      ),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => ColoredBox(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: Icon(
                          Icons.image,
                          size: 24,
                          color: isDark
                              ? const Color(0xFF9A9A9A)
                              : TeslaColors.graphite,
                        ),
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
                  text: strings.pendingAiRecognition,
                  onPressed:
                      recState.isRecognizing ? null : () => onRecognize(fish),
                  padding: const EdgeInsets.symmetric(
                    horizontal: TeslaTheme.spacingMd,
                    vertical: TeslaTheme.spacingSm,
                  ),
                ),
                const SizedBox(width: TeslaTheme.spacingSm),
                PremiumButton(
                  text: strings.pendingManual,
                  onPressed: () => onManualIdentify(fish),
                  variant: PremiumButtonVariant.outline,
                  padding: const EdgeInsets.symmetric(
                    horizontal: TeslaTheme.spacingMd,
                    vertical: TeslaTheme.spacingSm,
                  ),
                ),
              ],
            ),
            // 识别中进度条
            if (recState.isRecognizing) ...[
              const SizedBox(height: TeslaTheme.spacingMd),
              LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
              const SizedBox(height: TeslaTheme.spacingMicro),
              Text(
                strings.pendingRecognizing,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            // 识别结果选项
            if (recState.options.isNotEmpty) ...[
              const SizedBox(height: TeslaTheme.spacingMd),
              ...recState.options.map(
                (option) => _buildRecognitionOption(context, fish, option),
              ),
            ],
            // 错误信息
            if (recState.error != null) ...[
              const SizedBox(height: TeslaTheme.spacingSm),
              Text(
                recState.error!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: TeslaColors.electricBlue,
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
      BuildContext context, FishCatch fish, AiRecognitionOption option,) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TeslaTheme.spacingSm),
      child: InkWell(
        onTap: () => onConfirmOption(fish, option),
        borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TeslaTheme.spacingMd,
            vertical: TeslaTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
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
                  horizontal: TeslaTheme.spacingSm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(option.confidence)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(TeslaTheme.radiusMicro),
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
    if (confidence >= 0.6) return TeslaColors.electricBlue;
    if (confidence >= 0.3) return TeslaColors.electricBlue;
    return TeslaColors.electricBlue;
  }

  Widget _buildBatchRecognizeButton(
      BuildContext context, List<FishCatch> pendingCatches,) {
    if (isBatchRecognizing) {
      return PremiumCard(
        variant: PremiumCardVariant.flat,
        child: Column(
          children: [
            LinearProgressIndicator(
              value: batchTotal > 0 ? batchProgress / batchTotal : 0,
            ),
            const SizedBox(height: TeslaTheme.spacingSm),
            Text(
              '识别中: $batchProgress/$batchTotal (成功: $batchSuccess, 失败: $batchFailed)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return PremiumButton(
      text: strings.pendingBatchRecognition,
      icon: Icons.auto_awesome,
      onPressed: pendingCatches.isEmpty ? null : onBatchRecognize,
      isFullWidth: true,
    );
  }
}
