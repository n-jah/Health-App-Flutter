import 'package:flutter/material.dart';
import '../../../core/models/health_data_type.dart';

class MetricCard extends StatelessWidget {
  final HealthDataTypeInfo info;
  final double? value;
  final double? target;
  final bool showProgress;

  const MetricCard({
    super.key,
    required this.info,
    this.value,
    this.target,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = value != null && value! > 0;
    final progress = hasValue && target != null
        ? (value! / target!).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon and title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: info.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(info.icon, color: info.color, size: 16),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    info.title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Value
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: hasValue
                    ? Text(
                        _formatValue(value!),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      )
                    : Text(
                        '--',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
              ),
            ),

            // Unit
            Text(
              info.unit,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Progress bar
            if (showProgress && target != null) ...[
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: info.color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(info.color),
                  minHeight: 3,
                ),
              ),
            ],
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
