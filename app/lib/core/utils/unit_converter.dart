/// Height in feet and inches
class FeetInches {
  final int feet;
  final int inches;

  FeetInches({required this.feet, required this.inches});

  @override
  String toString() => "$feet'$inches\"";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeetInches &&
          runtimeType == other.runtimeType &&
          feet == other.feet &&
          inches == other.inches;

  @override
  int get hashCode => feet.hashCode ^ inches.hashCode;
}

/// Unit conversion utilities for metric and imperial units
/// 
/// Provides conversion functions between metric and imperial units.
/// All data is stored internally in metric units, and conversion happens
/// at display time only.
class UnitConverter {
  UnitConverter._();

  // ============================================================================
  // Conversion Constants
  // ============================================================================

  /// Kilograms to pounds conversion factor
  /// 1 kg = 2.20462 lb
  static const double kgToLb = 2.20462;

  /// Pounds to kilograms conversion factor
  /// 1 lb = 0.453592 kg
  static const double lbToKg = 0.453592;

  /// Centimeters to inches conversion factor
  /// 1 cm = 0.393701 in
  static const double cmToIn = 0.393701;

  /// Inches to centimeters conversion factor
  /// 1 in = 2.54 cm
  static const double inToCm = 2.54;

  /// Inches per foot
  static const int inchesPerFoot = 12;

  // ============================================================================
  // Weight Conversions
  // ============================================================================

  /// Convert weight from kilograms to pounds
  /// 
  /// [kg] - Weight in kilograms
  /// Returns weight in pounds, rounded to 1 decimal place
  static double convertWeightMetricToImperial(double kg) {
    final lb = kg * kgToLb;
    return double.parse(lb.toStringAsFixed(1));
  }

  /// Convert weight from pounds to kilograms
  /// 
  /// [lb] - Weight in pounds
  /// Returns weight in kilograms, rounded to 1 decimal place
  static double convertWeightImperialToMetric(double lb) {
    final kg = lb * lbToKg;
    return double.parse(kg.toStringAsFixed(1));
  }

  /// Format weight value with appropriate unit label
  /// 
  /// [valueInMetric] - Weight value in kilograms (metric)
  /// [useImperial] - If true, convert to pounds; if false, use kilograms
  /// Returns formatted string with unit (e.g., "75.5 kg" or "166.4 lb")
  static String formatWeight(double valueInMetric, bool useImperial) {
    if (useImperial) {
      final lb = convertWeightMetricToImperial(valueInMetric);
      return '${lb.toStringAsFixed(1)} lb';
    } else {
      return '${valueInMetric.toStringAsFixed(1)} kg';
    }
  }

  // ============================================================================
  // Height Conversions
  // ============================================================================

  /// Convert height from centimeters to feet and inches
  /// 
  /// [cm] - Height in centimeters
  /// Returns FeetInches object with feet and inches
  static FeetInches convertHeightMetricToImperial(double cm) {
    final totalInches = (cm * cmToIn).round();
    final feet = totalInches ~/ inchesPerFoot;
    final inches = totalInches % inchesPerFoot;
    return FeetInches(feet: feet, inches: inches);
  }

  /// Convert height from feet and inches to centimeters
  /// 
  /// [feet] - Height in feet
  /// [inches] - Height in inches
  /// Returns height in centimeters, rounded to nearest integer
  static double convertHeightImperialToMetric(int feet, int inches) {
    final totalInches = (feet * inchesPerFoot) + inches;
    final cm = totalInches * inToCm;
    return cm.roundToDouble();
  }

  /// Format height value with appropriate unit label
  /// 
  /// [valueInMetric] - Height value in centimeters (metric)
  /// [useImperial] - If true, convert to ft/in; if false, use cm
  /// Returns formatted string (e.g., "175 cm" or "5'9\"")
  static String formatHeight(double valueInMetric, bool useImperial) {
    if (useImperial) {
      final ftIn = convertHeightMetricToImperial(valueInMetric);
      return ftIn.toString();
    } else {
      return '${valueInMetric.toStringAsFixed(0)} cm';
    }
  }

  // ============================================================================
  // Length Conversions (for body measurements)
  // ============================================================================

  /// Convert length from centimeters to inches
  /// 
  /// [cm] - Length in centimeters
  /// Returns length in inches, rounded to 1 decimal place
  static double convertLengthMetricToImperial(double cm) {
    final inches = cm * cmToIn;
    return double.parse(inches.toStringAsFixed(1));
  }

  /// Convert length from inches to centimeters
  /// 
  /// [inches] - Length in inches
  /// Returns length in centimeters, rounded to 1 decimal place
  static double convertLengthImperialToMetric(double inches) {
    final cm = inches * inToCm;
    return double.parse(cm.toStringAsFixed(1));
  }

  /// Format length value with appropriate unit label
  /// 
  /// [valueInMetric] - Length value in centimeters (metric)
  /// [useImperial] - If true, convert to inches; if false, use centimeters
  /// Returns formatted string (e.g., "81.3 cm" or "32.0 in")
  static String formatLength(double valueInMetric, bool useImperial) {
    if (useImperial) {
      final inches = convertLengthMetricToImperial(valueInMetric);
      return '${inches.toStringAsFixed(1)} in';
    } else {
      return '${valueInMetric.toStringAsFixed(1)} cm';
    }
  }

  // ============================================================================
  // Unit Label Helpers
  // ============================================================================

  /// Get weight unit label
  /// 
  /// [useImperial] - If true, returns "lb"; if false, returns "kg"
  static String getWeightUnitLabel(bool useImperial) {
    return useImperial ? 'lb' : 'kg';
  }

  /// Get height unit label
  /// 
  /// [useImperial] - If true, returns "ft/in"; if false, returns "cm"
  static String getHeightUnitLabel(bool useImperial) {
    return useImperial ? 'ft/in' : 'cm';
  }

  /// Get length unit label
  /// 
  /// [useImperial] - If true, returns "in"; if false, returns "cm"
  static String getLengthUnitLabel(bool useImperial) {
    return useImperial ? 'in' : 'cm';
  }

  // ============================================================================
  // Validation Helpers
  // ============================================================================

  /// Get minimum weight in selected units for validation
  /// 
  /// [useImperial] - If true, returns minimum in pounds; if false, in kilograms
  /// Returns minimum reasonable weight (30 kg = 66 lb)
  static double getMinWeight(bool useImperial) {
    const minKg = 30.0;
    return useImperial ? convertWeightMetricToImperial(minKg) : minKg;
  }

  /// Get maximum weight in selected units for validation
  /// 
  /// [useImperial] - If true, returns maximum in pounds; if false, in kilograms
  /// Returns maximum reasonable weight (300 kg = 660 lb)
  static double getMaxWeight(bool useImperial) {
    const maxKg = 300.0;
    return useImperial ? convertWeightMetricToImperial(maxKg) : maxKg;
  }

  /// Get minimum height in selected units for validation
  /// 
  /// [useImperial] - If true, returns minimum in inches; if false, in centimeters
  /// Returns minimum reasonable height (100 cm = 39 in ≈ 3'3")
  static double getMinHeight(bool useImperial) {
    const minCm = 100.0;
    return useImperial ? convertLengthMetricToImperial(minCm) : minCm;
  }

  /// Get maximum height in selected units for validation
  /// 
  /// [useImperial] - If true, returns maximum in inches; if false, in centimeters
  /// Returns maximum reasonable height (250 cm = 98 in ≈ 8'2")
  static double getMaxHeight(bool useImperial) {
    const maxCm = 250.0;
    return useImperial ? convertLengthMetricToImperial(maxCm) : maxCm;
  }
}

