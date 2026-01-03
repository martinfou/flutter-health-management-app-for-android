import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:health_app/features/user_profile/domain/entities/gender.dart';
import 'package:health_app/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:health_app/features/user_profile/data/datasources/local/user_profile_local_datasource.dart';

/// UserProfile repository implementation
/// 
/// Implements the UserProfileRepository interface using local data source.
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileLocalDataSource _localDataSource;
  final bool _authDisabled;

  UserProfileRepositoryImpl(this._localDataSource, {bool authDisabled = false})
      : _authDisabled = authDisabled;

  /// Get a mock/default user profile for use when authentication is disabled
  UserProfile _getMockUserProfile() {
    final now = DateTime.now();
    final dateOfBirth = DateTime(now.year - 30, now.month, now.day); // 30 years old
    
    return UserProfile(
      id: 'mock-user-profile',
      name: 'Demo User',
      email: 'demo@healthapp.com',
      dateOfBirth: dateOfBirth,
      gender: Gender.other,
      height: 170.0, // 170 cm
      weight: 75.0, // 75 kg
      targetWeight: 70.0, // 70 kg
      fitnessGoals: ['Weight loss', 'Better health'],
      dietaryApproach: 'Standard',
      dislikes: [],
      allergies: [],
      healthConditions: [],
      syncEnabled: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<UserProfileResult> getUserProfile(String id) async {
    final result = await _localDataSource.getUserProfile(id);
    
    // If profile not found and auth is disabled, return mock profile
    if (result.isLeft()) {
      final failure = result.getLeft().getOrElse(() => DatabaseFailure('Unknown error'));
      if (failure is NotFoundFailure && _authDisabled) {
        final mockProfile = _getMockUserProfile();
        // Only return mock if the requested ID matches or if it's the mock ID
        if (id == mockProfile.id || _authDisabled) {
          return Right(mockProfile);
        }
      }
    }
    
    return result;
  }

  @override
  Future<UserProfileResult> getCurrentUserProfile() async {
    final result = await _localDataSource.getCurrentUserProfile();
    
    // If profile not found and auth is disabled, return mock profile
    if (result.isLeft()) {
      final failure = result.getLeft().getOrElse(() => DatabaseFailure('Unknown error'));
      if (failure is NotFoundFailure && _authDisabled) {
        return Right(_getMockUserProfile());
      }
    }
    
    return result;
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

