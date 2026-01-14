import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/sync/providers/sync_orchestrator_provider.dart';
import 'package:health_app/core/sync/services/periodic_sync_service.dart';

/// Provider to manage the periodic background synchronization service
///
/// This provider creates and manages a PeriodicSyncService that automatically
/// syncs health data at regular intervals. Watching this provider in the root
/// widget ensures the service is started when the app starts.
final backgroundSyncProvider = Provider<PeriodicSyncService>((ref) {
  final orchestrator = ref.watch(syncOrchestratorProvider);

  // Create the periodic sync service
  final syncService = PeriodicSyncService(orchestrator);

  // Start the service
  syncService.start();

  // Setup cleanup when provider is disposed
  ref.onDispose(() {
    syncService.stop();
  });

  return syncService;
});
