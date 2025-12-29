import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';

/// Type alias for repository result
typedef ExerciseResult = Result<Exercise>;
typedef ExerciseListResult = Result<List<Exercise>>;

/// Exercise repository interface
/// 
/// Defines the contract for exercise data operations.
/// Implementation is in the data layer.
abstract class ExerciseRepository {
  /// Get exercise by ID
  /// 
  /// Returns [NotFoundFailure] if exercise doesn't exist.
  Future<ExerciseResult> getExercise(String id);

  /// Get all exercises for a user
  Future<ExerciseListResult> getExercisesByUserId(String userId);

  /// Get exercises for a date range
  Future<ExerciseListResult> getExercisesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get exercises for a specific date
  Future<ExerciseListResult> getExercisesByDate(String userId, DateTime date);

  /// Get exercises by type
  Future<ExerciseListResult> getExercisesByType(
    String userId,
    String exerciseType,
  );

  /// Save exercise
  /// 
  /// Creates new exercise or updates existing one.
  /// Returns [ValidationFailure] if exercise data is invalid.
  Future<ExerciseResult> saveExercise(Exercise exercise);

  /// Update exercise
  /// 
  /// Updates existing exercise.
  /// Returns [NotFoundFailure] if exercise doesn't exist.
  /// Returns [ValidationFailure] if exercise data is invalid.
  Future<ExerciseResult> updateExercise(Exercise exercise);

  /// Delete exercise
  /// 
  /// Returns [NotFoundFailure] if exercise doesn't exist.
  Future<Result<void>> deleteExercise(String id);
}

