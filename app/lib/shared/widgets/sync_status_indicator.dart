import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/sync/providers/sync_state_provider.dart';

/// A compact sync status indicator for the app bar
///
/// Shows sync progress, errors, and last sync time.
/// Includes a manual sync button when not currently syncing.
class SyncStatusIndicator extends ConsumerWidget {
  /// Creates a SyncStatusIndicator
  const SyncStatusIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStateProvider);

    return syncState.when(
      data: (state) {
        // Show syncing indicator
        if (state.isSyncing) {
          return Tooltip(
            message: 'Syncing...',
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          );
        }

        // Show error indicator
        if (state.errorMessage != null) {
          return Tooltip(
            message: 'Sync failed: ${state.errorMessage}',
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(
                Icons.cloud_off,
                color: Colors.red.shade700,
                size: 20,
              ),
            ),
          );
        }

        // Show offline indicator
        if (!state.isConnected) {
          return Tooltip(
            message: 'Offline - changes will sync when online',
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(
                Icons.cloud_queue,
                color: Colors.orange.shade600,
                size: 20,
              ),
            ),
          );
        }

        // Show success indicator
        return Tooltip(
          message: state.lastSyncDisplay ?? 'Synced',
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.cloud_done,
              color: Colors.green.shade600,
              size: 20,
            ),
          ),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(12.0),
        child: Icon(
          Icons.error,
          color: Colors.red.shade700,
          size: 20,
        ),
      ),
    );
  }
}

/// A manual sync button that triggers a sync operation
///
/// Shows loading state while syncing is in progress.
/// Displays success/error feedback via snackbar.
class ManualSyncButton extends ConsumerWidget {
  /// Creates a ManualSyncButton
  const ManualSyncButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSyncing = ref.watch(isSyncingProvider);
    final manualSync = ref.watch(manualSyncTriggerProvider);

    return IconButton(
      icon: const Icon(Icons.sync),
      tooltip: 'Sync now',
      onPressed: isSyncing ? null : () async {
        try {
          final success = await manualSync();

          if (!context.mounted) return;

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sync completed successfully'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sync already in progress'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sync failed: ${e.toString()}'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }
}
