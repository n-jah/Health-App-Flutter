import 'package:flutter/material.dart';
import 'package:health/health.dart';

enum HealthDataCategory { steps, heartRate, calories, sleep }

class HealthDataTypeInfo {
  final HealthDataCategory category;
  final HealthDataType type;
  final String title;
  final String unit;
  final IconData icon;
  final Color color;

  const HealthDataTypeInfo({
    required this.category,
    required this.type,
    required this.title,
    required this.unit,
    required this.icon,
    required this.color,
  });

  static const steps = HealthDataTypeInfo(
    category: HealthDataCategory.steps,
    type: HealthDataType.STEPS,
    title: 'Steps',
    unit: 'steps',
    icon: Icons.directions_walk,
    color: Color(0xFF3B82F6),
  );

  static const heartRate = HealthDataTypeInfo(
    category: HealthDataCategory.heartRate,
    type: HealthDataType.HEART_RATE,
    title: 'Heart Rate',
    unit: 'bpm',
    icon: Icons.favorite,
    color: Color(0xFFEF4444),
  );

  static const calories = HealthDataTypeInfo(
    category: HealthDataCategory.calories,
    type: HealthDataType.ACTIVE_ENERGY_BURNED,
    title: 'Calories',
    unit: 'kcal',
    icon: Icons.local_fire_department,
    color: Color(0xFFF59E0B),
  );

  static const sleep = HealthDataTypeInfo(
    category: HealthDataCategory.sleep,
    type: HealthDataType.SLEEP_ASLEEP,
    title: 'Sleep',
    unit: 'hours',
    icon: Icons.bedtime,
    color: Color(0xFF8B5CF6),
  );

  static List<HealthDataTypeInfo> get all => [
    steps,
    heartRate,
    calories,
    sleep,
  ];

  static HealthDataTypeInfo fromCategory(HealthDataCategory category) {
    return all.firstWhere((info) => info.category == category);
  }
}
