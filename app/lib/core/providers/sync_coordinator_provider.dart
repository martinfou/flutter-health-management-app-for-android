import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/sync/sync_coordinator.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';
import 'package:health_app/features/nutrition_management/presentation/providers/nutrition_providers.dart';
import 'package:health_app/features/exercise_management/presentation/providers/exercise_providers.dart';
import 'package:health_app/features/medication_management/presentation/providers/medication_providers.dart';

/// Provider for SyncCoordinator - orchestrates all data type sync operations
final syncCoordinatorProvider = Provider<SyncCoordinator>((ref) {
  final healthMetricsSync = ref.watch(healthMetricsSyncServiceProvider);
  final mealsSync = ref.watch(mealsSyncServiceProvider);
  final exercisesSync = ref.watch(exercisesSyncServiceProvider);
  final medicationsSync = ref.watch(medicationsSyncServiceProvider);

  return SyncCoordinator(
    healthMetricsSync: healthMetricsSync,
    mealsSync: mealsSync,
    exercisesSync: exercisesSync,
    medicationsSync: medicationsSync,
  );
});
