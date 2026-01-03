import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit_category.dart';
import 'package:health_app/features/behavioral_support/domain/repositories/behavioral_repository.dart';
import 'package:health_app/features/behavioral_support/presentation/providers/behavioral_providers.dart';
import 'package:health_app/features/behavioral_support/presentation/providers/behavioral_repository_provider.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:health_app/features/user_profile/domain/entities/gender.dart';
import 'package:health_app/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';

// Mock for BehavioralRepository
class MockBehavioralRepository implements BehavioralRepository {
  List<Habit>? habitsToReturn;
  Failure? failureToReturn;

  @override
  Future<HabitResult> getHabit(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<HabitListResult> getHabitsByUserId(String userId) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(habitsToReturn ?? []);
  }

  @override
  Future<HabitListResult> getHabitsByCategory(String userId, String category) async {
    throw UnimplementedError();
  }

  @override
  Future<HabitResult> saveHabit(Habit habit) async {
    throw UnimplementedError();
  }

  @override
  Future<HabitResult> updateHabit(Habit habit) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteHabit(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<GoalResult> getGoal(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<GoalListResult> getGoalsByUserId(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<GoalListResult> getGoalsByType(String userId, String goalType) async {
    throw UnimplementedError();
  }

  @override
  Future<GoalListResult> getGoalsByStatus(String userId, String status) async {
    throw UnimplementedError();
  }

  @override
  Future<GoalResult> saveGoal(Goal goal) async {
    throw UnimplementedError();
  }

  @override
  Future<GoalResult> updateGoal(Goal goal) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteGoal(String id) async {
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
  late MockBehavioralRepository mockBehavioralRepository;
  late MockUserProfileRepository mockUserProfileRepository;
  late ProviderContainer container;

  setUp(() {
    mockBehavioralRepository = MockBehavioralRepository();
    mockUserProfileRepository = MockUserProfileRepository();
    
    container = ProviderContainer(
      overrides: [
        behavioralRepositoryProvider.overrideWithValue(mockBehavioralRepository),
        userProfileRepositoryProvider.overrideWithValue(mockUserProfileRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('habitsProvider', () {
    test('should return habits when user exists and has habits', () async {
      // Arrange
      final profile = UserProfile(
        id: 'user-123',
        name: 'Test User',
        email: 'test@example.com',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175.0,
        weight: 70.0,
        targetWeight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockUserProfileRepository.profileToReturn = profile;

      final now = DateTime.now();
      final habits = [
        Habit(
          id: 'habit-1',
          userId: 'user-123',
          name: 'Daily Walk',
          category: HabitCategory.exercise,
          description: 'Walk 10,000 steps',
          completedDates: [],
          currentStreak: 0,
          longestStreak: 0,
          startDate: now,
          createdAt: now,
          updatedAt: now,
        ),
        Habit(
          id: 'habit-2',
          userId: 'user-123',
          name: 'Drink Water',
          category: HabitCategory.nutrition,
          description: 'Drink 8 glasses of water',
          completedDates: [],
          currentStreak: 0,
          longestStreak: 0,
          startDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      mockBehavioralRepository.habitsToReturn = habits;

      // Act
      final result = await container.read(habitsProvider.future);

      // Assert
      expect(result, hasLength(2));
      expect(result[0].id, 'habit-1');
      expect(result[0].name, 'Daily Walk');
      expect(result[1].id, 'habit-2');
      expect(result[1].name, 'Drink Water');
    });

    test('should return empty list when user not found', () async {
      // Arrange
      mockUserProfileRepository.profileToReturn = null;
      mockUserProfileRepository.failureToReturn = NotFoundFailure('UserProfile');

      // Act
      final result = await container.read(habitsProvider.future);

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
        weight: 70.0,
        targetWeight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockUserProfileRepository.profileToReturn = profile;
      mockBehavioralRepository.failureToReturn = DatabaseFailure('Database error');

      // Act
      final result = await container.read(habitsProvider.future);

      // Assert
      expect(result, isEmpty);
    });

    test('should return empty list when no habits exist', () async {
      // Arrange
      final profile = UserProfile(
        id: 'user-123',
        name: 'Test User',
        email: 'test@example.com',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175.0,
        weight: 70.0,
        targetWeight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockUserProfileRepository.profileToReturn = profile;
      mockBehavioralRepository.habitsToReturn = [];

      // Act
      final result = await container.read(habitsProvider.future);

      // Assert
      expect(result, isEmpty);
    });
  });

  group('weeklyReviewProvider', () {
    test('should return basic review structure', () {
      // Act
      final result = container.read(weeklyReviewProvider);

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['summary'], '');
      expect(result['insights'], isA<List>());
      expect(result['recommendations'], isA<List>());
      expect(result['insights'], isEmpty);
      expect(result['recommendations'], isEmpty);
    });
  });
}

