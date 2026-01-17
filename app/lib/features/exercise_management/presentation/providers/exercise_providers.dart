// Dart SDK
import 'package:flutter/foundation.dart';

// Packages
import 'package:riverpod/riverpod.dart';

// Project
import 'package:health_app/core/network/auth_helper.dart';
import 'package:health_app/features/exercise_management/data/datasources/local/exercise_local_datasource.dart';
import 'package:health_app/features/exercise_management/data/datasources/remote/exercise_remote_datasource.dart';
import 'package:health_app/features/exercise_management/data/services/exercises_sync_service.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/domain/entities/workout_plan.dart';
import 'package:health_app/features/exercise_management/domain/usecases/create_exercise_template.dart';
import 'package:health_app/features/exercise_management/domain/usecases/create_workout_plan.dart';
import 'package:health_app/features/exercise_management/domain/usecases/delete_exercise_template.dart';
import 'package:health_app/features/exercise_management/domain/usecases/get_exercise_by_id.dart';
import 'package:health_app/features/exercise_management/domain/usecases/get_exercise_library.dart';
import 'package:health_app/features/exercise_management/domain/usecases/get_workout_history.dart';
import 'package:health_app/features/exercise_management/domain/usecases/log_workout.dart';
import 'package:health_app/features/exercise_management/domain/usecases/update_exercise_template.dart';
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

/// Provider for GetExerciseLibraryUseCase
final getExerciseLibraryUseCaseProvider =
    Provider<GetExerciseLibraryUseCase>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return GetExerciseLibraryUseCase(repository);
});

/// Provider for GetExerciseByIdUseCase
final getExerciseByIdUseCaseProvider = Provider<GetExerciseByIdUseCase>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return GetExerciseByIdUseCase(repository);
});

/// Provider for CreateExerciseTemplateUseCase
final createExerciseTemplateUseCaseProvider =
    Provider<CreateExerciseTemplateUseCase>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return CreateExerciseTemplateUseCase(repository);
});

/// Provider for UpdateExerciseTemplateUseCase
final updateExerciseTemplateUseCaseProvider =
    Provider<UpdateExerciseTemplateUseCase>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return UpdateExerciseTemplateUseCase(repository);
});

/// Provider for DeleteExerciseTemplateUseCase
final deleteExerciseTemplateUseCaseProvider =
    Provider<DeleteExerciseTemplateUseCase>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return DeleteExerciseTemplateUseCase(repository);
});

/// Provider for exercise library
///
/// Fetches all template exercises (exercises with date == null) for the current user.
/// Returns empty list if no user profile found or error occurs.
final exerciseLibraryProvider = FutureProvider<List<Exercise>>((ref) async {
  try {
    final userId = await ref.watch(currentUserIdProvider.future);

    if (userId == null) {
      return [];
    }

    final useCase = ref.watch(getExerciseLibraryUseCaseProvider);
    final result = await useCase.call(userId: userId);

    return result.fold(
      (failure) {
        // Log error for debugging
        debugPrint('Error fetching exercise library: ${failure.message}');
        // Return empty list on error
        return <Exercise>[];
      },
      (exercises) => exercises,
    );
  } catch (e) {
    // Log exception for debugging
    debugPrint('Exception fetching exercise library: $e');
    // Return empty list on exception
    return <Exercise>[];
  }
});

/// Provider for exercise by ID (family provider)
///
/// Fetches a single exercise by its ID.
/// Returns null if exercise not found or error occurs.
final exerciseByIdProvider =
    FutureProvider.family<Exercise?, String>((ref, exerciseId) async {
  try {
    final useCase = ref.watch(getExerciseByIdUseCaseProvider);
    final result = await useCase.call(exerciseId: exerciseId);

    return result.fold(
      (failure) {
        // Log error for debugging
        debugPrint('Error fetching exercise by ID: ${failure.message}');
        // Return null on error
        return null;
      },
      (exercise) => exercise,
    );
  } catch (e) {
    // Log exception for debugging
    debugPrint('Exception fetching exercise by ID: $e');
    // Return null on exception
    return null;
  }
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
final workoutHistoryProvider =
    FutureProvider.family<List<Exercise>, WorkoutHistoryParams>(
        (ref, params) async {
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

/// Provider for ExerciseRemoteDataSource
final exerciseRemoteDataSourceProvider =
    Provider<ExerciseRemoteDataSource>((ref) {
  return ExerciseRemoteDataSource();
});

/// Provider for ExercisesSyncService
final exercisesSyncServiceProvider = Provider<ExercisesSyncService>((ref) {
  final localDataSource = ref.watch(exerciseLocalDataSourceProvider);
  final remoteDataSource = ref.watch(exerciseRemoteDataSourceProvider);
  return ExercisesSyncService(localDataSource, remoteDataSource);
});
