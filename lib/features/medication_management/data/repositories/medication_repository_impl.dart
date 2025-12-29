import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/medication_management/domain/entities/medication.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_log.dart';
import 'package:health_app/features/medication_management/domain/repositories/medication_repository.dart';
import 'package:health_app/features/medication_management/data/datasources/local/medication_local_datasource.dart';

/// Medication repository implementation
/// 
/// Implements the MedicationRepository interface using local data source.
class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationLocalDataSource _localDataSource;

  MedicationRepositoryImpl(this._localDataSource);

  @override
  Future<MedicationResult> getMedication(String id) async {
    return await _localDataSource.getMedication(id);
  }

  @override
  Future<MedicationListResult> getMedicationsByUserId(String userId) async {
    return await _localDataSource.getMedicationsByUserId(userId);
  }

  @override
  Future<MedicationListResult> getActiveMedications(String userId) async {
    return await _localDataSource.getActiveMedications(userId);
  }

  @override
  Future<MedicationResult> saveMedication(Medication medication) async {
    // Validation
    if (medication.name.isEmpty) {
      return Left(ValidationFailure('Medication name cannot be empty'));
    }
    if (medication.dosage.isEmpty) {
      return Left(ValidationFailure('Dosage cannot be empty'));
    }
    if (medication.times.isEmpty) {
      return Left(ValidationFailure('At least one time must be specified'));
    }
    if (medication.times.length > 10) {
      return Left(ValidationFailure('Maximum 10 times per day allowed'));
    }
    if (medication.startDate.isAfter(DateTime.now())) {
      return Left(ValidationFailure('Start date cannot be in the future'));
    }
    if (medication.endDate != null &&
        medication.endDate!.isBefore(medication.startDate)) {
      return Left(
        ValidationFailure('End date must be after start date'),
      );
    }

    return await _localDataSource.saveMedication(medication);
  }

  @override
  Future<MedicationResult> updateMedication(Medication medication) async {
    // Validation (same as save)
    if (medication.name.isEmpty) {
      return Left(ValidationFailure('Medication name cannot be empty'));
    }
    if (medication.dosage.isEmpty) {
      return Left(ValidationFailure('Dosage cannot be empty'));
    }
    if (medication.times.isEmpty) {
      return Left(ValidationFailure('At least one time must be specified'));
    }

    return await _localDataSource.updateMedication(medication);
  }

  @override
  Future<Result<void>> deleteMedication(String id) async {
    return await _localDataSource.deleteMedication(id);
  }

  @override
  Future<MedicationLogResult> getMedicationLog(String id) async {
    return await _localDataSource.getMedicationLog(id);
  }

  @override
  Future<MedicationLogListResult> getMedicationLogsByMedicationId(
    String medicationId,
  ) async {
    return await _localDataSource.getMedicationLogsByMedicationId(medicationId);
  }

  @override
  Future<MedicationLogListResult> getMedicationLogsByDateRange(
    String medicationId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Validation
    if (startDate.isAfter(endDate)) {
      return Left(
        ValidationFailure('Start date must be before or equal to end date'),
      );
    }

    return await _localDataSource.getMedicationLogsByDateRange(
      medicationId,
      startDate,
      endDate,
    );
  }

  @override
  Future<MedicationLogResult> saveMedicationLog(MedicationLog log) async {
    // Validation
    if (log.dosage.isEmpty) {
      return Left(ValidationFailure('Dosage cannot be empty'));
    }
    if (log.takenAt.isAfter(DateTime.now())) {
      return Left(ValidationFailure('Taken date cannot be in the future'));
    }

    return await _localDataSource.saveMedicationLog(log);
  }

  @override
  Future<Result<void>> deleteMedicationLog(String id) async {
    return await _localDataSource.deleteMedicationLog(id);
  }
}

