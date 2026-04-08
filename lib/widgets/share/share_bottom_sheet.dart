import 'package:flutter/material.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/services/share_template.dart';
import '../../core/services/share_card_service.dart';
import '../common/premium_button.dart';
import 'share_card_widget.dart';

class ShareBottomSheet extends StatefulWidget {
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
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  late ShareCardConfig _config;
  final GlobalKey _previewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _config = ShareCardConfig(statsData: widget.statsData);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: AppColors.borderDark.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Share',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimaryDark,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Template',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryDark),
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
                          ? AppColors.accentLight
                          : AppColors.borderDark.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accentLight
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      template.name[0].toUpperCase() +
                          template.name.substring(1),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? AppColors.surfaceLight
                                : AppColors.textSecondaryDark,
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
    return Column(
      children: [
        _buildOptionSwitch(
          'Show Stats',
          _config.showStats,
          (value) => setState(() {
            _config = _config.copyWith(showStats: value);
          }),
        ),
        _buildOptionSwitch(
          'Show Hashtags',
          _config.showHashtags,
          (value) => setState(() {
            _config = _config.copyWith(showHashtags: value);
          }),
        ),
        _buildOptionSwitch(
          'Show Watermark',
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondaryDark),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.accentLight,
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.backgroundDark.withValues(alpha: 0.3),
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
    return PremiumButton(
      text: 'Share',
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
