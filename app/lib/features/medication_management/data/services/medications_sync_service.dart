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

  /// Synchronize medications (push changes, pull changes, resolve conflicts)
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

      // 2. Get user ID from auth helper
      final userResult = await _authHelper.getProfile();
      final userId = userResult.fold(
        (failure) {
          print(
              'MedicationsSyncService: Failed to get user profile: ${failure.message}');
          return null;
        },
        (user) => user.id,
      );

      if (userId == null) {
        print('MedicationsSyncService: No user ID available');
        return Left(MedicationsSyncFailure('No user ID available for sync'));
      }

      // 3. Push local changes to backend
      final pushResult = await _pushLocalChanges(userId);
      print(
          'MedicationsSyncService: Push result: ${pushResult.isRight() ? "Success" : "Failure"}');
      if (pushResult.isLeft()) {
        return pushResult;
      }

      // 4. Update last sync timestamp
      await _updateLastSyncTimestamp();

      return const Right(null);
    } catch (e) {
      print('MedicationsSyncService: Error during sync: $e');
      return Left(MedicationsSyncFailure('Sync error: ${e.toString()}'));
    } finally {
      _syncStatusController.add(false);
    }
  }

  /// Push local changes to backend
  Future<Result<void>> _pushLocalChanges(String userId) async {
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

          if (medications.isEmpty) {
            print('MedicationsSyncService: No medications to sync');
            return const Right(null);
          }

          final models =
              medications.map((e) => MedicationModel.fromEntity(e)).toList();

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

  Future<void> _updateLastSyncTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('MedicationsSyncService: Error updating sync timestamp: $e');
    }
  }
}
