import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/domain/repositories/exercise_repository.dart';

/// Use case for getting workout history
/// 
/// Retrieves exercises for a user within a date range, sorted by date.
/// Can filter by exercise type if provided.
class GetWorkoutHistoryUseCase {
  /// Exercise repository
  final ExerciseRepository repository;

  /// Creates a GetWorkoutHistoryUseCase
  GetWorkoutHistoryUseCase(this.repository);

  /// Execute the use case
  /// 
  /// Gets exercises for the user within the date range.
  /// Optionally filters by exercise type.
  /// 
  /// Returns [ValidationFailure] if date range is invalid.
  /// Returns [Right] with list of exercises sorted by date (newest first).
  Future<Result<List<Exercise>>> call({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? exerciseType,
  }) async {
    // Validate date range
    if (startDate.isAfter(endDate)) {
      return Left(ValidationFailure(
        'Start date must be before or equal to end date',
      ));
    }

    // Get exercises by date range
    final result = await repository.getExercisesByDateRange(
      userId,
      startDate,
      endDate,
    );

    return result.fold(
      (failure) => Left(failure),
      (exercises) {
        // Filter by type if provided
        List<Exercise> filteredExercises = exercises;
        if (exerciseType != null) {
          filteredExercises = exercises
              .where((exercise) => exercise.type.name == exerciseType)
              .toList();
        }

        // Sort by date (newest first)
        filteredExercises.sort((a, b) => b.date.compareTo(a.date));

        return Right(filteredExercises);
      },
    );
  }

  /// Get workout history for a specific date
  /// 
  /// Convenience method to get exercises for a single date.
  Future<Result<List<Exercise>>> getByDate({
    required String userId,
    required DateTime date,
    String? exerciseType,
  }) async {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = startDate.add(Duration(days: 1));

    return call(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      exerciseType: exerciseType,
    );
  }
}

