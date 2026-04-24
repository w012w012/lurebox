import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/strings.dart';
import '../../../core/design/theme/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/services/share_template.dart';
import '../../../core/services/share_card_service.dart';
import '../../../widgets/common/premium_button.dart';
import 'share_card_widget.dart';

class ShareBottomSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic>? statsData;
  final VoidCallback? onShare;

  const ShareBottomSheet({super.key, this.statsData, this.onShare});

  static Future<void> show(
    BuildContext context, {
    Map<String, dynamic>? statsData,
    VoidCallback? onShare,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ShareBottomSheet(statsData: statsData, onShare: onShare),
    );
  }

  @override
  ConsumerState<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends ConsumerState<ShareBottomSheet> {
  late ShareCardConfig _config;
  final GlobalKey _previewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _config = ShareCardConfig(statsData: widget.statsData);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final strings = ref.watch(currentStringsProvider);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                strings.share,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildTemplateSelector(),
              const SizedBox(height: 24),
              _buildOptions(),
              const SizedBox(height: 24),
              _buildPreview(),
              const SizedBox(height: 24),
              _buildShareButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    final strings = ref.watch(currentStringsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.template,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Row(
          children: ShareTemplate.values.map((template) {
            final isSelected = _config.template == template;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => setState(() {
                    _config = _config.copyWith(template: template);
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      template.name[0].toUpperCase() +
                          template.name.substring(1),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurfaceVariant,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    final strings = ref.watch(currentStringsProvider);

    return Column(
      children: [
        _buildOptionSwitch(
          strings.showStats,
          _config.showStats,
          (value) => setState(() {
            _config = _config.copyWith(showStats: value);
          }),
        ),
        _buildOptionSwitch(
          strings.showHashtags,
          _config.showHashtags,
          (value) => setState(() {
            _config = _config.copyWith(showHashtags: value);
          }),
        ),
        _buildOptionSwitch(
          strings.showWatermark,
          _config.showWatermark,
          (value) => setState(() {
            _config = _config.copyWith(showWatermark: value);
          }),
        ),
      ],
    );
  }

  Widget _buildOptionSwitch(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ShareCardWidget(config: _config, repaintKey: _previewKey),
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    final strings = ref.watch(currentStringsProvider);

    return PremiumButton(
      text: strings.share,
      variant: PremiumButtonVariant.primary,
      isFullWidth: true,
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(vertical: 16),
      onPressed: _handleShare,
    );
  }

  Future<void> _handleShare() async {
    final imageBytes = await ShareCardService.generateShareCard(
      repaintBoundaryKey: _previewKey,
    );
    if (imageBytes != null) {
      final text = ShareCardService.generateShareText(_config);
      await ShareCardService.shareImage(imageBytes, text: text);
      widget.onShare?.call();
      if (mounted) Navigator.of(context).pop();
    }
  }
}
