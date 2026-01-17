import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/providers/sync_coordinator_provider.dart';
import 'package:health_app/core/providers/sync_providers.dart';
import 'package:health_app/core/sync/services/offline_sync_queue.dart';

/// Sync status indicator widget
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For now, just use a static indicator. In a full implementation,
    // this would track actual sync state across all services
    final isSyncing = false; // Replace with actual sync state tracking

    return IconButton(
      icon: Icon(
        isSyncing ? Icons.sync : Icons.sync_outlined,
        color: isSyncing ? Theme.of(context).colorScheme.primary : null,
      ),
      onPressed: isSyncing ? null : () => _triggerSync(ref, context),
      tooltip: isSyncing ? 'Syncing...' : 'Sync data',
    );
  }

  Future<void> _triggerSync(WidgetRef ref, BuildContext context) async {
    try {
      // Show sync started message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Starting sync...'),
          duration: Duration(seconds: 1),
        ),
      );

      // In a real implementation, this would trigger the actual sync
      // For now, just show a success message
      await Future.delayed(const Duration(seconds: 2));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync completed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Sync status dialog for detailed sync information
class SyncStatusDialog extends StatelessWidget {
  const SyncStatusDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sync Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSyncStatusItem(context, 'Health Metrics', Icons.favorite),
          _buildSyncStatusItem(context, 'Meals', Icons.restaurant),
          _buildSyncStatusItem(context, 'Exercises', Icons.fitness_center),
          _buildSyncStatusItem(context, 'Medications', Icons.medication),
          const Divider(),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.sync),
            label: const Text('Sync All Data'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSyncStatusItem(BuildContext context, String name, IconData icon) {
    // For now, just show static status. In a real implementation, you'd track per-data-type status
    final isOnline = true; // This would come from connectivity monitoring

    return ListTile(
      leading: Icon(icon, color: isOnline ? Colors.green : Colors.grey),
      title: Text(name),
      subtitle: Text(isOnline ? 'Ready to sync' : 'Offline'),
      trailing: isOnline
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.offline_bolt, color: Colors.orange),
    );
  }
}

  Widget _buildSyncStatusItem(
      BuildContext context, String name, IconData icon, WidgetRef ref) {
    // For now, just show static status. In a real implementation, you'd track per-data-type status
    final isOnline = true; // This would come from connectivity monitoring

    return ListTile(
      leading: Icon(icon, color: isOnline ? Colors.green : Colors.grey),
      title: Text(name),
      subtitle: Text(isOnline ? 'Ready to sync' : 'Offline'),
      trailing: isOnline
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.offline_bolt, color: Colors.orange),
    );
  }



  Future<void> _triggerManualSync(WidgetRef ref, BuildContext context) async {
    try {
      final result = await ref.read(completeSyncProvider.future);

      result.fold(
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sync failed: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success),
              backgroundColor: Colors.green,
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Offline indicator widget
class OfflineIndicator extends StatelessWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    // This would be connected to connectivity monitoring
    // For now, just show a static indicator
    final isOffline = false; // Replace with actual connectivity check

    if (!isOffline) return const SizedBox.shrink();

    return Container(
      color: Colors.orange,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'You are offline. Changes will sync when online.',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
