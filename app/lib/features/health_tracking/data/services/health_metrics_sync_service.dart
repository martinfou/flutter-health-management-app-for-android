
import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/network/authentication_service.dart';
import 'package:health_app/core/network/auth_helper.dart';
import 'package:health_app/features/health_tracking/data/datasources/local/health_tracking_local_datasource.dart';
import 'package:health_app/features/health_tracking/data/datasources/remote/health_tracking_remote_datasource.dart';
import 'package:health_app/features/health_tracking/data/models/health_metric_model.dart';
import 'package:health_app/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle synchronization of health metrics
class HealthMetricsSyncService {
  final HealthTrackingLocalDataSource _localDataSource;
  final HealthTrackingRemoteDataSource _remoteDataSource;
  final AuthHelper _authHelper;
  final UserProfileRepository? _userProfileRepository;
  static const String _lastSyncKey = 'last_health_metrics_sync_timestamp';

  final _syncStatusController = StreamController<bool>.broadcast();
  Stream<bool> get isSyncing => _syncStatusController.stream;

  HealthMetricsSyncService(
    this._localDataSource,
    this._remoteDataSource,
    {AuthHelper? authHelper, UserProfileRepository? userProfileRepository}
  ) : _authHelper = authHelper ?? AuthHelper(),
      _userProfileRepository = userProfileRepository;

  /// Synchronize health metrics (push changes, pull changes, resolve conflicts)
  Future<Result<void>> syncHealthMetrics({bool forceCount = false}) async {
    _syncStatusController.add(true);
    try {
      // 1. Check if authenticated
      final isAuthenticated = await _authHelper.isAuthenticated();
      print('SyncService: Starting sync. Authenticated: $isAuthenticated');
      if (!isAuthenticated) {
        return const Right(null); // Silent skip if not authenticated
      }

      // 2. Get user ID from local profile first (more reliable)
      // The local profile is set during login and has the correct userId
      // This avoids depending on backend profile endpoint which might not exist yet
      String? userId = await _getLocalUserId();

      if (userId == null) {
        print('SyncService: No local user ID, trying backend profile call');
        // Fallback to backend call if local profile not available
        var userResult = await _authHelper.getProfile();
        return userResult.fold(
          (failure) {
            print('SyncService: Backend profile call failed: ${failure.message}');
            return Left(failure);
          },
          (user) async {
            return await _performSync(user.id);
          },
        );
      }

      print('SyncService: Using local user ID: $userId');
      return await _performSync(userId);
    } catch (e) {
      print('SyncService: Exception: $e');
      return Left(SyncFailure('Sync error: ${e.toString()}'));
    } finally {
      _syncStatusController.add(false);
    }
  }

  /// Get the local user ID from the user profile repository
  Future<String?> _getLocalUserId() async {
    try {
      if (_userProfileRepository == null) {
        print('SyncService: UserProfileRepository not available');
        return null;
      }

      final profileResult = await _userProfileRepository!.getCurrentUserProfile();

      return profileResult.fold(
        (failure) {
          print('SyncService: Failed to get local profile: ${failure.message}');
          return null;
        },
        (profile) {
          print('SyncService: Got local user ID from profile: ${profile.id}');
          return profile.id;
        },
      );
    } catch (e) {
      print('SyncService: Error getting local user ID: $e');
      return null;
    }
  }

  /// Perform the actual sync operation with the given user ID
  Future<Either<Failure, void>> _performSync(String userId) async {
    try {
      // Get last sync timestamp
      final prefs = await SharedPreferences.getInstance();
      final lastSyncStr = prefs.getString(_lastSyncKey);
      final lastSync = lastSyncStr != null ? DateTime.parse(lastSyncStr) : null;
      print('SyncService: Last sync: $lastSync');

      // 3. Push local changes (created/updated since last sync)
      // For simplicity in this iteration, we push *all* local metrics that might have changed
      // A better approach would be to track 'dirty' flags locally
      // Here we fetch recent local metrics
      // Use a reasonable lookback window or all if no last sync
      final pushResult = await _pushLocalChanges(userId, lastSync);
      print('SyncService: Push result: ${pushResult.isRight() ? "Success" : "Failure"}');
      if (pushResult.isLeft()) {
        // Continue to pull even if push fails partially?
        // Ideally yes, but let's return error for now to be safe
        return pushResult;
      }

      // 4. Pull remote changes
      final pullResult = await _pullRemoteChanges(userId, lastSync);
      print('SyncService: Pull result: ${pullResult.isRight() ? "Success" : "Failure"}');

      // 5. Update last sync timestamp if successful
      if (pullResult.isRight()) {
        await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      }

      return pullResult;
    } catch (e) {
      print('SyncService: Error during sync: $e');
      return Left(SyncFailure('Sync error: ${e.toString()}'));
    }
  }

