import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/data/services/health_metrics_sync_service.dart';
import 'package:health_app/features/nutrition_management/data/services/meals_sync_service.dart';
import 'package:health_app/features/exercise_management/data/services/exercises_sync_service.dart';
import 'package:health_app/features/medication_management/data/services/medications_sync_service.dart';

/// Unified sync coordinator for all data types
///
/// Orchestrates synchronization across health metrics, meals, exercises, and medications.
/// Provides a single entry point for complete data synchronization.
class SyncCoordinator {
  final HealthMetricsSyncService _healthMetricsSync;
  final MealsSyncService _mealsSync;
  final ExercisesSyncService _exercisesSync;
  final MedicationsSyncService _medicationsSync;

  SyncCoordinator({
    required HealthMetricsSyncService healthMetricsSync,
    required MealsSyncService mealsSync,
    required ExercisesSyncService exercisesSync,
    required MedicationsSyncService medicationsSync,
  }) : _healthMetricsSync = healthMetricsSync,
       _mealsSync = mealsSync,
       _exercisesSync = exercisesSync,
       _medicationsSync = medicationsSync;

  /// Perform complete synchronization of all data types
  Future<Either<Failure, SyncResult>> syncAll({bool forceCount = false}) async {
    print('SyncCoordinator: Starting complete sync for all data types');

    final results = <String, Either<Failure, void>>{};
    final errors = <String>[];

    // Sync health metrics
    print('SyncCoordinator: Syncing health metrics...');
    final healthResult = await _healthMetricsSync.syncHealthMetrics(forceCount: forceCount);
    results['health_metrics'] = healthResult;
    healthResult.fold(
      (failure) => errors.add('Health metrics: ${failure.message}'),
      (_) => print('SyncCoordinator: Health metrics sync completed'),
    );

    // Sync meals
    print('SyncCoordinator: Syncing meals...');
    final mealsResult = await _mealsSync.syncMeals(forceCount: forceCount);
    results['meals'] = mealsResult;
    mealsResult.fold(
      (failure) => errors.add('Meals: ${failure.message}'),
      (_) => print('SyncCoordinator: Meals sync completed'),
    );

    // Sync exercises
    print('SyncCoordinator: Syncing exercises...');
    final exercisesResult = await _exercisesSync.syncExercises(forceCount: forceCount);
    results['exercises'] = exercisesResult;
    exercisesResult.fold(
      (failure) => errors.add('Exercises: ${failure.message}'),
      (_) => print('SyncCoordinator: Exercises sync completed'),
    );

    // Sync medications
    print('SyncCoordinator: Syncing medications...');
    final medicationsResult = await _medicationsSync.syncMedications(forceCount: forceCount);
    results['medications'] = medicationsResult;
    medicationsResult.fold(
      (failure) => errors.add('Medications: ${failure.message}'),
      (_) => print('SyncCoordinator: Medications sync completed'),
    );

    // Calculate summary
    final successful = results.values.where((r) => r.isRight()).length;
    final failed = results.values.where((r) => r.isLeft()).length;

    print('SyncCoordinator: Sync complete. Successful: $successful, Failed: $failed');

    final syncResult = SyncResult(
      totalSynced: successful,
      totalFailed: failed,
      results: results,
      errors: errors,
    );

    // Return success if at least one sync succeeded
    return successful > 0
        ? Right(syncResult)
        : Left(SyncCoordinatorFailure('All sync operations failed: ${errors.join(", ")}'));
  }
}

/// Result of a sync coordinator operation
class SyncResult {
  final int totalSynced;
  final int totalFailed;
  final Map<String, Either<Failure, void>> results;
  final List<String> errors;

