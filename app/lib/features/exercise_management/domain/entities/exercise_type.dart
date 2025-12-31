/// Exercise type enumeration
enum ExerciseType {
  strength,
  cardio,
  flexibility,
  other;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case ExerciseType.strength:
        return 'Strength Training';
      case ExerciseType.cardio:
        return 'Cardio';
      case ExerciseType.flexibility:
        return 'Flexibility';
      case ExerciseType.other:
        return 'Other';
    }
  }
}

