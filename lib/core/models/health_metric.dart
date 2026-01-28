class HealthMetric {
  final DateTime date;
  final double value;
  final String unit;

  HealthMetric({required this.date, required this.value, required this.unit});
}

class DailyHealthSummary {
  final DateTime date;
  final int steps;
  final double? heartRate;
  final double? calories;
  final double? sleepHours;

  DailyHealthSummary({
    required this.date,
    this.steps = 0,
    this.heartRate,
    this.calories,
    this.sleepHours,
  });
}
