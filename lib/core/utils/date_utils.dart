import 'package:health_app/core/constants/health_constants.dart';

/// Date manipulation and calculation utilities
class DateUtils {
  DateUtils._();

  /// Get the start of the day (00:00:00) for the given date
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get the end of the day (23:59:59) for the given date
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Get the date N days ago from the given date
  static DateTime daysAgo(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  /// Get the date N days from the given date
  static DateTime daysFrom(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  /// Check if a date is within the last N days (inclusive)
  static bool isWithinLastDays(DateTime date, DateTime reference, int days) {
    final cutoff = reference.subtract(Duration(days: days - 1));
    return !date.isBefore(cutoff) && !date.isAfter(reference);
  }

  /// Get the start date for a 7-day window ending on the given date (inclusive)
  /// Returns the date 6 days before the given date
  static DateTime get7DayWindowStart(DateTime endDate) {
    return endDate.subtract(Duration(days: HealthConstants.movingAverageDays - 1));
  }

  /// Get all dates in a 7-day window ending on the given date (inclusive)
  static List<DateTime> get7DayWindowDates(DateTime endDate) {
    final startDate = get7DayWindowStart(endDate);
    final dates = <DateTime>[];
    for (int i = 0; i < HealthConstants.movingAverageDays; i++) {
      dates.add(startDate.add(Duration(days: i)));
    }
    return dates;
  }

  /// Check if a date is within the 7-day window ending on the given date (inclusive)
  static bool isIn7DayWindow(DateTime date, DateTime endDate) {
    final startDate = get7DayWindowStart(endDate);
    return !date.isBefore(startDate) && !date.isAfter(endDate);
  }

  /// Get the start date for a plateau detection window (21 days)
  static DateTime getPlateauWindowStart(DateTime endDate) {
    return endDate.subtract(Duration(days: HealthConstants.plateauDetectionDays - 1));
  }

  /// Check if a date is within the plateau detection window (21 days)
  static bool isInPlateauWindow(DateTime date, DateTime endDate) {
    final startDate = getPlateauWindowStart(endDate);
    return !date.isBefore(startDate) && !date.isAfter(endDate);
  }

  /// Get the start of the week (Monday) for the given date
  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    final daysFromMonday = weekday == 7 ? 0 : weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysFromMonday)));
  }

  /// Get the end of the week (Sunday) for the given date
  static DateTime endOfWeek(DateTime date) {
    final weekday = date.weekday;
    final daysToSunday = weekday == 7 ? 0 : 7 - weekday;
    return endOfDay(date.add(Duration(days: daysToSunday)));
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Check if a date is yesterday
  static bool isYesterday(DateTime date) {
    return isSameDay(date, DateTime.now().subtract(Duration(days: 1)));
  }

  /// Get the number of days between two dates (inclusive)
  static int daysBetween(DateTime start, DateTime end) {
    final startDay = startOfDay(start);
    final endDay = startOfDay(end);
    return endDay.difference(startDay).inDays + 1;
  }

  /// Check if dates are consecutive (day after day)
  static bool areConsecutive(DateTime date1, DateTime date2) {
    final diff = date2.difference(date1).inDays;
    return diff == 1 || diff == -1;
  }

  /// Get the first day of the month for the given date
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get the last day of the month for the given date
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }
}

