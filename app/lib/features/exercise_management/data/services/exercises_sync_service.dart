import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/network/auth_helper.dart';
import 'package:health_app/features/exercise_management/data/datasources/local/exercise_local_datasource.dart';
import 'package:health_app/features/exercise_management/data/datasources/remote/exercise_remote_datasource.dart';
import 'package:health_app/features/exercise_management/data/models/exercise_model.dart';
import 'package:health_app/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sync failure for exercises synchronization
class ExercisesSyncFailure extends Failure {
  ExercisesSyncFailure(super.message);
}

/// Service to handle synchronization of exercises
class ExercisesSyncService {
  final ExerciseLocalDataSource _localDataSource;
  final ExerciseRemoteDataSource _remoteDataSource;
  final AuthHelper _authHelper;
  final UserProfileRepository? _userProfileRepository;
  static const String _lastSyncKey = 'last_exercises_sync_timestamp';

  final _syncStatusController = StreamController<bool>.broadcast();
  Stream<bool> get isSyncing => _syncStatusController.stream;

  ExercisesSyncService(this._localDataSource, this._remoteDataSource,
      {AuthHelper? authHelper, UserProfileRepository? userProfileRepository})
      : _authHelper = authHelper ?? AuthHelper(),
        _userProfileRepository = userProfileRepository;

  /// Synchronize exercises (push changes with delta filtering)
  Future<Result<void>> syncExercises({bool forceCount = false}) async {
    _syncStatusController.add(true);
    try {
      // 1. Check if authenticated
      final isAuthenticated = await _authHelper.isAuthenticated();
      print(
          'ExercisesSyncService: Starting sync. Authenticated: $isAuthenticated');
      if (!isAuthenticated) {
        return const Right(null); // Silent skip if not authenticated
      }

      // 2. Get user ID from local profile first (more reliable)
      String? userId = await _getLocalUserId();

      if (userId == null) {
        print('ExercisesSyncService: No local user ID, trying backend profile call');
        // Fallback to backend call if local profile not available
        var userResult = await _authHelper.getProfile();
        return userResult.fold(
          (failure) {
            print('ExercisesSyncService: Backend profile call failed: ${failure.message}');
            return Left(failure);
          },
          (user) async {
            return await _performSync(user.id);
          },
        );
      }

      print('ExercisesSyncService: Using local user ID: $userId');
      return await _performSync(userId);
    } catch (e) {
      print('ExercisesSyncService: Exception: $e');
      return Left(ExercisesSyncFailure('Sync error: ${e.toString()}'));
    } finally {
      _syncStatusController.add(false);
    }
  }

  /// Get the local user ID from the user profile repository
  Future<String?> _getLocalUserId() async {
    try {
      if (_userProfileRepository == null) {
        print('ExercisesSyncService: UserProfileRepository not available');
        return null;
      }

      final profileResult = await _userProfileRepository!.getCurrentUserProfile();

      return profileResult.fold(
        (failure) {
          print('ExercisesSyncService: Failed to get local profile: ${failure.message}');
          return null;
        },
        (profile) {
          print('ExercisesSyncService: Got local user ID from profile: ${profile.id}');
          return profile.id;
        },
      );
    } catch (e) {
      print('ExercisesSyncService: Error getting local user ID: $e');
      return null;
    }
  }

  /// Perform the actual sync operation with the given user ID
  Future<Either<Failure, void>> _performSync(String userId) async {
    try {
      // 1. Get last sync timestamp for delta filtering
      final prefs = await SharedPreferences.getInstance();
      final lastSyncStr = prefs.getString(_lastSyncKey);
      final lastSync = lastSyncStr != null ? DateTime.parse(lastSyncStr) : null;
      print('ExercisesSyncService: Last sync: $lastSync');

      // 2. Push local changes to backend
      final pushResult = await _pushLocalChanges(userId, lastSync);
      print('ExercisesSyncService: Push result: ${pushResult.isRight() ? "Success" : "Failure"}');
      if (pushResult.isLeft()) {
        return pushResult;
      }

      // 3. Update last sync timestamp
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

      return const Right(null);
    } catch (e) {
      print('ExercisesSyncService: Error during sync: $e');
      return Left(ExercisesSyncFailure('Sync error: ${e.toString()}'));
    }
  }
  Future<Result<void>> _pushLocalChanges(String userId, DateTime? lastSync) async {
    try {
      print(
          'ExercisesSyncService: Querying local exercises for userId=$userId');

      final localExercisesResult =
          await _localDataSource.getExercisesByUserId(userId);

      return localExercisesResult.fold(
        (failure) {
          print(
              'ExercisesSyncService: Failed to get local exercises: ${failure.message}');
          return Left(failure);
        },
        (exercises) async {
          print(
              'ExercisesSyncService: Total local exercises: ${exercises.length}');
          print('ExercisesSyncService: Last sync time: $lastSync');

          // Delta filtering: only sync exercises updated since last sync
          final exercisesToSync = lastSync == null
              ? exercises
              : exercises.where((e) => e.updatedAt.isAfter(lastSync)).toList();

          print('ExercisesSyncService: Exercises to sync: ${exercisesToSync.length}');

          if (exercisesToSync.isEmpty) {
            print('ExercisesSyncService: No exercises to sync - all are already synced');
            return const Right(null);
          }

          final models =
              exercisesToSync.map((e) => ExerciseModel.fromEntity(e)).toList();

          print(
              'ExercisesSyncService: Pushing ${models.length} exercises to backend');

          final syncResult = await _remoteDataSource.bulkSync(models);

          return syncResult.fold(
            (failure) {
              print(
                  'ExercisesSyncService: Push failed with error: ${failure.message}');
              return Left(failure);
            },
            (result) {
              print(
                  'ExercisesSyncService: Push succeeded. Synced: ${result['synced_count']}, Updated: ${result['updated_count']}');
              return const Right(null);
            },
          );
        },
      );
    } catch (e) {
      return Left(ExercisesSyncFailure('Push error: ${e.toString()}'));
    }
  }

  /// Force clear sync timestamp (for debugging or logout)
  Future<void> clearSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSyncKey);
  }
}
