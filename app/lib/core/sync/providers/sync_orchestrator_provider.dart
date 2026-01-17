import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/sync/services/unified_sync_orchestrator.dart';
import 'package:health_app/core/sync/strategies/health_metrics_sync_strategy.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';
import 'package:health_app/features/nutrition_management/data/services/meals_sync_strategy.dart';
import 'package:health_app/features/nutrition_management/presentation/providers/nutrition_providers.dart';

/// Provider for the UnifiedSyncOrchestrator
///
/// This is a singleton provider that creates and manages the orchestrator
/// with all registered sync strategies.
final syncOrchestratorProvider = Provider<UnifiedSyncOrchestrator>((ref) {
  // Get the sync services
  final healthMetricsSyncService = ref.watch(healthMetricsSyncServiceProvider);
  final mealsSyncService = ref.watch(mealsSyncServiceProvider);

  // Create strategies
  final strategies = [
    HealthMetricsSyncStrategy(healthMetricsSyncService),
    MealsSyncStrategy(mealsSyncService),
    // TODO: Add exercise and medication strategies when ready
    // ExerciseSyncStrategy(...),
    // MedicationSyncStrategy(...),
  ];

  // Create and return orchestrator
  return UnifiedSyncOrchestrator(strategies: strategies);
});
