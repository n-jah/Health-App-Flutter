import 'package:intl/intl.dart';

class AppDateUtils {
  static DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime get yesterday {
    return today.subtract(const Duration(days: 1));
  }

  static DateTime daysAgo(int days) {
    return today.subtract(Duration(days: days));
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  static String formatDateFull(DateTime date) {
    return DateFormat('EEEE, MMM dd').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static List<DateTime> getLast7Days() {
    return List.generate(7, (index) => daysAgo(6 - index));
  }
}
