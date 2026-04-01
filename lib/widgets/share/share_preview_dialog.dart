import 'package:flutter/material.dart';
import '../../core/design/theme/app_colors.dart';
import '../../core/services/share_template.dart';
import '../common/premium_button.dart';
import 'share_card_widget.dart';

class SharePreviewDialog extends StatelessWidget {
  final ShareCardConfig config;
  final VoidCallback? onShare;
  final VoidCallback? onEdit;

  const SharePreviewDialog({
    super.key,
    required this.config,
    this.onShare,
    this.onEdit,
  });

  static Future<void> show(
    BuildContext context, {
    required ShareCardConfig config,
    VoidCallback? onShare,
    VoidCallback? onEdit,
  }) {
    return showDialog(
      context: context,
      builder: (context) =>
          SharePreviewDialog(config: config, onShare: onShare, onEdit: onEdit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.accentLight.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Preview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getTemplateDescription(config.template),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.borderDark.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ShareCardWidget(config: config),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildConfigSummary(context),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (onEdit != null)
                        Expanded(
                          child: PremiumButton(
                            text: 'Edit',
                            variant: PremiumButtonVariant.outline,
                            borderRadius: 12,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            onPressed: () {
                              Navigator.of(context).pop();
                              onEdit?.call();
                            },
                          ),
                        ),
                      if (onEdit != null) const SizedBox(width: 12),
                      Expanded(
                        child: PremiumButton(
                          text: 'Share',
                          variant: PremiumButtonVariant.primary,
                          borderRadius: 12,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          onPressed: () {
                            Navigator.of(context).pop();
                            onShare?.call();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTemplateDescription(ShareTemplate template) {
    switch (template) {
      case ShareTemplate.classic:
        return 'Traditional share card with bordered design';
      case ShareTemplate.card:
        return 'Gradient card with modern styling';
      case ShareTemplate.minimal:
        return 'Clean, minimal design for subtle sharing';
    }
  }

  Widget _buildConfigSummary(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildChip(
          context,
          config.template.name[0].toUpperCase() +
              config.template.name.substring(1),
          Icons.style_outlined,
        ),
        if (config.showStats)
          _buildChip(context, 'Stats', Icons.bar_chart_outlined),
        if (config.showHashtags) _buildChip(context, 'Hashtags', Icons.tag),
        if (config.showWatermark)
          _buildChip(context, 'Watermark', Icons.water_drop_outlined),
      ],
    );
  }

  Widget _buildChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentLight.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accentLight),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.accentLight,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
