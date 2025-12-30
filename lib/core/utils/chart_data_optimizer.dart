import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

/// Utility for optimizing chart data
/// 
/// Provides methods to limit data points and optimize chart rendering
/// for large datasets.
class ChartDataOptimizer {
  ChartDataOptimizer._();

  /// Maximum number of data points to display in a chart
  /// 
  /// Charts with more points will be sampled to this limit.
  static const int maxDataPoints = 100;

  /// Optimize chart data by sampling if necessary
  /// 
  /// If the data has more than [maxDataPoints] points, samples the data
  /// to reduce rendering time while maintaining visual accuracy.
  /// 
  /// Uses uniform sampling to evenly distribute points across the dataset.
  static List<HealthMetric> optimizeDataPoints(List<HealthMetric> metrics) {
    if (metrics.length <= maxDataPoints) {
      return metrics;
    }

    // Use uniform sampling
    final step = metrics.length / maxDataPoints;
    final optimized = <HealthMetric>[];

    for (int i = 0; i < maxDataPoints; i++) {
      final index = (i * step).floor();
      if (index < metrics.length) {
        optimized.add(metrics[index]);
      }
    }

    // Always include the last point
    if (optimized.last != metrics.last) {
      optimized[optimized.length - 1] = metrics.last;
    }

    return optimized;
  }

  /// Optimize data points for a specific date range
  /// 
  /// Filters metrics to the date range first, then optimizes if needed.
  static List<HealthMetric> optimizeForDateRange(
    List<HealthMetric> metrics,
    DateTime startDate,
    DateTime endDate,
  ) {
    // Filter to date range first
    final filtered = metrics.where((m) {
      final metricDate = DateTime(m.date.year, m.date.month, m.date.day);
      return !metricDate.isBefore(startDate) && !metricDate.isAfter(endDate);
    }).toList();

    // Then optimize if needed
    return optimizeDataPoints(filtered);
  }

  /// Calculate sampling interval for large datasets
  /// 
  /// Returns the interval to use for sampling (e.g., every Nth point).
  static int calculateSamplingInterval(int totalPoints) {
    if (totalPoints <= maxDataPoints) {
      return 1;
    }
    return (totalPoints / maxDataPoints).ceil();
  }
}

