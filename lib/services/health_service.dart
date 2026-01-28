import 'package:health/health.dart';
import '../core/models/health_data_type.dart';
import '../core/models/health_metric.dart';
import '../core/utils/date_utils.dart';

class HealthService {
  final Health _health = Health();
  bool _permissionsChecked = false;
  bool _hasPermissions = false;

  // Track which data types are enabled
  final Map<HealthDataCategory, bool> _enabledTypes = {
    HealthDataCategory.steps: true,
    HealthDataCategory.heartRate: true,
    HealthDataCategory.calories: true,
    HealthDataCategory.sleep: true,
  };

  Map<HealthDataCategory, bool> get enabledTypes =>
      Map.unmodifiable(_enabledTypes);

  bool get isUsingDemoData => false; // Never use demo data

  void toggleDataType(HealthDataCategory category, bool enabled) {
    _enabledTypes[category] = enabled;
  }

  /// Check permissions on first use
  Future<void> _checkPermissionsIfNeeded() async {
    if (_permissionsChecked) return;

    _permissionsChecked = true;
    _hasPermissions = await hasPermissions();
  }

  /// Request permissions for all enabled health data types
  Future<bool> requestPermissions() async {
    final types = _getEnabledHealthDataTypes();

    print('🔐 Requesting permissions for ${types.length} health data types');
    print('📋 Types: ${types.map((t) => t.name).join(", ")}');

    if (types.isEmpty) {
      print('❌ No health data types enabled');
      return false;
    }

    final permissions = types.map((type) => HealthDataAccess.READ).toList();

    try {
      final granted = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );

      print('✅ Permission request result: $granted');

      if (granted == true) {
        _hasPermissions = true;
        _permissionsChecked = true;
        print('✅ Permissions granted successfully');
        return true;
      }

      print('❌ Permissions denied');
      return false;
    } catch (e) {
      print('❌ Error requesting permissions: $e');
      return false;
    }
  }

  /// Check if permissions are granted
  Future<bool> hasPermissions() async {
    final types = _getEnabledHealthDataTypes();

    if (types.isEmpty) {
      print('❌ No health data types to check');
      return false;
    }

    try {
      final granted = await _health.hasPermissions(types);
      print('🔍 Has permissions check: $granted');
      return granted ?? false;
    } catch (e) {
      print('❌ Error checking permissions: $e');
      return false;
    }
  }

  /// Fetch health data for the last 7 days
  Future<List<DailyHealthSummary>> fetchLast7Days() async {
    await _checkPermissionsIfNeeded();

    final days = AppDateUtils.getLast7Days();
    final summaries = <DailyHealthSummary>[];

    for (final day in days) {
      final summary = await fetchDailySummary(day);
      summaries.add(summary);
    }

    return summaries;
  }

  /// Fetch health data for a specific day
  Future<DailyHealthSummary> fetchDailySummary(DateTime date) async {
    await _checkPermissionsIfNeeded();

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    int steps = 0;
    double? heartRate;
    double? calories;
    double? sleepHours;

    try {
      // Fetch steps
      if (_enabledTypes[HealthDataCategory.steps] == true) {
        steps = await _fetchSteps(startOfDay, endOfDay);
      }

      // Fetch heart rate (average)
      if (_enabledTypes[HealthDataCategory.heartRate] == true) {
        heartRate = await _fetchAverageHeartRate(startOfDay, endOfDay);
      }

      // Fetch calories
      if (_enabledTypes[HealthDataCategory.calories] == true) {
        calories = await _fetchCalories(startOfDay, endOfDay);
      }

      // Fetch sleep
      if (_enabledTypes[HealthDataCategory.sleep] == true) {
        sleepHours = await _fetchSleepHours(startOfDay, endOfDay);
      }
    } catch (e) {
      // Silently handle errors - will return zeros
    }

    return DailyHealthSummary(
      date: date,
      steps: steps,
      heartRate: heartRate,
      calories: calories,
      sleepHours: sleepHours,
    );
  }

  /// Fetch weekly metrics for a specific data type
  Future<List<HealthMetric>> fetchWeeklyMetrics(
    HealthDataCategory category,
  ) async {
    await _checkPermissionsIfNeeded();

    final days = AppDateUtils.getLast7Days();
    final metrics = <HealthMetric>[];

    for (final day in days) {
      final startOfDay = DateTime(day.year, day.month, day.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      double value = 0;
      String unit = '';

      try {
        switch (category) {
          case HealthDataCategory.steps:
            value = (await _fetchSteps(startOfDay, endOfDay)).toDouble();
            unit = 'steps';
            break;
          case HealthDataCategory.heartRate:
            value = await _fetchAverageHeartRate(startOfDay, endOfDay) ?? 0;
            unit = 'bpm';
            break;
          case HealthDataCategory.calories:
            value = await _fetchCalories(startOfDay, endOfDay) ?? 0;
            unit = 'kcal';
            break;
          case HealthDataCategory.sleep:
            value = await _fetchSleepHours(startOfDay, endOfDay) ?? 0;
            unit = 'hours';
            break;
        }
      } catch (e) {
        // Silently handle errors - will use 0
      }

      metrics.add(HealthMetric(date: day, value: value, unit: unit));
    }

    return metrics;
  }

  // Private helper methods

  List<HealthDataType> _getEnabledHealthDataTypes() {
    return _enabledTypes.entries
        .where((entry) => entry.value)
        .map((entry) => HealthDataTypeInfo.fromCategory(entry.key).type)
        .toList();
  }

  Future<int> _fetchSteps(DateTime start, DateTime end) async {
    try {
      print('📊 Fetching steps from $start to $end');
      final dataPoints = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: start,
        endTime: end,
      );

      print('📊 Received ${dataPoints.length} step data points');

      if (dataPoints.isEmpty) {
        print('⚠️ No step data found');
        return 0;
      }

      final total = dataPoints
          .map(
            (point) => (point.value as NumericHealthValue).numericValue.toInt(),
          )
          .reduce((a, b) => a + b);

      print('✅ Total steps: $total');
      return total;
    } catch (e) {
      print('❌ Error fetching steps: $e');
      return 0;
    }
  }

  Future<double?> _fetchAverageHeartRate(DateTime start, DateTime end) async {
    try {
      print('💓 Fetching heart rate from $start to $end');
      final dataPoints = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: start,
        endTime: end,
      );

      print('💓 Received ${dataPoints.length} heart rate data points');

      if (dataPoints.isEmpty) {
        print('⚠️ No heart rate data found');
        return null;
      }

      final values = dataPoints
          .map((point) => (point.value as NumericHealthValue).numericValue)
          .toList();

      final avg = values.reduce((a, b) => a + b) / values.length;
      print('✅ Average heart rate: $avg');
      return avg;
    } catch (e) {
      print('❌ Error fetching heart rate: $e');
      return null;
    }
  }

  Future<double?> _fetchCalories(DateTime start, DateTime end) async {
    try {
      print('🔥 Fetching calories from $start to $end');
      final dataPoints = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: start,
        endTime: end,
      );

      print('🔥 Received ${dataPoints.length} calorie data points');

      if (dataPoints.isEmpty) {
        print('⚠️ No calorie data found');
        return null;
      }

      final total = dataPoints
          .map((point) => (point.value as NumericHealthValue).numericValue)
          .reduce((a, b) => a + b)
          .toDouble();

      print('✅ Total calories: $total');
      return total;
    } catch (e) {
      print('❌ Error fetching calories: $e');
      return null;
    }
  }

  Future<double?> _fetchSleepHours(DateTime start, DateTime end) async {
    try {
      print('😴 Fetching sleep from $start to $end');
      final dataPoints = await _health.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_ASLEEP],
        startTime: start,
        endTime: end,
      );

      print('😴 Received ${dataPoints.length} sleep data points');

      if (dataPoints.isEmpty) {
        print('⚠️ No sleep data found');
        return null;
      }

      // Sum up sleep duration in minutes and convert to hours
      final totalMinutes = dataPoints
          .map((point) => (point.value as NumericHealthValue).numericValue)
          .reduce((a, b) => a + b);

      final hours = totalMinutes / 60;
      print('✅ Total sleep hours: $hours');
      return hours;
    } catch (e) {
      print('❌ Error fetching sleep: $e');
      return null;
    }
  }
}
