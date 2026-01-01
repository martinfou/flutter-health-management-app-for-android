import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/domain/repositories/exercise_repository.dart';

/// Use case for getting an exercise by ID
/// 
/// Retrieves a single exercise by its ID.
class GetExerciseByIdUseCase {
  /// Exercise repository
  final ExerciseRepository repository;

  /// Creates a GetExerciseByIdUseCase
  GetExerciseByIdUseCase(this.repository);

  /// Execute the use case
  /// 
  /// Gets the exercise with the specified ID.
  /// 
  /// Returns [NotFoundFailure] if exercise doesn't exist.
  /// Returns [DatabaseFailure] if retrieval fails.
  /// Returns [Right] with the exercise entity.
  Future<Result<Exercise>> call({
    required String exerciseId,
  }) async {
    return await repository.getExercise(exerciseId);
  }
}

