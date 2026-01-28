import 'package:flutter/material.dart';
import '../../services/health_service.dart';
import '../../core/models/health_metric.dart';
import '../../core/models/health_data_type.dart';
import '../../core/utils/date_utils.dart';
import '../charts/charts_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/metric_card.dart';
import 'widgets/weekly_summary_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final HealthService _healthService = HealthService();
  DailyHealthSummary? _todaySummary;
  List<DailyHealthSummary>? _weeklySummaries;
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final today = await _healthService.fetchDailySummary(AppDateUtils.today);
      final weekly = await _healthService.fetchLast7Days();

      setState(() {
        _todaySummary = today;
        _weeklySummaries = weekly;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? _buildDashboard()
          : _selectedIndex == 1
          ? const ChartsScreen()
          : const SettingsScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Charts',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('HealthTrack'),
              Text(
                AppDateUtils.formatDateFull(DateTime.now()),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          ],
        ),

        if (_isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Today's metrics
                Text(
                  'Today',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildTodayMetrics(),

                const SizedBox(height: 32),

                // Weekly summary
                Text(
                  'This Week',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildWeeklySummary(),

                const SizedBox(height: 16),
              ]),
            ),
          ),
      ],
    );
  }

  Widget _buildTodayMetrics() {
    if (_todaySummary == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.health_and_safety_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'No health data available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Grant permissions in Settings to start tracking',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Check if all data is zero
    final hasAnyData =
        _todaySummary!.steps > 0 ||
        (_todaySummary!.heartRate != null && _todaySummary!.heartRate! > 0) ||
        (_todaySummary!.calories != null && _todaySummary!.calories! > 0) ||
        (_todaySummary!.sleepHours != null && _todaySummary!.sleepHours! > 0);

    return Column(
      children: [
        if (!hasAnyData)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No health data found. Make sure Health Connect is installed and has data.',
                    style: TextStyle(color: Colors.orange[700]),
                  ),
                ),
              ],
            ),
          ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            MetricCard(
              info: HealthDataTypeInfo.steps,
              value: _todaySummary!.steps.toDouble(),
              target: 10000,
            ),
            MetricCard(
              info: HealthDataTypeInfo.heartRate,
              value: _todaySummary!.heartRate,
              showProgress: false,
            ),
            MetricCard(
              info: HealthDataTypeInfo.calories,
              value: _todaySummary!.calories,
              target: 500,
            ),
            MetricCard(
              info: HealthDataTypeInfo.sleep,
              value: _todaySummary!.sleepHours,
              target: 8,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklySummary() {
    if (_weeklySummaries == null || _weeklySummaries!.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No weekly data available')),
        ),
      );
    }

    return Column(
      children: [
        WeeklySummaryCard(
          info: HealthDataTypeInfo.steps,
          summaries: _weeklySummaries!,
          getValue: (summary) => summary.steps.toDouble(),
        ),
        const SizedBox(height: 16),
        WeeklySummaryCard(
          info: HealthDataTypeInfo.heartRate,
          summaries: _weeklySummaries!,
          getValue: (summary) => summary.heartRate ?? 0,
        ),
      ],
    );
  }
}
