import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/domain/repositories/exercise_repository.dart';
import 'package:health_app/features/exercise_management/data/datasources/local/exercise_local_datasource.dart';

/// Exercise repository implementation
/// 
/// Implements the ExerciseRepository interface using local data source.
class ExerciseRepositoryImpl implements ExerciseRepository {
  final ExerciseLocalDataSource _localDataSource;

  ExerciseRepositoryImpl(this._localDataSource);

  @override
  Future<ExerciseResult> getExercise(String id) async {
    return await _localDataSource.getExercise(id);
  }

  @override
  Future<ExerciseListResult> getExercisesByUserId(String userId) async {
    return await _localDataSource.getExercisesByUserId(userId);
  }

  @override
  Future<ExerciseListResult> getExercisesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Validation
    if (startDate.isAfter(endDate)) {
      return Left(
        ValidationFailure('Start date must be before or equal to end date'),
      );
    }

    return await _localDataSource.getExercisesByDateRange(
      userId,
      startDate,
      endDate,
    );
  }

  @override
  Future<ExerciseListResult> getExercisesByDate(
    String userId,
    DateTime date,
  ) async {
    return await _localDataSource.getExercisesByDate(userId, date);
  }

  @override
  Future<ExerciseListResult> getExercisesByType(
    String userId,
    String exerciseType,
  ) async {
    return await _localDataSource.getExercisesByType(userId, exerciseType);
  }

  @override
  Future<ExerciseResult> saveExercise(Exercise exercise) async {
    // Validation
    if (exercise.name.isEmpty) {
      return Left(ValidationFailure('Exercise name cannot be empty'));
    }
    if (exercise.name.length > 200) {
      return Left(ValidationFailure('Exercise name must be 200 characters or less'));
    }
    if (exercise.duration != null && exercise.duration! <= 0) {
      return Left(ValidationFailure('Duration must be greater than 0 if provided'));
    }
    if (exercise.sets != null && exercise.sets! <= 0) {
      return Left(ValidationFailure('Sets must be greater than 0 if provided'));
    }
    if (exercise.reps != null && exercise.reps! <= 0) {
      return Left(ValidationFailure('Reps must be greater than 0 if provided'));
    }
    if (exercise.weight != null && exercise.weight! <= 0) {
      return Left(ValidationFailure('Weight must be greater than 0 if provided'));
    }
    if (exercise.distance != null && exercise.distance! <= 0) {
      return Left(ValidationFailure('Distance must be greater than 0 if provided'));
    }
    if (exercise.date.isAfter(DateTime.now())) {
      return Left(ValidationFailure('Date cannot be in the future'));
    }

    return await _localDataSource.saveExercise(exercise);
  }

  @override
  Future<ExerciseResult> updateExercise(Exercise exercise) async {
    // Validation (same as save)
    if (exercise.name.isEmpty) {
      return Left(ValidationFailure('Exercise name cannot be empty'));
    }

    return await _localDataSource.updateExercise(exercise);
  }

  @override
  Future<Result<void>> deleteExercise(String id) async {
    return await _localDataSource.deleteExercise(id);
  }
}

