
import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/network/authentication_service.dart';
import 'package:health_app/core/network/auth_helper.dart';
import 'package:health_app/features/health_tracking/data/datasources/local/health_tracking_local_datasource.dart';
import 'package:health_app/features/health_tracking/data/datasources/remote/health_tracking_remote_datasource.dart';
import 'package:health_app/features/health_tracking/data/models/health_metric_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle synchronization of health metrics
class HealthMetricsSyncService {
  final HealthTrackingLocalDataSource _localDataSource;
  final HealthTrackingRemoteDataSource _remoteDataSource;
  final AuthHelper _authHelper;
  static const String _lastSyncKey = 'last_health_metrics_sync_timestamp';
  
  final _syncStatusController = StreamController<bool>.broadcast();
  Stream<bool> get isSyncing => _syncStatusController.stream;

  HealthMetricsSyncService(
    this._localDataSource,
    this._remoteDataSource,
    [AuthHelper? authHelper]
  ) : _authHelper = authHelper ?? AuthHelper();

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
      
      final userResult = await _authHelper.getProfile();
      return userResult.fold(
        (failure) => Left(failure),
        (user) async {
          // 2. Get last sync timestamp
          final prefs = await SharedPreferences.getInstance();
          final lastSyncStr = prefs.getString(_lastSyncKey);
          final lastSync = lastSyncStr != null ? DateTime.parse(lastSyncStr) : null;
          print('SyncService: Last sync: $lastSync');
          
          // 3. Push local changes (created/updated since last sync)
          // For simplicity in this iteration, we push *all* local metrics that might have changed
          // A better approach would be to track 'dirty' flags locally
          // Here we fetch recent local metrics
          // Use a reasonable lookback window or all if no last sync
          final pushResult = await _pushLocalChanges(user.id, lastSync);
          print('SyncService: Push result: ${pushResult.isRight() ? "Success" : "Failure"}');
          if (pushResult.isLeft()) {
             // Continue to pull even if push fails partially? 
             // Ideally yes, but let's return error for now to be safe
             return pushResult;
          }

          // 4. Pull remote changes
          final pullResult = await _pullRemoteChanges(user.id, lastSync);
          print('SyncService: Pull result: ${pullResult.isRight() ? "Success" : "Failure"}');
          
          // 5. Update last sync timestamp if successful
          if (pullResult.isRight()) {
            await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
          }
          
          return pullResult;
        },
      );
    } catch (e) {
      print('SyncService: Exception: $e');
      return Left(SyncFailure('Sync error: ${e.toString()}'));
    } finally {
      _syncStatusController.add(false);
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
      
      final localMetricsResult = await _localDataSource.getHealthMetricsByUserId(userId);
      
      return localMetricsResult.fold(
        (failure) => Left(failure),
        (metrics) async {
          final metricsToSync = lastSync == null 
              ? metrics 
              : metrics.where((m) => m.updatedAt.isAfter(lastSync)).toList();
          
          if (metricsToSync.isEmpty) {
            return const Right(null);
          }

          final models = metricsToSync
              .map((e) => HealthMetricModel.fromEntity(e))
              .toList();

          // Use bulk sync endpoint
          print('SyncService: Pushing ${models.length} metrics to backend');
          final syncResult = await _remoteDataSource.bulkSync(models);
          
          return syncResult.fold(
            (failure) => Left(failure),
            (_) => const Right(null),
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
      final remoteMetricsResult = await _remoteDataSource.getHealthMetrics(
        startDate: lastSync != null ? lastSync.subtract(const Duration(days: 1)) : DateTime(2020),
      );

      return remoteMetricsResult.fold(
        (failure) => Left(failure),
        (remoteModels) async {
          if (remoteModels.isEmpty) {
            return const Right(null);
          }

          // Convert to Entities
          final remoteMetrics = remoteModels.map((m) => m.toEntity()).toList();

          // Save to local database (LocalDataSource handles upsert)
          final saveResult = await _localDataSource.saveHealthMetricsBatch(remoteMetrics);
          
          return saveResult.fold(
            (failure) => Left(failure),
            (_) => const Right(null),
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
