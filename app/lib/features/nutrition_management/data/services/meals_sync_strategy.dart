import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/sync/enums/sync_data_type.dart';
import 'package:health_app/core/sync/models/data_type_sync_status.dart';
import 'package:health_app/core/sync/strategies/sync_strategy.dart';
import 'package:health_app/features/nutrition_management/data/services/meals_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Strategy for synchronizing meals data
class MealsSyncStrategy implements SyncStrategy {
  final MealsSyncService _mealsSyncService;
  static const String _lastSyncKey = 'last_meals_sync_timestamp';

  MealsSyncStrategy(this._mealsSyncService);

  @override
  SyncDataType get dataType => SyncDataType.meals;

  @override
  Future<Either<Failure, DataTypeSyncStatus>> sync() async {
    try {
      final result = await _mealsSyncService.syncMeals();

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
      return Left(NetworkFailure('Meals sync error: ${e.toString()}'));
    }
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
