import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/medication_management/domain/entities/medication.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_frequency.dart';
import 'package:health_app/features/medication_management/domain/entities/time_of_day.dart';
import 'package:health_app/features/medication_management/domain/repositories/medication_repository.dart';

/// Use case for adding a medication
/// 
/// Validates medication data and saves it to the repository.
/// Validates name, dosage, frequency, times, and date ranges.
class AddMedicationUseCase {
  /// Medication repository
  final MedicationRepository repository;

  /// Creates an AddMedicationUseCase
  AddMedicationUseCase(this.repository);

  /// Execute the use case
  /// 
  /// Validates the medication data and saves it. Generates an ID if not provided.
  /// 
  /// Returns [ValidationFailure] if validation fails.
  /// Returns [DatabaseFailure] if save operation fails.
  Future<Result<Medication>> call({
    required String userId,
    required String name,
    required String dosage,
    required MedicationFrequency frequency,
    required List<TimeOfDay> times,
    required DateTime startDate,
    DateTime? endDate,
    bool reminderEnabled = true,
    String? id,
  }) async {
    // Generate ID if not provided
    final medicationId = id ?? _generateId();

    // Validate the medication
    final validationResult = _validateMedication(
      name: name,
      dosage: dosage,
      frequency: frequency,
      times: times,
      startDate: startDate,
      endDate: endDate,
    );
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Create medication entity
    final medication = Medication(
      id: medicationId,
      userId: userId,
      name: name,
      dosage: dosage,
      frequency: frequency,
      times: times,
      startDate: startDate,
      endDate: endDate,
      reminderEnabled: reminderEnabled,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save to repository
    return await repository.saveMedication(medication);
  }

  /// Validate medication data
  ValidationFailure? _validateMedication({
    required String name,
    required String dosage,
    required MedicationFrequency frequency,
    required List<TimeOfDay> times,
    required DateTime startDate,
    DateTime? endDate,
  }) {
    // Validate name
    if (name.trim().isEmpty) {
      return ValidationFailure('Medication name cannot be empty');
    }

    // Validate dosage
    if (dosage.trim().isEmpty) {
      return ValidationFailure('Dosage cannot be empty');
    }

    // Validate times list
    if (times.isEmpty) {
      return ValidationFailure('Medication must have at least one scheduled time');
    }

    // Validate times are unique
    final uniqueTimes = times.toSet();
    if (times.length != uniqueTimes.length) {
      return ValidationFailure('Medication cannot have duplicate scheduled times');
    }

    // Validate times are valid (hour 0-23, minute 0-59)
    for (final time in times) {
      if (time.hour < 0 || time.hour > 23) {
        return ValidationFailure('Invalid hour in scheduled time: ${time.hour}');
      }
      if (time.minute < 0 || time.minute > 59) {
        return ValidationFailure('Invalid minute in scheduled time: ${time.minute}');
      }
    }

    // Validate frequency matches number of times
    final expectedTimesCount = _getExpectedTimesCount(frequency);
    if (expectedTimesCount != null && times.length != expectedTimesCount) {
      return ValidationFailure(
        'Number of scheduled times (${times.length}) does not match frequency ($frequency)',
      );
    }

    // Validate start date is not in the future
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
    
    if (startDateOnly.isAfter(today)) {
      return ValidationFailure('Start date cannot be in the future');
    }

    // Validate end date is after start date if provided
    if (endDate != null) {
      final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
      if (endDateOnly.isBefore(startDateOnly) || endDateOnly.isAtSameMomentAs(startDateOnly)) {
        return ValidationFailure('End date must be after start date');
      }
    }

    return null;
  }

  /// Get expected number of times based on frequency
  /// Returns null if frequency doesn't require a specific count
  int? _getExpectedTimesCount(MedicationFrequency frequency) {
    switch (frequency) {
      case MedicationFrequency.daily:
        return 1;
      case MedicationFrequency.twiceDaily:
        return 2;
      case MedicationFrequency.threeTimesDaily:
        return 3;
      case MedicationFrequency.weekly:
      case MedicationFrequency.asNeeded:
        return null; // Flexible number of times
    }
  }

  /// Generate a unique ID for the medication
  String _generateId() {
    final now = DateTime.now();
    return 'medication-${now.millisecondsSinceEpoch}-${now.microsecondsSinceEpoch}';
  }
}

