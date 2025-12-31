import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/domain/repositories/health_tracking_repository.dart';

/// Use case for deleting a health metric
/// 
/// Validates the metric ID and deletes it from the repository.
class DeleteHealthMetricUseCase {
  /// Health tracking repository
  final HealthTrackingRepository repository;

  /// Creates a DeleteHealthMetricUseCase
  DeleteHealthMetricUseCase(this.repository);

  /// Execute the use case
  /// 
  /// Validates that the ID is provided and not empty, then deletes
  /// the metric from the repository.
  /// 
  /// Returns [ValidationFailure] if ID is invalid.
  /// Returns [NotFoundFailure] if metric doesn't exist.
  /// Returns [DatabaseFailure] if delete operation fails.
  Future<Result<void>> call(String id) async {
    // Validate that ID is provided
    if (id.isEmpty) {
      return Left(
        ValidationFailure('Metric ID is required for delete operation'),
      );
    }

    // Delete from repository
    return await repository.deleteHealthMetric(id);
  }
}

