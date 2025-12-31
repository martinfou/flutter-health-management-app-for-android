// Dart SDK
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

/// Use case to calculate daily progress percentage
/// 
/// Calculates overall completion percentage based on logged metrics.
class CalculateDailyProgress {
  /// Calculate progress percentage
  /// 
  /// Returns a value between 0.0 and 1.0 (0.0 = 0%, 1.0 = 100%).
  double call({
    required List<HealthMetric> todayMetrics,
    required double macroCompletionPercentage,
    required double medicationAdherencePercentage,
  }) {
    // Count completed metrics (1.0 each if logged, 0.0 if not)
    double completed = 0.0;

    // Weight (0.2 weight)
    final hasWeight = todayMetrics.any((m) => m.weight != null);
    if (hasWeight) completed += 0.2;

    // Sleep (0.2 weight)
    final hasSleep = todayMetrics.any((m) => m.sleepQuality != null);
    if (hasSleep) completed += 0.2;

    // Energy (0.15 weight)
    final hasEnergy = todayMetrics.any((m) => m.energyLevel != null);
    if (hasEnergy) completed += 0.15;

    // Heart Rate (0.1 weight)
    final hasHeartRate = todayMetrics.any((m) => m.restingHeartRate != null);
    if (hasHeartRate) completed += 0.1;

    // Macros (0.2 weight) - use percentage
    completed += 0.2 * (macroCompletionPercentage / 100.0).clamp(0.0, 1.0);

    // Medication (0.15 weight) - use percentage
    completed += 0.15 * (medicationAdherencePercentage / 100.0).clamp(0.0, 1.0);

    // Return as percentage (0.0 to 1.0)
    return completed.clamp(0.0, 1.0);
  }
}

/// Metric status for progress tracking
enum MetricStatus {
  /// Metric is logged/completed
  completed,

  /// Metric is partially completed
  partial,

  /// Metric is not logged
  notLogged,
}

/// Daily metric status for progress display
class DailyMetricStatus {
  /// Weight status
  final MetricStatus weight;

  /// Sleep status
  final MetricStatus sleep;

  /// Energy status
  final MetricStatus energy;

  /// Heart rate status
  final MetricStatus heartRate;

  /// Macros status (based on completion percentage)
  final MetricStatus macros;

  /// Medication status (based on adherence percentage)
  final MetricStatus medication;

  /// Creates DailyMetricStatus
  DailyMetricStatus({
    required this.weight,
    required this.sleep,
    required this.energy,
    required this.heartRate,
    required this.macros,
    required this.medication,
  });
}

/// Use case to get daily metric status
class GetDailyMetricStatus {
  /// Get metric status for today
  DailyMetricStatus call({
    required List<HealthMetric> todayMetrics,
    required double macroCompletionPercentage,
    required double medicationAdherencePercentage,
  }) {
    return DailyMetricStatus(
      weight: todayMetrics.any((m) => m.weight != null)
          ? MetricStatus.completed
          : MetricStatus.notLogged,
      sleep: todayMetrics.any((m) => m.sleepQuality != null)
          ? MetricStatus.completed
          : MetricStatus.notLogged,
      energy: todayMetrics.any((m) => m.energyLevel != null)
          ? MetricStatus.completed
          : MetricStatus.notLogged,
      heartRate: todayMetrics.any((m) => m.restingHeartRate != null)
          ? MetricStatus.completed
          : MetricStatus.notLogged,
      macros: macroCompletionPercentage >= 80
          ? MetricStatus.completed
          : macroCompletionPercentage >= 50
              ? MetricStatus.partial
              : MetricStatus.notLogged,
      medication: medicationAdherencePercentage >= 80
          ? MetricStatus.completed
          : medicationAdherencePercentage >= 50
              ? MetricStatus.partial
              : MetricStatus.notLogged,
    );
  }
}