  /// Push local changes to backend
  Future<Result<void>> _pushLocalChanges(String userId, DateTime? lastSync) async {
    try {
      // Get all local metrics for user
      // Optimization: filter by updated_at > lastSync
      // Since `getHealthMetricsByUserId` returns Entity, we might need a method that returns Model
      // or convert Entity to Model. LocalDataSource returns Entity.
      // We will cast/convert.

      print('SyncService: Querying local metrics for userId=$userId');

      final localMetricsResult = await _localDataSource.getHealthMetricsByUserId(userId);

      return localMetricsResult.fold(
        (failure) {
          print('SyncService: Failed to get local metrics: ${failure.message}');
          return Left(failure);
        },
        (metrics) async {
          print('SyncService: Total local metrics: ${metrics.length}');
          print('SyncService: Last sync time: $lastSync');
          if (metrics.isNotEmpty) {
            print('SyncService: Local metric userIds: ${metrics.map((m) => m.userId).toSet()}');
          }

          final metricsToSync = lastSync == null
              ? metrics
              : metrics.where((m) => m.updatedAt.isAfter(lastSync)).toList();

          print('SyncService: Metrics to sync: ${metricsToSync.length}');

          if (metricsToSync.isEmpty) {
            print('SyncService: No metrics to sync - all are already synced');
            return const Right(null);
          }

          final models = metricsToSync
              .map((e) => HealthMetricModel.fromEntity(e))
              .toList();

          // Use bulk sync endpoint
          print('SyncService: Pushing ${models.length} metrics to backend');
          print('SyncService: Metrics to sync: ${models.map((m) => m.id).toList()}');
          final syncResult = await _remoteDataSource.bulkSync(models);

          return syncResult.fold(
            (failure) {
              print('SyncService: Push failed with error: ${failure.message}');
              return Left(failure);
            },
            (result) {
              print('SyncService: Push succeeded. Result: $result');
              return const Right(null);
            },
          );
        },
      );
    } catch (e) {
      return Left(SyncFailure('Push error: ${e.toString()}'));
    }
  }

  /// Pull remote changes from backend
  Future<Result<void>> _pullRemoteChanges(String userId, DateTime? lastSync) async {
    try {
      // Use updated_since for efficient delta sync if we have a last sync time
      // This ensures we only download metrics that have changed since last sync
      final remoteMetricsResult = await _remoteDataSource.getHealthMetrics(
        updatedSince: lastSync, // Pass null if no last sync to get all
      );

      return remoteMetricsResult.fold(
        (failure) => Left(failure),
        (remoteModels) async {
          if (remoteModels.isEmpty) {
            print('SyncService: No remote changes since $lastSync');
            return const Right(null);
          }

          print('SyncService: Received ${remoteModels.length} remote changes');

          // Convert to Entities
          final remoteMetrics = remoteModels.map((m) => m.toEntity()).toList();

          // Save to local database (LocalDataSource handles upsert with conflict resolution)
          final saveResult = await _localDataSource.saveHealthMetricsBatch(remoteMetrics);

          return saveResult.fold(
            (failure) => Left(failure),
            (_) {
              print('SyncService: Successfully saved ${remoteMetrics.length} remote metrics locally');
              return const Right(null);
            },
          );
        },
      );
    } catch (e) {
      return Left(SyncFailure('Pull error: ${e.toString()}'));
    }
  }

  /// Force clear sync timestamp (for debugging or logout)
  Future<void> clearSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSyncKey);
  }
}

class SyncFailure extends Failure {
  SyncFailure(super.message);
}
