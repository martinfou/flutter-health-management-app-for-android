import 'package:riverpod/riverpod.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit.dart';
import 'package:health_app/features/behavioral_support/presentation/providers/behavioral_repository_provider.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';

// Export goals provider
export 'package:health_app/features/behavioral_support/presentation/providers/goals_provider.dart';

/// Provider for all habits for the current user
/// 
/// Fetches all habits for the current user from the repository.
/// Returns empty list if user not found or no habits exist.
/// Handles error states by returning empty list.
final habitsProvider = FutureProvider<List<Habit>>((ref) async {
  try {
    // Get user profile to get userId
    final userProfileRepo = ref.watch(userProfileRepositoryProvider);
    final userResult = await userProfileRepo.getCurrentUserProfile();

    final userProfile = userResult.fold(
      (failure) => null,
      (profile) => profile,
    );

    if (userProfile == null) {
      return <Habit>[];
    }

    // Get habits for the user
    final behavioralRepo = ref.watch(behavioralRepositoryProvider);
    final result = await behavioralRepo.getHabitsByUserId(userProfile.id);

    return result.fold(
      (failure) {
        // Return empty list on error
        return <Habit>[];
      },
      (habits) => habits,
    );
  } catch (e) {
    // Return empty list on exception
    return <Habit>[];
  }
});

/// Provider for weekly review data
/// 
/// For MVP, this is a basic provider that returns empty data.
/// LLM integration will be added in post-MVP phase.
/// Currently returns a placeholder structure.
final weeklyReviewProvider = Provider<Map<String, dynamic>>((ref) {
  // Basic implementation for MVP - returns empty review data
  // LLM integration will be added in post-MVP phase
  return {
    'summary': '',
    'insights': [],
    'recommendations': [],
  };
});

