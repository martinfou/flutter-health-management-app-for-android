import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_log.dart';
import 'package:health_app/features/medication_management/domain/repositories/medication_repository.dart';

/// Use case for logging a medication dose
/// 
/// Validates medication log data and saves it to the repository.
/// Validates that the medication exists and that the log data is valid.
class LogMedicationDoseUseCase {
  /// Medication repository
  final MedicationRepository repository;

  /// Creates a LogMedicationDoseUseCase
  LogMedicationDoseUseCase(this.repository);

  /// Execute the use case
  /// 
  /// Validates the medication log data and saves it. Generates an ID if not provided.
  /// Optionally validates that the medication exists.
  /// 
  /// Returns [ValidationFailure] if validation fails.
  /// Returns [NotFoundFailure] if medication doesn't exist (when validateMedication is true).
  /// Returns [DatabaseFailure] if save operation fails.
  Future<Result<MedicationLog>> call({
    required String medicationId,
    required String dosage,
    DateTime? takenAt,
    String? notes,
    String? id,
    bool validateMedication = true,
  }) async {
    // Generate ID if not provided
    final logId = id ?? _generateId();
    final logTakenAt = takenAt ?? DateTime.now();

    // Validate medication exists if requested
    if (validateMedication) {
      final medicationResult = await repository.getMedication(medicationId);
      if (medicationResult.isLeft()) {
        return medicationResult.fold(
          (failure) => Left(failure),
          (_) => throw StateError('Unexpected success'),
        );
      }
    }

    // Validate the medication log
    final validationResult = _validateMedicationLog(
      dosage: dosage,
      takenAt: logTakenAt,
    );
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Create medication log entity
    final log = MedicationLog(
      id: logId,
      medicationId: medicationId,
      takenAt: logTakenAt,
      dosage: dosage,
      notes: notes,
      createdAt: DateTime.now(),
    );

    // Save to repository
    return await repository.saveMedicationLog(log);
  }

  /// Validate medication log data
  ValidationFailure? _validateMedicationLog({
    required String dosage,
    required DateTime takenAt,
  }) {
    // Validate dosage
    if (dosage.trim().isEmpty) {
      return ValidationFailure('Dosage cannot be empty');
    }

    // Validate takenAt is not in the future
    final now = DateTime.now();
    if (takenAt.isAfter(now)) {
      return ValidationFailure('Medication cannot be logged in the future');
    }

    // Validate takenAt is not too far in the past (e.g., more than 1 year)
    final oneYearAgo = now.subtract(Duration(days: 365));
    if (takenAt.isBefore(oneYearAgo)) {
      return ValidationFailure('Medication log date cannot be more than 1 year in the past');
    }

    return null;
  }

  /// Generate a unique ID for the medication log
  String _generateId() {
    final now = DateTime.now();
    return 'medication-log-${now.millisecondsSinceEpoch}-${now.microsecondsSinceEpoch}';
  }
}

