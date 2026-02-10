import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/sync/enums/sync_data_type.dart';
import 'package:health_app/core/sync/models/data_type_sync_status.dart';
import 'package:health_app/core/sync/strategies/sync_strategy.dart';
import 'package:health_app/features/medication_management/data/services/medications_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Strategy for synchronizing medications data
class MedicationsSyncStrategy implements SyncStrategy {
  final MedicationsSyncService _medicationsSyncService;
  static const String _lastSyncKey = 'last_medications_sync_timestamp';

  MedicationsSyncStrategy(this._medicationsSyncService);

  @override
  SyncDataType get dataType => SyncDataType.medications;

  @override
  Future<Either<Failure, DataTypeSyncStatus>> sync() async {
    try {
      final result = await _medicationsSyncService.syncMedications();

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
      return Left(NetworkFailure('Medications sync error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> syncItem(
    String operation,
    Map<String, dynamic> data,
  ) async {
    return _medicationsSyncService.syncMedications();
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
