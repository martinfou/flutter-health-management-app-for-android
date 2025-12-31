import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/constants/health_constants.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

/// Use case for calculating baseline heart rate
/// 
/// Calculates the baseline resting heart rate as the average of the
/// first 7 days of heart rate data. This baseline is used for
/// elevated heart rate alert calculations.
/// 
/// The baseline can be recalculated monthly to account for fitness
/// improvements.
class CalculateBaselineHeartRateUseCase {
  /// Creates a CalculateBaselineHeartRateUseCase
  CalculateBaselineHeartRateUseCase();

  /// Calculate initial baseline from first 7 days
  /// 
  /// Gets the first 7 days of heart rate data (sorted by date)
  /// and calculates the average.
  /// 
  /// Returns [ValidationFailure] if insufficient data.
  /// Returns [Right] with baseline value.
  Result<double> calculateInitialBaseline(List<HealthMetric> metrics) {
    // Validate input
    if (metrics.isEmpty) {
      return Left(ValidationFailure('Metrics list cannot be empty'));
    }

    // Get metrics with heart rate data, sorted by date
    final sortedMetrics = metrics
        .where((m) => m.restingHeartRate != null)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (sortedMetrics.length < HealthConstants.baselineCalculationDays) {
      return Left(ValidationFailure(
        'Insufficient data: Need at least ${HealthConstants.baselineCalculationDays} days of heart rate data',
      ));
    }

    // Get first 7 days
    final first7Days = sortedMetrics.take(HealthConstants.baselineCalculationDays).toList();
    final heartRates = first7Days.map((m) => m.restingHeartRate!.toDouble()).toList();

    // Calculate average
    final sum = heartRates.fold(0.0, (a, b) => a + b);
    final average = sum / heartRates.length;

    // Round to 1 decimal place
    final roundedAverage = double.parse(average.toStringAsFixed(1));

    return Right(roundedAverage);
  }

  /// Recalculate baseline for a specific month
  /// 
  /// Calculates the baseline using all heart rate data from the
  /// specified month. Used for monthly baseline recalculation.
  /// 
  /// Returns [ValidationFailure] if no data for the month.
  /// Returns [Right] with baseline value.
  Result<double> recalculateMonthlyBaseline(
    List<HealthMetric> metrics,
    DateTime monthStart,
  ) {
    // Validate input
    if (metrics.isEmpty) {
      return Left(ValidationFailure('Metrics list cannot be empty'));
    }

    final monthEnd = monthStart.add(Duration(days: 30));

    // Get all heart rate data from the month
    final monthMetrics = metrics
        .where((m) {
          final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
          return !metricDate.isBefore(monthStart) &&
              metricDate.isBefore(monthEnd) &&
              m.restingHeartRate != null;
        })
        .toList();

    if (monthMetrics.isEmpty) {
      return Left(ValidationFailure('No heart rate data for the specified month'));
    }

    // Calculate average
    final heartRates = monthMetrics.map((m) => m.restingHeartRate!.toDouble()).toList();
    final sum = heartRates.fold(0.0, (a, b) => a + b);
    final average = sum / heartRates.length;

    // Round to 1 decimal place
    final roundedAverage = double.parse(average.toStringAsFixed(1));

    return Right(roundedAverage);
  }

  /// Execute the use case (alias for calculateInitialBaseline)
  /// 
  /// This is the main entry point that calculates the initial baseline.
  Result<double> call(List<HealthMetric> metrics) {
    return calculateInitialBaseline(metrics);
  }
}

