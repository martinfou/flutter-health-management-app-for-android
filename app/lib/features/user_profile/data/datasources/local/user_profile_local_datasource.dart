import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fpdart/fpdart.dart';
import 'package:path_provider/path_provider.dart';
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
  /// 
  /// Ensures the box is open before returning it.
  /// If the box is not open, attempts to open it.
  /// If opening fails due to corrupted data, deletes the box file and creates a fresh one.
  Future<Box<UserProfileModel>> get _box async {
    if (!Hive.isBoxOpen(HiveBoxNames.userProfile)) {
      // Try to open the box if it's not open
      try {
        // Ensure adapter is registered before opening
        if (!Hive.isAdapterRegistered(0)) {
          Hive.registerAdapter(UserProfileModelAdapter());
        }
        return await Hive.openBox<UserProfileModel>(HiveBoxNames.userProfile);
      } catch (e) {
        // Check if it's a type cast error (corrupted data)
        // Catch TypeError, CastError, or any error containing type mismatch messages
        final errorString = e.toString().toLowerCase();
        final isTypeError = e is TypeError ||
            errorString.contains('is not a subtype') ||
            errorString.contains('type cast') ||
            errorString.contains('type \'bool\'') ||
            errorString.contains('type \'double\'');
        
        if (isTypeError) {
          // Corrupted box file - delete it and create a fresh one
          try {
            // Close the box if it's partially open (might fail, that's ok)
            try {
              if (Hive.isBoxOpen(HiveBoxNames.userProfile)) {
                await Hive.box(HiveBoxNames.userProfile).close();
              }
            } catch (_) {
              // Ignore close errors
            }
            
            // Delete the corrupted box file
            // Hive stores boxes in the application documents directory
            final appDir = await getApplicationDocumentsDirectory();
            final boxName = HiveBoxNames.userProfile;
            
            // Hive stores boxes with the box name as the filename
            // Try multiple possible locations and file patterns
            final filesToDelete = [
              '${appDir.path}/$boxName.hive',
              '${appDir.path}/$boxName.lock',
              '${appDir.path}/.hive/$boxName.hive',
              '${appDir.path}/.hive/$boxName.lock',
              // Also try with different extensions
              '${appDir.path}/$boxName',
            ];
            
            // Delete all possible box files
            for (final path in filesToDelete) {
              try {
                final file = File(path);
                if (await file.exists()) {
                  await file.delete(recursive: false);
                }
              } catch (_) {
                // Ignore individual file deletion errors
              }
            }
            
            // Also try to delete the directory if it exists
            try {
              final hiveDir = Directory('${appDir.path}/.hive');
              if (await hiveDir.exists()) {
                // Don't delete the whole .hive directory, just the specific box files
                // But we already tried those above
              }
            } catch (_) {
              // Ignore directory errors
            }
            
            // Wait a bit to ensure file system operations complete
            await Future.delayed(const Duration(milliseconds: 100));
            
            // Now try to open a fresh box
            return await Hive.openBox<UserProfileModel>(HiveBoxNames.userProfile);
          } catch (deleteError) {
            // If deletion or retry fails, we need to inform the user
            // But first, let's try one more time with a different approach
            try {
              // Force close all Hive boxes and try again
              await Hive.close();
              await Future.delayed(const Duration(milliseconds: 200));
              
              // Re-register adapter
              if (!Hive.isAdapterRegistered(0)) {
                Hive.registerAdapter(UserProfileModelAdapter());
              }
              
              return await Hive.openBox<UserProfileModel>(HiveBoxNames.userProfile);
            } catch (finalError) {
              // Last resort - throw a clear error message
              throw DatabaseFailure(
                'Failed to open user profile box due to corrupted data. '
                'Original error: $e\n'
                'Please clear app data in Android settings and restart the app.',
              );
            }
          }
        }
        // For other errors, throw as-is
        throw DatabaseFailure('Failed to open user profile box: $e');
      }
    }
    return Hive.box<UserProfileModel>(HiveBoxNames.userProfile);
  }

  /// Get user profile by ID
  Future<Result<UserProfile>> getUserProfile(String id) async {
    try {
      final box = await _box;
      
      // Try to get the model, handling potential type cast errors
      UserProfileModel? model;
      try {
        model = box.get(_userProfileKey);
      } catch (e) {
        // Type cast error - corrupted data in Hive
        // Clear the corrupted entry
        try {
          await box.delete(_userProfileKey);
        } catch (_) {
          // Ignore delete errors
        }
        return Left(DatabaseFailure(
          'User profile data is corrupted. Please recreate your profile.',
        ));
      }
      
      if (model == null) {
        return Left(NotFoundFailure('UserProfile'));
      }

      if (model.id != id) {
        return Left(NotFoundFailure('UserProfile'));
      }

      // Safely convert to entity, handling any remaining type issues
      try {
        return Right(model.toEntity());
      } catch (e) {
        // If toEntity fails, the data is corrupted
        // Clear it and return error
        try {
          await box.delete(_userProfileKey);
        } catch (_) {
          // Ignore delete errors
        }
        return Left(DatabaseFailure(
          'User profile data is corrupted. Please recreate your profile.',
        ));
      }
    } catch (e) {
      return Left(DatabaseFailure('Failed to get user profile: $e'));
    }
  }

  /// Get the current user profile
  /// 
  /// For MVP, there's only one user profile stored with constant key.
  Future<Result<UserProfile>> getCurrentUserProfile() async {
    try {
      // Get box - this will handle corrupted data automatically
      final box = await _box;
      
      // Try to get the model, handling potential type cast errors
      UserProfileModel? model;
      try {
        model = box.get(_userProfileKey);
      } catch (e) {
        // Type cast error - corrupted data in Hive
        // Clear the corrupted entry
        try {
          await box.delete(_userProfileKey);
        } catch (_) {
          // Ignore delete errors
        }
        return Left(DatabaseFailure(
          'User profile data is corrupted. Please recreate your profile.',
        ));
      }
      
      if (model == null) {
        return Left(NotFoundFailure('UserProfile'));
      }

      // Safely convert to entity, handling any remaining type issues
      try {
        return Right(model.toEntity());
      } catch (e) {
        // If toEntity fails, the data is corrupted
        // Clear it and return error
        try {
          await box.delete(_userProfileKey);
        } catch (_) {
          // Ignore delete errors
        }
        return Left(DatabaseFailure(
          'User profile data is corrupted. Please recreate your profile.',
        ));
      }
    } catch (e) {
      return Left(DatabaseFailure('Failed to get current user profile: $e'));
    }
  }

  /// Save user profile
  /// 
  /// Creates new profile or updates existing one.
  Future<Result<UserProfile>> saveUserProfile(UserProfile profile) async {
    try {
      final box = await _box;
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
      final box = await _box;
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
      final box = await _box;
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
      final box = await _box;
      
      // Try to get the model, handling potential type cast errors
      UserProfileModel? model;
      try {
        model = box.get(_userProfileKey);
      } catch (e) {
        // Type cast error - corrupted data
        // Clear it and return false
        try {
          await box.delete(_userProfileKey);
        } catch (_) {
          // Ignore delete errors
        }
        return const Right(false);
      }
      
      if (model == null) {
        return const Right(false);
      }

      return Right(model.id == id);
    } catch (e) {
      return Left(DatabaseFailure('Failed to check if user profile exists: $e'));
    }
  }

  /// Clear corrupted user profile data
  /// 
  /// Use this if you encounter type cast errors with user profile data.
  Future<Result<void>> clearCorruptedData() async {
    try {
      final box = await _box;
      await box.delete(_userProfileKey);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to clear corrupted data: $e'));
    }
  }
}

