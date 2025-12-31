/// Habit category enumeration
enum HabitCategory {
  nutrition,
  exercise,
  sleep,
  medication,
  selfCare,
  other;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case HabitCategory.nutrition:
        return 'Nutrition';
      case HabitCategory.exercise:
        return 'Exercise';
      case HabitCategory.sleep:
        return 'Sleep';
      case HabitCategory.medication:
        return 'Medication';
      case HabitCategory.selfCare:
        return 'Self-Care';
      case HabitCategory.other:
        return 'Other';
    }
  }
}

