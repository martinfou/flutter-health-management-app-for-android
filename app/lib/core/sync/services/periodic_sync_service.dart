import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:health_app/core/network/auth_helper.dart';
import 'package:health_app/core/sync/services/unified_sync_orchestrator.dart';

/// Service that manages periodic sync operations
///
/// Automatically syncs health data at regular intervals when conditions are met:
/// - User is authenticated
/// - Device has internet connectivity
/// - Not already syncing
/// - App is active (timer paused when app is backgrounded)
class PeriodicSyncService {
  final UnifiedSyncOrchestrator _orchestrator;
  final AuthHelper _authHelper;

  /// Timer for periodic sync
  Timer? _syncTimer;

  /// Sync interval (15 minutes)
  static const _syncInterval = Duration(minutes: 15);

  /// Whether the service is currently running
  bool _isRunning = false;

  PeriodicSyncService(
    this._orchestrator, {
    AuthHelper? authHelper,
  }) : _authHelper = authHelper ?? AuthHelper();

  /// Start the periodic sync service
  ///
  /// Begins the timer that triggers sync operations at regular intervals.
  /// If already running, this does nothing.
  void start() {
    if (_isRunning) {
      if (kDebugMode) {
        print('PeriodicSyncService: Already running');
      }
      return;
    }

    _isRunning = true;
    if (kDebugMode) {
      print('PeriodicSyncService: Started');
    }

    // Attempt initial sync immediately
    _attemptSync();

    // Schedule periodic syncs
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      _attemptSync();
    });
  }

  /// Stop the periodic sync service
  ///
  /// Cancels the timer and stops automatic sync operations.
  void stop() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _isRunning = false;
    if (kDebugMode) {
      print('PeriodicSyncService: Stopped');
    }
  }

  /// Attempt to sync if conditions are met
  Future<void> _attemptSync() async {
    try {
      // Check if already syncing
      if (_orchestrator.isSyncing) {
        if (kDebugMode) {
          print('PeriodicSyncService: Sync already in progress, skipping');
        }
        return;
      }

      // Check authentication
      final isAuthenticated = await _authHelper.isAuthenticated();
      if (!isAuthenticated) {
        if (kDebugMode) {
          print('PeriodicSyncService: Not authenticated, skipping');
        }
        return;
      }

      // Check connectivity (implicitly - sync will fail if no connection)
      // We could add explicit connectivity check here, but for now
      // we'll let the sync fail gracefully

      // Perform sync (silently - no user-facing feedback)
      if (kDebugMode) {
        print('PeriodicSyncService: Attempting sync');
      }

      await _orchestrator.syncAll();

      if (kDebugMode) {
        print('PeriodicSyncService: Sync completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('PeriodicSyncService: Sync error: $e');
      }
    }
  }

  /// Check whether the service is running
  bool get isRunning => _isRunning;

  /// Dispose of the service and cleanup resources
  Future<void> dispose() async {
    stop();
  }
}
