import 'package:health_app/core/constants/health_constants.dart';

/// Calculation utilities for health metrics
class CalculationUtils {
  CalculationUtils._();

  /// Calculate 7-day moving average
  /// Returns null if insufficient data (< 7 entries)
  /// Returns average rounded to 1 decimal place
  static double? calculate7DayMovingAverage(List<double> values) {
    if (values.length < HealthConstants.movingAverageDays) {
      return null; // Insufficient data
    }

    final sum = values.fold(0.0, (a, b) => a + b);
    final average = sum / values.length;
    return double.parse(average.toStringAsFixed(1));
  }

  /// Calculate percentage of a value relative to total
  static double calculatePercentage(double value, double total) {
    if (total == 0) {
      return 0.0;
    }
    return (value / total) * 100.0;
  }

  /// Calculate calories from protein (4 cal/g)
  static double caloriesFromProtein(double grams) {
    return grams * HealthConstants.caloriesPerGramProtein;
  }

  /// Calculate calories from carbohydrates (4 cal/g)
  static double caloriesFromCarbs(double grams) {
    return grams * HealthConstants.caloriesPerGramCarbs;
  }

  /// Calculate calories from fat (9 cal/g)
  static double caloriesFromFat(double grams) {
    return grams * HealthConstants.caloriesPerGramFat;
  }

  /// Calculate total calories from macros
  static double totalCaloriesFromMacros({
    required double proteinGrams,
    required double carbsGrams,
    required double fatGrams,
  }) {
    return caloriesFromProtein(proteinGrams) +
        caloriesFromCarbs(carbsGrams) +
        caloriesFromFat(fatGrams);
  }

  /// Calculate protein percentage of total calories
  static double proteinPercentageOfCalories(
    double proteinGrams,
    double totalCalories,
  ) {
    if (totalCalories == 0) {
      return 0.0;
    }
    return calculatePercentage(
      caloriesFromProtein(proteinGrams),
      totalCalories,
    );
  }

  /// Calculate carbs percentage of total calories
  static double carbsPercentageOfCalories(
    double carbsGrams,
    double totalCalories,
  ) {
    if (totalCalories == 0) {
      return 0.0;
    }
    return calculatePercentage(
      caloriesFromCarbs(carbsGrams),
      totalCalories,
    );
  }

  /// Calculate fat percentage of total calories
  static double fatPercentageOfCalories(
    double fatGrams,
    double totalCalories,
  ) {
    if (totalCalories == 0) {
      return 0.0;
    }
    return calculatePercentage(
      caloriesFromFat(fatGrams),
      totalCalories,
    );
  }

  /// Calculate weight change (kg)
  static double? calculateWeightChange(double? currentWeight, double? previousWeight) {
    if (currentWeight == null || previousWeight == null) {
      return null;
    }
    return currentWeight - previousWeight;
  }

  /// Calculate weight change percentage
  static double? calculateWeightChangePercentage(
    double? currentWeight,
    double? previousWeight,
  ) {
    if (currentWeight == null || previousWeight == null || previousWeight == 0) {
      return null;
    }
    return ((currentWeight - previousWeight) / previousWeight) * 100.0;
  }

  /// Calculate weekly weight loss rate (kg per week)
  static double? calculateWeeklyWeightLossRate(
    double? currentWeight,
    double? previousWeight,
    int daysBetween,
  ) {
    if (currentWeight == null || previousWeight == null || daysBetween <= 0) {
      return null;
    }
    final weightChange = currentWeight - previousWeight;
    final weeklyRate = (weightChange / daysBetween) * 7;
    return double.parse(weeklyRate.toStringAsFixed(2));
  }

  /// Calculate BMI (Body Mass Index)
  static double? calculateBMI(double? weightKg, double? heightCm) {
    if (weightKg == null || heightCm == null || heightCm == 0) {
      return null;
    }
    final heightM = heightCm / 100.0;
    final bmi = weightKg / (heightM * heightM);
    return double.parse(bmi.toStringAsFixed(1));
  }

  /// Calculate average of a list of values
  static double? calculateAverage(List<double> values) {
    if (values.isEmpty) {
      return null;
    }
    final sum = values.fold(0.0, (a, b) => a + b);
    return sum / values.length;
  }

  /// Calculate minimum value in a list
  static double? calculateMin(List<double> values) {
    if (values.isEmpty) {
      return null;
    }
    return values.reduce((a, b) => a < b ? a : b);
  }

  /// Calculate maximum value in a list
  static double? calculateMax(List<double> values) {
    if (values.isEmpty) {
      return null;
    }
    return values.reduce((a, b) => a > b ? a : b);
  }

  /// Check if values are within tolerance (for plateau detection)
  static bool areValuesWithinTolerance(
    List<double> values,
    double tolerance,
  ) {
    if (values.isEmpty) {
      return false;
    }
    final min = calculateMin(values)!;
    final max = calculateMax(values)!;
    return (max - min) <= tolerance;
  }
}

