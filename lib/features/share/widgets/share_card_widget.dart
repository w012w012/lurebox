import 'package:flutter/material.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/services/share_template.dart';

class ShareCardWidget extends StatelessWidget {

  const ShareCardWidget({required this.config, super.key, this.repaintKey});
  final ShareCardConfig config;
  final GlobalKey? repaintKey;

  @override
  Widget build(BuildContext context) {
    final widget = Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: _getDecoration(),
      child: _buildContent(context),
    );

    if (repaintKey != null) {
      return RepaintBoundary(key: repaintKey, child: widget);
    }
    return widget;
  }

  BoxDecoration _getDecoration() {
    switch (config.template) {
      case ShareTemplate.classic:
        return BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF4A9EFF), width: 2),
        );
      case ShareTemplate.card:
        return BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF16213E), Color(0xFF1A1A2E)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A9EFF).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        );
      case ShareTemplate.minimal:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        );
    }
  }

  Widget _buildContent(BuildContext context) {
    switch (config.template) {
      case ShareTemplate.classic:
        return _buildClassicContent(context);
      case ShareTemplate.card:
        return _buildCardContent(context);
      case ShareTemplate.minimal:
        return _buildMinimalContent(context);
    }
  }

  Widget _buildClassicContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (config.showWatermark) ...[
          const Text(
            ShareCardConfig.watermark,
            style: TextStyle(
              color: Color(0xFF4A9EFF),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (config.showStats && config.statsData != null) ...[
          _buildStatsList(),
        ],
        if (config.showHashtags) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: (config.customHashtags.isNotEmpty
                    ? config.customHashtags
                    : ShareCardConfig.defaultHashtags)
                .map(
                  (tag) => Text(
                    tag,
                    style: TextStyle(
                      color: config.template == ShareTemplate.minimal
                          ? AppColors.grey600
                          : const Color(0xFF4A9EFF),
                      fontSize: 14,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (config.showWatermark)
          const Text(
            ShareCardConfig.watermark,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        if (config.showWatermark) const SizedBox(height: 24),
        Container(
          height: 2,
          width: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF4A9EFF),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        if (config.showStats && config.statsData != null) ...[
          const SizedBox(height: 24),
          _buildStatsGrid(),
        ],
        if (config.showHashtags) ...[
          const SizedBox(height: 24),
          Text(
            (config.customHashtags.isNotEmpty
                    ? config.customHashtags
                    : ShareCardConfig.defaultHashtags)
                .join('  '),
            style: const TextStyle(
              color: Color(0xFF4A9EFF),
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMinimalContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (config.showWatermark)
              const Text(
                ShareCardConfig.watermark,
                style: TextStyle(
                  color: AppColors.grey800,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (config.showHashtags)
              Text(
                (config.customHashtags.isNotEmpty
                        ? config.customHashtags
                        : ShareCardConfig.defaultHashtags)
                    .first,
                style: const TextStyle(color: AppColors.grey400, fontSize: 12),
              ),
          ],
        ),
        if (config.showStats && config.statsData != null) ...[
          const SizedBox(height: 16),
          _buildStatsRow(),
        ],
      ],
    );
  }

  Widget _buildStatsList() {
    final stats = config.statsData!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: stats.entries.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                e.key,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                e.value.toString(),
                style: const TextStyle(
                  color: Color(0xFF4A9EFF),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsGrid() {
    final stats = config.statsData!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: stats.entries.map((e) {
        return Column(
          children: [
            Text(
              e.value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              e.key,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStatsRow() {
    final stats = config.statsData!;
    return Row(
      children: stats.entries.map((e) {
        return Expanded(
          child: Column(
            children: [
              Text(
                e.value.toString(),
                style: const TextStyle(
                  color: AppColors.grey800,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                e.key,
                style: const TextStyle(color: AppColors.grey500, fontSize: 10),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
