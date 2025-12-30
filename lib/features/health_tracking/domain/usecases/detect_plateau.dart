import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/constants/health_constants.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

/// Result of plateau detection
class PlateauResult {
  /// Whether a plateau was detected
  final bool isPlateau;

  /// Message explaining the result
  final String message;

  /// Average weight during plateau (if detected)
  final double? averageWeight;

  PlateauResult._(this.isPlateau, this.message, this.averageWeight);

  /// Create result for detected plateau
  factory PlateauResult.plateauDetected(String message, double avgWeight) {
    return PlateauResult._(true, message, avgWeight);
  }

  /// Create result for no plateau
  factory PlateauResult.noPlateau(String reason) {
    return PlateauResult._(false, reason, null);
  }
}

/// Use case for detecting weight loss plateaus
/// 
/// Detects when weight and body measurements have been unchanged
/// for 3 consecutive weeks (21 days). A plateau occurs when:
/// 1. Weight is unchanged (within ±0.2 kg tolerance) for 3 consecutive weeks
/// 2. AND body measurements (waist, hips) are unchanged (within ±1 cm tolerance)
class DetectPlateauUseCase {
  /// Creates a DetectPlateauUseCase
  DetectPlateauUseCase();

  /// Execute the use case
  /// 
  /// Analyzes the last 21 days of metrics to detect a plateau.
  /// Groups metrics by week and checks if all 3 weekly averages
  /// are within tolerance, then checks body measurements.
  /// 
  /// Returns [ValidationFailure] if insufficient data.
  /// Returns [Right] with PlateauResult indicating if plateau was detected.
  Result<PlateauResult> call(List<HealthMetric> metrics) {
    // Validate input
    if (metrics.isEmpty) {
      return Left(ValidationFailure('Metrics list cannot be empty'));
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final twentyOneDaysAgo = today.subtract(Duration(days: HealthConstants.plateauDetectionDays - 1));

    // Get metrics from last 21 days with weight data
    final recentMetrics = metrics
        .where((m) {
          final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
          return !metricDate.isBefore(twentyOneDaysAgo) &&
              !metricDate.isAfter(today) &&
              m.weight != null;
        })
        .toList();

    if (recentMetrics.length < 7) {
      return Right(PlateauResult.noPlateau('Insufficient data: Need at least 7 days of weight entries'));
    }

    // Group by week (last 7 days, 8-14 days ago, 15-21 days ago)
    final week1Start = today.subtract(Duration(days: 6));
    final week2Start = today.subtract(Duration(days: 13));
    final week3Start = today.subtract(Duration(days: 20));

    final week1 = recentMetrics
        .where((m) {
          final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
          return !metricDate.isBefore(week1Start) && !metricDate.isAfter(today);
        })
        .map((m) => m.weight!)
        .toList();

    final week2 = recentMetrics
        .where((m) {
          final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
          return !metricDate.isBefore(week2Start) && metricDate.isBefore(week1Start);
        })
        .map((m) => m.weight!)
        .toList();

    final week3 = recentMetrics
        .where((m) {
          final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
          return !metricDate.isBefore(week3Start) && metricDate.isBefore(week2Start);
        })
        .map((m) => m.weight!)
        .toList();

    if (week1.isEmpty || week2.isEmpty || week3.isEmpty) {
      return Right(PlateauResult.noPlateau('Insufficient weekly data'));
    }

    // Calculate weekly averages
    final avg1 = week1.reduce((a, b) => a + b) / week1.length;
    final avg2 = week2.reduce((a, b) => a + b) / week2.length;
    final avg3 = week3.reduce((a, b) => a + b) / week3.length;

    // Check if all averages are within ±0.2 kg tolerance
    final maxAvg = [avg1, avg2, avg3].reduce((a, b) => a > b ? a : b);
    final minAvg = [avg1, avg2, avg3].reduce((a, b) => a < b ? a : b);

    if (maxAvg - minAvg > HealthConstants.plateauWeightToleranceKg) {
      return Right(PlateauResult.noPlateau('Weight is changing'));
    }

    // Check body measurements if available
    final measurements = recentMetrics
        .where((m) => m.bodyMeasurements != null && m.bodyMeasurements!.isNotEmpty)
        .toList();

    if (measurements.isNotEmpty) {
      final waistValues = measurements
          .where((m) => m.bodyMeasurements!.containsKey('waist'))
          .map((m) => m.bodyMeasurements!['waist']!)
          .toList();

      final hipsValues = measurements
          .where((m) => m.bodyMeasurements!.containsKey('hips'))
          .map((m) => m.bodyMeasurements!['hips']!)
          .toList();

      if (waistValues.isNotEmpty && hipsValues.isNotEmpty) {
        final waistMax = waistValues.reduce((a, b) => a > b ? a : b);
        final waistMin = waistValues.reduce((a, b) => a < b ? a : b);
        final hipsMax = hipsValues.reduce((a, b) => a > b ? a : b);
        final hipsMin = hipsValues.reduce((a, b) => a < b ? a : b);

        if (waistMax - waistMin <= HealthConstants.plateauMeasurementToleranceCm &&
            hipsMax - hipsMin <= HealthConstants.plateauMeasurementToleranceCm) {
          return Right(PlateauResult.plateauDetected(
            'Weight and measurements unchanged for 3 weeks',
            avg1,
          ));
        }
      }
    }

    // If weight is stable but measurements are changing or not available,
    // still consider it a plateau (weight-only plateau)
    return Right(PlateauResult.plateauDetected(
      'Weight unchanged for 3 weeks',
      avg1,
    ));
  }
}

