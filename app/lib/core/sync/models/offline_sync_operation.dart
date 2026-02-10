import 'package:hive/hive.dart';
import 'package:health_app/core/sync/enums/sync_data_type.dart';

part 'offline_sync_operation.g.dart';

/// Represents a pending sync operation that occurred while offline
@HiveType(typeId: 11)
class OfflineSyncOperation extends HiveObject {
  /// Unique identifier for this operation
  @HiveField(0)
  late String id;

  /// Type of data being synced (metrics, meals, etc)
  @HiveField(1)
  late String dataTypeStr;

  /// Type of operation ('create', 'update', 'delete')
  @HiveField(2)
  late String operation;

  /// The record data as a JSON-serializable map
  @HiveField(3)
  late Map<String, dynamic> data;

  /// When the operation was locally created
  @HiveField(4)
  late DateTime timestamp;

  /// Number of sync attempts
  @HiveField(5)
  int retryCount = 0;

  OfflineSyncOperation();

  SyncDataType get dataType => SyncDataType.values.firstWhere(
        (e) => e.name == dataTypeStr,
        orElse: () => SyncDataType.healthMetrics,
      );

  factory OfflineSyncOperation.create({
    required String id,
    required SyncDataType dataType,
    required String operation,
    required Map<String, dynamic> data,
  }) {
    return OfflineSyncOperation()
      ..id = id
      ..dataTypeStr = dataType.name
      ..operation = operation
      ..data = data
      ..timestamp = DateTime.now();
  }
}
