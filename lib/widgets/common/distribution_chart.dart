import 'package:flutter/material.dart';

import '../../core/design/theme/app_colors.dart';

/// 通用分布图表组件
class DistributionChart extends StatelessWidget {
  final Map<String, int> data;
  final String title;
  final Color color;
  final int maxItems;
  final ChartType chartType;

  const DistributionChart({
    super.key,
    required this.data,
    required this.title,
    required this.color,
    this.maxItems = 6,
    this.chartType = ChartType.bar,
  });

  static const _chartColors = [
    AppColors.blue,
    AppColors.teal,
    AppColors.cyan,
    AppColors.indigo,
    AppColors.purple,
    AppColors.pink,
    AppColors.orange,
    AppColors.amber,
  ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = data.values.fold(0, (sum, v) => sum + v);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (chartType == ChartType.bar)
              _buildBarChart(sortedEntries, total, context)
            else
              _buildPieChart(sortedEntries, total, context),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(
    List<MapEntry<String, int>> entries,
    int total,
    BuildContext context,
  ) {
    final colors = [
      color,
      color.withValues(alpha: 0.8),
      color.withValues(alpha: 0.6),
      color.withValues(alpha: 0.4),
      color.withValues(alpha: 0.3),
      color.withValues(alpha: 0.2),
    ];

    return Column(
      children: entries.take(maxItems).toList().asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final percent = (item.value / total * 100).toStringAsFixed(1);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.key,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 30,
                child: Text(
                  '${item.value}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPieChart(
    List<MapEntry<String, int>> entries,
    int total,
    BuildContext context,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CustomPaint(
            painter: _PieChartPainter(
              entries: entries.take(maxItems).toList(),
              total: total,
              colors: _chartColors,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entries.take(maxItems).toList().asMap().entries.map((
              entry,
            ) {
              final item = entry.value;
              final percent = (item.value / total * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _chartColors[entry.key % _chartColors.length],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.key,
                        style: const TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

enum ChartType { bar, pie }

class _PieChartPainter extends CustomPainter {
  final List<MapEntry<String, int>> entries;
  final int total;
  final List<Color> colors;

  _PieChartPainter({
    required this.entries,
    required this.total,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    double startAngle = -90 * (3.14159265359 / 180);

    for (int i = 0; i < entries.length; i++) {
      final sweepAngle =
          (entries[i].value / total) * 360 * (3.14159265359 / 180);
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
