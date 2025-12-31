import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

/// Type alias for repository result
typedef HealthMetricResult = Result<HealthMetric>;
typedef HealthMetricListResult = Result<List<HealthMetric>>;

/// HealthTracking repository interface
/// 
/// Defines the contract for health metric data operations.
/// Implementation is in the data layer.
abstract class HealthTrackingRepository {
  /// Get health metric by ID
  /// 
  /// Returns [NotFoundFailure] if metric doesn't exist.
  Future<HealthMetricResult> getHealthMetric(String id);

  /// Get all health metrics for a user
  Future<HealthMetricListResult> getHealthMetricsByUserId(String userId);

  /// Get health metrics for a date range
  /// 
  /// Returns metrics for the specified user within the date range (inclusive).
  Future<HealthMetricListResult> getHealthMetricsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get health metric for a specific date
  /// 
  /// Returns the first metric found for the date, or [NotFoundFailure] if none exists.
  Future<HealthMetricResult> getHealthMetricByDate(
    String userId,
    DateTime date,
  );

  /// Get latest weight for a user
  /// 
  /// Returns the most recent weight entry, or [NotFoundFailure] if no weight data exists.
  Future<HealthMetricResult> getLatestWeight(String userId);

  /// Save health metric
  /// 
  /// Creates new metric or updates existing one.
  /// Returns [ValidationFailure] if metric data is invalid.
  Future<HealthMetricResult> saveHealthMetric(HealthMetric metric);

  /// Update health metric
  /// 
  /// Updates existing metric.
  /// Returns [NotFoundFailure] if metric doesn't exist.
  /// Returns [ValidationFailure] if metric data is invalid.
  Future<HealthMetricResult> updateHealthMetric(HealthMetric metric);

  /// Delete health metric
  /// 
  /// Returns [NotFoundFailure] if metric doesn't exist.
  Future<Result<void>> deleteHealthMetric(String id);

  /// Delete all health metrics for a user
  Future<Result<void>> deleteHealthMetricsByUserId(String userId);
}

