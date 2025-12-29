import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/medication_management/domain/entities/medication.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_log.dart';

/// Type alias for repository result
typedef MedicationResult = Result<Medication>;
typedef MedicationListResult = Result<List<Medication>>;
typedef MedicationLogResult = Result<MedicationLog>;
typedef MedicationLogListResult = Result<List<MedicationLog>>;

/// Medication repository interface
/// 
/// Defines the contract for medication data operations.
/// Implementation is in the data layer.
abstract class MedicationRepository {
  /// Get medication by ID
  /// 
  /// Returns [NotFoundFailure] if medication doesn't exist.
  Future<MedicationResult> getMedication(String id);

  /// Get all medications for a user
  Future<MedicationListResult> getMedicationsByUserId(String userId);

  /// Get active medications for a user
  Future<MedicationListResult> getActiveMedications(String userId);

  /// Save medication
  /// 
  /// Creates new medication or updates existing one.
  /// Returns [ValidationFailure] if medication data is invalid.
  Future<MedicationResult> saveMedication(Medication medication);

  /// Update medication
  /// 
  /// Updates existing medication.
  /// Returns [NotFoundFailure] if medication doesn't exist.
  /// Returns [ValidationFailure] if medication data is invalid.
  Future<MedicationResult> updateMedication(Medication medication);

  /// Delete medication
  /// 
  /// Returns [NotFoundFailure] if medication doesn't exist.
  Future<Result<void>> deleteMedication(String id);

  /// Get medication log by ID
  /// 
  /// Returns [NotFoundFailure] if log doesn't exist.
  Future<MedicationLogResult> getMedicationLog(String id);

  /// Get all medication logs for a medication
  Future<MedicationLogListResult> getMedicationLogsByMedicationId(
    String medicationId,
  );

  /// Get medication logs for a date range
  Future<MedicationLogListResult> getMedicationLogsByDateRange(
    String medicationId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Save medication log
  /// 
  /// Creates new log entry.
  /// Returns [ValidationFailure] if log data is invalid.
  Future<MedicationLogResult> saveMedicationLog(MedicationLog log);

  /// Delete medication log
  /// 
  /// Returns [NotFoundFailure] if log doesn't exist.
  Future<Result<void>> deleteMedicationLog(String id);
}

