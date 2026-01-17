import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/sync/enums/sync_data_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Offline sync operation
class OfflineSyncOperation {
  final String id;
  final SyncDataType dataType;
  final String operation; // 'create', 'update', 'delete'
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;

  const OfflineSyncOperation({
    required this.id,
    required this.dataType,
    required this.operation,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dataType': dataType.name,
      'operation': operation,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  factory OfflineSyncOperation.fromJson(Map<String, dynamic> json) {
    return OfflineSyncOperation(
      id: json['id'],
      dataType: SyncDataType.values.firstWhere(
        (type) => type.name == json['dataType'],
        orElse: () => SyncDataType.healthMetrics,
      ),
      operation: json['operation'],
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp']),
      retryCount: json['retryCount'] ?? 0,
    );
  }

  OfflineSyncOperation copyWith({
    int? retryCount,
  }) {
    return OfflineSyncOperation(
      id: id,
      dataType: dataType,
      operation: operation,
      data: data,
      timestamp: timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

/// Service to manage offline sync operations
class OfflineSyncQueue {
  static const String _queueKey = 'offline_sync_queue';
  static const int _maxRetries = 3;

  final SharedPreferences _prefs;
  final StreamController<List<OfflineSyncOperation>> _queueController;

  OfflineSyncQueue(this._prefs)
      : _queueController =
            StreamController<List<OfflineSyncOperation>>.broadcast();

  Stream<List<OfflineSyncOperation>> get queueStream => _queueController.stream;

  /// Add operation to offline queue
  Future<void> enqueueOperation(OfflineSyncOperation operation) async {
    final queue = await _getQueue();
    queue.add(operation);
    await _saveQueue(queue);
    _queueController.add(queue);
  }

  /// Process queued operations when online
  Future<Either<Failure, List<OfflineSyncOperation>>> processQueue() async {
    final queue = await _getQueue();
    if (queue.isEmpty) {
      return const Right([]);
    }

    final processed = <OfflineSyncOperation>[];
    final failed = <OfflineSyncOperation>[];

    for (final operation in queue) {
      try {
        // Here you would call the appropriate sync service
        // For now, we'll just simulate success/failure
        final success = await _processOperation(operation);

        if (success) {
          processed.add(operation);
        } else if (operation.retryCount < _maxRetries) {
          // Increment retry count and keep in queue
          final updatedOperation = operation.copyWith(
            retryCount: operation.retryCount + 1,
          );
          failed.add(updatedOperation);
        } else {
          // Max retries exceeded, remove from queue
          print('Max retries exceeded for operation: ${operation.id}');
        }
      } catch (e) {
        print('Error processing operation ${operation.id}: $e');
        if (operation.retryCount < _maxRetries) {
          failed.add(operation.copyWith(retryCount: operation.retryCount + 1));
        }
      }
    }

    // Update queue with failed operations
    final newQueue = failed;
    await _saveQueue(newQueue);
    _queueController.add(newQueue);

    return Right(processed);
  }

  /// Check if device is online
  Future<bool> isOnline() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  /// Listen for connectivity changes and process queue when online
  StreamSubscription<List<ConnectivityResult>> startConnectivityMonitoring() {
    return Connectivity().onConnectivityChanged.listen((results) async {
      // Check if any result indicates connectivity
      final hasConnectivity =
          results.any((result) => result != ConnectivityResult.none);

      if (hasConnectivity) {
        print('Connectivity restored, processing offline queue...');
        final result = await processQueue();
        result.fold(
          (failure) =>
              print('Failed to process offline queue: ${failure.message}'),
          (processed) =>
              print('Processed ${processed.length} offline operations'),
        );
      }
    });
  }

  /// Get current queue size
  Future<int> getQueueSize() async {
    final queue = await _getQueue();
    return queue.length;
  }

  /// Clear all queued operations
  Future<void> clearQueue() async {
    await _saveQueue([]);
    _queueController.add([]);
  }

  Future<List<OfflineSyncOperation>> _getQueue() async {
    final queueJson = _prefs.getStringList(_queueKey) ?? [];
    return queueJson.map((json) {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      return OfflineSyncOperation.fromJson(decoded);
    }).toList();
  }

  Future<void> _saveQueue(List<OfflineSyncOperation> queue) async {
    final queueJson = queue.map((op) => jsonEncode(op.toJson())).toList();
    await _prefs.setStringList(_queueKey, queueJson);
  }

  /// Simulate processing an operation (replace with actual sync logic)
  Future<bool> _processOperation(OfflineSyncOperation operation) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate 90% success rate
    return DateTime.now().millisecondsSinceEpoch % 10 != 0;
  }

  void dispose() {
    _queueController.close();
  }
}

/// Provider for OfflineSyncQueue
final offlineSyncQueueProvider = FutureProvider<OfflineSyncQueue>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final queue = OfflineSyncQueue(prefs);

  // Start connectivity monitoring
  final subscription = queue.startConnectivityMonitoring();

  // Clean up subscription when provider is disposed
  ref.onDispose(() {
    subscription.cancel();
    queue.dispose();
  });

  return queue;
});
