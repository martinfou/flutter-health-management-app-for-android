import 'package:health_app/core/sync/enums/sync_data_type.dart';

/// Represents the sync status for a specific data type
class DataTypeSyncStatus {
  /// Type of data being synced
  final SyncDataType type;

  /// Whether this data type is currently syncing
  final bool isSyncing;

  /// When this data type was last synced (null if never)
  final DateTime? lastSync;

  /// Number of items synced in last operation (null if unknown)
  final int? itemsSynced;

  /// Error message if sync failed (null if successful)
  final String? error;

  /// Percentage of sync completion (0-100, null if not applicable)
  final int? progress;

  const DataTypeSyncStatus({
    required this.type,
    required this.isSyncing,
    this.lastSync,
    this.itemsSynced,
    this.error,
    this.progress,
  });

  /// Whether this data type's last sync was successful
  bool get wasSuccessful => error == null;

  /// Create a copy with modified fields
  DataTypeSyncStatus copyWith({
    SyncDataType? type,
    bool? isSyncing,
    DateTime? lastSync,
    int? itemsSynced,
    String? error,
    int? progress,
  }) {
    return DataTypeSyncStatus(
      type: type ?? this.type,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSync: lastSync ?? this.lastSync,
      itemsSynced: itemsSynced ?? this.itemsSynced,
      error: error ?? this.error,
      progress: progress ?? this.progress,
    );
  }

  @override
  String toString() =>
      'DataTypeSyncStatus(type: $type, isSyncing: $isSyncing, lastSync: $lastSync, itemsSynced: $itemsSynced, error: $error)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataTypeSyncStatus &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          isSyncing == other.isSyncing &&
          lastSync == other.lastSync &&
          itemsSynced == other.itemsSynced &&
          error == other.error &&
          progress == other.progress;

  @override
  int get hashCode =>
      type.hashCode ^
      isSyncing.hashCode ^
      lastSync.hashCode ^
      itemsSynced.hashCode ^
      error.hashCode ^
      progress.hashCode;
}
