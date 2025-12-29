import 'package:health_app/core/constants/health_constants.dart';

/// Input validation utilities
class ValidationUtils {
  ValidationUtils._();

  /// Validate weight in kilograms
  /// Returns null if valid, error message if invalid
  static String? validateWeightKg(double? weight) {
    if (weight == null) {
      return 'Weight is required';
    }
    if (weight < HealthConstants.minWeightKg) {
      return 'Weight must be at least ${HealthConstants.minWeightKg} kg';
    }
    if (weight > HealthConstants.maxWeightKg) {
      return 'Weight must not exceed ${HealthConstants.maxWeightKg} kg';
    }
    return null;
  }

  /// Validate weight in pounds
  /// Returns null if valid, error message if invalid
  static String? validateWeightLbs(double? weight) {
    if (weight == null) {
      return 'Weight is required';
    }
    if (weight < HealthConstants.minWeightLbs) {
      return 'Weight must be at least ${HealthConstants.minWeightLbs} lbs';
    }
    if (weight > HealthConstants.maxWeightLbs) {
      return 'Weight must not exceed ${HealthConstants.maxWeightLbs} lbs';
    }
    return null;
  }

  /// Validate height in centimeters
  /// Returns null if valid, error message if invalid
  static String? validateHeightCm(double? height) {
    if (height == null) {
      return 'Height is required';
    }
    if (height < HealthConstants.minHeightCm) {
      return 'Height must be at least ${HealthConstants.minHeightCm} cm';
    }
    if (height > HealthConstants.maxHeightCm) {
      return 'Height must not exceed ${HealthConstants.maxHeightCm} cm';
    }
    return null;
  }

  /// Validate height in inches
  /// Returns null if valid, error message if invalid
  static String? validateHeightInches(double? height) {
    if (height == null) {
      return 'Height is required';
    }
    if (height < HealthConstants.minHeightInches) {
      return 'Height must be at least ${HealthConstants.minHeightInches} inches';
    }
    if (height > HealthConstants.maxHeightInches) {
      return 'Height must not exceed ${HealthConstants.maxHeightInches} inches';
    }
    return null;
  }

  /// Validate resting heart rate
  /// Returns null if valid, error message if invalid
  static String? validateRestingHeartRate(int? heartRate) {
    if (heartRate == null) {
      return 'Resting heart rate is required';
    }
    if (heartRate < HealthConstants.minRestingHeartRate) {
      return 'Resting heart rate must be at least ${HealthConstants.minRestingHeartRate} BPM';
    }
    if (heartRate > HealthConstants.maxRestingHeartRate) {
      return 'Resting heart rate must not exceed ${HealthConstants.maxRestingHeartRate} BPM';
    }
    return null;
  }

  /// Validate sleep quality (0-10)
  /// Returns null if valid, error message if invalid
  static String? validateSleepQuality(int? quality) {
    if (quality == null) {
      return 'Sleep quality is required';
    }
    if (quality < HealthConstants.minSleepQuality) {
      return 'Sleep quality must be at least ${HealthConstants.minSleepQuality}';
    }
    if (quality > HealthConstants.maxSleepQuality) {
      return 'Sleep quality must not exceed ${HealthConstants.maxSleepQuality}';
    }
    return null;
  }

  /// Validate daily calories
  /// Returns null if valid, error message if invalid
  static String? validateDailyCalories(int? calories) {
    if (calories == null) {
      return 'Calories are required';
    }
    if (calories < HealthConstants.minDailyCalories) {
      return 'Daily calories must be at least ${HealthConstants.minDailyCalories}';
    }
    if (calories > HealthConstants.maxDailyCalories) {
      return 'Daily calories must not exceed ${HealthConstants.maxDailyCalories}';
    }
    return null;
  }

  /// Validate macro percentage (0-100)
  /// Returns null if valid, error message if invalid
  static String? validateMacroPercentage(double? percentage) {
    if (percentage == null) {
      return 'Percentage is required';
    }
    if (percentage < HealthConstants.minProteinPercentage) {
      return 'Percentage must be at least ${HealthConstants.minProteinPercentage}%';
    }
    if (percentage > HealthConstants.maxProteinPercentage) {
      return 'Percentage must not exceed ${HealthConstants.maxProteinPercentage}%';
    }
    return null;
  }

  /// Validate that macro percentages sum to approximately 100%
  /// Returns null if valid, error message if invalid
  static String? validateMacroPercentagesSum(
    double protein,
    double carbs,
    double fat,
  ) {
    final sum = protein + carbs + fat;
    const tolerance = 5.0; // Allow 5% tolerance
    if ((sum - 100.0).abs() > tolerance) {
      return 'Macro percentages must sum to approximately 100% (current: ${sum.toStringAsFixed(1)}%)';
    }
    return null;
  }

  /// Validate that a value is not null
  static String? validateNotNull<T>(T? value, String fieldName) {
    if (value == null) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate that a string is not empty
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate that a string length is within range
  static String? validateStringLength(
    String? value,
    String fieldName,
    int minLength,
    int maxLength,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    if (value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    return null;
  }
}

