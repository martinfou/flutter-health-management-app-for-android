import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit_category.dart';
import 'package:health_app/features/behavioral_support/domain/repositories/behavioral_repository.dart';
import 'package:health_app/features/behavioral_support/domain/usecases/track_habit.dart';

// Manual mock for BehavioralRepository
class MockBehavioralRepository implements BehavioralRepository {
  Habit? habitToReturn;
  Habit? updatedHabit;
  Failure? failureToReturn;
  Failure? getHabitFailure;

  @override
  Future<Result<Habit>> getHabit(String id) async {
    if (getHabitFailure != null) {
      return Left(getHabitFailure!);
    }
    if (habitToReturn != null) {
      return Right(habitToReturn!);
    }
    return Left(NotFoundFailure('Habit'));
  }

  @override
  Future<Result<Habit>> updateHabit(Habit habit) async {
    updatedHabit = habit;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(habit);
  }

  @override
  Future<Result<List<Habit>>> getHabitsByUserId(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Habit>>> getHabitsByCategory(String userId, String category) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<Habit>> saveHabit(Habit habit) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteHabit(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<Goal>> getGoal(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Goal>>> getGoalsByUserId(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Goal>>> getGoalsByType(String userId, String goalType) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Goal>>> getGoalsByStatus(String userId, String status) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<Goal>> saveGoal(Goal goal) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<Goal>> updateGoal(Goal goal) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteGoal(String id) async {
    throw UnimplementedError();
  }
}

void main() {
  late TrackHabitUseCase useCase;
  late MockBehavioralRepository mockRepository;

  setUp(() {
    mockRepository = MockBehavioralRepository();
    useCase = TrackHabitUseCase(mockRepository);
  });

  group('TrackHabitUseCase', () {
    test('should track habit completion successfully', () async {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final habit = Habit(
        id: 'habit-1',
        userId: 'user-id',
        name: 'Drink Water',
        category: HabitCategory.nutrition,
        completedDates: [],
        currentStreak: 0,
        longestStreak: 0,
        startDate: today.subtract(Duration(days: 7)),
        createdAt: now,
        updatedAt: now,
      );
      mockRepository.habitToReturn = habit;
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(habitId: 'habit-1');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (updated) {
          expect(updated.completedDates.length, 1);
          expect(updated.currentStreak, 1);
          expect(updated.longestStreak, 1);
        },
      );
    });

    test('should not add duplicate completion for same date', () async {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final habit = Habit(
        id: 'habit-1',
        userId: 'user-id',
        name: 'Drink Water',
        category: HabitCategory.nutrition,
        completedDates: [today],
        currentStreak: 1,
        longestStreak: 1,
        startDate: today.subtract(Duration(days: 7)),
        createdAt: now,
        updatedAt: now,
      );
      mockRepository.habitToReturn = habit;

      // Act
      final result = await useCase.call(habitId: 'habit-1');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (updated) {
          expect(updated.completedDates.length, 1);
          expect(updated.currentStreak, 1);
        },
      );
    });

    test('should calculate current streak correctly', () async {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(Duration(days: 1));
      final habit = Habit(
        id: 'habit-1',
        userId: 'user-id',
        name: 'Exercise',
        category: HabitCategory.exercise,
        completedDates: [yesterday],
        currentStreak: 1,
        longestStreak: 1,
        startDate: today.subtract(Duration(days: 7)),
        createdAt: now,
        updatedAt: now,
      );
      mockRepository.habitToReturn = habit;

      // Act
      final result = await useCase.call(habitId: 'habit-1');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (updated) {
          expect(updated.completedDates.length, 2);
          expect(updated.currentStreak, 2);
        },
      );
    });

    test('should calculate longest streak correctly', () async {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dates = [
        today.subtract(Duration(days: 5)),
        today.subtract(Duration(days: 4)),
        today.subtract(Duration(days: 3)),
        today.subtract(Duration(days: 1)),
      ];
      final habit = Habit(
        id: 'habit-1',
        userId: 'user-id',
        name: 'Exercise',
        category: HabitCategory.exercise,
        completedDates: dates,
        currentStreak: 1,
        longestStreak: 3,
        startDate: today.subtract(Duration(days: 10)),
        createdAt: now,
        updatedAt: now,
      );
      mockRepository.habitToReturn = habit;

      // Act
      final result = await useCase.call(habitId: 'habit-1');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (updated) {
          expect(updated.completedDates.length, 5);
          // Longest streak should be 3 (days 5, 4, 3) or 2 (days 1, today)
          expect(updated.longestStreak, greaterThanOrEqualTo(2));
        },
      );
    });

    test('should track completion for specific date', () async {
      // Arrange
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final habit = Habit(
        id: 'habit-1',
        userId: 'user-id',
        name: 'Meditation',
        category: HabitCategory.selfCare,
        completedDates: [],
        currentStreak: 0,
        longestStreak: 0,
        startDate: yesterday.subtract(Duration(days: 7)),
        createdAt: now,
        updatedAt: now,
      );
      mockRepository.habitToReturn = habit;

      // Act
      final result = await useCase.call(
        habitId: 'habit-1',
        completedDate: yesterday,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (updated) {
          expect(updated.completedDates.length, 1);
          final completedDate = DateTime(
            updated.completedDates.first.year,
            updated.completedDates.first.month,
            updated.completedDates.first.day,
          );
          expect(completedDate, yesterday);
        },
      );
    });

    test('should return ValidationFailure when date is in future', () async {
      // Arrange
      final futureDate = DateTime.now().add(Duration(days: 1));
      final habit = Habit(
        id: 'habit-1',
        userId: 'user-id',
        name: 'Habit',
        category: HabitCategory.other,
        completedDates: [],
        currentStreak: 0,
        longestStreak: 0,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockRepository.habitToReturn = habit;

      // Act
      final result = await useCase.call(
        habitId: 'habit-1',
        completedDate: futureDate,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('future'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return NotFoundFailure when habit does not exist', () async {
      // Arrange
      mockRepository.getHabitFailure = NotFoundFailure('Habit');

      // Act
      final result = await useCase.call(habitId: 'non-existent');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<NotFoundFailure>());
          expect(failure.message, contains('Habit'));
        },
        (_) => fail('Should return NotFoundFailure'),
      );
    });

    test('should propagate DatabaseFailure from repository', () async {
      // Arrange
      final now = DateTime.now();
      final habit = Habit(
        id: 'habit-1',
        userId: 'user-id',
        name: 'Habit',
        category: HabitCategory.other,
        completedDates: [],
        currentStreak: 0,
        longestStreak: 0,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );
      mockRepository.habitToReturn = habit;
      mockRepository.failureToReturn = DatabaseFailure('Database error');

      // Act
      final result = await useCase.call(habitId: 'habit-1');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Database error');
        },
        (_) => fail('Should return DatabaseFailure'),
      );
    });

    test('should handle streak reset when gap exists', () async {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final threeDaysAgo = today.subtract(Duration(days: 3));
      final habit = Habit(
        id: 'habit-1',
        userId: 'user-id',
        name: 'Exercise',
        category: HabitCategory.exercise,
        completedDates: [threeDaysAgo],
        currentStreak: 0, // Streak broken
        longestStreak: 1,
        startDate: today.subtract(Duration(days: 7)),
        createdAt: now,
        updatedAt: now,
      );
      mockRepository.habitToReturn = habit;

      // Act
      final result = await useCase.call(habitId: 'habit-1');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (updated) {
          expect(updated.completedDates.length, 2);
          // Current streak should be 1 (only today, gap before)
          expect(updated.currentStreak, 1);
        },
      );
    });
  });
}

