import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise_type.dart';
import 'package:health_app/features/exercise_management/domain/repositories/exercise_repository.dart';
import 'package:health_app/features/exercise_management/domain/usecases/create_workout_plan.dart';
import 'package:health_app/features/exercise_management/domain/usecases/get_workout_history.dart';
import 'package:health_app/features/exercise_management/domain/usecases/log_workout.dart';
import 'package:health_app/features/exercise_management/presentation/providers/exercise_providers.dart';
import 'package:health_app/features/exercise_management/presentation/providers/exercise_repository_provider.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:health_app/features/user_profile/domain/entities/gender.dart';
import 'package:health_app/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';

// Mock for ExerciseRepository
class MockExerciseRepository implements ExerciseRepository {
  List<Exercise>? exercisesToReturn;
  Failure? failureToReturn;

  @override
  Future<ExerciseResult> getExercise(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<ExerciseListResult> getExercisesByUserId(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<ExerciseListResult> getExercisesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(exercisesToReturn ?? []);
  }

  @override
  Future<ExerciseListResult> getExercisesByDate(
    String userId,
    DateTime date,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<ExerciseListResult> getExercisesByType(
    String userId,
    String exerciseType,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<ExerciseResult> saveExercise(Exercise exercise) async {
    throw UnimplementedError();
  }

  @override
  Future<ExerciseResult> updateExercise(Exercise exercise) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteExercise(String id) async {
    throw UnimplementedError();
  }
}

// Mock for UserProfileRepository
class MockUserProfileRepository implements UserProfileRepository {
  UserProfile? profileToReturn;
  Failure? failureToReturn;

  @override
  Future<UserProfileResult> getUserProfile(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<UserProfileResult> getCurrentUserProfile() async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    if (profileToReturn == null) {
      return Left(NotFoundFailure('UserProfile'));
    }
    return Right(profileToReturn!);
  }

  @override
  Future<UserProfileResult> saveUserProfile(UserProfile profile) async {
    throw UnimplementedError();
  }

  @override
  Future<UserProfileResult> updateUserProfile(UserProfile profile) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteUserProfile(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<bool>> userProfileExists(String id) async {
    throw UnimplementedError();
  }
}

void main() {
  late MockExerciseRepository mockExerciseRepository;
  late MockUserProfileRepository mockUserProfileRepository;
  late ProviderContainer container;

  setUp(() {
    mockExerciseRepository = MockExerciseRepository();
    mockUserProfileRepository = MockUserProfileRepository();

    container = ProviderContainer(
      overrides: [
        exerciseRepositoryProvider.overrideWithValue(mockExerciseRepository),
        userProfileRepositoryProvider.overrideWithValue(mockUserProfileRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('createWorkoutPlanUseCaseProvider', () {
    test('should provide CreateWorkoutPlanUseCase instance', () {
      // Act
      final useCase = container.read(createWorkoutPlanUseCaseProvider);

      // Assert
      expect(useCase, isNotNull);
      expect(useCase, isA<CreateWorkoutPlanUseCase>());
    });
  });

  group('getWorkoutHistoryUseCaseProvider', () {
    test('should provide GetWorkoutHistoryUseCase instance', () {
      // Act
      final useCase = container.read(getWorkoutHistoryUseCaseProvider);

      // Assert
      expect(useCase, isNotNull);
      expect(useCase, isA<GetWorkoutHistoryUseCase>());
    });
  });

  group('logWorkoutUseCaseProvider', () {
    test('should provide LogWorkoutUseCase instance', () {
      // Act
      final useCase = container.read(logWorkoutUseCaseProvider);

      // Assert
      expect(useCase, isNotNull);
      expect(useCase, isA<LogWorkoutUseCase>());
    });
  });

  group('currentUserIdProvider', () {
    test('should return user ID when user profile exists', () async {
      // Arrange
      final profile = UserProfile(
        id: 'user-123',
        name: 'Test User',
        email: 'test@example.com',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175.0,
        targetWeight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockUserProfileRepository.profileToReturn = profile;

      // Act
      final result = await container.read(currentUserIdProvider.future);

      // Assert
      expect(result, 'user-123');
    });

    test('should return null when user profile not found', () async {
      // Arrange
      mockUserProfileRepository.profileToReturn = null;
      mockUserProfileRepository.failureToReturn = NotFoundFailure('UserProfile');

      // Act
      final result = await container.read(currentUserIdProvider.future);

      // Assert
      expect(result, isNull);
    });
  });

  group('workoutPlansProvider', () {
    test('should return empty list when user not found', () async {
      // Arrange
      mockUserProfileRepository.profileToReturn = null;
      mockUserProfileRepository.failureToReturn = NotFoundFailure('UserProfile');

      // Act
      final result = await container.read(workoutPlansProvider.future);

      // Assert
      expect(result, isEmpty);
    });

    test('should return empty list when user exists (MVP - no repository support)', () async {
      // Arrange
      final profile = UserProfile(
        id: 'user-123',
        name: 'Test User',
        email: 'test@example.com',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175.0,
        targetWeight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockUserProfileRepository.profileToReturn = profile;

      // Act
      final result = await container.read(workoutPlansProvider.future);

      // Assert
      // In MVP, workout plans are not persisted, so should return empty list
      expect(result, isEmpty);
    });
  });

  group('workoutHistoryProvider', () {
    test('should return exercises when user exists and has exercises', () async {
      // Arrange
      final profile = UserProfile(
        id: 'user-123',
        name: 'Test User',
        email: 'test@example.com',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175.0,
        targetWeight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockUserProfileRepository.profileToReturn = profile;

      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day);
      final endDate = startDate.add(Duration(days: 7));

      final exercises = [
        Exercise(
          id: 'exercise-1',
          userId: 'user-123',
          name: 'Push-ups',
          type: ExerciseType.strength,
          muscleGroups: ['chest', 'triceps'],
          equipment: [],
          sets: 3,
          reps: 10,
          date: startDate,
          createdAt: now,
          updatedAt: now,
        ),
        Exercise(
          id: 'exercise-2',
          userId: 'user-123',
          name: 'Running',
          type: ExerciseType.cardio,
          muscleGroups: [],
          equipment: [],
          duration: 30,
          distance: 5.0,
          date: startDate.add(Duration(days: 1)),
          createdAt: now,
          updatedAt: now,
        ),
      ];
      mockExerciseRepository.exercisesToReturn = exercises;

      final params = WorkoutHistoryParams(
        startDate: startDate,
        endDate: endDate,
      );

      // Act
      final result = await container.read(workoutHistoryProvider(params).future);

      // Assert
      expect(result, hasLength(2));
      expect(result[0].id, 'exercise-2'); // Sorted by date (newest first)
      expect(result[1].id, 'exercise-1');
    });

    test('should return empty list when user not found', () async {
      // Arrange
      mockUserProfileRepository.profileToReturn = null;
      mockUserProfileRepository.failureToReturn = NotFoundFailure('UserProfile');

      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day);
      final endDate = startDate.add(Duration(days: 7));

      final params = WorkoutHistoryParams(
        startDate: startDate,
        endDate: endDate,
      );

      // Act
      final result = await container.read(workoutHistoryProvider(params).future);

      // Assert
      expect(result, isEmpty);
    });

    test('should return empty list when repository returns failure', () async {
      // Arrange
      final profile = UserProfile(
        id: 'user-123',
        name: 'Test User',
        email: 'test@example.com',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175.0,
        targetWeight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockUserProfileRepository.profileToReturn = profile;
      mockExerciseRepository.failureToReturn = DatabaseFailure('Database error');

      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day);
      final endDate = startDate.add(Duration(days: 7));

      final params = WorkoutHistoryParams(
        startDate: startDate,
        endDate: endDate,
      );

      // Act
      final result = await container.read(workoutHistoryProvider(params).future);

      // Assert
      expect(result, isEmpty);
    });

    test('should return empty list when no exercises exist', () async {
      // Arrange
      final profile = UserProfile(
        id: 'user-123',
        name: 'Test User',
        email: 'test@example.com',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175.0,
        targetWeight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockUserProfileRepository.profileToReturn = profile;
      mockExerciseRepository.exercisesToReturn = [];

      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day);
      final endDate = startDate.add(Duration(days: 7));

      final params = WorkoutHistoryParams(
        startDate: startDate,
        endDate: endDate,
      );

      // Act
      final result = await container.read(workoutHistoryProvider(params).future);

      // Assert
      expect(result, isEmpty);
    });

    test('should filter by exercise type when provided', () async {
      // Arrange
      final profile = UserProfile(
        id: 'user-123',
        name: 'Test User',
        email: 'test@example.com',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175.0,
        targetWeight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockUserProfileRepository.profileToReturn = profile;

      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day);
      final endDate = startDate.add(Duration(days: 7));

      final exercises = [
        Exercise(
          id: 'exercise-1',
          userId: 'user-123',
          name: 'Push-ups',
          type: ExerciseType.strength,
          muscleGroups: ['chest', 'triceps'],
          equipment: [],
          sets: 3,
          reps: 10,
          date: startDate,
          createdAt: now,
          updatedAt: now,
        ),
        Exercise(
          id: 'exercise-2',
          userId: 'user-123',
          name: 'Running',
          type: ExerciseType.cardio,
          muscleGroups: [],
          equipment: [],
          duration: 30,
          distance: 5.0,
          date: startDate.add(Duration(days: 1)),
          createdAt: now,
          updatedAt: now,
        ),
      ];
      mockExerciseRepository.exercisesToReturn = exercises;

      final params = WorkoutHistoryParams(
        startDate: startDate,
        endDate: endDate,
        exerciseType: 'strength',
      );

      // Act
      final result = await container.read(workoutHistoryProvider(params).future);

      // Assert
      expect(result, hasLength(1));
      expect(result[0].id, 'exercise-1');
      expect(result[0].type, ExerciseType.strength);
    });
  });
}

