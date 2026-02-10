import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/network/auth_helper.dart';
import 'package:health_app/features/medication_management/data/datasources/local/medication_local_datasource.dart';
import 'package:health_app/features/medication_management/data/datasources/remote/medication_remote_datasource.dart';
import 'package:health_app/features/medication_management/data/models/medication_model.dart';
import 'package:health_app/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sync failure for medications synchronization
class MedicationsSyncFailure extends Failure {
  MedicationsSyncFailure(super.message);
}

/// Service to handle synchronization of medications
class MedicationsSyncService {
  final MedicationLocalDataSource _localDataSource;
  final MedicationRemoteDataSource _remoteDataSource;
  final AuthHelper _authHelper;
  final UserProfileRepository? _userProfileRepository;
  static const String _lastSyncKey = 'last_medications_sync_timestamp';

  final _syncStatusController = StreamController<bool>.broadcast();
  Stream<bool> get isSyncing => _syncStatusController.stream;

  MedicationsSyncService(this._localDataSource, this._remoteDataSource,
      {AuthHelper? authHelper, UserProfileRepository? userProfileRepository})
      : _authHelper = authHelper ?? AuthHelper(),
        _userProfileRepository = userProfileRepository;

  /// Synchronize medications (push changes with delta filtering)
  Future<Result<void>> syncMedications({bool forceCount = false}) async {
    _syncStatusController.add(true);
    try {
      // 1. Check if authenticated
      final isAuthenticated = await _authHelper.isAuthenticated();
      print(
          'MedicationsSyncService: Starting sync. Authenticated: $isAuthenticated');
      if (!isAuthenticated) {
        return const Right(null); // Silent skip if not authenticated
      }

      // 2. Get user ID from local profile first (more reliable)
      String? userId = await _getLocalUserId();

      if (userId == null) {
        print('MedicationsSyncService: No local user ID, trying backend profile call');
        // Fallback to backend call if local profile not available
        var userResult = await _authHelper.getProfile();
        return userResult.fold(
          (failure) {
            print('MedicationsSyncService: Backend profile call failed: ${failure.message}');
            return Left(failure);
          },
          (user) async {
            return await _performSync(user.id);
          },
        );
      }

      print('MedicationsSyncService: Using local user ID: $userId');
      return await _performSync(userId);
    } catch (e) {
      print('MedicationsSyncService: Exception: $e');
      return Left(MedicationsSyncFailure('Sync error: ${e.toString()}'));
    } finally {
      _syncStatusController.add(false);
    }
  }

  /// Get the local user ID from the user profile repository
  Future<String?> _getLocalUserId() async {
    try {
      if (_userProfileRepository == null) {
        print('MedicationsSyncService: UserProfileRepository not available');
        return null;
      }

      final profileResult = await _userProfileRepository!.getCurrentUserProfile();

      return profileResult.fold(
        (failure) {
          print('MedicationsSyncService: Failed to get local profile: ${failure.message}');
          return null;
        },
        (profile) {
          print('MedicationsSyncService: Got local user ID from profile: ${profile.id}');
          return profile.id;
        },
      );
    } catch (e) {
      print('MedicationsSyncService: Error getting local user ID: $e');
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
      print('MedicationsSyncService: Last sync: $lastSync');

      // 2. Push local changes to backend
      final pushResult = await _pushLocalChanges(userId, lastSync);
      print('MedicationsSyncService: Push result: ${pushResult.isRight() ? "Success" : "Failure"}');
      if (pushResult.isLeft()) {
        return pushResult;
      }

      // 3. Update last sync timestamp
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

      return const Right(null);
    } catch (e) {
      print('MedicationsSyncService: Error during sync: $e');
      return Left(MedicationsSyncFailure('Sync error: ${e.toString()}'));
    }
  }
  Future<Result<void>> _pushLocalChanges(String userId, DateTime? lastSync) async {
    try {
      print(
          'MedicationsSyncService: Querying local medications for userId=$userId');

      final localMedicationsResult =
          await _localDataSource.getMedicationsByUserId(userId);

      return localMedicationsResult.fold(
        (failure) {
          print(
              'MedicationsSyncService: Failed to get local medications: ${failure.message}');
          return Left(failure);
        },
        (medications) async {
          print(
              'MedicationsSyncService: Total local medications: ${medications.length}');
          print('MedicationsSyncService: Last sync time: $lastSync');

          // Delta filtering: only sync medications updated since last sync
          final medicationsToSync = lastSync == null
              ? medications
              : medications.where((m) => m.updatedAt.isAfter(lastSync)).toList();

          print('MedicationsSyncService: Medications to sync: ${medicationsToSync.length}');

          if (medicationsToSync.isEmpty) {
            print('MedicationsSyncService: No medications to sync - all are already synced');
            return const Right(null);
          }

          final models =
              medicationsToSync.map((e) => MedicationModel.fromEntity(e)).toList();

          print(
              'MedicationsSyncService: Pushing ${models.length} medications to backend');

          final syncResult = await _remoteDataSource.bulkSync(models);

          return syncResult.fold(
            (failure) {
              print(
                  'MedicationsSyncService: Push failed with error: ${failure.message}');
              return Left(failure);
            },
            (result) {
              print(
                  'MedicationsSyncService: Push succeeded. Synced: ${result['synced_count']}, Updated: ${result['updated_count']}');
              return const Right(null);
            },
          );
        },
      );
    } catch (e) {
      return Left(MedicationsSyncFailure('Push error: ${e.toString()}'));
    }
  }

  /// Force clear sync timestamp (for debugging or logout)
  Future<void> clearSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSyncKey);
  }
}
