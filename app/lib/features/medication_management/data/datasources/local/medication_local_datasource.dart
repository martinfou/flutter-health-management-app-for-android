import 'package:hive_flutter/hive_flutter.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/providers/database_provider.dart';
import 'package:health_app/features/medication_management/data/models/medication_model.dart';
import 'package:health_app/features/medication_management/data/models/medication_log_model.dart';
import 'package:health_app/features/medication_management/domain/entities/medication.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_log.dart';

/// Local data source for Medication and MedicationLog
/// 
/// Handles direct Hive database operations for medications and logs.
class MedicationLocalDataSource {
  /// Get Hive box for medications
  Box<MedicationModel> get _medicationsBox {
    if (!Hive.isBoxOpen(HiveBoxNames.medications)) {
      throw DatabaseFailure('Medications box is not open');
    }
    return Hive.box<MedicationModel>(HiveBoxNames.medications);
  }

  /// Get Hive box for medication logs
  Box<MedicationLogModel> get _medicationLogsBox {
    if (!Hive.isBoxOpen(HiveBoxNames.medicationLogs)) {
      throw DatabaseFailure('Medication logs box is not open');
    }
    return Hive.box<MedicationLogModel>(HiveBoxNames.medicationLogs);
  }

  /// Get medication by ID
  Future<Result<Medication>> getMedication(String id) async {
    try {
      final box = _medicationsBox;
      final model = box.get(id);
      
      if (model == null) {
        return Left(NotFoundFailure('Medication'));
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get medication: $e'));
    }
  }

  /// Get all medications for a user
  Future<Result<List<Medication>>> getMedicationsByUserId(
    String userId,
  ) async {
    try {
      final box = _medicationsBox;
      final models = box.values
          .where((model) => model.userId == userId)
          .map((model) => model.toEntity())
          .toList();
      
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get medications: $e'));
    }
  }

  /// Get active medications for a user
  Future<Result<List<Medication>>> getActiveMedications(String userId) async {
    try {
      final box = _medicationsBox;
      final now = DateTime.now();
      final models = box.values
          .where((model) {
            if (model.userId != userId) return false;
            if (model.endDate == null) return true;
            return now.isBefore(model.endDate!);
          })
          .map((model) => model.toEntity())
          .toList();
      
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get active medications: $e'));
    }
  }

  /// Save medication
  Future<Result<Medication>> saveMedication(Medication medication) async {
    try {
      final box = _medicationsBox;
      final model = MedicationModel.fromEntity(medication);
      await box.put(medication.id, model);
      return Right(medication);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save medication: $e'));
    }
  }

  /// Update medication
  Future<Result<Medication>> updateMedication(Medication medication) async {
    try {
      final box = _medicationsBox;
      final existing = box.get(medication.id);
      
      if (existing == null) {
        return Left(NotFoundFailure('Medication'));
      }

      final model = MedicationModel.fromEntity(medication);
      await box.put(medication.id, model);
      return Right(medication);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update medication: $e'));
    }
  }

  /// Delete medication
  Future<Result<void>> deleteMedication(String id) async {
    try {
      final box = _medicationsBox;
      final model = box.get(id);
      
      if (model == null) {
        return Left(NotFoundFailure('Medication'));
      }

      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete medication: $e'));
    }
  }

  /// Get medication log by ID
  Future<Result<MedicationLog>> getMedicationLog(String id) async {
    try {
      final box = _medicationLogsBox;
      final model = box.get(id);
      
      if (model == null) {
        return Left(NotFoundFailure('MedicationLog'));
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get medication log: $e'));
    }
  }

  /// Get all medication logs for a medication
  Future<Result<List<MedicationLog>>> getMedicationLogsByMedicationId(
    String medicationId,
  ) async {
    try {
      final box = _medicationLogsBox;
      final models = box.values
          .where((model) => model.medicationId == medicationId)
          .map((model) => model.toEntity())
          .toList();
      
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get medication logs: $e'));
    }
  }

  /// Get medication logs for a date range
  Future<Result<List<MedicationLog>>> getMedicationLogsByDateRange(
    String medicationId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final box = _medicationLogsBox;
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      
      final models = box.values
          .where((model) {
            if (model.medicationId != medicationId) return false;
            return model.takenAt.isAfter(start.subtract(const Duration(days: 1))) &&
                model.takenAt.isBefore(end.add(const Duration(days: 1)));
          })
          .map((model) => model.toEntity())
          .toList();
      
      return Right(models);
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to get medication logs by date range: $e'),
      );
    }
  }

  /// Save medication log
  Future<Result<MedicationLog>> saveMedicationLog(MedicationLog log) async {
    try {
      final box = _medicationLogsBox;
      final model = MedicationLogModel.fromEntity(log);
      await box.put(log.id, model);
      return Right(log);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save medication log: $e'));
    }
  }

  /// Delete medication log
  Future<Result<void>> deleteMedicationLog(String id) async {
    try {
      final box = _medicationLogsBox;
      final model = box.get(id);

      if (model == null) {
        return Left(NotFoundFailure('MedicationLog'));
      }

      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete medication log: $e'));
    }
  }

  /// Batch save medications with conflict resolution
  ///
  /// Saves multiple medications in a single operation for better performance.
  /// Uses timestamp-based conflict resolution: only overwrites local data if
  /// incoming medication is newer (has later updatedAt).
  ///
  /// This ensures that in case of concurrent edits, the latest version wins.
  Future<Result<List<Medication>>> saveMedicationsBatch(
    List<Medication> medications,
  ) async {
    try {
      final box = _medicationsBox;
      final modelsMap = <String, MedicationModel>{};
      int skippedCount = 0;

      for (final medication in medications) {
        final existing = box.get(medication.id);

        // Conflict resolution: Compare timestamps
        if (existing != null) {
          // Only overwrite if incoming medication is newer
          if (medication.updatedAt.isBefore(existing.updatedAt)) {
            // Skip this medication - local version is newer
            skippedCount++;
            continue;
          }
        }

        // Either no existing record or incoming is newer - save it
        modelsMap[medication.id] = MedicationModel.fromEntity(medication);
      }

      // Use batch put operation
      await box.putAll(modelsMap);

      if (skippedCount > 0) {
        print('saveMedicationsBatch: Skipped $skippedCount medications (local versions are newer)');
      }

      return Right(medications);
    } catch (e) {
      return Left(DatabaseFailure('Failed to batch save medications: $e'));
    }
  }
}

