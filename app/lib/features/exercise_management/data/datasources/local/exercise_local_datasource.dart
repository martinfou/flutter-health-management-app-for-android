import 'package:hive_flutter/hive_flutter.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/providers/database_provider.dart';
import 'package:health_app/features/exercise_management/data/models/exercise_model.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';

/// Local data source for Exercise
/// 
/// Handles direct Hive database operations for exercises.
class ExerciseLocalDataSource {
  /// Get Hive box for exercises
  Box<ExerciseModel> get _box {
    if (!Hive.isBoxOpen(HiveBoxNames.exercises)) {
      throw DatabaseFailure('Exercises box is not open');
    }
    return Hive.box<ExerciseModel>(HiveBoxNames.exercises);
  }

  /// Get exercise by ID
  Future<Result<Exercise>> getExercise(String id) async {
    try {
      final box = _box;
      final model = box.get(id);
      
      if (model == null) {
        return Left(NotFoundFailure('Exercise'));
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get exercise: $e'));
    }
  }

  /// Get all exercises for a user
  Future<Result<List<Exercise>>> getExercisesByUserId(String userId) async {
    try {
      final box = _box;
      final models = box.values
          .where((model) => model.userId == userId)
          .map((model) => model.toEntity())
          .toList();
      
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get exercises: $e'));
    }
  }

  /// Get exercises for a date range
  Future<Result<List<Exercise>>> getExercisesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final box = _box;
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      
      final models = box.values
          .where((model) {
            if (model.userId != userId) return false;
            // Exclude template exercises (null date)
            if (model.date == null) return false;
            final modelDate = DateTime(
              model.date!.year,
              model.date!.month,
              model.date!.day,
            );
            return modelDate.isAfter(start.subtract(const Duration(days: 1))) &&
                modelDate.isBefore(end.add(const Duration(days: 1)));
          })
          .map((model) => model.toEntity())
          .toList();
      
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get exercises by date range: $e'));
    }
  }

  /// Get exercises for a specific date
  Future<Result<List<Exercise>>> getExercisesByDate(
    String userId,
    DateTime date,
  ) async {
    try {
      final box = _box;
      final targetDate = DateTime(date.year, date.month, date.day);
      
      final models = box.values
          .where((model) {
            if (model.userId != userId) return false;
            // Exclude template exercises (null date)
            if (model.date == null) return false;
            final modelDate = DateTime(
              model.date!.year,
              model.date!.month,
              model.date!.day,
            );
            return modelDate == targetDate;
          })
          .map((model) => model.toEntity())
          .toList();
      
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get exercises by date: $e'));
    }
  }

  /// Get exercises by type
  Future<Result<List<Exercise>>> getExercisesByType(
    String userId,
    String exerciseType,
  ) async {
    try {
      final box = _box;
      final models = box.values
          .where((model) =>
              model.userId == userId && model.type == exerciseType)
          .map((model) => model.toEntity())
          .toList();
      
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get exercises by type: $e'));
    }
  }

  /// Save exercise
  Future<Result<Exercise>> saveExercise(Exercise exercise) async {
    try {
      final box = _box;
      final model = ExerciseModel.fromEntity(exercise);
      await box.put(exercise.id, model);
      return Right(exercise);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save exercise: $e'));
    }
  }

  /// Update exercise
  Future<Result<Exercise>> updateExercise(Exercise exercise) async {
    try {
      final box = _box;
      final existing = box.get(exercise.id);
      
      if (existing == null) {
        return Left(NotFoundFailure('Exercise'));
      }

      final model = ExerciseModel.fromEntity(exercise);
      await box.put(exercise.id, model);
      return Right(exercise);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update exercise: $e'));
    }
  }

  /// Delete exercise
  Future<Result<void>> deleteExercise(String id) async {
    try {
      final box = _box;
      final model = box.get(id);
      
      if (model == null) {
        return Left(NotFoundFailure('Exercise'));
      }

      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete exercise: $e'));
    }
  }
}

