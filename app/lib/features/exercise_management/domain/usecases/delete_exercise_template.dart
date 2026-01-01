import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/exercise_management/domain/repositories/exercise_repository.dart';

/// Use case for deleting an exercise template
/// 
/// Deletes an exercise template from the exercise library.
/// 
/// Note: Checking if exercise is used in workout plans is not yet implemented
/// as workout plan repository is not yet available. This will be added in a future update.
class DeleteExerciseTemplateUseCase {
  /// Exercise repository
  final ExerciseRepository repository;

  /// Creates a DeleteExerciseTemplateUseCase
  DeleteExerciseTemplateUseCase(this.repository);

  /// Execute the use case
  /// 
  /// Deletes the exercise template with the specified ID.
  /// 
  /// Returns [NotFoundFailure] if exercise doesn't exist.
  /// Returns [DatabaseFailure] if delete operation fails.
  /// 
  /// Note: This use case does not currently check if the exercise is used
  /// in workout plans. This check will be added when workout plan repository
  /// is implemented. For now, exercise deletion is allowed without checking
  /// workout plan references.
  Future<Result<void>> call({
    required String exerciseId,
  }) async {
    // Get the exercise first to verify it exists
    final getResult = await repository.getExercise(exerciseId);
    
    return getResult.fold(
      (failure) => Left(failure),
      (exercise) async {
        // Verify it's a template (date should be null)
        if (exercise.date != null) {
          return Left(ValidationFailure(
            'Cannot delete logged workout exercise as template. '
            'This use case is for template exercises only.',
          ));
        }

        // TODO: Check if exercise is used in workout plans
        // This will be implemented when workout plan repository is available
        // For now, proceed with deletion

        // Delete the exercise
        return await repository.deleteExercise(exerciseId);
      },
    );
  }
}

