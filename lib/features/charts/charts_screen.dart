import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/health_service.dart';
import '../../core/models/health_data_type.dart';
import '../../core/models/health_metric.dart';
import '../../core/utils/date_utils.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  final HealthService _healthService = HealthService();
  HealthDataCategory _selectedCategory = HealthDataCategory.steps;
  List<HealthMetric>? _metrics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoading = true);

    try {
      final metrics = await _healthService.fetchWeeklyMetrics(
        _selectedCategory,
      );
      setState(() {
        _metrics = metrics;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading metrics: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onCategoryChanged(HealthDataCategory category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadMetrics();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.medium(title: const Text('Weekly Trends')),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Category selector
              _buildCategorySelector(),

              const SizedBox(height: 24),

              // Chart
              if (_isLoading)
                const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_metrics != null && _metrics!.isNotEmpty)
                _buildChart()
              else
                SizedBox(
                  height: 300,
                  child: Card(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.health_and_safety_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No health data available',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Install Health Connect and a health app to start tracking',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Stats summary
              if (_metrics != null && _metrics!.isNotEmpty) _buildStats(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: HealthDataTypeInfo.all.map((info) {
          final isSelected = info.category == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    info.icon,
                    size: 18,
                    color: isSelected ? info.color : null,
                  ),
                  const SizedBox(width: 8),
                  Text(info.title),
                ],
              ),
              onSelected: (_) => _onCategoryChanged(info.category),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart() {
    final info = HealthDataTypeInfo.fromCategory(_selectedCategory);
    final maxValue = _metrics!
        .map((m) => m.value)
        .reduce((a, b) => a > b ? a : b);
    final minValue = _metrics!
        .map((m) => m.value)
        .reduce((a, b) => a < b ? a : b);

    // Handle case when all values are zero or same
    final valueRange = maxValue - minValue;
    final interval = valueRange > 0 ? valueRange / 4 : 1.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${info.title} - Last 7 Days',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatAxisValue(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < _metrics!.length) {
                            final date = _metrics![value.toInt()].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                AppDateUtils.formatDate(date).substring(4),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _metrics!
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                          .toList(),
                      isCurved: true,
                      color: info.color,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: info.color,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: info.color.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  minY: minValue > 0 ? minValue * 0.8 : 0,
                  maxY: maxValue > 0 ? maxValue * 1.2 : 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    final info = HealthDataTypeInfo.fromCategory(_selectedCategory);
    final values = _metrics!.map((m) => m.value).toList();
    final total = values.reduce((a, b) => a + b);
    final average = total / values.length;
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Average',
                    value: _formatValue(average),
                    unit: info.unit,
                    color: info.color,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Max',
                    value: _formatValue(max),
                    unit: info.unit,
                    color: info.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Min',
                    value: _formatValue(min),
                    unit: info.unit,
                    color: info.color,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Total',
                    value: _formatValue(total),
                    unit: info.unit,
                    color: info.color,
                  ),
                ),
              ],
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

  String _formatAxisValue(double val) {
    if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(0)}k';
    }
    return val.toStringAsFixed(0);
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(unit, style: theme.textTheme.bodySmall),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
