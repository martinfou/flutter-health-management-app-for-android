import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/sync/enums/sync_data_type.dart';
import 'package:health_app/core/sync/models/data_type_sync_status.dart';
import 'package:health_app/core/sync/strategies/sync_strategy.dart';
import 'package:health_app/core/sync/utils/sync_failure.dart';
import 'package:health_app/features/health_tracking/data/services/health_metrics_sync_service.dart' hide SyncFailure;
import 'package:shared_preferences/shared_preferences.dart';

/// Strategy for syncing health metrics
///
/// Wraps the existing HealthMetricsSyncService to implement the SyncStrategy interface.
class HealthMetricsSyncStrategy implements SyncStrategy {
  final HealthMetricsSyncService _syncService;
  static const String _lastSyncKey = 'last_health_metrics_sync_timestamp';

  HealthMetricsSyncStrategy(this._syncService);

  @override
  SyncDataType get dataType => SyncDataType.healthMetrics;

  @override
  Future<Either<Failure, DataTypeSyncStatus>> sync() async {
    try {
      // Perform the sync using the existing service
      final result = await _syncService.syncHealthMetrics();

      // Handle the result
      if (result.isLeft()) {
        // Extract the failure from Left
        return result as Either<Failure, DataTypeSyncStatus>;
      }

      // Sync succeeded - get last sync time and return status
      final lastSync = await getLastSyncTime();
      return Right(DataTypeSyncStatus(
        type: dataType,
        isSyncing: false,
        lastSync: lastSync,
        itemsSynced: null, // Not tracked by existing service
        error: null,
      ));
    } catch (e) {
      return Left(SyncFailure('Health metrics sync error: ${e.toString()}'));
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
      await _syncService.clearSyncTimestamp();
    } catch (e) {
      // Silently ignore errors when clearing
    }
  }
}
