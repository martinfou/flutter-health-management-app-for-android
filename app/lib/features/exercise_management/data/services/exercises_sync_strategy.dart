import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/sync/enums/sync_data_type.dart';
import 'package:health_app/core/sync/models/data_type_sync_status.dart';
import 'package:health_app/core/sync/strategies/sync_strategy.dart';
import 'package:health_app/features/exercise_management/data/services/exercises_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Strategy for synchronizing exercises data
class ExercisesSyncStrategy implements SyncStrategy {
  final ExercisesSyncService _exercisesSyncService;
  static const String _lastSyncKey = 'last_exercises_sync_timestamp';

  ExercisesSyncStrategy(this._exercisesSyncService);

  @override
  SyncDataType get dataType => SyncDataType.exercises;

  @override
  Future<Either<Failure, DataTypeSyncStatus>> sync() async {
    try {
      final result = await _exercisesSyncService.syncExercises();

      return result.fold(
        (failure) => Left(failure),
        (_) async {
          // Update last sync time
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

          return Right(DataTypeSyncStatus(
            type: dataType,
            isSyncing: false,
            lastSync: DateTime.now(),
          ));
        },
      );
    } catch (e) {
      return Left(NetworkFailure('Exercises sync error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> syncItem(
    String operation,
    Map<String, dynamic> data,
  ) async {
    return _exercisesSyncService.syncExercises();
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getString(_lastSyncKey);
      return timestamp != null ? DateTime.parse(timestamp) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearSyncTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastSyncKey);
    } catch (e) {
      // Ignore errors
    }
  }
}
