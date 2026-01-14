import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/sync/services/unified_sync_orchestrator.dart';
import 'package:health_app/core/sync/strategies/health_metrics_sync_strategy.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';

/// Provider for the UnifiedSyncOrchestrator
///
/// This is a singleton provider that creates and manages the orchestrator
/// with all registered sync strategies.
final syncOrchestratorProvider = Provider<UnifiedSyncOrchestrator>((ref) {
  // Get the health metrics sync service
  final healthMetricsSyncService = ref.watch(healthMetricsSyncServiceProvider);

  // Create health metrics strategy
  final strategies = [
    HealthMetricsSyncStrategy(healthMetricsSyncService),
    // TODO: Add more strategies as backend endpoints are implemented
    // MealsSyncStrategy(...),
    // ExerciseSyncStrategy(...),
    // etc.
  ];

  // Create and return orchestrator
  return UnifiedSyncOrchestrator(strategies: strategies);
});
