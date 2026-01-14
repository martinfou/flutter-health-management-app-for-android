import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/sync/enums/sync_data_type.dart';
import 'package:health_app/core/sync/models/data_type_sync_status.dart';

/// Abstract strategy for syncing a specific data type
///
/// Each data type (Health Metrics, Meals, Exercises, etc.) implements
/// this interface to handle its own sync logic.
abstract class SyncStrategy {
  /// The type of data this strategy handles
  SyncDataType get dataType;

  /// Perform the sync operation for this data type
  ///
  /// Returns either a failure or the updated sync status for this data type.
  /// Should handle its own error recovery and retry logic.
  Future<Either<Failure, DataTypeSyncStatus>> sync();

  /// Get the last time this data type was synced
  ///
  /// Returns null if never synced before.
  Future<DateTime?> getLastSyncTime();

  /// Clear the sync timestamp for this data type
  ///
  /// Useful for logout or debugging.
  Future<void> clearSyncTimestamp();
}
