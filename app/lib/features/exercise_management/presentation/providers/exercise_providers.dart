// Dart SDK
import 'package:flutter/foundation.dart';

// Packages
import 'package:riverpod/riverpod.dart';

// Project
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/domain/entities/workout_plan.dart';
import 'package:health_app/features/exercise_management/domain/usecases/create_workout_plan.dart';
import 'package:health_app/features/exercise_management/domain/usecases/get_workout_history.dart';
import 'package:health_app/features/exercise_management/domain/usecases/log_workout.dart';
import 'package:health_app/features/exercise_management/presentation/providers/exercise_repository_provider.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';

/// Provider for CreateWorkoutPlanUseCase
final createWorkoutPlanUseCaseProvider =
    Provider<CreateWorkoutPlanUseCase>((ref) {
  return CreateWorkoutPlanUseCase();
});

/// Provider for GetWorkoutHistoryUseCase
final getWorkoutHistoryUseCaseProvider =
    Provider<GetWorkoutHistoryUseCase>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return GetWorkoutHistoryUseCase(repository);
});

/// Provider for LogWorkoutUseCase
final logWorkoutUseCaseProvider = Provider<LogWorkoutUseCase>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return LogWorkoutUseCase(repository);
});

/// Provider for current user ID
/// 
/// Gets the current user profile and extracts the user ID.
/// Returns null if no user profile exists.
final currentUserIdProvider = FutureProvider<String?>((ref) async {
  final repository = ref.watch(userProfileRepositoryProvider);
  final result = await repository.getCurrentUserProfile();
  
  return result.fold(
    (failure) => null,
    (profile) => profile.id,
  );
});

/// Provider for workout plans
/// 
/// Fetches all workout plans for the current user.
/// Note: Workout plan repository support is not yet implemented in MVP.
/// This provider returns an empty list for now.
/// Returns empty list if user not found or error occurs.
final workoutPlansProvider = FutureProvider<List<WorkoutPlan>>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  
  if (userId == null) {
    return [];
  }
  
  // TODO: Implement workout plan repository support in post-MVP
  // For MVP, return empty list as workout plans are not persisted yet
  return [];
});

/// Provider for workout history
/// 
/// Uses family provider to accept date range parameters.
/// Returns empty list if no user profile found or error occurs.
final workoutHistoryProvider = FutureProvider.family<
    List<Exercise>, WorkoutHistoryParams>((ref, params) async {
  try {
    final userId = await ref.watch(currentUserIdProvider.future);
    
    if (userId == null) {
      return [];
    }
    
    final useCase = ref.watch(getWorkoutHistoryUseCaseProvider);
    final result = await useCase.call(
      userId: userId,
      startDate: params.startDate,
      endDate: params.endDate,
      exerciseType: params.exerciseType,
    );
    
    return result.fold(
      (failure) {
        // Log error for debugging
        debugPrint('Error fetching workout history: ${failure.message}');
        // Return empty list on error
        return <Exercise>[];
      },
      (exercises) => exercises,
    );
  } catch (e) {
    // Log exception for debugging
    debugPrint('Exception fetching workout history: $e');
    // Return empty list on exception
    return <Exercise>[];
  }
});

/// Parameters for workout history provider
class WorkoutHistoryParams {
  /// Start date for the workout history query
  final DateTime startDate;
  
  /// End date for the workout history query
  final DateTime endDate;
  
  /// Optional exercise type filter
  final String? exerciseType;
  
  /// Creates WorkoutHistoryParams
  WorkoutHistoryParams({
    required this.startDate,
    required this.endDate,
    this.exerciseType,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutHistoryParams &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          exerciseType == other.exerciseType;
  
  @override
  int get hashCode =>
      startDate.hashCode ^ endDate.hashCode ^ exerciseType.hashCode;
}

