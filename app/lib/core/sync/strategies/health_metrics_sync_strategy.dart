import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/sync/enums/sync_data_type.dart';
import 'package:health_app/core/sync/services/offline_sync_queue.dart';
import 'package:health_app/core/sync/models/data_type_sync_status.dart';
import 'package:health_app/core/sync/strategies/sync_strategy.dart';
import 'package:health_app/core/sync/utils/sync_failure.dart';
import 'package:health_app/features/health_tracking/data/services/health_metrics_sync_service.dart' hide SyncFailure;
import 'package:shared_preferences/shared_preferences.dart';

// ignore: avoid_private_typedef_functions
typedef _GetFailure = Failure Function();
typedef _FoldFunction = Either<Failure, dynamic> Function();


/// Strategy for syncing health metrics
///
/// Wraps the existing HealthMetricsSyncService to implement the SyncStrategy interface.
/// Includes automatic retry with exponential backoff for transient failures.
class HealthMetricsSyncStrategy implements SyncStrategy {
  final HealthMetricsSyncService _syncService;
  final OfflineSyncQueue _offlineQueue;
  static const String _lastSyncKey = 'last_health_metrics_sync_timestamp';
  static const String _lastSyncErrorKey = 'last_health_metrics_sync_error';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  HealthMetricsSyncStrategy(this._syncService, this._offlineQueue);

  @override
  SyncDataType get dataType => SyncDataType.healthMetrics;

  @override
  Future<Either<Failure, DataTypeSyncStatus>> sync() async {
    return _syncWithRetry(0);
  }

  /// Sync with automatic retry on transient failures
  Future<Either<Failure, DataTypeSyncStatus>> _syncWithRetry(int attemptCount) async {
    try {
      // Perform the sync using the existing service
      final result = await _syncService.syncHealthMetrics();

      // Handle the result
      if (result.isLeft()) {
        // Extract the failure
        Failure? failure;
        result.fold(
          (f) => failure = f,
          (_) {},
        );

        if (failure != null) {
          // Check if failure is transient (network error) vs permanent
          final errorMsg = failure!.message.toLowerCase();
          final isTransient = failure is NetworkFailure ||
              errorMsg.contains('network') ||
              errorMsg.contains('timeout') ||
              errorMsg.contains('connection');

          // Retry on transient failures
          if (isTransient && attemptCount < _maxRetries) {
            final delayMs = _retryDelay.inMilliseconds * (1 << attemptCount); // exponential backoff
            print('HealthMetricsSyncStrategy: Retry ${attemptCount + 1}/$_maxRetries after ${delayMs}ms due to: ${failure!.message}');
            await Future.delayed(Duration(milliseconds: delayMs));
            return _syncWithRetry(attemptCount + 1);
          }

          // Save error for UI display
          await _saveLastSyncError(failure!.message);
        }

        // Return the failure
        return result as Either<Failure, DataTypeSyncStatus>;
      }

      // Sync succeeded - clear error and get last sync time
      await _clearLastSyncError();
      final lastSync = await getLastSyncTime();

      return Right(DataTypeSyncStatus(
        type: dataType,
        isSyncing: false,
        lastSync: lastSync,
        itemsSynced: null, // Not tracked by existing service
        error: null,
      ));
    } catch (e) {
      // Retry on unexpected errors
      if (attemptCount < _maxRetries) {
        final delayMs = _retryDelay.inMilliseconds * (1 << attemptCount);
        print('HealthMetricsSyncStrategy: Retry ${attemptCount + 1}/$_maxRetries after ${delayMs}ms due to: $e');
        await Future.delayed(Duration(milliseconds: delayMs));
        return _syncWithRetry(attemptCount + 1);
      }

      final errorMsg = 'Health metrics sync error: ${e.toString()}';
      await _saveLastSyncError(errorMsg);

      return Left(SyncFailure(errorMsg));
    }
  }

  /// Save last sync error for UI display
  Future<void> _saveLastSyncError(String error) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncErrorKey, error);
    } catch (e) {
      print('HealthMetricsSyncStrategy: Failed to save sync error: $e');
    }
  }

  /// Clear last sync error
  Future<void> _clearLastSyncError() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastSyncErrorKey);
    } catch (e) {
      print('HealthMetricsSyncStrategy: Failed to clear sync error: $e');
    }
  }

  /// Get last sync error for UI display
  Future<String?> getLastSyncError() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastSyncErrorKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Either<Failure, void>> syncItem(String operation, Map<String, dynamic> data) async {
    try {
      final result = await _syncService.syncHealthMetrics();
      return result.map((_) => null);
    } catch (e) {
      return Left(SyncFailure('Single health metric sync failed: $e'));
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
