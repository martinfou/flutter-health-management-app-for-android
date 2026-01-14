import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/sync/models/sync_state.dart';
import 'package:health_app/core/sync/providers/sync_state_provider.dart';

/// Animated sync button widget that displays sync status
///
/// Shows different states:
/// - Idle: Static sync icon
/// - Syncing: Rotating sync icon
/// - Success: Green checkmark (2 seconds)
/// - Error: Red sync problem icon
class SyncButtonWidget extends ConsumerStatefulWidget {
  /// Optional callback when sync completes
  final Function(bool success)? onSyncComplete;

  const SyncButtonWidget({
    super.key,
    this.onSyncComplete,
  });

  @override
  ConsumerState<SyncButtonWidget> createState() => _SyncButtonWidgetState();
}

class _SyncButtonWidgetState extends ConsumerState<SyncButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  IconData _displayIcon = Icons.sync;
  Color _displayColor = Colors.grey;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _handleSyncComplete(bool success) {
    if (success) {
      // Show success state
      _showSuccess = true;
      _displayIcon = Icons.check_circle;
      _displayColor = Colors.green;

      // Return to normal state after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showSuccess = false;
            _displayIcon = Icons.sync;
            _displayColor = Colors.grey;
          });
        }
      });
    } else {
      // Show error state
      _displayIcon = Icons.sync_problem;
      _displayColor = Colors.red;
    }

    widget.onSyncComplete?.call(success);
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncStateProvider);
    final manualSyncTrigger = ref.watch(manualSyncTriggerProvider);

    return syncState.when(
      data: (state) {
        // Update controller based on sync state
        if (state.isSyncing) {
          if (!_rotationController.isAnimating) {
            _rotationController.repeat();
          }
        } else {
          if (_rotationController.isAnimating) {
            _rotationController.stop();
          }
        }

        // Update display properties based on state
        _updateDisplay(state);

        return IconButton(
          icon: RotationTransition(
            turns: _rotationController,
            child: Icon(_displayIcon),
          ),
          color: _displayColor,
          onPressed: state.isSyncing ? null : () => _onPressed(manualSyncTrigger),
          tooltip: _getTooltip(state),
        );
      },
      loading: () {
        return IconButton(
          icon: const Icon(Icons.sync),
          onPressed: null,
          tooltip: 'Loading...',
        );
      },
      error: (error, _) {
        return IconButton(
          icon: const Icon(Icons.sync_problem),
          color: Colors.red,
          onPressed: () => _onPressed(manualSyncTrigger),
          tooltip: 'Sync error. Tap to retry.',
        );
      },
    );
  }

  void _updateDisplay(SyncState state) {
    if (state.isSyncing) {
      _displayIcon = Icons.sync;
      _displayColor = Theme.of(context).primaryColor;
    } else if (_showSuccess) {
      _displayIcon = Icons.check_circle;
      _displayColor = Colors.green;
    } else if (state.errorMessage != null) {
      _displayIcon = Icons.sync_problem;
      _displayColor = Colors.red;
    } else {
      _displayIcon = Icons.sync;
      _displayColor = Colors.grey;
    }
  }

  String _getTooltip(SyncState state) {
    if (state.isSyncing) {
      return 'Syncing...';
    } else if (state.errorMessage != null) {
      return 'Sync failed • Tap to retry';
    } else if (state.lastSyncDisplay != null) {
      return 'Sync data • ${state.lastSyncDisplay}';
    } else {
      return 'Sync data';
    }
  }

  Future<void> _onPressed(Future<bool> Function() syncTrigger) async {
    try {
      final success = await syncTrigger();
      _handleSyncComplete(success);

      // Show feedback snackbar
      if (mounted && context.mounted) {
        final syncState = ref.read(syncStateProvider).value;
        if (syncState != null) {
          final message = syncState.lastResult != null
              ? _formatSyncMessage(syncState)
              : 'Sync completed';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync error: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _formatSyncMessage(SyncState state) {
    final result = state.lastResult;
    if (result == null) return 'Sync completed';

    if (result.success) {
      if (result.totalSynced == 0) {
        return 'Sync completed (no changes)';
      } else {
        return 'Synced ${result.totalSynced} items';
      }
    } else {
      if (result.partialFailures.isEmpty) {
        return 'Sync completed';
      } else {
        final failed = result.partialFailures.keys.join(', ');
        return 'Sync completed with errors: $failed';
      }
    }
  }
}
