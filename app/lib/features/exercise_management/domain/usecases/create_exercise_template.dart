import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise_type.dart';
import 'package:health_app/features/exercise_management/domain/repositories/exercise_repository.dart';

/// Use case for creating an exercise template
/// 
/// Creates a template exercise (without date) for use in the exercise library.
/// Templates can be reused across workout plans.
class CreateExerciseTemplateUseCase {
  /// Exercise repository
  final ExerciseRepository repository;

  /// Creates a CreateExerciseTemplateUseCase
  CreateExerciseTemplateUseCase(this.repository);

  /// Execute the use case
  /// 
  /// Creates a template exercise with the provided details.
  /// Generates an ID if not provided.
  /// 
  /// Returns [ValidationFailure] if validation fails.
  /// Returns [DatabaseFailure] if save operation fails.
  Future<Result<Exercise>> call({
    required String userId,
    required String name,
    required ExerciseType type,
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

    // Create exercise template entity (date is null for templates)
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
      date: null, // Templates have no date
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

    // Type-specific validation is optional for templates
    // Users can create templates with minimal info and fill in details later
    // But still validate that provided values are positive

    if (sets != null && sets < 0) {
      return ValidationFailure('Sets cannot be negative');
    }
    if (reps != null && reps < 0) {
      return ValidationFailure('Reps cannot be negative');
    }
    if (weight != null && weight < 0) {
      return ValidationFailure('Weight cannot be negative');
    }
    if (duration != null && duration < 0) {
      return ValidationFailure('Duration cannot be negative');
    }
    if (distance != null && distance < 0) {
      return ValidationFailure('Distance cannot be negative');
    }

    return null;
  }

  /// Generate a unique ID for the exercise
  String _generateId() {
    final now = DateTime.now();
    return 'exercise-${now.millisecondsSinceEpoch}-${now.microsecondsSinceEpoch}';
  }
}

