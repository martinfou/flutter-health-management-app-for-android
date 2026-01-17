import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/providers/sync_coordinator_provider.dart';

/// Provider for complete data synchronization
/// Triggers sync for all data types: health metrics, meals, exercises, medications
final completeSyncProvider =
    FutureProvider.autoDispose<Either<String, String>>((ref) async {
  try {
    final syncCoordinator = ref.watch(syncCoordinatorProvider);

    final result = await syncCoordinator.syncAll();

    return result.fold(
      (failure) => Left('Sync failed: ${failure.message}'),
      (syncResult) {
        final successCount = syncResult.totalSynced;
        final failureCount = syncResult.totalFailed;

        if (failureCount == 0) {
          return Right('Successfully synced $successCount data types');
        } else {
          return Right(
              'Partially synced: $successCount successful, $failureCount failed');
        }
      },
    );
  } catch (e) {
    return Left('Sync error: ${e.toString()}');
  }
});

/// Provider for core data synchronization (health metrics + meals only)
/// Useful for faster syncs or when not all data types are needed
final coreSyncProvider =
    FutureProvider.autoDispose<Either<String, String>>((ref) async {
  try {
    final syncCoordinator = ref.watch(syncCoordinatorProvider);

    final result = await syncCoordinator.syncCoreData();

    return result.fold(
      (failure) => Left('Core sync failed: ${failure.message}'),
      (syncResult) {
        final successCount = syncResult.totalSynced;
        final failureCount = syncResult.totalFailed;

        if (failureCount == 0) {
          return Right('Core data synced successfully ($successCount types)');
        } else {
          return Right(
              'Core sync partial: $successCount successful, $failureCount failed');
        }
      },
    );
  } catch (e) {
    return Left('Core sync error: ${e.toString()}');
  }
});
