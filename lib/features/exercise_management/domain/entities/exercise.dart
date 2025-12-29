import 'package:health_app/features/exercise_management/domain/entities/exercise_type.dart';

/// Exercise domain entity
/// 
/// Represents exercise and workout tracking.
/// This is a pure Dart class with no external dependencies.
class Exercise {
  /// Unique identifier (UUID)
  final String id;

  /// User ID (FK to UserProfile)
  final String userId;

  /// Exercise name
  final String name;

  /// Exercise type
  final ExerciseType type;

  /// List of muscle groups targeted
  final List<String> muscleGroups;

  /// List of equipment needed
  final List<String> equipment;

  /// Duration in minutes (nullable)
  final int? duration;

  /// Number of sets (nullable)
  final int? sets;

  /// Number of reps (nullable)
  final int? reps;

  /// Weight in kilograms (nullable)
  final double? weight;

  /// Distance in kilometers (nullable)
  final double? distance;

  /// Date of the exercise
  final DateTime date;

  /// Optional notes
  final String? notes;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Creates an Exercise
  Exercise({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.muscleGroups,
    required this.equipment,
    this.duration,
    this.sets,
    this.reps,
    this.weight,
    this.distance,
    required this.date,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy with updated fields
  Exercise copyWith({
    String? id,
    String? userId,
    String? name,
    ExerciseType? type,
    List<String>? muscleGroups,
    List<String>? equipment,
    int? duration,
    int? sets,
    int? reps,
    double? weight,
    double? distance,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      equipment: equipment ?? this.equipment,
      duration: duration ?? this.duration,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      distance: distance ?? this.distance,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Exercise &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          name == other.name &&
          type == other.type &&
          muscleGroups == other.muscleGroups &&
          equipment == other.equipment &&
          duration == other.duration &&
          sets == other.sets &&
          reps == other.reps &&
          weight == other.weight &&
          distance == other.distance &&
          date == other.date &&
          notes == other.notes;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      name.hashCode ^
      type.hashCode ^
      muscleGroups.hashCode ^
      equipment.hashCode ^
      duration.hashCode ^
      sets.hashCode ^
      reps.hashCode ^
      weight.hashCode ^
      distance.hashCode ^
      date.hashCode ^
      notes.hashCode;

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, type: $type, date: $date, duration: $duration, sets: $sets, reps: $reps)';
  }
}

