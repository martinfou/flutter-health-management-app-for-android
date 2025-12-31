import 'package:health_app/features/medication_management/domain/entities/time_of_day.dart';

/// User preferences domain entity
/// 
/// Represents user preferences for the application.
/// This is a pure Dart class with no external dependencies.
class UserPreferences {
  /// Dietary approach ('low_carb', 'keto', 'balanced', etc.)
  final String dietaryApproach;

  /// Preferred meal times
  final List<TimeOfDay> preferredMealTimes;

  /// List of allergies
  final List<String> allergies;

  /// List of disliked foods
  final List<String> dislikes;

  /// List of fitness goals
  final List<String> fitnessGoals;

  /// Notification preferences map
  final Map<String, bool> notificationPreferences;

  /// Units preference ('metric', 'imperial')
  final String units;

  /// Theme preference ('light', 'dark', 'system')
  final String theme;

  /// Weight loss objective ('aggressive', 'moderate', 'mild', 'maintenance', 'gain')
  final String weightLossObjective;

  /// Activity factor for TDEE calculation (1.2 = sedentary, 1.375 = lightly active, 1.55 = moderate, 1.725 = very active, 1.9 = extremely active)
  final double activityFactor;

  /// Number of meals per day for calorie distribution (default: 3)
  final int mealsPerDay;

  /// Whether to show calorie warnings for meals
  final bool showCalorieWarnings;

  /// Creates UserPreferences
  UserPreferences({
    required this.dietaryApproach,
    required this.preferredMealTimes,
    required this.allergies,
    required this.dislikes,
    required this.fitnessGoals,
    required this.notificationPreferences,
    required this.units,
    required this.theme,
    this.weightLossObjective = 'moderate',
    this.activityFactor = 1.2,
    this.mealsPerDay = 3,
    this.showCalorieWarnings = true,
  });

  /// Create default preferences
  factory UserPreferences.defaults() {
    return UserPreferences(
      dietaryApproach: 'low_carb',
      preferredMealTimes: TimeOfDay.defaultTimes,
      allergies: [],
      dislikes: [],
      fitnessGoals: [],
      notificationPreferences: {
        'medicationReminders': true,
        'workoutReminders': true,
        'mealReminders': false,
      },
      units: 'metric',
      theme: 'system',
      weightLossObjective: 'moderate',
      activityFactor: 1.2,
      mealsPerDay: 3,
      showCalorieWarnings: true,
    );
  }

  /// Create a copy with updated fields
  UserPreferences copyWith({
    String? dietaryApproach,
    List<TimeOfDay>? preferredMealTimes,
    List<String>? allergies,
    List<String>? dislikes,
    List<String>? fitnessGoals,
    Map<String, bool>? notificationPreferences,
    String? units,
    String? theme,
    String? weightLossObjective,
    double? activityFactor,
    int? mealsPerDay,
    bool? showCalorieWarnings,
  }) {
    return UserPreferences(
      dietaryApproach: dietaryApproach ?? this.dietaryApproach,
      preferredMealTimes: preferredMealTimes ?? this.preferredMealTimes,
      allergies: allergies ?? this.allergies,
      dislikes: dislikes ?? this.dislikes,
      fitnessGoals: fitnessGoals ?? this.fitnessGoals,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      units: units ?? this.units,
      theme: theme ?? this.theme,
      weightLossObjective: weightLossObjective ?? this.weightLossObjective,
      activityFactor: activityFactor ?? this.activityFactor,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
      showCalorieWarnings: showCalorieWarnings ?? this.showCalorieWarnings,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferences &&
          runtimeType == other.runtimeType &&
          dietaryApproach == other.dietaryApproach &&
          preferredMealTimes == other.preferredMealTimes &&
          allergies == other.allergies &&
          dislikes == other.dislikes &&
          fitnessGoals == other.fitnessGoals &&
          notificationPreferences == other.notificationPreferences &&
          units == other.units &&
          theme == other.theme &&
          weightLossObjective == other.weightLossObjective &&
          activityFactor == other.activityFactor &&
          mealsPerDay == other.mealsPerDay &&
          showCalorieWarnings == other.showCalorieWarnings;

  @override
  int get hashCode =>
      dietaryApproach.hashCode ^
      preferredMealTimes.hashCode ^
      allergies.hashCode ^
      dislikes.hashCode ^
      fitnessGoals.hashCode ^
      notificationPreferences.hashCode ^
      units.hashCode ^
      theme.hashCode ^
      weightLossObjective.hashCode ^
      activityFactor.hashCode ^
      mealsPerDay.hashCode ^
      showCalorieWarnings.hashCode;

  @override
  String toString() {
    return 'UserPreferences(dietaryApproach: $dietaryApproach, units: $units, theme: $theme)';
  }
}

