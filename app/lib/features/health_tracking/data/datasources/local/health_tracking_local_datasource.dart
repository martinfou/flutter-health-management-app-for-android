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
  /// 
  /// Optimized: Filters at database level before converting to list.
  Future<Result<List<HealthMetric>>> getHealthMetricsByUserId(
    String userId,
  ) async {
    try {
      final box = _box;
      // Filter before converting to list to reduce memory usage
      final models = box.values
          .where((model) => model.userId == userId)
          .map((model) => model.toEntity())
          .toList();
      
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get health metrics: $e'));
    }
  }

  /// Get health metrics with pagination
  /// 
  /// Returns a paginated list of health metrics for a user.
  /// Useful for large datasets to avoid loading everything into memory.
  Future<Result<List<HealthMetric>>> getHealthMetricsPaginated({
    required String userId,
    required int page,
    required int pageSize,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final box = _box;
      
      // Build query with filters
      var query = box.values.where((model) => model.userId == userId);
      
      // Apply date range filter if provided
      if (startDate != null || endDate != null) {
        final start = startDate != null
            ? DateTime(startDate.year, startDate.month, startDate.day)
            : null;
        final end = endDate != null
            ? DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59)
            : null;
        
        query = query.where((model) {
          final modelDate = DateTime(
            model.date.year,
            model.date.month,
            model.date.day,
          );
          if (start != null && modelDate.isBefore(start)) return false;
          if (end != null && modelDate.isAfter(end)) return false;
          return true;
        });
      }
      
      // Convert to list, sort by date descending, then paginate
      final allModels = query.map((model) => model.toEntity()).toList();
      allModels.sort((a, b) => b.date.compareTo(a.date)); // Most recent first
      
      final startIndex = page * pageSize;
      final endIndex = (startIndex + pageSize).clamp(0, allModels.length);
      
      if (startIndex >= allModels.length) {
        return Right([]);
      }
      
      return Right(allModels.sublist(startIndex, endIndex));
    } catch (e) {
      return Left(DatabaseFailure('Failed to get paginated health metrics: $e'));
    }
  }

  /// Get health metrics for a date range
  /// 
  /// Optimized: Filters at database level before converting to list.
  /// More efficient than loading all records and filtering in memory.
  Future<Result<List<HealthMetric>>> getHealthMetricsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final box = _box;
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      
      // Filter at database level before converting to list
      // This is more memory-efficient for large datasets
      final models = box.values
          .where((model) {
            // Filter by userId first (most selective)
            if (model.userId != userId) return false;
            
            // Then filter by date range
            final modelDate = DateTime(
              model.date.year,
              model.date.month,
              model.date.day,
            );
            return !modelDate.isBefore(start) && !modelDate.isAfter(end);
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
  /// 
  /// Optimized: Uses batch delete operation for better performance.
  Future<Result<void>> deleteHealthMetricsByUserId(String userId) async {
    try {
      final box = _box;
      final keysToDelete = box.values
          .where((model) => model.userId == userId)
          .map((model) => model.id)
          .toList();
      
      // Use batch delete for better performance
      await box.deleteAll(keysToDelete);
      
      return const Right(null);
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to delete health metrics by user: $e'),
      );
    }
  }

  /// Batch save health metrics
  ///
  /// Saves multiple health metrics in a single operation for better performance.
  Future<Result<List<HealthMetric>>> saveHealthMetricsBatch(
    List<HealthMetric> metrics,
  ) async {
    try {
      final box = _box;
      final modelsMap = <String, HealthMetricModel>{};

      for (final metric in metrics) {
        modelsMap[metric.id] = HealthMetricModel.fromEntity(metric);
      }

      // Use batch put operation
      await box.putAll(modelsMap);

      return Right(metrics);
    } catch (e) {
      return Left(DatabaseFailure('Failed to batch save health metrics: $e'));
    }
  }

  /// Migrate health metrics from old userId to new userId
  ///
  /// Used during login to associate previously created metrics with the authenticated user.
  /// This ensures that metrics created before authentication (with random/default userIds)
  /// are reassigned to the authenticated user so they can be synced to the backend.
  Future<Result<int>> migrateMetricsToUserId({
    required String fromUserId,
    required String toUserId,
  }) async {
    try {
      final box = _box;
      int migratedCount = 0;

      // Find all metrics with the old userId
      final metricsToMigrate = box.values
          .where((model) => model.userId == fromUserId)
          .toList();

      if (metricsToMigrate.isEmpty) {
        return const Right(0);
      }

      print('HealthTrackingLocalDataSource: Migrating ${metricsToMigrate.length} metrics from $fromUserId to $toUserId');

      // Update each metric's userId and save back to box
      for (final model in metricsToMigrate) {
        model.userId = toUserId;
        await box.put(model.id, model);
        migratedCount++;
      }

      print('HealthTrackingLocalDataSource: Successfully migrated $migratedCount metrics');
      return Right(migratedCount);
    } catch (e) {
      return Left(DatabaseFailure('Failed to migrate health metrics: $e'));
    }
  }

  /// Get all health metrics regardless of userId
  ///
  /// Useful for finding metrics that need migration or debugging.
  Future<Result<List<HealthMetric>>> getAllHealthMetrics() async {
    try {
      final box = _box;
      final metrics = box.values
          .map((model) => model.toEntity())
          .toList();

      return Right(metrics);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get all health metrics: $e'));
    }
  }
}

