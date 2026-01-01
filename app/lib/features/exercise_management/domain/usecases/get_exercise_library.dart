import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/domain/repositories/exercise_repository.dart';

/// Use case for getting exercise library
/// 
/// Retrieves all exercises for a user, filtered to template exercises (date == null)
/// for use in the exercise library.
class GetExerciseLibraryUseCase {
  /// Exercise repository
  final ExerciseRepository repository;

  /// Creates a GetExerciseLibraryUseCase
  GetExerciseLibraryUseCase(this.repository);

  /// Execute the use case
  /// 
  /// Gets all exercises for the user and filters to template exercises (date == null).
  /// 
  /// Returns [DatabaseFailure] if retrieval fails.
  /// Returns [Right] with list of template exercises.
  Future<Result<List<Exercise>>> call({
    required String userId,
  }) async {
    final result = await repository.getExercisesByUserId(userId);

    return result.fold(
      (failure) => Left(failure),
      (exercises) {
        // Filter to template exercises (date == null)
        final templates = exercises
            .where((exercise) => exercise.date == null)
            .toList();
        return Right(templates);
      },
    );
  }
}

