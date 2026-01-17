import 'dart:async';
import 'package:fpdart/fpdart.dart';
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
  static const String _lastSyncKey = 'last_meals_sync_timestamp';

  final _syncStatusController = StreamController<bool>.broadcast();
  Stream<bool> get isSyncing => _syncStatusController.stream;

  MealsSyncService(this._localDataSource, this._remoteDataSource,
      {AuthHelper? authHelper, UserProfileRepository? userProfileRepository})
      : _authHelper = authHelper ?? AuthHelper(),
        _userProfileRepository = userProfileRepository;

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

      // 2. Get user ID from auth helper (same pattern as health metrics)
      final userResult = await _authHelper.getProfile();
      final userId = userResult.fold(
        (failure) {
          print(
              'MealsSyncService: Failed to get user profile: ${failure.message}');
          return null;
        },
        (user) => user.id,
      );

      if (userId == null) {
        print('MealsSyncService: No user ID available');
        return Left(MealsSyncFailure('No user ID available for sync'));
      }

      // 3. Migrate any existing meals to correct userId
      final migrationResult =
          await _localDataSource.migrateMealsToUserId(userId);
      if (migrationResult.isLeft()) {
        print(
            'MealsSyncService: Migration failed: ${migrationResult.fold((f) => f.message, (_) => "")}');
        // Continue with sync even if migration fails
      }

      // 4. Push local changes (created/updated since last sync)
      final pushResult = await _pushLocalChanges(userId);
      print(
          'MealsSyncService: Push result: ${pushResult.isRight() ? "Success" : "Failure"}');
      if (pushResult.isLeft()) {
        return pushResult;
      }

      // 5. Update last sync timestamp
      await _updateLastSyncTimestamp();

      return const Right(null);
    } catch (e) {
      print('MealsSyncService: Error during sync: $e');
      return Left(MealsSyncFailure('Sync error: ${e.toString()}'));
    } finally {
      _syncStatusController.add(false);
    }
  }

  /// Push local changes to backend
  Future<Result<void>> _pushLocalChanges(String userId) async {
    try {
      print('MealsSyncService: Querying local meals for userId=$userId');

      final localMealsResult = await _localDataSource.getMealsByUserId(userId);

      return localMealsResult.fold(
        (failure) {
          print(
              'MealsSyncService: Failed to get local meals: ${failure.message}');
          return Left(failure);
        },
        (meals) async {
          print('MealsSyncService: Total local meals: ${meals.length}');

          if (meals.isEmpty) {
            print('MealsSyncService: No meals to sync');
            return const Right(null);
          }

          final models = meals.map((e) => MealModel.fromEntity(e)).toList();

          print('MealsSyncService: Pushing ${models.length} meals to backend');

          final syncResult = await _remoteDataSource.bulkSync(models);

          return syncResult.fold(
            (failure) {
              print(
                  'MealsSyncService: Push failed with error: ${failure.message}');
              return Left(failure);
            },
            (result) {
              print(
                  'MealsSyncService: Push succeeded. Synced: ${result['synced_count']}, Updated: ${result['updated_count']}');
              return const Right(null);
            },
          );
        },
      );
    } catch (e) {
      return Left(MealsSyncFailure('Push error: ${e.toString()}'));
    }
  }

  Future<void> _updateLastSyncTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('MealsSyncService: Error updating sync timestamp: $e');
    }
  }
}
