import 'package:hive_flutter/hive_flutter.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/providers/database_provider.dart';
import 'package:health_app/features/user_profile/data/models/user_profile_model.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';

/// Local data source for UserProfile
/// 
/// Handles direct Hive database operations for user profiles.
class UserProfileLocalDataSource {
  /// Constant key for single user profile in box
  static const String _userProfileKey = 'user_profile';

  /// Get Hive box for user profiles
  Box<UserProfileModel> get _box {
    if (!Hive.isBoxOpen(HiveBoxNames.userProfile)) {
      throw DatabaseFailure('User profile box is not open');
    }
    return Hive.box<UserProfileModel>(HiveBoxNames.userProfile);
  }

  /// Get user profile by ID
  Future<Result<UserProfile>> getUserProfile(String id) async {
    try {
      final box = _box;
      final model = box.get(_userProfileKey);
      
      if (model == null) {
        return Left(NotFoundFailure('UserProfile'));
      }

      if (model.id != id) {
        return Left(NotFoundFailure('UserProfile'));
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get user profile: $e'));
    }
  }

  /// Get the current user profile
  /// 
  /// For MVP, there's only one user profile stored with constant key.
  Future<Result<UserProfile>> getCurrentUserProfile() async {
    try {
      final box = _box;
      final model = box.get(_userProfileKey);
      
      if (model == null) {
        return Left(NotFoundFailure('UserProfile'));
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get current user profile: $e'));
    }
  }

  /// Save user profile
  /// 
  /// Creates new profile or updates existing one.
  Future<Result<UserProfile>> saveUserProfile(UserProfile profile) async {
    try {
      final box = _box;
      final model = UserProfileModel.fromEntity(profile);
      await box.put(_userProfileKey, model);
      return Right(profile);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save user profile: $e'));
    }
  }

  /// Update user profile
  /// 
  /// Updates existing profile.
  Future<Result<UserProfile>> updateUserProfile(UserProfile profile) async {
    try {
      final box = _box;
      final existing = box.get(_userProfileKey);
      
      if (existing == null) {
        return Left(NotFoundFailure('UserProfile'));
      }

      final model = UserProfileModel.fromEntity(profile);
      await box.put(_userProfileKey, model);
      return Right(profile);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update user profile: $e'));
    }
  }

  /// Delete user profile
  Future<Result<void>> deleteUserProfile(String id) async {
    try {
      final box = _box;
      final model = box.get(_userProfileKey);
      
      if (model == null || model.id != id) {
        return Left(NotFoundFailure('UserProfile'));
      }

      await box.delete(_userProfileKey);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete user profile: $e'));
    }
  }

  /// Check if user profile exists
  Future<Result<bool>> userProfileExists(String id) async {
    try {
      final box = _box;
      final model = box.get(_userProfileKey);
      
      if (model == null) {
        return const Right(false);
      }

      return Right(model.id == id);
    } catch (e) {
      return Left(DatabaseFailure('Failed to check if user profile exists: $e'));
    }
  }
}

