import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:health_app/features/user_profile/domain/entities/gender.dart';

/// Calorie calculation utilities
/// 
/// Calculates recommended daily calories and meal calorie ranges
/// based on user profile and weight loss objectives.
class CalorieCalculationUtils {
  CalorieCalculationUtils._();

  /// Calculate Basal Metabolic Rate (BMR) using Mifflin-St Jeor Equation
  /// 
  /// BMR is the number of calories your body burns at rest.
  static double calculateBMR(UserProfile profile, double? currentWeight) {
    // Use target weight if current weight not available (for MVP)
    final weight = currentWeight ?? profile.targetWeight;
    
    // Mifflin-St Jeor Equation:
    // Men: BMR = 10 * weight(kg) + 6.25 * height(cm) - 5 * age(years) + 5
    // Women: BMR = 10 * weight(kg) + 6.25 * height(cm) - 5 * age(years) - 161
    
    final baseBMR = (10 * weight) + (6.25 * profile.height) - (5 * profile.age);
    
    return profile.gender == Gender.male
        ? baseBMR + 5
        : baseBMR - 161;
  }

  /// Calculate Total Daily Energy Expenditure (TDEE)
  /// 
  /// TDEE = BMR * Activity Factor
  /// Activity factors:
  /// - Sedentary (little/no exercise): 1.2
  /// - Lightly active (light exercise 1-3 days/week): 1.375
  /// - Moderately active (moderate exercise 3-5 days/week): 1.55
  /// - Very active (hard exercise 6-7 days/week): 1.725
  /// - Extremely active (very hard exercise, physical job): 1.9
  static double calculateTDEE(UserProfile profile, double? currentWeight, {double activityFactor = 1.2}) {
    final bmr = calculateBMR(profile, currentWeight);
    return bmr * activityFactor;
  }

  /// Calculate recommended daily calories based on weight loss objective
  /// 
  /// Weight loss objectives:
  /// - Aggressive: -1000 cal/day deficit (2 lbs/week)
  /// - Moderate: -500 cal/day deficit (1 lb/week)
  /// - Mild: -250 cal/day deficit (0.5 lb/week)
  /// - Maintenance: 0 cal deficit
  /// - Gain: +500 cal/day surplus
  static double calculateRecommendedDailyCalories(
    UserProfile profile,
    double? currentWeight, {
    String objective = 'moderate', // 'aggressive', 'moderate', 'mild', 'maintenance', 'gain'
    double activityFactor = 1.2,
  }) {
    final tdee = calculateTDEE(profile, currentWeight, activityFactor: activityFactor);
    
    switch (objective) {
      case 'aggressive':
        return tdee - 1000; // Aggressive weight loss
      case 'moderate':
        return tdee - 500; // Moderate weight loss (1 lb/week)
      case 'mild':
        return tdee - 250; // Mild weight loss (0.5 lb/week)
      case 'maintenance':
        return tdee; // Maintenance
      case 'gain':
        return tdee + 500; // Weight gain
      default:
        return tdee - 500; // Default to moderate
    }
  }

  /// Calculate meal calorie thresholds based on daily recommendations
  /// 
  /// Returns min and max calories per meal based on:
  /// - Daily recommended calories
  /// - Number of meals per day (default: 3)
  /// - Allowable range: 50% to 200% of average meal calories
  static MealCalorieThresholds calculateMealCalorieThresholds(
    UserProfile profile,
    double? currentWeight, {
    String objective = 'moderate',
    double activityFactor = 1.2,
    int mealsPerDay = 3,
  }) {
    final dailyCalories = calculateRecommendedDailyCalories(
      profile,
      currentWeight,
      objective: objective,
      activityFactor: activityFactor,
    );
    
    final averageMealCalories = dailyCalories / mealsPerDay;
    
    // Meal thresholds: 50% to 200% of average meal calories
    // This allows for snacks (lower) and large meals (higher)
    final minMealCalories = averageMealCalories * 0.3; // 30% for small snacks
    final maxMealCalories = averageMealCalories * 2.5; // 250% for large meals
    
    return MealCalorieThresholds(
      recommendedDailyCalories: dailyCalories,
      averageMealCalories: averageMealCalories,
      minMealCalories: minMealCalories,
      maxMealCalories: maxMealCalories,
      warningLowThreshold: averageMealCalories * 0.5, // Warn if < 50% of average
      warningHighThreshold: averageMealCalories * 2.0, // Warn if > 200% of average
    );
  }
}

/// Meal calorie thresholds for warnings
class MealCalorieThresholds {
  /// Recommended daily calories
  final double recommendedDailyCalories;
  
  /// Average calories per meal
  final double averageMealCalories;
  
  /// Minimum meal calories (absolute minimum)
  final double minMealCalories;
  
  /// Maximum meal calories (absolute maximum)
  final double maxMealCalories;
  
  /// Low calorie warning threshold
  final double warningLowThreshold;
  
  /// High calorie warning threshold
  final double warningHighThreshold;

  MealCalorieThresholds({
    required this.recommendedDailyCalories,
    required this.averageMealCalories,
    required this.minMealCalories,
    required this.maxMealCalories,
    required this.warningLowThreshold,
    required this.warningHighThreshold,
  });

  /// Check if calories are low enough to warrant a warning
  bool shouldWarnLow(double calories) {
    return calories > 0 && calories < warningLowThreshold;
  }

  /// Check if calories are high enough to warrant a warning
  bool shouldWarnHigh(double calories) {
    return calories > warningHighThreshold;
  }

  /// Get warning message for calorie value
  String? getWarningMessage(double calories) {
    if (shouldWarnLow(calories)) {
      return 'This meal has very few calories (${calories.toStringAsFixed(0)} cal). '
          'Average meal should be around ${averageMealCalories.toStringAsFixed(0)} cal '
          'for your daily goal of ${recommendedDailyCalories.toStringAsFixed(0)} cal.';
    } else if (shouldWarnHigh(calories)) {
      return 'This meal has high calories (${calories.toStringAsFixed(0)} cal). '
          'Average meal should be around ${averageMealCalories.toStringAsFixed(0)} cal '
          'for your daily goal of ${recommendedDailyCalories.toStringAsFixed(0)} cal.';
    }
    return null;
  }
}

