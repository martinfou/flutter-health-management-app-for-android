import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:health_app/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:health_app/features/user_profile/data/datasources/local/user_profile_local_datasource.dart';

/// UserProfile repository implementation
/// 
/// Implements the UserProfileRepository interface using local data source.
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileLocalDataSource _localDataSource;

  UserProfileRepositoryImpl(this._localDataSource);

  @override
  Future<UserProfileResult> getUserProfile(String id) async {
    return await _localDataSource.getUserProfile(id);
  }

  @override
  Future<UserProfileResult> getCurrentUserProfile() async {
    return await _localDataSource.getCurrentUserProfile();
  }

  @override
  Future<UserProfileResult> saveUserProfile(UserProfile profile) async {
    // Basic validation
    if (profile.name.isEmpty) {
      return Left(ValidationFailure('Name cannot be empty'));
    }
    if (profile.email.isEmpty) {
      return Left(ValidationFailure('Email cannot be empty'));
    }
    if (profile.height <= 0) {
      return Left(ValidationFailure('Height must be greater than 0'));
    }
    if (profile.targetWeight <= 0) {
      return Left(ValidationFailure('Target weight must be greater than 0'));
    }

    return await _localDataSource.saveUserProfile(profile);
  }

  @override
  Future<UserProfileResult> updateUserProfile(UserProfile profile) async {
    // Basic validation
    if (profile.name.isEmpty) {
      return Left(ValidationFailure('Name cannot be empty'));
    }
    if (profile.email.isEmpty) {
      return Left(ValidationFailure('Email cannot be empty'));
    }
    if (profile.height <= 0) {
      return Left(ValidationFailure('Height must be greater than 0'));
    }
    if (profile.targetWeight <= 0) {
      return Left(ValidationFailure('Target weight must be greater than 0'));
    }

    return await _localDataSource.updateUserProfile(profile);
  }

  @override
  Future<Result<void>> deleteUserProfile(String id) async {
    return await _localDataSource.deleteUserProfile(id);
  }

  @override
  Future<Result<bool>> userProfileExists(String id) async {
    return await _localDataSource.userProfileExists(id);
  }
}

