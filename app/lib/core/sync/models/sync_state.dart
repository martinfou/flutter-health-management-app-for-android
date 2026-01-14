import 'package:health_app/core/sync/enums/sync_data_type.dart';
import 'package:health_app/core/sync/models/data_type_sync_status.dart';
import 'package:health_app/core/sync/models/sync_result.dart';

/// Represents the overall sync state of the application
class SyncState {
  /// Whether a sync operation is currently in progress
  final bool isSyncing;

  /// When the overall sync was last completed (null if never)
  final DateTime? lastSyncTime;

  /// Sync status for each data type
  final Map<SyncDataType, DataTypeSyncStatus> dataTypeStatuses;

  /// Result of the last completed sync operation
  final SyncResult? lastResult;

  /// Error message from the last sync attempt (null if no error)
  final String? errorMessage;

  /// Whether the device has internet connectivity
  final bool isConnected;

  /// When the connectivity status was last updated
  final DateTime? lastConnectivityCheck;

  const SyncState({
    required this.isSyncing,
    this.lastSyncTime,
    required this.dataTypeStatuses,
    this.lastResult,
    this.errorMessage,
    required this.isConnected,
    this.lastConnectivityCheck,
  });

  /// Initial state with no syncs performed
  const SyncState.initial()
      : isSyncing = false,
        lastSyncTime = null,
        dataTypeStatuses = const {},
        lastResult = null,
        errorMessage = null,
        isConnected = true,
        lastConnectivityCheck = null;

  /// Whether the last sync was successful
  bool get lastSyncWasSuccessful =>
      lastResult != null && lastResult!.success;

  /// Time since last sync (or null if never synced)
  Duration? get timeSinceLastSync {
    if (lastSyncTime == null) return null;
    return DateTime.now().difference(lastSyncTime!);
  }

  /// Get status for a specific data type
  DataTypeSyncStatus? getStatus(SyncDataType type) =>
      dataTypeStatuses[type];

  /// Count of data types synced since last operation
  int get totalDataTypesSynced =>
      lastResult?.totalSynced ?? 0;

  /// Create a copy with modified fields
  SyncState copyWith({
    bool? isSyncing,
    DateTime? lastSyncTime,
    Map<SyncDataType, DataTypeSyncStatus>? dataTypeStatuses,
    SyncResult? lastResult,
    String? errorMessage,
    bool? isConnected,
    DateTime? lastConnectivityCheck,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      dataTypeStatuses: dataTypeStatuses ?? this.dataTypeStatuses,
      lastResult: lastResult ?? this.lastResult,
      errorMessage: errorMessage ?? this.errorMessage,
      isConnected: isConnected ?? this.isConnected,
      lastConnectivityCheck: lastConnectivityCheck ?? this.lastConnectivityCheck,
    );
  }

  /// Get human-readable time since last sync
  String? get lastSyncDisplay {
    if (lastSyncTime == null) return 'Never synced';

    final diff = timeSinceLastSync;
    if (diff == null) return null;

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
  }

  @override
  String toString() =>
      'SyncState(isSyncing: $isSyncing, lastSyncTime: $lastSyncTime, isConnected: $isConnected, errorMessage: $errorMessage)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncState &&
          runtimeType == other.runtimeType &&
          isSyncing == other.isSyncing &&
          lastSyncTime == other.lastSyncTime &&
          dataTypeStatuses == other.dataTypeStatuses &&
          lastResult == other.lastResult &&
          errorMessage == other.errorMessage &&
          isConnected == other.isConnected;

  @override
  int get hashCode =>
      isSyncing.hashCode ^
      lastSyncTime.hashCode ^
      dataTypeStatuses.hashCode ^
      lastResult.hashCode ^
      errorMessage.hashCode ^
      isConnected.hashCode;
}
