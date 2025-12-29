import 'package:hive_flutter/hive_flutter.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/providers/database_provider.dart';
import 'package:health_app/features/health_tracking/data/models/health_metric_model.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

/// Local data source for HealthMetric
/// 
/// Handles direct Hive database operations for health metrics.
class HealthTrackingLocalDataSource {
  /// Get Hive box for health metrics
  Box<HealthMetricModel> get _box {
    if (!Hive.isBoxOpen(HiveBoxNames.healthMetrics)) {
      throw DatabaseFailure('Health metrics box is not open');
    }
    return Hive.box<HealthMetricModel>(HiveBoxNames.healthMetrics);
  }

  /// Get health metric by ID
  Future<Result<HealthMetric>> getHealthMetric(String id) async {
    try {
      final box = _box;
      final model = box.get(id);
      
      if (model == null) {
        return Left(NotFoundFailure('HealthMetric'));
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get health metric: $e'));
    }
  }

  /// Get all health metrics for a user
  Future<Result<List<HealthMetric>>> getHealthMetricsByUserId(
    String userId,
  ) async {
    try {
      final box = _box;
      final models = box.values
          .where((model) => model.userId == userId)
          .map((model) => model.toEntity())
          .toList();
      
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get health metrics: $e'));
    }
  }

  /// Get health metrics for a date range
  Future<Result<List<HealthMetric>>> getHealthMetricsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final box = _box;
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      
      final models = box.values
          .where((model) {
            if (model.userId != userId) return false;
            final modelDate = DateTime(
              model.date.year,
              model.date.month,
              model.date.day,
            );
            return modelDate.isAfter(start.subtract(const Duration(days: 1))) &&
                modelDate.isBefore(end.add(const Duration(days: 1)));
          })
          .map((model) => model.toEntity())
          .toList();
      
      return Right(models);
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to get health metrics by date range: $e'),
      );
    }
  }

  /// Get health metric for a specific date
  Future<Result<HealthMetric>> getHealthMetricByDate(
    String userId,
    DateTime date,
  ) async {
    try {
      final box = _box;
      final targetDate = DateTime(date.year, date.month, date.day);
      
      final model = box.values.firstWhere(
        (model) {
          if (model.userId != userId) return false;
          final modelDate = DateTime(
            model.date.year,
            model.date.month,
            model.date.day,
          );
          return modelDate == targetDate;
        },
        orElse: () => throw Exception('Not found'),
      );
      
      return Right(model.toEntity());
    } catch (e) {
      return Left(NotFoundFailure('HealthMetric'));
    }
  }

  /// Get latest weight for a user
  Future<Result<HealthMetric>> getLatestWeight(String userId) async {
    try {
      final box = _box;
      final modelsWithWeight = box.values
          .where((model) => model.userId == userId && model.weight != null)
          .toList();
      
      if (modelsWithWeight.isEmpty) {
        return Left(NotFoundFailure('HealthMetric'));
      }

      // Sort by date descending and get the first one
      modelsWithWeight.sort((a, b) => b.date.compareTo(a.date));
      return Right(modelsWithWeight.first.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get latest weight: $e'));
    }
  }

  /// Save health metric
  Future<Result<HealthMetric>> saveHealthMetric(HealthMetric metric) async {
    try {
      final box = _box;
      final model = HealthMetricModel.fromEntity(metric);
      await box.put(metric.id, model);
      return Right(metric);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save health metric: $e'));
    }
  }

  /// Update health metric
  Future<Result<HealthMetric>> updateHealthMetric(HealthMetric metric) async {
    try {
      final box = _box;
      final existing = box.get(metric.id);
      
      if (existing == null) {
        return Left(NotFoundFailure('HealthMetric'));
      }

      final model = HealthMetricModel.fromEntity(metric);
      await box.put(metric.id, model);
      return Right(metric);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update health metric: $e'));
    }
  }

  /// Delete health metric
  Future<Result<void>> deleteHealthMetric(String id) async {
    try {
      final box = _box;
      final model = box.get(id);
      
      if (model == null) {
        return Left(NotFoundFailure('HealthMetric'));
      }

      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete health metric: $e'));
    }
  }

  /// Delete all health metrics for a user
  Future<Result<void>> deleteHealthMetricsByUserId(String userId) async {
    try {
      final box = _box;
      final keysToDelete = box.values
          .where((model) => model.userId == userId)
          .map((model) => model.id)
          .toList();
      
      for (final key in keysToDelete) {
        await box.delete(key);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to delete health metrics by user: $e'),
      );
    }
  }
}

