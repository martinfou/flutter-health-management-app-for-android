import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/constants/health_constants.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

/// Use case for calculating 7-day moving average
/// 
/// Calculates the 7-day moving average of weight to smooth out daily
/// fluctuations and show meaningful trends. Requires at least 7 days
/// of weight data within the last 7 days (inclusive of today).
class CalculateMovingAverageUseCase {
  /// Creates a CalculateMovingAverageUseCase
  CalculateMovingAverageUseCase();

  /// Execute the use case
  /// 
  /// Calculates the 7-day moving average from the provided metrics.
  /// Filters metrics to the last 7 days (inclusive of today) and
  /// calculates the average of weights.
  /// 
  /// Returns [ValidationFailure] if insufficient data.
  /// Returns [Right] with the average rounded to 1 decimal place.
  Result<double> call(List<HealthMetric> metrics) {
    // Validate input
    if (metrics.isEmpty) {
      return Left(ValidationFailure('Metrics list cannot be empty'));
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sevenDaysAgo = today.subtract(Duration(days: HealthConstants.movingAverageDays - 1));

    // Filter to only include metrics from the last 7 days with weight data
    final recentMetrics = metrics
        .where((m) {
          final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
          return !metricDate.isBefore(sevenDaysAgo) &&
              !metricDate.isAfter(today) &&
              m.weight != null;
        })
        .toList();

    // Check if we have enough data
    if (recentMetrics.length < HealthConstants.movingAverageDays) {
      return Left(ValidationFailure(
        'Insufficient data: Need at least ${HealthConstants.movingAverageDays} days of weight entries in the last ${HealthConstants.movingAverageDays} days',
      ));
    }

    // Calculate average
    final weights = recentMetrics.map((m) => m.weight!).toList();
    final sum = weights.fold(0.0, (a, b) => a + b);
    final average = sum / weights.length;

    // Round to 1 decimal place
    final roundedAverage = double.parse(average.toStringAsFixed(1));

    return Right(roundedAverage);
  }
}

