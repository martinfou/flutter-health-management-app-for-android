import 'dart:async';
import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/sync/enums/sync_data_type.dart';
import 'package:health_app/core/sync/models/data_type_sync_status.dart';
import 'package:health_app/core/sync/models/sync_result.dart';
import 'package:health_app/core/sync/models/sync_state.dart';
import 'package:health_app/core/sync/strategies/sync_strategy.dart';
import 'package:health_app/core/sync/utils/sync_failure.dart';

/// Service that orchestrates sync across multiple data types
///
/// This service:
/// - Manages a collection of sync strategies (one per data type)
/// - Coordinates sync operations across all strategies
/// - Handles partial failures gracefully
/// - Aggregates results from all data types
/// - Provides overall sync state as a stream
class UnifiedSyncOrchestrator {
  /// List of registered sync strategies
  final List<SyncStrategy> _strategies;

  /// Stream controller for sync state updates
  final _stateController = StreamController<SyncState>.broadcast();

  /// Current sync state
  SyncState _currentState = const SyncState.initial();

  /// Whether a sync is currently in progress
  bool _syncing = false;

  UnifiedSyncOrchestrator({
    required List<SyncStrategy> strategies,
  }) : _strategies = strategies;

  /// Stream of sync state updates
  Stream<SyncState> get syncState => _stateController.stream;

  /// Get current sync state synchronously
  SyncState get currentState => _currentState;

  /// Whether sync is currently in progress
  bool get isSyncing => _syncing;

  /// Perform a sync operation across all registered strategies
  ///
  /// Returns either a failure or the result of the sync.
  /// Handles partial failures gracefully - if some data types fail,
  /// others will still be synced.
  Future<Either<Failure, SyncResult>> syncAll() async {
    // Prevent concurrent sync operations
    if (_syncing) {
      return Left(SyncFailure('Sync already in progress'));
    }

    _syncing = true;
    _emitState(_currentState.copyWith(isSyncing: true));

    try {
      final results = <SyncDataType, Either<Failure, DataTypeSyncStatus>>{};

      // Sync each strategy
      for (final strategy in _strategies) {
        try {
          final result = await strategy.sync();
          results[strategy.dataType] = result;
        } catch (e) {
          // Catch any exceptions and convert to failures
          results[strategy.dataType] = Left(
            SyncFailure('${strategy.dataType.displayName} sync error: ${e.toString()}'),
          );
        }
      }

      // Aggregate results
      final statusMap = <SyncDataType, DataTypeSyncStatus>{};
      final failures = <String, String>{};
      int totalSynced = 0;

      for (final entry in results.entries) {
        entry.value.fold(
          (failure) {
            failures[entry.key.displayName] = failure.message;
            statusMap[entry.key] = DataTypeSyncStatus(
              type: entry.key,
              isSyncing: false,
              error: failure.message,
            );
          },
          (status) {
            statusMap[entry.key] = status;
            if (status.itemsSynced != null) {
              totalSynced += status.itemsSynced!;
            }
          },
        );
      }

      final success = failures.isEmpty;
      final syncResult = SyncResult(
        success: success,
        totalSynced: totalSynced,
        partialFailures: failures,
        timestamp: DateTime.now(),
      );

      // Update state with result
      final newState = _currentState.copyWith(
        isSyncing: false,
        lastSyncTime: DateTime.now(),
        dataTypeStatuses: statusMap,
        lastResult: syncResult,
        errorMessage: success ? null : _formatErrors(failures),
      );

      _emitState(newState);

      return success ? Right(syncResult) : Left(SyncFailure(_formatErrors(failures)));
    } catch (e) {
      final error = SyncFailure('Sync orchestration error: ${e.toString()}');
      final newState = _currentState.copyWith(
        isSyncing: false,
        errorMessage: error.message,
      );
      _emitState(newState);
      return Left(error);
    } finally {
      _syncing = false;
    }
  }

  /// Get sync status for a specific data type
  DataTypeSyncStatus? getStatus(SyncDataType type) {
    return _currentState.getStatus(type);
  }

  /// Clear all sync timestamps (useful for logout or debugging)
  Future<void> clearAllTimestamps() async {
    for (final strategy in _strategies) {
      await strategy.clearSyncTimestamp();
    }
  }

  /// Update connectivity status
  void setConnectivity(bool connected) {
    _emitState(_currentState.copyWith(
      isConnected: connected,
      lastConnectivityCheck: DateTime.now(),
    ));
  }

  /// Close the stream and cleanup resources
  Future<void> close() async {
    await _stateController.close();
  }

  /// Emit a new state and update current state
  void _emitState(SyncState state) {
    _currentState = state;
    _stateController.add(state);
  }

  /// Format error messages for display
  String _formatErrors(Map<String, String> failures) {
    if (failures.isEmpty) return '';

    final failedTypes = failures.keys.join(', ');
    return 'Failed to sync: $failedTypes';
  }
}
