import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/domain/repositories/health_tracking_repository.dart';
import 'package:health_app/features/health_tracking/data/datasources/local/health_tracking_local_datasource.dart';

/// HealthTracking repository implementation
/// 
/// Implements the HealthTrackingRepository interface using local data source.
class HealthTrackingRepositoryImpl implements HealthTrackingRepository {
  final HealthTrackingLocalDataSource _localDataSource;

  HealthTrackingRepositoryImpl(this._localDataSource);

  @override
  Future<HealthMetricResult> getHealthMetric(String id) async {
    return await _localDataSource.getHealthMetric(id);
  }

  @override
  Future<HealthMetricListResult> getHealthMetricsByUserId(
    String userId,
  ) async {
    return await _localDataSource.getHealthMetricsByUserId(userId);
  }

  @override
  Future<HealthMetricListResult> getHealthMetricsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Validation
    if (startDate.isAfter(endDate)) {
      return Left(
        ValidationFailure('Start date must be before or equal to end date'),
      );
    }

    return await _localDataSource.getHealthMetricsByDateRange(
      userId,
      startDate,
      endDate,
    );
  }

  @override
  Future<HealthMetricResult> getHealthMetricByDate(
    String userId,
    DateTime date,
  ) async {
    return await _localDataSource.getHealthMetricByDate(userId, date);
  }

  @override
  Future<HealthMetricResult> getLatestWeight(String userId) async {
    return await _localDataSource.getLatestWeight(userId);
  }

  @override
  Future<HealthMetricResult> saveHealthMetric(HealthMetric metric) async {
    // Validation
    if (!metric.hasData) {
      return Left(
        ValidationFailure(
          'At least one metric (weight, sleep, energy, heart rate, or measurements) must be provided',
        ),
      );
    }

    if (metric.date.isAfter(DateTime.now())) {
      return Left(ValidationFailure('Date cannot be in the future'));
    }

    if (metric.weight != null &&
        (metric.weight! < 20 || metric.weight! > 500)) {
      return Left(ValidationFailure('Weight must be between 20 and 500 kg'));
    }

    if (metric.sleepQuality != null &&
        (metric.sleepQuality! < 1 || metric.sleepQuality! > 10)) {
      return Left(ValidationFailure('Sleep quality must be between 1 and 10'));
    }

    if (metric.energyLevel != null &&
        (metric.energyLevel! < 1 || metric.energyLevel! > 10)) {
      return Left(ValidationFailure('Energy level must be between 1 and 10'));
    }

    if (metric.restingHeartRate != null &&
        (metric.restingHeartRate! < 40 || metric.restingHeartRate! > 200)) {
      return Left(
        ValidationFailure('Resting heart rate must be between 40 and 200 bpm'),
      );
    }

    return await _localDataSource.saveHealthMetric(metric);
  }

  @override
  Future<HealthMetricResult> updateHealthMetric(HealthMetric metric) async {
    // Validation (same as save)
    if (!metric.hasData) {
      return Left(
        ValidationFailure(
          'At least one metric (weight, sleep, energy, heart rate, or measurements) must be provided',
        ),
      );
    }

    if (metric.date.isAfter(DateTime.now())) {
      return Left(ValidationFailure('Date cannot be in the future'));
    }

    return await _localDataSource.updateHealthMetric(metric);
  }

  @override
  Future<Result<void>> deleteHealthMetric(String id) async {
    return await _localDataSource.deleteHealthMetric(id);
  }

  @override
  Future<Result<void>> deleteHealthMetricsByUserId(String userId) async {
    return await _localDataSource.deleteHealthMetricsByUserId(userId);
  }
}

