import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/device/device_service.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/network/auth_helper.dart';
import 'package:health_app/features/nutrition_management/data/datasources/local/nutrition_local_datasource.dart';
import 'package:health_app/features/nutrition_management/data/datasources/remote/nutrition_remote_datasource.dart';
import 'package:health_app/features/nutrition_management/data/models/meal_model.dart';
import 'package:health_app/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sync failure for meals synchronization
class MealsSyncFailure extends Failure {
  MealsSyncFailure(super.message);
}

/// Service to handle synchronization of meals
class MealsSyncService {
  final NutritionLocalDataSource _localDataSource;
  final NutritionRemoteDataSource _remoteDataSource;
  final AuthHelper _authHelper;
  final UserProfileRepository? _userProfileRepository;
  final DeviceService _deviceService;
  static const String _lastSyncKey = 'last_meals_sync_timestamp';

  final _syncStatusController = StreamController<bool>.broadcast();
  Stream<bool> get isSyncing => _syncStatusController.stream;

  MealsSyncService(this._localDataSource, this._remoteDataSource,
      {AuthHelper? authHelper,
      UserProfileRepository? userProfileRepository,
      DeviceService? deviceService})
      : _authHelper = authHelper ?? AuthHelper(),
        _userProfileRepository = userProfileRepository,
        _deviceService = deviceService ?? DeviceService();

  /// Synchronize meals (push changes, pull changes, resolve conflicts)
  Future<Result<void>> syncMeals({bool forceCount = false}) async {
    _syncStatusController.add(true);
    try {
      // 1. Check if authenticated
      final isAuthenticated = await _authHelper.isAuthenticated();
      print('MealsSyncService: Starting sync. Authenticated: $isAuthenticated');
      if (!isAuthenticated) {
        return const Right(null); // Silent skip if not authenticated
      }

      // 2. Get user ID from local profile first (more reliable)
      String? userId = await _getLocalUserId();

      if (userId == null) {
        print('MealsSyncService: No local user ID, trying backend profile call');
        // Fallback to backend call if local profile not available
        var userResult = await _authHelper.getProfile();
        return userResult.fold(
          (failure) {
            print('MealsSyncService: Backend profile call failed: ${failure.message}');
            return Left(failure);
          },
          (user) async {
            return await _performSync(user.id);
          },
        );
      }

      print('MealsSyncService: Using local user ID: $userId');
      return await _performSync(userId);
    } catch (e) {
      print('MealsSyncService: Exception: $e');
      return Left(MealsSyncFailure('Sync error: ${e.toString()}'));
    } finally {
      _syncStatusController.add(false);
    }
  }

  /// Get the local user ID from the user profile repository
  Future<String?> _getLocalUserId() async {
    try {
      if (_userProfileRepository == null) {
        print('MealsSyncService: UserProfileRepository not available');
        return null;
      }

      final profileResult = await _userProfileRepository!.getCurrentUserProfile();

      return profileResult.fold(
        (failure) {
          print('MealsSyncService: Failed to get local profile: ${failure.message}');
          return null;
        },
        (profile) {
          print('MealsSyncService: Got local user ID from profile: ${profile.id}');
          return profile.id;
        },
      );
    } catch (e) {
      print('MealsSyncService: Error getting local user ID: $e');
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
      print('MealsSyncService: Last sync: $lastSync');

      // 1. Migrate any existing meals to correct userId (for meals created before authentication)
      final migrationResult = await _localDataSource.migrateMealsToUserId(userId);
      if (migrationResult.isLeft()) {
        print('MealsSyncService: Migration failed: ${migrationResult.fold((f) => f.message, (_) => "")}');
        // Continue with sync even if migration fails
      }

      // 2. Push local changes (created/updated since last sync)
      final pushResult = await _pushLocalChanges(userId, lastSync);
      print('MealsSyncService: Push result: ${pushResult.isRight() ? "Success" : "Failure"}');
      if (pushResult.isLeft()) {
        return pushResult;
      }

      // 3. Pull remote changes
      final pullResult = await _pullRemoteChanges(userId, lastSync);
      print('MealsSyncService: Pull result: ${pullResult.isRight() ? "Success" : "Failure"}');

      // 4. Update last sync timestamp if successful
      if (pullResult.isRight()) {
        await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      }

      return pullResult;
    } catch (e) {
      print('MealsSyncService: Error during sync: $e');
      return Left(MealsSyncFailure('Sync error: ${e.toString()}'));
    }
  }

