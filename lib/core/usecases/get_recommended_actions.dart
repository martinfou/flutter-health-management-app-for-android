// Dart SDK
import 'package:health_app/core/entities/recommended_action.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/medication_management/domain/entities/medication.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_log.dart';

/// Use case to get recommended actions for home screen
/// 
/// Determines what actions the user should take next based on:
/// - Time of day
/// - Medication schedules
/// - Missing critical metrics
/// - User patterns and preferences
class GetRecommendedActions {
  /// Get recommended actions
  /// 
  /// Returns list of actions sorted by priority (highest priority first).
  List<RecommendedAction> call({
    required List<HealthMetric> todayMetrics,
    required List<Medication> activeMedications,
    required List<MedicationLog> todayMedicationLogs,
    required DateTime now,
  }) {
    final actions = <RecommendedAction>[];

    // 1. Check for due medications (highest priority)
    final medicationActions = _getMedicationActions(
      activeMedications,
      todayMedicationLogs,
      now,
    );
    actions.addAll(medicationActions);

    // 2. Check for missing critical metrics based on time of day
    final timeBasedActions = _getTimeBasedActions(todayMetrics, now);
    actions.addAll(timeBasedActions);

    // 3. Check for missing critical metrics (always important)
    final criticalActions = _getCriticalMetricActions(todayMetrics);
    actions.addAll(criticalActions);

    // Sort by priority (lower number = higher priority)
    actions.sort((a, b) => a.priority.compareTo(b.priority));

    // Return top 3-5 actions
    return actions.take(5).toList();
  }

  /// Get medication actions that are due
  List<RecommendedAction> _getMedicationActions(
    List<Medication> medications,
    List<MedicationLog> todayLogs,
    DateTime now,
  ) {
    final actions = <RecommendedAction>[];

    for (final medication in medications) {
      if (!medication.isActive) continue;

      // Check each scheduled time for this medication
      for (final time in medication.times) {
        // Check if medication is due (within 1 hour window)
        final scheduledTime = now.copyWith(
          hour: time.hour,
          minute: time.minute,
          second: 0,
          millisecond: 0,
        );

        // Check if it's past the scheduled time and within 2 hours
        final timeDiff = now.difference(scheduledTime);
        if (timeDiff.isNegative || timeDiff.inHours > 2) {
          continue;
        }

        // Check if already logged today for this time
        final alreadyLogged = todayLogs.any((log) {
          if (log.medicationId != medication.id) return false;

          // Check if logged within 2 hours of scheduled time
          final logTimeDiff = log.takenAt.difference(scheduledTime);
          return logTimeDiff.inHours.abs() <= 2;
        });

        if (!alreadyLogged) {
          final timeOfDay = _getTimeOfDayName(time.hour);
          actions.add(
            RecommendedAction(
              type: RecommendedActionType.takeMedication,
              title: '⚠ Medication Due',
              description: 'Take your $timeOfDay medication: ${medication.name}',
              priority: 1, // Highest priority
              medicationId: medication.id,
              medicationName: medication.name,
            ),
          );
        }
      }
    }

    return actions;
  }

  /// Get time-based actions based on time of day
  List<RecommendedAction> _getTimeBasedActions(
    List<HealthMetric> todayMetrics,
    DateTime now,
  ) {
    final actions = <RecommendedAction>[];
    final hour = now.hour;

    // Morning (6 AM - 12 PM)
    if (hour >= 6 && hour < 12) {
      // Check if weight logged
      final hasWeight = todayMetrics.any((m) => m.weight != null);
      if (!hasWeight) {
        actions.add(
          RecommendedAction(
            type: RecommendedActionType.logWeight,
            title: '⚪ Log Morning Weight',
            description: 'Track your daily weight',
            priority: 3,
          ),
        );
      }

      // Check if sleep logged (morning is good time to log previous night's sleep)
      final hasSleep = todayMetrics.any((m) => m.sleepQuality != null);
      if (!hasSleep) {
        actions.add(
          RecommendedAction(
            type: RecommendedActionType.logSleep,
            title: '⚪ Record Sleep Quality',
            description: 'Log how you slept last night',
            priority: 4,
          ),
        );
      }
    }

    // Afternoon (12 PM - 6 PM)
    if (hour >= 12 && hour < 18) {
      // Check if lunch logged
      // Note: We don't have meal data here, so we'll skip this for now
      // It would require nutrition repository access
    }

    // Evening (6 PM - 12 AM)
    if (hour >= 18 || hour < 6) {
      // Check if energy logged
      final hasEnergy = todayMetrics.any((m) => m.energyLevel != null);
      if (!hasEnergy) {
        actions.add(
          RecommendedAction(
            type: RecommendedActionType.logEnergy,
            title: '⚪ Log Energy Level',
            description: 'Track how energized you feel today',
            priority: 4,
          ),
        );
      }
    }

    return actions;
  }

  /// Get critical metric actions (always important)
  List<RecommendedAction> _getCriticalMetricActions(
    List<HealthMetric> todayMetrics,
  ) {
    final actions = <RecommendedAction>[];

    // Weight is critical - check if logged today
    final hasWeight = todayMetrics.any((m) => m.weight != null);
    if (!hasWeight) {
      // Don't add if already in time-based actions
      final alreadyAdded = actions.any(
        (a) => a.type == RecommendedActionType.logWeight,
      );
      if (!alreadyAdded) {
        actions.add(
          RecommendedAction(
            type: RecommendedActionType.logWeight,
            title: '⚪ Log Weight',
            description: 'Track your daily weight',
            priority: 2, // High priority but lower than medication
          ),
        );
      }
    }

    return actions;
  }

  /// Get time of day name from hour
  String _getTimeOfDayName(int hour) {
    if (hour >= 5 && hour < 12) {
      return 'morning';
    } else if (hour >= 12 && hour < 17) {
      return 'afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'evening';
    } else {
      return 'night';
    }
  }
}

