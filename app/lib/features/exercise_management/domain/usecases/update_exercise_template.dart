import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/domain/repositories/exercise_repository.dart';

/// Use case for updating an exercise template
/// 
/// Updates an existing exercise template in the exercise library.
class UpdateExerciseTemplateUseCase {
  /// Exercise repository
  final ExerciseRepository repository;

  /// Creates an UpdateExerciseTemplateUseCase
  UpdateExerciseTemplateUseCase(this.repository);

  /// Execute the use case
  /// 
  /// Updates the exercise template with the provided details.
  /// 
  /// Returns [ValidationFailure] if validation fails.
  /// Returns [NotFoundFailure] if exercise doesn't exist.
  /// Returns [DatabaseFailure] if update operation fails.
  Future<Result<Exercise>> call({
    required Exercise exercise,
  }) async {
    // Validate that it's a template (date should be null)
    if (exercise.date != null) {
      return Left(ValidationFailure(
        'Cannot update logged workout exercise as template. Use updateExercise instead.',
      ));
    }

    // Validate name
    if (exercise.name.trim().isEmpty) {
      return Left(ValidationFailure('Exercise name cannot be empty'));
    }

    // Validate other fields
    if (exercise.sets != null && exercise.sets! < 0) {
      return Left(ValidationFailure('Sets cannot be negative'));
    }
    if (exercise.reps != null && exercise.reps! < 0) {
      return Left(ValidationFailure('Reps cannot be negative'));
    }
    if (exercise.weight != null && exercise.weight! < 0) {
      return Left(ValidationFailure('Weight cannot be negative'));
    }
    if (exercise.duration != null && exercise.duration! < 0) {
      return Left(ValidationFailure('Duration cannot be negative'));
    }
    if (exercise.distance != null && exercise.distance! < 0) {
      return Left(ValidationFailure('Distance cannot be negative'));
    }

    // Create updated exercise with updated timestamp
    final updatedExercise = exercise.copyWith(
      updatedAt: DateTime.now(),
    );

    // Update in repository
    return await repository.updateExercise(updatedExercise);
  }
}

