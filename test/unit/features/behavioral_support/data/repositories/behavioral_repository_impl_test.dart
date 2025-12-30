import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/behavioral_support/data/repositories/behavioral_repository_impl.dart';
import 'package:health_app/features/behavioral_support/data/datasources/local/behavioral_local_datasource.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit_category.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal_type.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal_status.dart';

// Mock data source
class MockBehavioralLocalDataSource implements BehavioralLocalDataSource {
  Habit? habitToReturn;
  List<Habit>? habitsToReturn;
  Goal? goalToReturn;
  List<Goal>? goalsToReturn;
  Failure? failureToReturn;
  Habit? savedHabit;
  Goal? savedGoal;
  String? deletedId;

  @override
  Future<Either<Failure, Habit>> getHabit(String id) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    if (habitToReturn == null) {
      return Left(NotFoundFailure('Habit'));
    }
    return Right(habitToReturn!);
  }

  @override
  Future<Either<Failure, List<Habit>>> getHabitsByUserId(String userId) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(habitsToReturn ?? []);
  }

  @override
  Future<Either<Failure, List<Habit>>> getHabitsByCategory(
    String userId,
    String category,
  ) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(habitsToReturn ?? []);
  }

  @override
  Future<Either<Failure, Habit>> saveHabit(Habit habit) async {
    savedHabit = habit;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(habit);
  }

  @override
  Future<Either<Failure, Habit>> updateHabit(Habit habit) async {
    savedHabit = habit;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(habit);
  }

  @override
  Future<Either<Failure, void>> deleteHabit(String id) async {
    deletedId = id;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, Goal>> getGoal(String id) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    if (goalToReturn == null) {
      return Left(NotFoundFailure('Goal'));
    }
    return Right(goalToReturn!);
  }

  @override
  Future<Either<Failure, List<Goal>>> getGoalsByUserId(String userId) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(goalsToReturn ?? []);
  }

  @override
  Future<Either<Failure, List<Goal>>> getGoalsByType(
    String userId,
    String goalType,
  ) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(goalsToReturn ?? []);
  }

  @override
  Future<Either<Failure, List<Goal>>> getGoalsByStatus(
    String userId,
    String status,
  ) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(goalsToReturn ?? []);
  }

  @override
  Future<Either<Failure, Goal>> saveGoal(Goal goal) async {
    savedGoal = goal;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(goal);
  }

  @override
  Future<Either<Failure, Goal>> updateGoal(Goal goal) async {
    savedGoal = goal;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(goal);
  }

  @override
  Future<Either<Failure, void>> deleteGoal(String id) async {
    deletedId = id;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return const Right(null);
  }
}

void main() {
  late BehavioralRepositoryImpl repository;
  late MockBehavioralLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockBehavioralLocalDataSource();
    repository = BehavioralRepositoryImpl(mockDataSource);
  });

  group('saveHabit', () {
    test('should return validation failure when habit name is empty', () async {
      // Arrange
      final habit = Habit(
        id: 'test-id',
        userId: 'user-1',
        name: '', // Empty name
        category: HabitCategory.nutrition,
        completedDates: [],
        currentStreak: 0,
        longestStreak: 0,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveHabit(habit);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Habit name cannot be empty'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return validation failure when start date is in future',
        () async {
      // Arrange
      final habit = Habit(
        id: 'test-id',
        userId: 'user-1',
        name: 'Log meals daily',
        category: HabitCategory.nutrition,
        completedDates: [],
        currentStreak: 0,
        longestStreak: 0,
        startDate: DateTime.now().add(Duration(days: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveHabit(habit);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            contains('Start date cannot be in the future'),
          );
        },
        (_) => fail('Should fail'),
      );
    });

    test('should save valid habit', () async {
      // Arrange
      final habit = Habit(
        id: 'test-id',
        userId: 'user-1',
        name: 'Log meals daily',
        category: HabitCategory.nutrition,
        completedDates: [],
        currentStreak: 0,
        longestStreak: 0,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveHabit(habit);

      // Assert
      expect(result.isRight(), isTrue);
      expect(mockDataSource.savedHabit, isNotNull);
      expect(mockDataSource.savedHabit!.id, 'test-id');
    });
  });

  group('saveGoal', () {
    test('should return validation failure when goal description is empty',
        () async {
      // Arrange
      final goal = Goal(
        id: 'test-id',
        userId: 'user-1',
        type: GoalType.behavior,
        description: '', // Empty description
        currentValue: 0.0,
        status: GoalStatus.inProgress,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveGoal(goal);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            contains('Goal description cannot be empty'),
          );
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return validation failure when target value <= 0', () async {
      // Arrange
      final goal = Goal(
        id: 'test-id',
        userId: 'user-1',
        type: GoalType.behavior,
        description: 'Exercise 3 times per week',
        targetValue: 0.0, // <= 0
        currentValue: 0.0,
        status: GoalStatus.inProgress,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveGoal(goal);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            contains('Target value must be greater than 0 if provided'),
          );
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return validation failure when deadline is in past', () async {
      // Arrange
      final goal = Goal(
        id: 'test-id',
        userId: 'user-1',
        type: GoalType.behavior,
        description: 'Exercise 3 times per week',
        targetValue: 3.0,
        currentValue: 0.0,
        deadline: DateTime.now().subtract(Duration(days: 1)),
        status: GoalStatus.inProgress,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveGoal(goal);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            contains('Deadline must be in the future if provided'),
          );
        },
        (_) => fail('Should fail'),
      );
    });

    test('should save valid goal', () async {
      // Arrange
      final goal = Goal(
        id: 'test-id',
        userId: 'user-1',
        type: GoalType.behavior,
        description: 'Exercise 3 times per week',
        targetValue: 3.0,
        currentValue: 0.0,
        status: GoalStatus.inProgress,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveGoal(goal);

      // Assert
      expect(result.isRight(), isTrue);
      expect(mockDataSource.savedGoal, isNotNull);
      expect(mockDataSource.savedGoal!.id, 'test-id');
    });
  });
}

