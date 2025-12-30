import 'package:riverpod/riverpod.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal.dart';
import 'package:health_app/features/behavioral_support/presentation/providers/behavioral_repository_provider.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';

/// Provider for all goals for the current user
/// 
/// Fetches all goals for the current user from the repository.
/// Returns empty list if user not found or no goals exist.
/// Handles error states by returning empty list.
final goalsProvider = FutureProvider<List<Goal>>((ref) async {
  try {
    // Get user profile to get userId
    final userProfileRepo = ref.watch(userProfileRepositoryProvider);
    final userResult = await userProfileRepo.getCurrentUserProfile();

    final userProfile = userResult.fold(
      (failure) => null,
      (profile) => profile,
    );

    if (userProfile == null) {
      return <Goal>[];
    }

    // Get goals for the user
    final behavioralRepo = ref.watch(behavioralRepositoryProvider);
    final result = await behavioralRepo.getGoalsByUserId(userProfile.id);

    return result.fold(
      (failure) {
        // Return empty list on error
        return <Goal>[];
      },
      (goals) => goals,
    );
  } catch (e) {
    // Return empty list on exception
    return <Goal>[];
  }
});

