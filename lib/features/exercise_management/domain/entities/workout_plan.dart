/// Workout day within a workout plan
class WorkoutDay {
  /// Day name (Monday, Tuesday, etc.)
  final String dayName;

  /// List of exercise IDs (references to Exercise entities)
  final List<String> exerciseIds;

  /// Optional focus (Push, Pull, Legs, Cardio, etc.)
  final String? focus;

  /// Estimated duration in minutes
  final int? estimatedDuration;

  WorkoutDay({
    required this.dayName,
    required this.exerciseIds,
    this.focus,
    this.estimatedDuration,
  });

  /// Create a copy with updated fields
  WorkoutDay copyWith({
    String? dayName,
    List<String>? exerciseIds,
    String? focus,
    int? estimatedDuration,
  }) {
    return WorkoutDay(
      dayName: dayName ?? this.dayName,
      exerciseIds: exerciseIds ?? this.exerciseIds,
      focus: focus ?? this.focus,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutDay &&
          runtimeType == other.runtimeType &&
          dayName == other.dayName &&
          exerciseIds == other.exerciseIds &&
          focus == other.focus &&
          estimatedDuration == other.estimatedDuration;

  @override
  int get hashCode =>
      dayName.hashCode ^
      exerciseIds.hashCode ^
      focus.hashCode ^
      estimatedDuration.hashCode;
}

/// Workout plan domain entity
/// 
/// Represents a workout plan with scheduled exercises by day.
/// This is a pure Dart class with no external dependencies.
class WorkoutPlan {
  /// Unique identifier (UUID)
  final String id;

  /// User ID (FK to UserProfile)
  final String userId;

  /// Plan name
  final String name;

  /// Optional description
  final String? description;

  /// List of workout days
  final List<WorkoutDay> days;

  /// Start date of the plan
  final DateTime startDate;

  /// Duration in weeks
  final int durationWeeks;

  /// Whether the plan is currently active
  final bool isActive;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  WorkoutPlan({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.days,
    required this.startDate,
    required this.durationWeeks,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate end date based on start date and duration
  DateTime get endDate {
    return startDate.add(Duration(days: durationWeeks * 7));
  }

  /// Create a copy with updated fields
  WorkoutPlan copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    List<WorkoutDay>? days,
    DateTime? startDate,
    int? durationWeeks,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      days: days ?? this.days,
      startDate: startDate ?? this.startDate,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutPlan &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          name == other.name &&
          description == other.description &&
          days == other.days &&
          startDate == other.startDate &&
          durationWeeks == other.durationWeeks &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      name.hashCode ^
      description.hashCode ^
      days.hashCode ^
      startDate.hashCode ^
      durationWeeks.hashCode ^
      isActive.hashCode;

  @override
  String toString() {
    return 'WorkoutPlan(id: $id, name: $name, durationWeeks: $durationWeeks, isActive: $isActive)';
  }
}

