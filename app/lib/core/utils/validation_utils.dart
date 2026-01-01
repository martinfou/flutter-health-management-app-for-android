// Dart SDK
import 'dart:core';

// Project
import 'package:health_app/core/constants/health_constants.dart';

/// General validation utilities for health metrics
class ValidationUtils {
  ValidationUtils._();

  /// Validate weight in kilograms
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
  static String? validateWeightLbs(double? weight) {
    if (weight == null) {
      return 'Weight is required';
    }
    // Convert to kg for validation
    final weightKg = weight / 2.20462;
    return validateWeightKg(weightKg);
  }

  /// Validate height in centimeters
  static String? validateHeightCm(double? height) {
    if (height == null) {
      return 'Height is required';
    }
    if (height < HealthConstants.minHeightCm) {
      return 'Height must be at least ${HealthConstants.minHeightCm} cm';
    }
    return null;
  }

  /// Validate height in inches
  static String? validateHeightInches(double? height) {
    if (height == null) {
      return 'Height is required';
    }
    // Convert to cm for validation
    final heightCm = height * 2.54;
    return validateHeightCm(heightCm);
  }

  /// Validate resting heart rate
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

  /// Validate sleep quality
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
  static String? validateDailyCalories(int? calories) {
    if (calories == null) {
      return 'Calories are required';
    }
    if (calories < HealthConstants.minDailyCalories) {
      return 'Calories must be at least ${HealthConstants.minDailyCalories}';
    }
    return null;
  }

  /// Validate macro percentage
  static String? validateMacroPercentage(double? percentage) {
    if (percentage == null) {
      return 'Percentage is required';
    }
    if (percentage < HealthConstants.minProteinPercentage) {
      return 'Percentage must be at least ${HealthConstants.minProteinPercentage}%';
    }
    return null;
  }

  /// Validate macro percentages sum to approximately 100%
  static String? validateMacroPercentagesSum(
    double? protein,
    double? carbs,
    double? fat,
  ) {
    if (protein == null || carbs == null || fat == null) {
      return 'All macro percentages are required';
    }
    final sum = protein + carbs + fat;
    const tolerance = 5.0; // 5% tolerance
    if ((sum - 100.0).abs() > tolerance) {
      return 'Macro percentages must sum to approximately 100% (current: ${sum.toStringAsFixed(1)}%)';
    }
    return null;
  }

  /// Validate value is not null
  static String? validateNotNull<T>(T? value, String fieldName) {
    if (value == null) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate string is not empty
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate string length
  static String? validateStringLength(
    String? value,
    String fieldName,
    int minLength,
    int maxLength,
  ) {
    if (value == null) {
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

/// Email validation utility
class EmailValidator {
  EmailValidator._();

  /// Email regex pattern
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validate email format
  static bool isValid(String email) {
    if (email.isEmpty) return false;
    return _emailRegex.hasMatch(email);
  }

  /// Get email validation error message
  static String? validate(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!isValid(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}

/// Password validation utility
class PasswordValidator {
  PasswordValidator._();

  /// Minimum password length
  static const int minLength = 8;

  /// Validate password meets requirements
  /// Requirements:
  /// - Minimum 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one number
  /// - At least one special character
  static bool isValid(String password) {
    if (password.length < minLength) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  /// Get password validation error message
  static String? validate(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  /// Get password strength indicator
  /// Returns: 'weak', 'medium', 'strong'
  static String getStrength(String password) {
    if (password.length < minLength) return 'weak';
    
    int strength = 0;
    if (password.length >= 12) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    if (strength >= 4) return 'strong';
    if (strength >= 3) return 'medium';
    return 'weak';
  }
}
