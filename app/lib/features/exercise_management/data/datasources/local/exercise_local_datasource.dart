import 'package:fpdart/fpdart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/providers/database_provider.dart';
import 'package:health_app/features/exercise_management/data/models/exercise_model.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/core/sync/services/offline_sync_queue.dart';
import 'package:health_app/core/sync/models/offline_sync_operation.dart';
import 'package:health_app/core/sync/enums/sync_data_type.dart';

/// Local data source for Exercise
/// 
/// Handles direct Hive database operations for exercises.
class ExerciseLocalDataSource {
  final OfflineSyncQueue? _offlineQueue;

  ExerciseLocalDataSource({OfflineSyncQueue? offlineQueue}) : _offlineQueue = offlineQueue;

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

      // Enqueue sync operation
      await _offlineQueue?.enqueueOperation(OfflineSyncOperation.create(
        id: 'sync-exercise-${exercise.id}-${DateTime.now().millisecondsSinceEpoch}',
        dataType: SyncDataType.exercises,
        operation: 'create',
        data: model.toJson(),
      ));

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

      // Enqueue sync operation
      await _offlineQueue?.enqueueOperation(OfflineSyncOperation.create(
        id: 'sync-exercise-${exercise.id}-${DateTime.now().millisecondsSinceEpoch}',
        dataType: SyncDataType.exercises,
        operation: 'update',
        data: model.toJson(),
      ));

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

      // Enqueue sync operation
      await _offlineQueue?.enqueueOperation(OfflineSyncOperation.create(
        id: 'sync-exercise-delete-$id-${DateTime.now().millisecondsSinceEpoch}',
        dataType: SyncDataType.exercises,
        operation: 'delete',
        data: {'id': id, 'client_id': id, 'deleted_at': DateTime.now().toIso8601String()},
      ));

      return Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete exercise: $e'));
    }
  }

  /// Batch save exercises with conflict resolution
  ///
  /// Saves multiple exercises in a single operation for better performance.
  /// Uses timestamp-based conflict resolution: only overwrites local data if
  /// incoming exercise is newer (has later updatedAt).
  ///
  /// This ensures that in case of concurrent edits, the latest version wins.
  Future<Result<List<Exercise>>> saveExercisesBatch(
    List<Exercise> exercises,
  ) async {
    try {
      final box = _box;
      final modelsMap = <String, ExerciseModel>{};
      int skippedCount = 0;

      for (final exercise in exercises) {
        final existing = box.get(exercise.id);

        // Conflict resolution: Compare timestamps
        if (existing != null) {
          // Only overwrite if incoming exercise is newer
          final incomingUpdate = exercise.updatedAt;
          final existingUpdate = existing.updatedAt; // exercise_model.dart has late updatedAt

          if (incomingUpdate.isBefore(existingUpdate)) {
            // Skip this exercise - local version is newer
            skippedCount++;
            continue;
          }
        }

        // Either no existing record or incoming is newer - save it
        modelsMap[exercise.id] = ExerciseModel.fromEntity(exercise);
      }

      // Use batch put operation
      await box.putAll(modelsMap);

      if (skippedCount > 0) {
        print('saveExercisesBatch: Skipped $skippedCount exercises (local versions are newer)');
      }

      return Right(exercises);
    } catch (e) {
      return Left(DatabaseFailure('Failed to batch save exercises: $e'));
    }
  }
}

