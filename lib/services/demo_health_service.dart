import 'dart:math';
import '../core/models/health_metric.dart';
import '../core/utils/date_utils.dart';

class DemoHealthService {
  final Random _random = Random();

  /// Generate demo daily summary
  DailyHealthSummary generateDemoDailySummary(DateTime date) {
    // Generate realistic demo data
    final steps = 3000 + _random.nextInt(7000); // 3000-10000 steps
    final heartRate = 60.0 + _random.nextDouble() * 40; // 60-100 bpm
    final calories = 200.0 + _random.nextDouble() * 600; // 200-800 kcal
    final sleepHours = 6.0 + _random.nextDouble() * 3; // 6-9 hours

    return DailyHealthSummary(
      date: date,
      steps: steps,
      heartRate: heartRate,
      calories: calories,
      sleepHours: sleepHours,
    );
  }

  /// Generate demo data for last 7 days
  List<DailyHealthSummary> generateDemoLast7Days() {
    final days = AppDateUtils.getLast7Days();
    return days.map((day) => generateDemoDailySummary(day)).toList();
  }

  /// Generate demo weekly metrics
  List<HealthMetric> generateDemoWeeklyMetrics(String type) {
    final days = AppDateUtils.getLast7Days();

    return days.map((day) {
      double value;
      String unit;

      switch (type) {
        case 'steps':
          value = (3000 + _random.nextInt(7000)).toDouble();
          unit = 'steps';
          break;
        case 'heartRate':
          value = 60.0 + _random.nextDouble() * 40;
          unit = 'bpm';
          break;
        case 'calories':
          value = 200.0 + _random.nextDouble() * 600;
          unit = 'kcal';
          break;
        case 'sleep':
          value = 6.0 + _random.nextDouble() * 3;
          unit = 'hours';
          break;
        default:
          value = 0;
          unit = '';
      }

      return HealthMetric(date: day, value: value, unit: unit);
    }).toList();
  }
}
