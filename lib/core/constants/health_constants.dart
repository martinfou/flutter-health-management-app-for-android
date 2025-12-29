/// Health domain constants including KPI thresholds and alert limits
class HealthConstants {
  HealthConstants._();

  // ============================================================================
  // Clinical Safety Alert Thresholds
  // ============================================================================

  /// Resting heart rate alert threshold (BPM)
  /// Alert triggered if > this value for 3 consecutive days
  static const int restingHeartRateAlertThreshold = 100;

  /// Resting heart rate alert duration (consecutive days)
  static const int restingHeartRateAlertDays = 3;

  /// Rapid weight loss alert threshold (kg per week)
  /// Alert triggered if weight loss > this value for 2 consecutive weeks
  static const double rapidWeightLossThresholdKg = 1.8; // 4 lbs/week

  /// Rapid weight loss alert threshold (lbs per week)
  static const double rapidWeightLossThresholdLbs = 4.0;

  /// Rapid weight loss alert duration (consecutive weeks)
  static const int rapidWeightLossAlertWeeks = 2;

  /// Poor sleep quality alert threshold (out of 10)
  /// Alert triggered if sleep quality < this value for 5 consecutive days
  static const int poorSleepQualityThreshold = 4;

  /// Poor sleep quality alert duration (consecutive days)
  static const int poorSleepQualityAlertDays = 5;

  /// Elevated heart rate alert threshold (BPM increase from baseline)
  /// Alert triggered if heart rate increases by > this value from baseline for 3 days
  static const int elevatedHeartRateThresholdBpm = 20;

  /// Elevated heart rate alert duration (consecutive days)
  static const int elevatedHeartRateAlertDays = 3;

  /// Baseline calculation period (days)
  /// Baseline is average of first N days, recalculated monthly
  static const int baselineCalculationDays = 7;

  // ============================================================================
  // Weight Tracking Constants
  // ============================================================================

  /// 7-day moving average calculation period (days)
  static const int movingAverageDays = 7;

  /// Plateau detection period (days)
  /// Weight unchanged for this period AND measurements unchanged
  static const int plateauDetectionDays = 21; // 3 weeks

  /// Plateau weight tolerance (kg)
  /// Weight considered unchanged if within ± this value
  static const double plateauWeightToleranceKg = 0.2;

  /// Plateau measurement tolerance (cm)
  /// Measurements considered unchanged if within ± this value
  static const double plateauMeasurementToleranceCm = 1.0;

  // ============================================================================
  // Validation Ranges
  // ============================================================================

  /// Minimum valid weight (kg)
  static const double minWeightKg = 20.0;

  /// Maximum valid weight (kg)
  static const double maxWeightKg = 300.0;

  /// Minimum valid weight (lbs)
  static const double minWeightLbs = 44.0;

  /// Maximum valid weight (lbs)
  static const double maxWeightLbs = 660.0;

  /// Minimum valid height (cm)
  static const double minHeightCm = 100.0;

  /// Maximum valid height (cm)
  static const double maxHeightCm = 250.0;

  /// Minimum valid height (inches)
  static const double minHeightInches = 39.0;

  /// Maximum valid height (inches)
  static const double maxHeightInches = 98.0;

  /// Minimum valid resting heart rate (BPM)
  static const int minRestingHeartRate = 30;

  /// Maximum valid resting heart rate (BPM)
  static const int maxRestingHeartRate = 200;

  /// Minimum valid sleep quality (out of 10)
  static const int minSleepQuality = 0;

  /// Maximum valid sleep quality (out of 10)
  static const int maxSleepQuality = 10;

  // ============================================================================
  // Nutrition Constants
  // ============================================================================

  /// Calories per gram of protein
  static const double caloriesPerGramProtein = 4.0;

  /// Calories per gram of carbohydrates
  static const double caloriesPerGramCarbs = 4.0;

  /// Calories per gram of fat
  static const double caloriesPerGramFat = 9.0;

  /// Minimum daily calories
  static const int minDailyCalories = 800;

  /// Maximum daily calories
  static const int maxDailyCalories = 10000;

  /// Minimum protein percentage (of total calories)
  static const double minProteinPercentage = 0.0;

  /// Maximum protein percentage (of total calories)
  static const double maxProteinPercentage = 100.0;

  /// Minimum carbs percentage (of total calories)
  static const double minCarbsPercentage = 0.0;

  /// Maximum carbs percentage (of total calories)
  static const double maxCarbsPercentage = 100.0;

  /// Minimum fat percentage (of total calories)
  static const double minFatPercentage = 0.0;

  /// Maximum fat percentage (of total calories)
  static const double maxFatPercentage = 100.0;
}

