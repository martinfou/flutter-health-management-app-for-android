/// Recommended action type for home screen "What's Next?" section
enum RecommendedActionType {
  /// Log weight
  logWeight,

  /// Log sleep quality
  logSleep,

  /// Log energy level
  logEnergy,

  /// Log meal
  logMeal,

  /// Log workout
  logWorkout,

  /// Take medication
  takeMedication,

  /// Complete habit
  completeHabit,

  /// Log heart rate
  logHeartRate,

  /// Log blood pressure
  logBloodPressure,

  /// Log body measurements
  logMeasurements,
}

/// Recommended action for home screen
/// 
/// Represents a suggested action the user should take.
class RecommendedAction {
  /// Action type
  final RecommendedActionType type;

  /// Action title (e.g., "Log Morning Weight")
  final String title;

  /// Action description (e.g., "Take your morning medication")
  final String description;

  /// Priority (lower number = higher priority, 1 = highest)
  final int priority;

  /// Optional medication ID if action is medication-related
  final String? medicationId;

  /// Optional medication name if action is medication-related
  final String? medicationName;

  /// Creates a RecommendedAction
  RecommendedAction({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    this.medicationId,
    this.medicationName,
  });
}

