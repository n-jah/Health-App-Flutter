import 'package:flutter/material.dart';
import '../../../core/models/health_data_type.dart';
import '../../../core/models/health_metric.dart';
import '../../../core/utils/date_utils.dart';

class WeeklySummaryCard extends StatelessWidget {
  final HealthDataTypeInfo info;
  final List<DailyHealthSummary> summaries;
  final double Function(DailyHealthSummary) getValue;

  const WeeklySummaryCard({
    super.key,
    required this.info,
    required this.summaries,
    required this.getValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final values = summaries.map(getValue).toList();
    final total = values.reduce((a, b) => a + b);
    final average = total / values.length;
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: info.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(info.icon, color: info.color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        info.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Avg: ${_formatValue(average)} ${info.unit}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Mini bar chart
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  final value = values[index];
                  final height = maxValue > 0 ? (value / maxValue * 35) : 0.0;
                  final isToday = index == 6;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Container(
                              height: height.clamp(3.0, 35.0),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? info.color
                                    : info.color.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppDateUtils.formatDate(
                              summaries[index].date,
                            ).substring(4),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 8,
                              fontWeight: isToday ? FontWeight.bold : null,
                              height: 1.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatValue(double val) {
    if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(1)}k';
    }
    return val.toStringAsFixed(val % 1 == 0 ? 0 : 1);
  }
}
