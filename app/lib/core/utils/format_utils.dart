import 'package:intl/intl.dart';

/// Formatting utilities for displaying data
class FormatUtils {
  FormatUtils._();

  // ============================================================================
  // Date Formatting
  // ============================================================================

  /// Format date as "MMM d, yyyy" (e.g., "Jan 15, 2024")
  static String formatDateShort(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Format date as "MMMM d, yyyy" (e.g., "January 15, 2024")
  static String formatDateLong(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  /// Format date as "MM/dd/yyyy" (e.g., "01/15/2024")
  static String formatDateNumeric(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }

  /// Format date as "EEE, MMM d" (e.g., "Mon, Jan 15")
  static String formatDateWithWeekday(DateTime date) {
    return DateFormat('EEE, MMM d').format(date);
  }

  /// Format date as relative time (e.g., "Today", "Yesterday", "3 days ago")
  static String formatDateRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 14) {
      return '1 week ago';
    } else {
      return formatDateShort(date);
    }
  }

  /// Format time as "h:mm a" (e.g., "3:45 PM")
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  /// Format date and time as "MMM d, yyyy h:mm a"
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, yyyy h:mm a').format(date);
  }

  // ============================================================================
  // Weight Formatting
  // ============================================================================

  /// Format weight in kilograms (e.g., "75.2 kg")
  static String formatWeightKg(double weight) {
    return '${weight.toStringAsFixed(1)} kg';
  }

  /// Format weight in pounds (e.g., "165.8 lbs")
  static String formatWeightLbs(double weight) {
    return '${weight.toStringAsFixed(1)} lbs';
  }

  /// Format weight change (e.g., "+2.3 kg", "-1.5 kg")
  static String formatWeightChange(double change) {
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)} kg';
  }

  /// Format weight change percentage (e.g., "+3.2%", "-2.1%")
  static String formatWeightChangePercentage(double percentage) {
    final sign = percentage >= 0 ? '+' : '';
    return '$sign${percentage.toStringAsFixed(1)}%';
  }

  // ============================================================================
  // Height Formatting
  // ============================================================================

  /// Format height in centimeters (e.g., "175 cm")
  static String formatHeightCm(double height) {
    return '${height.toStringAsFixed(0)} cm';
  }

  /// Format height in inches (e.g., "69 in")
  static String formatHeightInches(double height) {
    return '${height.toStringAsFixed(0)} in';
  }

  // ============================================================================
  // Number Formatting
  // ============================================================================

  /// Format number with specified decimal places
  static String formatNumber(double number, {int decimals = 1}) {
    return number.toStringAsFixed(decimals);
  }

  /// Format number with thousand separators (e.g., "1,234.5")
  static String formatNumberWithSeparators(double number, {int decimals = 0}) {
    final formatter = NumberFormat('#,##0.${'0' * decimals}');
    return formatter.format(number);
  }

  /// Format percentage (e.g., "45.2%")
  static String formatPercentage(double percentage, {int decimals = 1}) {
    return '${percentage.toStringAsFixed(decimals)}%';
  }

  // ============================================================================
  // Nutrition Formatting
  // ============================================================================

  /// Format calories (e.g., "2,150 cal")
  static String formatCalories(int calories) {
    return '${formatNumberWithSeparators(calories.toDouble())} cal';
  }

  /// Format grams (e.g., "150 g")
  static String formatGrams(double grams, {int decimals = 1}) {
    return '${grams.toStringAsFixed(decimals)} g';
  }

  // ============================================================================
  // Heart Rate Formatting
  // ============================================================================

  /// Format heart rate (e.g., "72 BPM")
  static String formatHeartRate(int heartRate) {
    return '$heartRate BPM';
  }

  // ============================================================================
  // Duration Formatting
  // ============================================================================

  /// Format duration in minutes (e.g., "45 min")
  static String formatDurationMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours hr';
    }
    return '$hours hr $remainingMinutes min';
  }

  /// Format duration in hours (e.g., "2.5 hr")
  static String formatDurationHours(double hours) {
    return '${hours.toStringAsFixed(1)} hr';
  }
}

