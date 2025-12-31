import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/constants/health_constants.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/domain/repositories/health_tracking_repository.dart';

/// Use case for updating a health metric
/// 
/// Validates the health metric data and updates it in the repository.
/// Preserves the original creation date but updates the updatedAt timestamp.
class UpdateHealthMetricUseCase {
  /// Health tracking repository
  final HealthTrackingRepository repository;

  /// Creates an UpdateHealthMetricUseCase
  UpdateHealthMetricUseCase(this.repository);

  /// Execute the use case
  /// 
  /// Gets the existing metric to preserve original createdAt, then updates
  /// the metric with new values while preserving id, userId, date, and createdAt.
  /// Updates the updatedAt timestamp.
  /// 
  /// Returns [NotFoundFailure] if metric doesn't exist.
  /// Returns [ValidationFailure] if validation fails.
  /// Returns [DatabaseFailure] if update operation fails.
  Future<Result<HealthMetric>> call(HealthMetric metric) async {
    // Validate that ID is provided
    if (metric.id.isEmpty) {
      return Left(
        ValidationFailure('Metric ID is required for update operation'),
      );
    }

    // Get existing metric to preserve createdAt
    final existingResult = await repository.getHealthMetric(metric.id);
    return existingResult.fold(
      (failure) => Left(failure),
      (existingMetric) async {
        // Create updated metric preserving original values
        final updatedMetric = metric.copyWith(
          id: existingMetric.id,
          userId: existingMetric.userId,
          date: existingMetric.date,
          createdAt: existingMetric.createdAt,
          updatedAt: DateTime.now(),
        );

        // Validate the metric
        final validationResult = _validateMetric(updatedMetric);
        if (validationResult != null) {
          return Left(validationResult);
        }

        // Update in repository
        return await repository.updateHealthMetric(updatedMetric);
      },
    );
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

    // Validate blood pressure if provided
    if (metric.systolicBP != null) {
      if (metric.systolicBP! < HealthConstants.minSystolicBP ||
          metric.systolicBP! > HealthConstants.maxSystolicBP) {
        return ValidationFailure(
          'Systolic blood pressure must be between ${HealthConstants.minSystolicBP} and ${HealthConstants.maxSystolicBP} mmHg',
        );
      }
    }

    if (metric.diastolicBP != null) {
      if (metric.diastolicBP! < HealthConstants.minDiastolicBP ||
          metric.diastolicBP! > HealthConstants.maxDiastolicBP) {
        return ValidationFailure(
          'Diastolic blood pressure must be between ${HealthConstants.minDiastolicBP} and ${HealthConstants.maxDiastolicBP} mmHg',
        );
      }
    }

    // Validate that if both blood pressure values are provided, systolic > diastolic
    if (metric.systolicBP != null && metric.diastolicBP != null) {
      if (metric.systolicBP! <= metric.diastolicBP!) {
        return ValidationFailure(
          'Systolic blood pressure must be greater than diastolic blood pressure',
        );
      }
    }

    // Validate that metric has at least one data field
    if (!metric.hasData) {
      return ValidationFailure('Health metric must have at least one data field');
    }

    return null;
  }
}

