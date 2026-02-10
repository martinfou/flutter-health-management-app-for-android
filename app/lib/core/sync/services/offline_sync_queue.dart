import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/sync/models/offline_sync_operation.dart';
import 'package:health_app/core/sync/services/unified_sync_orchestrator.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Re-export offlineSyncQueueProvider so existing imports of offline_sync_queue continue to work
export 'package:health_app/core/sync/providers/sync_orchestrator_provider.dart'
    show offlineSyncQueueProvider;

/// Service to manage offline sync operations using Hive for persistence
///
/// Orchestrator getter is set after construction to avoid circular provider
/// dependency (offlineSyncQueueProvider -> syncOrchestratorProvider).
class OfflineSyncQueue {
  static const int _maxRetries = 5;

  final Box<OfflineSyncOperation> _box;
  UnifiedSyncOrchestrator Function()? _getOrchestrator;
  final StreamController<List<OfflineSyncOperation>> _queueController;

  OfflineSyncQueue(this._box)
      : _queueController =
            StreamController<List<OfflineSyncOperation>>.broadcast() {
    _emitLatest();
  }

  /// Set the orchestrator getter (called by syncOrchestratorProvider after init)
  void setOrchestratorGetter(UnifiedSyncOrchestrator Function() getter) {
    _getOrchestrator = getter;
  }

  Stream<List<OfflineSyncOperation>> get queueStream => _queueController.stream;

  /// Add operation to offline queue
  Future<void> enqueueOperation(OfflineSyncOperation operation) async {
    print('OfflineSyncQueue: Enqueuing operation ${operation.operation} for ${operation.dataTypeStr}');
    await _box.put(operation.id, operation);
    _emitLatest();
  }

  /// Process queued operations when online
  Future<Either<Failure, List<OfflineSyncOperation>>> processQueue() async {
    final getter = _getOrchestrator;
    if (getter == null) return const Right([]);
    return processQueueWith(getter());
  }

  /// Process queued operations with the given orchestrator
  Future<Either<Failure, List<OfflineSyncOperation>>> processQueueWith(
    UnifiedSyncOrchestrator orchestrator,
  ) async {
    if (_box.isEmpty) {
      return const Right([]);
    }

    print('OfflineSyncQueue: Processing ${_box.length} queued operations');
    final processed = <OfflineSyncOperation>[];
    final operations = _box.values.toList();

    // Sort by timestamp to preserve order
    operations.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (final operation in operations) {
      try {
        final success = await _processOperationWith(operation, orchestrator);

        if (success) {
          print('OfflineSyncQueue: Successfully processed ${operation.id}');
          await _box.delete(operation.id);
          processed.add(operation);
        } else {
          operation.retryCount++;
          if (operation.retryCount >= _maxRetries) {
            print('OfflineSyncQueue: Max retries exceeded for ${operation.id}, removing.');
            await _box.delete(operation.id);
          } else {
            await operation.save();
          }
        }
      } catch (e) {
        print('OfflineSyncQueue: Error processing ${operation.id}: $e');
      }
    }

    _emitLatest();
    return Right(processed);
  }

  /// Check if device is online
  Future<bool> isOnline() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return results.any((r) => r != ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  /// Listen for connectivity changes and process queue when online
  StreamSubscription<List<ConnectivityResult>> startConnectivityMonitoring(
    UnifiedSyncOrchestrator Function() getOrchestrator,
  ) {
    return Connectivity().onConnectivityChanged.listen((results) async {
      final hasConnectivity =
          results.any((result) => result != ConnectivityResult.none);

      if (hasConnectivity && _box.isNotEmpty) {
        print('OfflineSyncQueue: Connectivity restored, processing queue...');
        await processQueueWith(getOrchestrator());
      }
    });
  }

  /// Get current queue size
  int get queueSize => _box.length;

  /// Clear all queued operations
  Future<void> clearQueue() async {
    await _box.clear();
    _emitLatest();
  }

  void _emitLatest() {
    _queueController.add(_box.values.toList());
  }

  Future<bool> _processOperationWith(
    OfflineSyncOperation operation,
    UnifiedSyncOrchestrator orchestrator,
  ) async {
    final result = await orchestrator.syncItem(
      operation.dataType,
      operation.operation,
      operation.data,
    );
    return result.isRight();
  }

  void dispose() {
    _queueController.close();
  }
}
