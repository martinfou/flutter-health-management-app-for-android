import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';

/// Type alias for repository result
typedef UserProfileResult = Result<UserProfile>;
typedef UserProfileListResult = Result<List<UserProfile>>;

/// UserProfile repository interface
/// 
/// Defines the contract for user profile data operations.
/// Implementation is in the data layer.
abstract class UserProfileRepository {
  /// Get user profile by ID
  /// 
  /// Returns [NotFoundFailure] if profile doesn't exist.
  Future<UserProfileResult> getUserProfile(String id);

  /// Get the current user profile
  /// 
  /// For MVP, there's only one user profile.
  /// Returns [NotFoundFailure] if no profile exists.
  Future<UserProfileResult> getCurrentUserProfile();

  /// Save user profile
  /// 
  /// Creates new profile or updates existing one.
  /// Returns [ValidationFailure] if profile data is invalid.
  Future<UserProfileResult> saveUserProfile(UserProfile profile);

  /// Update user profile
  /// 
  /// Updates existing profile.
  /// Returns [NotFoundFailure] if profile doesn't exist.
  /// Returns [ValidationFailure] if profile data is invalid.
  Future<UserProfileResult> updateUserProfile(UserProfile profile);

  /// Delete user profile
  /// 
  /// Returns [NotFoundFailure] if profile doesn't exist.
  Future<Result<void>> deleteUserProfile(String id);

  /// Check if user profile exists
  Future<Result<bool>> userProfileExists(String id);
}

