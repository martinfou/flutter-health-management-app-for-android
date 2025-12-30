import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/exercise_management/domain/entities/workout_plan.dart';
import 'package:health_app/features/exercise_management/domain/usecases/create_workout_plan.dart';

void main() {
  late CreateWorkoutPlanUseCase useCase;

  setUp(() {
    useCase = CreateWorkoutPlanUseCase();
  });

  group('CreateWorkoutPlanUseCase', () {
    test('should create workout plan successfully when valid', () {
      // Arrange
      final days = [
        WorkoutDay(
          dayName: 'Monday',
          exerciseIds: ['exercise-1', 'exercise-2'],
          focus: 'Push',
          estimatedDuration: 60,
        ),
        WorkoutDay(
          dayName: 'Wednesday',
          exerciseIds: ['exercise-3'],
          focus: 'Pull',
          estimatedDuration: 45,
        ),
      ];

      // Act
      final result = useCase.call(
        userId: 'user-id',
        name: 'Push/Pull Split',
        description: 'Weekly push/pull workout',
        days: days,
        durationWeeks: 4,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (plan) {
          expect(plan.name, 'Push/Pull Split');
          expect(plan.description, 'Weekly push/pull workout');
          expect(plan.days.length, 2);
          expect(plan.durationWeeks, 4);
          expect(plan.isActive, true);
          expect(plan.id, isNotEmpty);
          expect(plan.userId, 'user-id');
        },
      );
    });

    test('should generate ID when not provided', () {
      // Arrange
      final days = [
        WorkoutDay(dayName: 'Monday', exerciseIds: []),
      ];

      // Act
      final result = useCase.call(
        userId: 'user-id',
        name: 'Plan',
        days: days,
        durationWeeks: 1,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (plan) => expect(plan.id, isNotEmpty),
      );
    });

    test('should use provided start date or default to now', () {
      // Arrange
      final customDate = DateTime(2024, 1, 15);
      final days = [
        WorkoutDay(dayName: 'Monday', exerciseIds: []),
      ];

      // Act
      final result = useCase.call(
        userId: 'user-id',
        name: 'Plan',
        days: days,
        durationWeeks: 1,
        startDate: customDate,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (plan) {
          final planDate = DateTime(
            plan.startDate.year,
            plan.startDate.month,
            plan.startDate.day,
          );
          final expectedDate = DateTime(
            customDate.year,
            customDate.month,
            customDate.day,
          );
          expect(planDate, expectedDate);
        },
      );
    });

    test('should return ValidationFailure when name is empty', () {
      // Arrange
      final days = [
        WorkoutDay(dayName: 'Monday', exerciseIds: []),
      ];

      // Act
      final result = useCase.call(
        userId: 'user-id',
        name: '   ', // Empty after trim
        days: days,
        durationWeeks: 1,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('name cannot be empty'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when days list is empty', () {
      // Act
      final result = useCase.call(
        userId: 'user-id',
        name: 'Plan',
        days: [],
        durationWeeks: 1,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('must have at least one day'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when duplicate day names', () {
      // Arrange
      final days = [
        WorkoutDay(dayName: 'Monday', exerciseIds: []),
        WorkoutDay(dayName: 'Monday', exerciseIds: []), // Duplicate
      ];

      // Act
      final result = useCase.call(
        userId: 'user-id',
        name: 'Plan',
        days: days,
        durationWeeks: 1,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('duplicate day names'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when duration is less than 1 week', () {
      // Arrange
      final days = [
        WorkoutDay(dayName: 'Monday', exerciseIds: []),
      ];

      // Act
      final result = useCase.call(
        userId: 'user-id',
        name: 'Plan',
        days: days,
        durationWeeks: 0,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('must be at least 1 week'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when duration exceeds 52 weeks', () {
      // Arrange
      final days = [
        WorkoutDay(dayName: 'Monday', exerciseIds: []),
      ];

      // Act
      final result = useCase.call(
        userId: 'user-id',
        name: 'Plan',
        days: days,
        durationWeeks: 53,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('cannot exceed 52 weeks'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when day name is empty', () {
      // Arrange
      final days = [
        WorkoutDay(dayName: '   ', exerciseIds: []), // Empty after trim
      ];

      // Act
      final result = useCase.call(
        userId: 'user-id',
        name: 'Plan',
        days: days,
        durationWeeks: 1,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Day name cannot be empty'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when duplicate exercise IDs in same day', () {
      // Arrange
      final days = [
        WorkoutDay(
          dayName: 'Monday',
          exerciseIds: ['exercise-1', 'exercise-1'], // Duplicate
        ),
      ];

      // Act
      final result = useCase.call(
        userId: 'user-id',
        name: 'Plan',
        days: days,
        durationWeeks: 1,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('duplicate exercise IDs'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when estimated duration is negative', () {
      // Arrange
      final days = [
        WorkoutDay(
          dayName: 'Monday',
          exerciseIds: [],
          estimatedDuration: -10,
        ),
      ];

      // Act
      final result = useCase.call(
        userId: 'user-id',
        name: 'Plan',
        days: days,
        durationWeeks: 1,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('cannot be negative'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should allow rest days (empty exercise list)', () {
      // Arrange
      final days = [
        WorkoutDay(dayName: 'Monday', exerciseIds: []), // Rest day
        WorkoutDay(dayName: 'Tuesday', exerciseIds: ['exercise-1']),
      ];

      // Act
      final result = useCase.call(
        userId: 'user-id',
        name: 'Plan',
        days: days,
        durationWeeks: 1,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (plan) {
          expect(plan.days.length, 2);
          expect(plan.days[0].exerciseIds.isEmpty, true);
        },
      );
    });

    test('should calculate end date correctly', () {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final days = [
        WorkoutDay(dayName: 'Monday', exerciseIds: []),
      ];

      // Act
      final result = useCase.call(
        userId: 'user-id',
        name: 'Plan',
        days: days,
        durationWeeks: 4,
        startDate: startDate,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (plan) {
          final expectedEndDate = startDate.add(Duration(days: 28)); // 4 weeks
          expect(plan.endDate, expectedEndDate);
        },
      );
    });
  });
}