  /// Push local changes to backend
  Future<Result<void>> _pushLocalChanges(String userId, DateTime? lastSync) async {
    try {
      print('MealsSyncService: Querying local meals for userId=$userId');

      final localMealsResult = await _localDataSource.getMealsByUserId(userId);

      return localMealsResult.fold(
        (failure) {
          print('MealsSyncService: Failed to get local meals: ${failure.message}');
          return Left(failure);
        },
        (meals) async {
          print('MealsSyncService: Total local meals: ${meals.length}');
          print('MealsSyncService: Last sync time: $lastSync');

          // Delta filtering: only sync meals updated since last sync
          final mealsToSync = lastSync == null
              ? meals
              : meals.where((m) => m.updatedAt.isAfter(lastSync)).toList();

          print('MealsSyncService: Meals to sync: ${mealsToSync.length}');

          if (mealsToSync.isEmpty) {
            print('MealsSyncService: No meals to sync - all are already synced');
            return const Right(null);
          }

          final models = mealsToSync.map((e) => MealModel.fromEntity(e)).toList();

          // Use bulk sync endpoint with last sync timestamp for bidirectional sync
          print('MealsSyncService: Pushing ${models.length} meals to backend');
          final syncResult = await _remoteDataSource.bulkSync(models, lastSyncTimestamp: lastSync);

          return syncResult.fold(
            (failure) {
              print('MealsSyncService: Push failed with error: ${failure.message}');
              return Left(failure);
            },
            (result) {
              print('MealsSyncService: Push succeeded. Synced: ${result['synced_count']}, Updated: ${result['updated_count']}');
              return const Right(null);
            },
          );
        },
      );
    } catch (e) {
      return Left(MealsSyncFailure('Push error: ${e.toString()}'));
    }
  }

  /// Pull remote changes from backend
  ///
  /// Fetches meals that have been created or modified on the server since the last sync.
  /// This enables multi-device synchronization - changes made on other devices will be
  /// pulled to this device and merged with local data using conflict resolution.
  Future<Result<void>> _pullRemoteChanges(String userId, DateTime? lastSync) async {
    try {
      print('MealsSyncService: Pulling remote changes since $lastSync');

      // Fetch meals changed since last sync from backend
      final remoteResult = await _remoteDataSource.getChangesSince(lastSync);

      return remoteResult.fold(
        (failure) {
          print('MealsSyncService: Failed to fetch remote meals: ${failure.message}');
          return Left(failure);
        },
        (remoteModels) async {
          if (remoteModels.isEmpty) {
            print('MealsSyncService: No remote changes since $lastSync');
            return const Right(null);
          }

          print('MealsSyncService: Received ${remoteModels.length} remote meal changes');

          // Convert models to entities
          final remoteMeals = remoteModels.map((m) => m.toEntity()).toList();

          // Save to local database with conflict resolution
          // (newer timestamp wins - implemented in saveMealsBatch)
          final saveResult = await _localDataSource.saveMealsBatch(remoteMeals);

          return saveResult.fold(
            (failure) {
              print('MealsSyncService: Failed to save remote meals: ${failure.message}');
              return Left(failure);
            },
            (_) {
              print('MealsSyncService: Successfully merged ${remoteMeals.length} remote meals locally');
              return const Right(null);
            },
          );
        },
      );
    } catch (e) {
      print('MealsSyncService: Error pulling remote changes: $e');
      return Left(MealsSyncFailure('Pull error: ${e.toString()}'));
    }
  }

  /// Force clear sync timestamp (for debugging or logout)
  Future<void> clearSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSyncKey);
  }
}
