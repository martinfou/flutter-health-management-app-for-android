import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise_type.dart';
import 'package:health_app/features/exercise_management/domain/repositories/exercise_repository.dart';

/// Use case for logging a workout/exercise
/// 
/// Validates exercise data and saves it to the repository.
/// Validates exercise type-specific requirements (e.g., strength needs sets/reps/weight,
/// cardio needs duration or distance).
class LogWorkoutUseCase {
  /// Exercise repository
  final ExerciseRepository repository;

  /// Creates a LogWorkoutUseCase
  LogWorkoutUseCase(this.repository);

  /// Execute the use case
  /// 
  /// Validates the exercise data and saves it. Generates an ID if not provided.
  /// 
  /// Returns [ValidationFailure] if validation fails.
  /// Returns [DatabaseFailure] if save operation fails.
  Future<Result<Exercise>> call({
    required String userId,
    required String name,
    required ExerciseType type,
    required DateTime date,
    List<String> muscleGroups = const [],
    List<String> equipment = const [],
    int? sets,
    int? reps,
    double? weight,
    int? duration,
    double? distance,
    String? notes,
    String? id,
  }) async {
    // Generate ID if not provided
    final exerciseId = id ?? _generateId();

    // Validate the exercise
    final validationResult = _validateExercise(
      name: name,
      type: type,
      sets: sets,
      reps: reps,
      weight: weight,
      duration: duration,
      distance: distance,
    );
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Create exercise entity
    final exercise = Exercise(
      id: exerciseId,
      userId: userId,
      name: name,
      type: type,
      muscleGroups: muscleGroups,
      equipment: equipment,
      duration: duration,
      sets: sets,
      reps: reps,
      weight: weight,
      distance: distance,
      date: date,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save to repository
    return await repository.saveExercise(exercise);
  }

  /// Validate exercise data
  ValidationFailure? _validateExercise({
    required String name,
    required ExerciseType type,
    int? sets,
    int? reps,
    double? weight,
    int? duration,
    double? distance,
  }) {
    // Validate name
    if (name.trim().isEmpty) {
      return ValidationFailure('Exercise name cannot be empty');
    }

    // Validate type-specific requirements
    switch (type) {
      case ExerciseType.strength:
        // Strength training should have sets and reps
        if (sets == null || sets < 1) {
          return ValidationFailure('Strength exercises must have at least 1 set');
        }
        if (reps == null || reps < 1) {
          return ValidationFailure('Strength exercises must have at least 1 rep');
        }
        // Weight is optional but should be positive if provided
        if (weight != null && weight < 0) {
          return ValidationFailure('Weight cannot be negative');
        }
        break;

      case ExerciseType.cardio:
        // Cardio should have duration or distance
        if (duration == null && distance == null) {
          return ValidationFailure(
            'Cardio exercises must have either duration or distance',
          );
        }
        if (duration != null && duration < 1) {
          return ValidationFailure('Duration must be at least 1 minute');
        }
        if (distance != null && distance < 0) {
          return ValidationFailure('Distance cannot be negative');
        }
        break;

      case ExerciseType.flexibility:
        // Flexibility exercises should have duration
        if (duration == null || duration < 1) {
          return ValidationFailure(
            'Flexibility exercises must have duration of at least 1 minute',
          );
        }
        break;

      case ExerciseType.other:
        // Other exercises should have at least duration or notes
        if (duration == null && distance == null) {
          // Allow if there are notes or other data
          break;
        }
        if (duration != null && duration < 0) {
          return ValidationFailure('Duration cannot be negative');
        }
        if (distance != null && distance < 0) {
          return ValidationFailure('Distance cannot be negative');
        }
        break;
    }

    // Validate sets/reps if provided (for any type)
    if (sets != null && sets < 0) {
      return ValidationFailure('Sets cannot be negative');
    }
    if (reps != null && reps < 0) {
      return ValidationFailure('Reps cannot be negative');
    }

    return null;
  }

  /// Generate a unique ID for the exercise
  String _generateId() {
    final now = DateTime.now();
    return 'exercise-${now.millisecondsSinceEpoch}-${now.microsecondsSinceEpoch}';
  }
}

