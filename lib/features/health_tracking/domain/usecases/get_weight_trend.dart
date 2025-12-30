import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/constants/health_constants.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

/// Weight trend direction
enum WeightTrend {
  /// Weight is increasing
  increasing,

  /// Weight is decreasing
  decreasing,

  /// Weight is stable
  stable,
}

/// Weight trend analysis result
class WeightTrendResult {
  /// Trend direction
  final WeightTrend trend;

  /// Change amount in kg (positive for increase, negative for decrease)
  final double change;

  /// Current 7-day average
  final double currentAverage;

  /// Previous 7-day average
  final double previousAverage;

  /// Message describing the trend
  final String message;

  WeightTrendResult({
    required this.trend,
    required this.change,
    required this.currentAverage,
    required this.previousAverage,
    required this.message,
  });
}

/// Use case for analyzing weight trend
/// 
/// Compares the current 7-day moving average to the previous 7-day
/// moving average to determine if weight is increasing, decreasing,
/// or stable.
class GetWeightTrendUseCase {
  /// Creates a GetWeightTrendUseCase
  GetWeightTrendUseCase();

  /// Execute the use case
  /// 
  /// Calculates two 7-day moving averages:
  /// - Current: last 7 days (inclusive of today)
  /// - Previous: 7 days before that (days 8-14)
  /// 
  /// Compares them to determine trend:
  /// - Increasing: > 0.1 kg increase
  /// - Decreasing: < -0.1 kg decrease
  /// - Stable: within ±0.1 kg
  /// 
  /// Returns [ValidationFailure] if insufficient data.
  /// Returns [Right] with WeightTrendResult.
  Result<WeightTrendResult> call(List<HealthMetric> metrics) {
    // Validate input
    if (metrics.isEmpty) {
      return Left(ValidationFailure('Metrics list cannot be empty'));
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sevenDaysAgo = today.subtract(Duration(days: HealthConstants.movingAverageDays - 1));
    final fourteenDaysAgo = today.subtract(Duration(days: (HealthConstants.movingAverageDays * 2) - 1));

    // Get current 7-day average (last 7 days)
    final currentMetrics = metrics
        .where((m) {
          final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
          return !metricDate.isBefore(sevenDaysAgo) &&
              !metricDate.isAfter(today) &&
              m.weight != null;
        })
        .toList();

    // Get previous 7-day average (days 8-14)
    final previousMetrics = metrics
        .where((m) {
          final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
          return !metricDate.isBefore(fourteenDaysAgo) &&
              metricDate.isBefore(sevenDaysAgo) &&
              m.weight != null;
        })
        .toList();

    if (currentMetrics.length < HealthConstants.movingAverageDays) {
      return Left(ValidationFailure(
        'Insufficient data: Need at least ${HealthConstants.movingAverageDays} days of weight entries in the last ${HealthConstants.movingAverageDays} days',
      ));
    }

    if (previousMetrics.length < HealthConstants.movingAverageDays) {
      return Left(ValidationFailure(
        'Insufficient data: Need at least ${HealthConstants.movingAverageDays} days of weight entries in the previous ${HealthConstants.movingAverageDays} days',
      ));
    }

    // Calculate averages
    final currentWeights = currentMetrics.map((m) => m.weight!).toList();
    final currentSum = currentWeights.fold(0.0, (a, b) => a + b);
    final currentAverage = currentSum / currentWeights.length;

    final previousWeights = previousMetrics.map((m) => m.weight!).toList();
    final previousSum = previousWeights.fold(0.0, (a, b) => a + b);
    final previousAverage = previousSum / previousWeights.length;

    // Calculate change
    final change = currentAverage - previousAverage;
    final tolerance = 0.1;

    // Determine trend
    WeightTrend trend;
    String message;

    if (change > tolerance) {
      trend = WeightTrend.increasing;
      message = 'Weight is increasing by ${change.toStringAsFixed(1)} kg';
    } else if (change < -tolerance) {
      trend = WeightTrend.decreasing;
      message = 'Weight is decreasing by ${(-change).toStringAsFixed(1)} kg';
    } else {
      trend = WeightTrend.stable;
      message = 'Weight is stable (change: ${change.toStringAsFixed(1)} kg)';
    }

    return Right(WeightTrendResult(
      trend: trend,
      change: change,
      currentAverage: double.parse(currentAverage.toStringAsFixed(1)),
      previousAverage: double.parse(previousAverage.toStringAsFixed(1)),
      message: message,
    ));
  }
}

