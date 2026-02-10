import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/sync/enums/sync_data_type.dart';
import 'package:health_app/core/sync/providers/sync_state_provider.dart';

/// A detailed sync status sheet showing per-data-type information
///
/// Displays:
/// - Overall sync status (syncing, error, offline, etc.)
/// - Last sync time
/// - Per-data-type sync status (health metrics, meals, exercises, medications)
/// - Specific errors if any
class SyncStatusDetails extends ConsumerWidget {
  /// Creates a SyncStatusDetails sheet
  const SyncStatusDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStateProvider);

    return syncState.when(
      data: (state) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'Sync Status',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),

                  // Overall Status Card
                  _buildOverallStatusCard(context, state),
                  const SizedBox(height: 24),

                  // Per-Data-Type Status
                  Text(
                    'Data Types',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ..._buildDataTypeStatuses(context, state),
                  const SizedBox(height: 24),

                  // Error Details (if any)
                  if (state.errorMessage != null) ...[
                    Text(
                      'Error Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Connectivity Status
                  _buildConnectivityStatus(context, state),
                ],
              ),
            ),
          ),
        ),
      ),
      loading: () => SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
      error: (error, stack) => SizedBox(
        height: 200,
        child: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  /// Build the overall status card
  Widget _buildOverallStatusCard(BuildContext context, dynamic state) {
    final isSyncing = state.isSyncing;
    final isConnected = state.isConnected;
    final lastSyncDisplay = state.lastSyncDisplay;
    final wasSuccessful = state.lastSyncWasSuccessful;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isSyncing) {
      statusColor = Colors.blue;
      statusIcon = Icons.cloud_upload;
      statusText = 'Syncing...';
    } else if (!isConnected) {
      statusColor = Colors.orange;
      statusIcon = Icons.cloud_queue;
      statusText = 'Offline';
    } else if (!wasSuccessful && state.errorMessage != null) {
      statusColor = Colors.red;
      statusIcon = Icons.cloud_off;
      statusText = 'Sync Failed';
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.cloud_done;
      statusText = 'Synced';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 28),
              const SizedBox(width: 12),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Last sync: ${lastSyncDisplay ?? "Never"}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// Build per-data-type status list
  List<Widget> _buildDataTypeStatuses(BuildContext context, dynamic state) {
    return state.dataTypeStatuses.entries.map((entry) {
      final dataType = entry.key;
      final status = entry.value;

      final color = status.wasSuccessful ? Colors.green : Colors.red;
      final icon =
          status.wasSuccessful ? Icons.check_circle : Icons.error_outline;

      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dataType.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (status.lastSync != null)
                      Text(
                        _formatLastSync(status.lastSync!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    if (status.error != null)
                      Text(
                        status.error!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (status.isSyncing)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  /// Build connectivity status section
  Widget _buildConnectivityStatus(BuildContext context, dynamic state) {
    final isConnected = state.isConnected;
    final lastCheck = state.lastConnectivityCheck;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green.shade50 : Colors.orange.shade50,
        border: Border.all(
          color: isConnected ? Colors.green.shade200 : Colors.orange.shade200,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.wifi : Icons.wifi_off,
            color: isConnected ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isConnected ? Colors.green : Colors.orange,
                  ),
                ),
                if (lastCheck != null)
                  Text(
                    'Checked ${_formatLastCheck(lastCheck)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Format last sync time
  String _formatLastSync(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  /// Format last connectivity check time
  String _formatLastCheck(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inSeconds < 60) {
      return 'just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

/// Show sync status details as a bottom sheet
void showSyncStatusDetails(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const SyncStatusDetails(),
  );
}
