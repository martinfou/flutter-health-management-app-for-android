import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal_status.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal_type.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit.dart';
import 'package:health_app/features/behavioral_support/domain/repositories/behavioral_repository.dart';
import 'package:health_app/features/behavioral_support/domain/usecases/create_goal.dart';

// Manual mock for BehavioralRepository
class MockBehavioralRepository implements BehavioralRepository {
  Goal? savedGoal;
  Failure? failureToReturn;

  @override
  Future<Result<Goal>> saveGoal(Goal goal) async {
    savedGoal = goal;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(goal);
  }

  @override
  Future<Result<Habit>> getHabit(String id) async {
    throw UnimplementedError();
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
  Future<Result<Habit>> updateHabit(Habit habit) async {
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
  Future<Result<Goal>> updateGoal(Goal goal) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteGoal(String id) async {
    throw UnimplementedError();
  }
}

void main() {
  late CreateGoalUseCase useCase;
  late MockBehavioralRepository mockRepository;

  setUp(() {
    mockRepository = MockBehavioralRepository();
    useCase = CreateGoalUseCase(mockRepository);
  });

  group('CreateGoalUseCase', () {
    test('should create goal successfully when valid', () async {
      // Arrange
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        type: GoalType.behavior,
        description: 'Exercise 3 times per week',
        targetValue: 3.0,
        currentValue: 0.0,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (goal) {
          expect(goal.description, 'Exercise 3 times per week');
          expect(goal.type, GoalType.behavior);
          expect(goal.targetValue, 3.0);
          expect(goal.currentValue, 0.0);
          expect(goal.status, GoalStatus.inProgress);
          expect(goal.id, isNotEmpty);
        },
      );
      expect(mockRepository.savedGoal, isNotNull);
    });

    test('should generate ID when not provided', () async {
      // Arrange
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        type: GoalType.identity,
        description: 'Goal',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (goal) => expect(goal.id, isNotEmpty),
      );
    });

    test('should use default current value of 0.0 when not provided', () async {
      // Arrange
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        type: GoalType.outcome,
        description: 'Goal',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (goal) => expect(goal.currentValue, 0.0),
      );
    });

    test('should return ValidationFailure when description is empty', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        type: GoalType.behavior,
        description: '   ',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('description cannot be empty'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when description exceeds 500 characters', () async {
      // Arrange
      final longDescription = 'a' * 501;

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        type: GoalType.behavior,
        description: longDescription,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('cannot exceed 500 characters'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when target value is negative', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        type: GoalType.behavior,
        description: 'Goal',
        targetValue: -10.0,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Target value cannot be negative'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when current value is negative', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        type: GoalType.behavior,
        description: 'Goal',
        currentValue: -5.0,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Current value cannot be negative'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when deadline is in past', () async {
      // Arrange
      final pastDate = DateTime.now().subtract(Duration(days: 1));

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        type: GoalType.behavior,
        description: 'Goal',
        deadline: pastDate,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('cannot be in the past'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should accept goal with all optional fields', () async {
      // Arrange
      mockRepository.failureToReturn = null;
      final futureDate = DateTime.now().add(Duration(days: 30));

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        type: GoalType.outcome,
        description: 'Lose 10 pounds',
        target: '10 pounds',
        targetValue: 10.0,
        currentValue: 2.0,
        deadline: futureDate,
        linkedMetric: 'weight',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (goal) {
          expect(goal.target, '10 pounds');
          expect(goal.targetValue, 10.0);
          expect(goal.currentValue, 2.0);
          expect(goal.deadline, futureDate);
          expect(goal.linkedMetric, 'weight');
        },
      );
    });

    test('should accept goal without target value', () async {
      // Arrange
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        type: GoalType.identity,
        description: 'Become a healthy person',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (goal) {
          expect(goal.targetValue, isNull);
          expect(goal.status, GoalStatus.inProgress);
        },
      );
    });

    test('should propagate DatabaseFailure from repository', () async {
      // Arrange
      mockRepository.failureToReturn = DatabaseFailure('Database error');

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        type: GoalType.behavior,
        description: 'Goal',
      );

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
  });
}

