import 'package:hive/hive.dart';
import 'package:health_app/core/entities/user_preferences.dart';
import 'package:health_app/features/medication_management/domain/entities/time_of_day.dart';

part 'user_preferences_model.g.dart';

/// UserPreferences Hive data model
/// 
/// Hive adapter for UserPreferences entity.
/// Uses typeId 12 as specified in database schema.
@HiveType(typeId: 12)
class UserPreferencesModel extends HiveObject {
  /// Dietary approach ('low_carb', 'keto', 'balanced', etc.)
  @HiveField(0)
  late String dietaryApproach;

  /// Preferred meal times as list of time strings
  @HiveField(1)
  late List<String> preferredMealTimes;

  /// List of allergies
  @HiveField(2)
  late List<String> allergies;

  /// List of disliked foods
  @HiveField(3)
  late List<String> dislikes;

  /// List of fitness goals
  @HiveField(4)
  late List<String> fitnessGoals;

  /// Notification preferences map
  @HiveField(5)
  late Map<String, bool> notificationPreferences;

  /// Units preference ('metric', 'imperial')
  @HiveField(6)
  late String units;

  /// Theme preference ('light', 'dark', 'system')
  @HiveField(7)
  late String theme;

  /// Default constructor for Hive
  UserPreferencesModel();

  /// Convert to domain entity
  UserPreferences toEntity() {
    return UserPreferences(
      dietaryApproach: dietaryApproach,
      preferredMealTimes: preferredMealTimes
          .map((t) => TimeOfDay.fromString(t))
          .toList(),
      allergies: allergies,
      dislikes: dislikes,
      fitnessGoals: fitnessGoals,
      notificationPreferences: notificationPreferences,
      units: units,
      theme: theme,
    );
  }

  /// Create from domain entity
  factory UserPreferencesModel.fromEntity(UserPreferences entity) {
    final model = UserPreferencesModel()
      ..dietaryApproach = entity.dietaryApproach
      ..preferredMealTimes =
          entity.preferredMealTimes.map((t) => t.toString()).toList()
      ..allergies = entity.allergies
      ..dislikes = entity.dislikes
      ..fitnessGoals = entity.fitnessGoals
      ..notificationPreferences = entity.notificationPreferences
      ..units = entity.units
      ..theme = entity.theme;
    return model;
  }
}

