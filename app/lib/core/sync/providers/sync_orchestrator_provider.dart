import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:health_app/core/providers/database_provider.dart';
import 'package:health_app/core/sync/models/offline_sync_operation.dart';
import 'package:health_app/core/sync/sync_coordinator.dart';
import 'package:health_app/core/sync/services/offline_sync_queue.dart';
import 'package:health_app/core/sync/services/unified_sync_orchestrator.dart';
import 'package:health_app/core/sync/strategies/health_metrics_sync_strategy.dart';
import 'package:health_app/core/sync/strategies/meals_sync_strategy.dart';
import 'package:health_app/core/sync/strategies/exercises_sync_strategy.dart';
import 'package:health_app/core/sync/strategies/medications_sync_strategy.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';
import 'package:health_app/features/nutrition_management/presentation/providers/nutrition_providers.dart';
import 'package:health_app/features/exercise_management/presentation/providers/exercise_providers.dart';
import 'package:health_app/features/medication_management/presentation/providers/medication_providers.dart';
import 'package:health_app/core/sync/services/sync_status_service.dart';

/// Provider for SyncStatusService
final syncStatusServiceProvider = Provider<SyncStatusService>((ref) {
  return SyncStatusService();
});

/// Provider for the UnifiedSyncOrchestrator
///
/// This is a singleton provider that creates and manages the orchestrator
/// with all registered sync strategies.
final syncOrchestratorProvider = Provider<UnifiedSyncOrchestrator>((ref) {
  // Get the sync services
  final healthMetricsSyncService = ref.watch(healthMetricsSyncServiceProvider);
  final mealsSyncService = ref.watch(mealsSyncServiceProvider);
  final exercisesSyncService = ref.watch(exercisesSyncServiceProvider);
  final medicationsSyncService = ref.watch(medicationsSyncServiceProvider);
  final offlineQueue = ref.read(offlineSyncQueueProvider);

  // Create strategies
  final strategies = [
    HealthMetricsSyncStrategy(healthMetricsSyncService, offlineQueue),
    MealsSyncStrategy(mealsSyncService, offlineQueue),
    ExercisesSyncStrategy(exercisesSyncService, offlineQueue),
    MedicationsSyncStrategy(medicationsSyncService, offlineQueue),
  ];

  // Create orchestrator
  final orchestrator = UnifiedSyncOrchestrator(strategies: strategies);

  // Wire queue to orchestrator and start connectivity monitoring (use local
  // variable to avoid provider self-reference).
  offlineQueue.setOrchestratorGetter(() => orchestrator);
  final sub = offlineQueue.startConnectivityMonitoring(() => orchestrator);
  ref.onDispose(() {
    sub.cancel();
    offlineQueue.dispose();
  });

  return orchestrator;
});

/// Provider for the SyncCoordinator
final syncCoordinatorProvider = Provider<SyncCoordinator>((ref) {
  final healthMetricsSyncService = ref.watch(healthMetricsSyncServiceProvider);
  final mealsSyncService = ref.watch(mealsSyncServiceProvider);
  final exercisesSyncService = ref.watch(exercisesSyncServiceProvider);
  final medicationsSyncService = ref.watch(medicationsSyncServiceProvider);
  final syncStatus = ref.watch(syncStatusServiceProvider);
  final offlineQueue = ref.read(offlineSyncQueueProvider);

  return SyncCoordinator(
    healthMetricsSync: healthMetricsSyncService,
    mealsSync: mealsSyncService,
    exercisesSync: exercisesSyncService,
    medicationsSync: medicationsSyncService,
    syncStatus: syncStatus,
    offlineQueue: offlineQueue,
  );
});

/// Provider for OfflineSyncQueue (no reference to syncOrchestratorProvider here
/// to break circular dependency; getter and connectivity monitoring set in
/// syncOrchestratorProvider).
final offlineSyncQueueProvider = Provider<OfflineSyncQueue>((ref) {
  final box = Hive.box<OfflineSyncOperation>(HiveBoxNames.offlineSyncQueue);
  return OfflineSyncQueue(box);
});
