import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/medication_management/domain/entities/medication.dart';
import 'package:health_app/features/medication_management/domain/repositories/medication_repository.dart';

/// Medication reminder result
class MedicationReminder {
  /// Medication that needs reminder
  final Medication medication;

  /// Scheduled time for the reminder
  final DateTime scheduledTime;

  /// Whether the medication has been taken today at this time
  final bool isTaken;

  /// Last taken time (if taken)
  final DateTime? lastTakenAt;

  MedicationReminder({
    required this.medication,
    required this.scheduledTime,
    required this.isTaken,
    this.lastTakenAt,
  });
}

/// Use case for checking medication reminders
/// 
/// Checks active medications with reminders enabled and determines
/// which medications need reminders based on their schedule and
/// whether they've been taken.
class CheckMedicationRemindersUseCase {
  /// Medication repository
  final MedicationRepository repository;

  /// Creates a CheckMedicationRemindersUseCase
  CheckMedicationRemindersUseCase(this.repository);

  /// Execute the use case
  /// 
  /// Gets active medications for the user and checks which ones need reminders.
  /// A medication needs a reminder if:
  /// - It's active and has reminders enabled
  /// - Current time matches or is past a scheduled time
  /// - It hasn't been taken at that scheduled time today
  /// 
  /// Returns [Right] with list of MedicationReminder objects.
  Future<Result<List<MedicationReminder>>> call(String userId) async {
    // Get active medications
    final medicationsResult = await repository.getActiveMedications(userId);
    
    return medicationsResult.fold(
      (failure) => Left(failure),
      (medications) async {
        final reminders = <MedicationReminder>[];
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        for (final medication in medications) {
          // Skip if reminders are disabled
          if (!medication.reminderEnabled) {
            continue;
          }

          // Check each scheduled time
          for (final scheduledTime in medication.times) {
            // Create scheduled DateTime for today
            final scheduledDateTime = DateTime(
              today.year,
              today.month,
              today.day,
              scheduledTime.hour,
              scheduledTime.minute,
            );

            // Check if it's time for this reminder (current time >= scheduled time)
            if (now.isBefore(scheduledDateTime)) {
              continue; // Not time yet
            }

            // Check if medication has been taken today at this scheduled time
            final logsResult = await repository.getMedicationLogsByDateRange(
              medication.id,
              today,
              today.add(Duration(days: 1)),
            );

            final isTaken = logsResult.fold(
              (_) => false,
              (logs) {
                // Check if any log exists for today
                // For simplicity, we check if there's any log today
                // In a more sophisticated implementation, we could check
                // if the log is close to the scheduled time
                return logs.isNotEmpty;
              },
            );

            // Add reminder if not taken
            if (!isTaken) {
              reminders.add(MedicationReminder(
                medication: medication,
                scheduledTime: scheduledDateTime,
                isTaken: false,
                lastTakenAt: null,
              ));
            }
          }
        }

        return Right(reminders);
      },
    );
  }

  /// Get reminders for a specific medication
  /// 
  /// Convenience method to check reminders for a single medication.
  Future<Result<List<MedicationReminder>>> getRemindersForMedication(
    String medicationId,
  ) async {
    // Get medication
    final medicationResult = await repository.getMedication(medicationId);
    
    return medicationResult.fold(
      (failure) => Left(failure),
      (medication) async {
        if (!medication.isActive || !medication.reminderEnabled) {
          return Right(<MedicationReminder>[]);
        }

        final reminders = <MedicationReminder>[];
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // Check each scheduled time
        for (final scheduledTime in medication.times) {
          final scheduledDateTime = DateTime(
            today.year,
            today.month,
            today.day,
            scheduledTime.hour,
            scheduledTime.minute,
          );

          if (now.isBefore(scheduledDateTime)) {
            continue;
          }

          // Check if taken
          final logsResult = await repository.getMedicationLogsByDateRange(
            medication.id,
            today,
            today.add(Duration(days: 1)),
          );

          final isTaken = logsResult.fold(
            (_) => false,
            (logs) => logs.isNotEmpty,
          );

          if (!isTaken) {
            reminders.add(MedicationReminder(
              medication: medication,
              scheduledTime: scheduledDateTime,
              isTaken: false,
              lastTakenAt: null,
            ));
          }
        }

        return Right(reminders);
      },
    );
  }
}

