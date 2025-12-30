import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/constants/health_constants.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/domain/repositories/health_tracking_repository.dart';

/// Use case for saving a health metric
/// 
/// Validates the health metric data and saves it to the repository.
/// Generates an ID if not provided, validates all fields, and ensures
/// the date is not in the future.
class SaveHealthMetricUseCase {
  /// Health tracking repository
  final HealthTrackingRepository repository;

  /// Creates a SaveHealthMetricUseCase
  SaveHealthMetricUseCase(this.repository);

  /// Execute the use case
  /// 
  /// Validates the health metric and saves it. If the metric doesn't
  /// have an ID, generates one. If the metric has an ID, updates the
  /// existing metric.
  /// 
  /// Returns [ValidationFailure] if validation fails.
  /// Returns [DatabaseFailure] if save operation fails.
  Future<Result<HealthMetric>> call(HealthMetric metric) async {
    // Generate ID if not provided
    final metricWithId = metric.id.isEmpty
        ? metric.copyWith(
            id: _generateId(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          )
        : metric.copyWith(updatedAt: DateTime.now());

    // Validate the metric
    final validationResult = _validateMetric(metricWithId);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Save to repository
    return await repository.saveHealthMetric(metricWithId);
  }

  /// Validate health metric data
  ValidationFailure? _validateMetric(HealthMetric metric) {
    // Validate date is not in the future
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final metricDate = DateTime(metric.date.year, metric.date.month, metric.date.day);
    
    if (metricDate.isAfter(today)) {
      return ValidationFailure('Date cannot be in the future');
    }

    // Validate weight if provided
    if (metric.weight != null) {
      if (metric.weight! < HealthConstants.minWeightKg ||
          metric.weight! > HealthConstants.maxWeightKg) {
        return ValidationFailure(
          'Weight must be between ${HealthConstants.minWeightKg} and ${HealthConstants.maxWeightKg} kg',
        );
      }
    }

    // Validate sleep quality if provided
    if (metric.sleepQuality != null) {
      if (metric.sleepQuality! < HealthConstants.minSleepQuality ||
          metric.sleepQuality! > HealthConstants.maxSleepQuality) {
        return ValidationFailure(
          'Sleep quality must be between ${HealthConstants.minSleepQuality} and ${HealthConstants.maxSleepQuality}',
        );
      }
    }

    // Validate energy level if provided (same range as sleep quality)
    if (metric.energyLevel != null) {
      if (metric.energyLevel! < HealthConstants.minSleepQuality ||
          metric.energyLevel! > HealthConstants.maxSleepQuality) {
        return ValidationFailure(
          'Energy level must be between ${HealthConstants.minSleepQuality} and ${HealthConstants.maxSleepQuality}',
        );
      }
    }

    // Validate resting heart rate if provided
    if (metric.restingHeartRate != null) {
      if (metric.restingHeartRate! < HealthConstants.minRestingHeartRate ||
          metric.restingHeartRate! > HealthConstants.maxRestingHeartRate) {
        return ValidationFailure(
          'Resting heart rate must be between ${HealthConstants.minRestingHeartRate} and ${HealthConstants.maxRestingHeartRate} BPM',
        );
      }
    }

    // Validate that metric has at least one data field
    if (!metric.hasData) {
      return ValidationFailure('Health metric must have at least one data field');
    }

    return null;
  }

  /// Generate a unique ID for the metric
  String _generateId() {
    final now = DateTime.now();
    return 'health-metric-${now.millisecondsSinceEpoch}-${now.microsecondsSinceEpoch}';
  }
}

