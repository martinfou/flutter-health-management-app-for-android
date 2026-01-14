import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/sync/models/sync_state.dart';
import 'package:health_app/core/sync/providers/connectivity_provider.dart';
import 'package:health_app/core/sync/providers/sync_orchestrator_provider.dart';

/// Provider for the current sync state
///
/// This is a StreamProvider that exposes the sync state from the orchestrator.
/// Watches this to react to sync state changes in the UI.
final syncStateProvider = StreamProvider<SyncState>((ref) async* {
  final orchestrator = ref.watch(syncOrchestratorProvider);

  // Listen to connectivity changes and update orchestrator
  ref.listen(connectivityProvider, (previous, next) {
    next.whenData((connected) {
      orchestrator.setConnectivity(connected);
    });
  });

  // Listen to orchestrator state stream
  yield* orchestrator.syncState;
});

/// Provider for manual sync trigger
///
/// Returns a function that can be called to trigger an immediate sync.
/// Shows whether a sync is currently in progress via the returned Future.
final manualSyncTriggerProvider = Provider<Future<bool> Function()>((ref) {
  return () async {
    final orchestrator = ref.read(syncOrchestratorProvider);

    // Check if already syncing
    if (orchestrator.isSyncing) {
      return false;
    }

    // Perform sync
    final result = await orchestrator.syncAll();

    // Return success status
    return result.isRight();
  };
});

/// Provider for the last sync time
///
/// Returns a formatted string showing when the last sync occurred.
/// Useful for display in UI (e.g., "Synced 5 minutes ago").
final lastSyncTimeDisplayProvider = Provider<String?>((ref) {
  final syncState = ref.watch(syncStateProvider);

  return syncState.whenData((state) => state.lastSyncDisplay).value;
});

/// Provider for whether sync is currently active
///
/// Simple boolean provider for checking if a sync is in progress.
final isSyncingProvider = Provider<bool>((ref) {
  final syncState = ref.watch(syncStateProvider);

  return syncState.whenData((state) => state.isSyncing).value ?? false;
});

/// Provider for the current sync error message
///
/// Returns the last sync error message if any, null otherwise.
final syncErrorProvider = Provider<String?>((ref) {
  final syncState = ref.watch(syncStateProvider);

  return syncState.whenData((state) => state.errorMessage).value;
});
