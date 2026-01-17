import 'package:hive/hive.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise_type.dart';

part 'exercise_model.g.dart';

/// Exercise Hive data model
///
/// Hive adapter for Exercise entity.
/// Uses typeId 5 as specified in database schema.
@HiveType(typeId: 5)
class ExerciseModel extends HiveObject {
  /// Unique identifier (UUID)
  @HiveField(0)
  late String id;

  /// User ID (FK to UserProfile)
  @HiveField(1)
  late String userId;

  /// Exercise name
  @HiveField(2)
  late String name;

  /// Exercise type as string ('strength', 'cardio', 'flexibility', 'other')
  @HiveField(3)
  late String type;

  /// List of muscle groups targeted
  @HiveField(4)
  late List<String> muscleGroups;

  /// List of equipment needed
  @HiveField(5)
  late List<String> equipment;

  /// Duration in minutes (nullable)
  @HiveField(6)
  int? duration;

  /// Number of sets (nullable)
  @HiveField(7)
  int? sets;

  /// Number of reps (nullable)
  @HiveField(8)
  int? reps;

  /// Weight in kilograms (nullable)
  @HiveField(9)
  double? weight;

  /// Distance in kilometers (nullable)
  @HiveField(10)
  double? distance;

  /// Date of the exercise (nullable for template exercises)
  @HiveField(11)
  DateTime? date;

  /// Optional notes
  @HiveField(12)
  String? notes;

  /// Creation timestamp
  @HiveField(13)
  late DateTime createdAt;

  /// Last update timestamp
  @HiveField(14)
  late DateTime updatedAt;

  /// Default constructor for Hive
  ExerciseModel();

  /// Convert to domain entity
  Exercise toEntity() {
    return Exercise(
      id: id,
      userId: userId,
      name: name,
      type: ExerciseType.values.firstWhere(
        (t) => t.name == type,
        orElse: () => ExerciseType.other,
      ),
      muscleGroups: muscleGroups,
      equipment: equipment,
      duration: duration,
      sets: sets,
      reps: reps,
      weight: weight,
      distance: distance,
      date: date,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory ExerciseModel.fromEntity(Exercise entity) {
    final model = ExerciseModel()
      ..id = entity.id
      ..userId = entity.userId
      ..name = entity.name
      ..type = entity.type.name
      ..muscleGroups = entity.muscleGroups
      ..equipment = entity.equipment
      ..duration = entity.duration
      ..sets = entity.sets
      ..reps = entity.reps
      ..weight = entity.weight
      ..distance = entity.distance
      ..date = entity.date
      ..notes = entity.notes
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;
    return model;
  }

  /// Convert to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'muscle_groups': muscleGroups,
      'equipment': equipment,
      'duration_minutes': duration,
      'sets': sets,
      'reps': reps,
      'weight_kg': weight,
      'distance_km': distance,
      'date': date
          ?.toIso8601String()
          .split('T')[0], // YYYY-MM-DD format for API, nullable for templates
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