  const SyncResult({
    required this.totalSynced,
    required this.totalFailed,
    required this.results,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get isCompleteSuccess => totalFailed == 0;
}

/// Sync coordinator failure
class SyncCoordinatorFailure extends Failure {
  const SyncCoordinatorFailure(super.message);
}

    // Sync meals
    print('SyncCoordinator: Syncing meals...');
    final allMealsResult = await _mealsSync.syncMeals(forceCount: forceCount);
    results['meals'] = allMealsResult;
    if (allMealsResult != null) {
      allMealsResult.fold(
        (failure) => errors.add('Meals: ${failure.message}'),
        (_) => print('SyncCoordinator: Meals sync completed'),
      );
    }

    // Sync exercises
    print('SyncCoordinator: Syncing exercises...');
    final allExercisesResult =
        await _exercisesSync.syncExercises(forceCount: forceCount);
    results['exercises'] = allExercisesResult;
    if (allExercisesResult != null) {
      allExercisesResult.fold(
        (failure) => errors.add('Exercises: ${failure.message}'),
        (_) => print('SyncCoordinator: Exercises sync completed'),
      );
    }

    // Sync medications
    print('SyncCoordinator: Syncing medications...');
    final allMedicationsResult =
        await _medicationsSync.syncMedications(forceCount: forceCount);
    results['medications'] = allMedicationsResult;
    if (allMedicationsResult != null) {
      allMedicationsResult.fold(
        (failure) => errors.add('Medications: ${failure.message}'),
        (_) => print('SyncCoordinator: Medications sync completed'),
      );
    }

    // Sync exercises
    print('SyncCoordinator: Syncing exercises...');
    final exercisesResult =
        await _exercisesSync.syncExercises(forceCount: forceCount);
    results['exercises'] = exercisesResult;
    if (exercisesResult != null) {
      exercisesResult.fold(
        (failure) => errors.add('Exercises: ${failure.message}'),
        (_) => print('SyncCoordinator: Exercises sync completed'),
      );
    }

    // Sync medications
    print('SyncCoordinator: Syncing medications...');
    final medicationsResult =
        await _medicationsSync.syncMedications(forceCount: forceCount);
    results['medications'] = medicationsResult;
    if (medicationsResult != null) {
      medicationsResult.fold(
        (failure) => errors.add('Medications: ${failure.message}'),
        (_) => print('SyncCoordinator: Medications sync completed'),
      );
    }

    // Sync meals
    print('SyncCoordinator: Syncing meals...');
    final mealsResult = await _mealsSync.syncMeals(forceCount: forceCount);
    results['meals'] = mealsResult;
    mealsResult.fold(
      (failure) => errors.add('Meals: ${failure.message}'),
      (_) => print('SyncCoordinator: Meals sync completed'),
    );

    // Skip exercises and medications for core data sync (optional)
    results['exercises'] = const Right(null);
    results['medications'] = const Right(null);

  /// Sync only health metrics and meals (lighter sync)
  Future<Result<SyncResult>> syncCoreData() async {
    print('SyncCoordinator: Starting core data sync (health metrics + meals)');

    final results = <String, Result<void>>{};
    final errors = <String>[];

    // Sync health metrics
    final coreHealthResult = await _healthMetricsSync.syncHealthMetrics();
    results['health_metrics'] = coreHealthResult;
    if (coreHealthResult != null) {
      coreHealthResult.fold(
        (failure) => errors.add('Health metrics: ${failure.message}'),
        (_) => null,
      );
    }

    // Sync meals
    final coreMealsResult = await _mealsSync.syncMeals();
    results['meals'] = coreMealsResult;
    if (coreMealsResult != null) {
      coreMealsResult.fold(
        (failure) => errors.add('Meals: ${failure.message}'),
        (_) => null,
      );
    }

    final successful = results.values.where((r) => r.isRight()).length;
    final failed = results.values.where((r) => r.isLeft()).length;

    final syncResult = SyncResult(
      totalSynced: successful,
      totalFailed: failed,
      results: results,
      errors: errors,
    );

    return successful > 0
        ? Right(syncResult)
        : Left(SyncCoordinatorFailure(
            'Core data sync failed: ${errors.join(", ")}'));
  }

  /// Get individual sync service streams
  Stream<bool> get healthMetricsSyncing => _healthMetricsSync.isSyncing;
  Stream<bool> get mealsSyncing => _mealsSync.isSyncing;
  Stream<bool> get exercisesSyncing => _exercisesSync.isSyncing;
  Stream<bool> get medicationsSyncing => _medicationsSync.isSyncing;

  /// Combine all sync streams into one
  Stream<bool> _combinedSyncStream() {
    return StreamGroup.merge([
      _healthMetricsSync.isSyncing,
      _mealsSync.isSyncing,
      _exercisesSync.isSyncing,
      _medicationsSync.isSyncing,
    ]).asBroadcastStream();
  }
}

/// Result of a sync coordinator operation
class SyncResult {
  final int totalSynced;
  final int totalFailed;
  final Map<String, Result<void>> results;
  final List<String> errors;

  const SyncResult({
    required this.totalSynced,
    required this.totalFailed,
    required this.results,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get isCompleteSuccess => totalFailed == 0;
}

/// Sync coordinator failure
class SyncCoordinatorFailure extends Failure {
  SyncCoordinatorFailure(super.message);
}
