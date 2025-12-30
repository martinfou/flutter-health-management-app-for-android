import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise_type.dart';
import 'package:health_app/features/exercise_management/domain/repositories/exercise_repository.dart';
import 'package:health_app/features/exercise_management/domain/usecases/log_workout.dart';

// Manual mock for ExerciseRepository
class MockExerciseRepository implements ExerciseRepository {
  Exercise? savedExercise;
  Failure? failureToReturn;

  @override
  Future<Result<Exercise>> saveExercise(Exercise exercise) async {
    savedExercise = exercise;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(exercise);
  }

  @override
  Future<Result<Exercise>> getExercise(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Exercise>>> getExercisesByUserId(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Exercise>>> getExercisesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Exercise>>> getExercisesByDate(String userId, DateTime date) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Exercise>>> getExercisesByType(
    String userId,
    String exerciseType,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<Exercise>> updateExercise(Exercise exercise) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteExercise(String id) async {
    throw UnimplementedError();
  }
}

void main() {
  late LogWorkoutUseCase useCase;
  late MockExerciseRepository mockRepository;

  setUp(() {
    mockRepository = MockExerciseRepository();
    useCase = LogWorkoutUseCase(mockRepository);
  });

  group('LogWorkoutUseCase', () {
    test('should save strength exercise successfully when valid', () async {
      // Arrange
      mockRepository.failureToReturn = null;
      final now = DateTime.now();

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Bench Press',
        type: ExerciseType.strength,
        date: now,
        sets: 3,
        reps: 10,
        weight: 80.0,
        muscleGroups: ['chest', 'triceps'],
        equipment: ['barbell', 'bench'],
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (exercise) {
          expect(exercise.name, 'Bench Press');
          expect(exercise.type, ExerciseType.strength);
          expect(exercise.sets, 3);
          expect(exercise.reps, 10);
          expect(exercise.weight, 80.0);
          expect(exercise.muscleGroups, ['chest', 'triceps']);
          expect(exercise.id, isNotEmpty);
        },
      );
      expect(mockRepository.savedExercise, isNotNull);
    });

    test('should save cardio exercise successfully when valid', () async {
      // Arrange
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Running',
        type: ExerciseType.cardio,
        date: DateTime.now(),
        duration: 30,
        distance: 5.0,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (exercise) {
          expect(exercise.type, ExerciseType.cardio);
          expect(exercise.duration, 30);
          expect(exercise.distance, 5.0);
        },
      );
    });

    test('should save flexibility exercise successfully when valid', () async {
      // Arrange
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Yoga',
        type: ExerciseType.flexibility,
        date: DateTime.now(),
        duration: 45,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (exercise) {
          expect(exercise.type, ExerciseType.flexibility);
          expect(exercise.duration, 45);
        },
      );
    });

    test('should return ValidationFailure when name is empty', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: '   ',
        type: ExerciseType.strength,
        date: DateTime.now(),
        sets: 3,
        reps: 10,
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

    test('should return ValidationFailure when strength exercise has no sets', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Bench Press',
        type: ExerciseType.strength,
        date: DateTime.now(),
        sets: null, // Missing sets
        reps: 10,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('must have at least 1 set'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when strength exercise has no reps', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Bench Press',
        type: ExerciseType.strength,
        date: DateTime.now(),
        sets: 3,
        reps: null, // Missing reps
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('must have at least 1 rep'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when strength exercise has negative weight', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Bench Press',
        type: ExerciseType.strength,
        date: DateTime.now(),
        sets: 3,
        reps: 10,
        weight: -10.0, // Negative weight
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Weight cannot be negative'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when cardio has neither duration nor distance', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Running',
        type: ExerciseType.cardio,
        date: DateTime.now(),
        // Missing both duration and distance
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('must have either duration or distance'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when cardio duration is less than 1', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Running',
        type: ExerciseType.cardio,
        date: DateTime.now(),
        duration: 0, // Invalid duration
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Duration must be at least 1 minute'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when cardio distance is negative', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Running',
        type: ExerciseType.cardio,
        date: DateTime.now(),
        distance: -5.0, // Negative distance
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Distance cannot be negative'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when flexibility has no duration', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Yoga',
        type: ExerciseType.flexibility,
        date: DateTime.now(),
        duration: null, // Missing duration
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('must have duration'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when flexibility duration is less than 1', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Yoga',
        type: ExerciseType.flexibility,
        date: DateTime.now(),
        duration: 0, // Invalid duration
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('must have duration of at least 1 minute'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when sets is negative', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Exercise',
        type: ExerciseType.other,
        date: DateTime.now(),
        sets: -1, // Negative sets
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Sets cannot be negative'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when reps is negative', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Exercise',
        type: ExerciseType.other,
        date: DateTime.now(),
        reps: -1, // Negative reps
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Reps cannot be negative'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should generate ID when not provided', () async {
      // Arrange
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Exercise',
        type: ExerciseType.strength,
        date: DateTime.now(),
        sets: 3,
        reps: 10,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (exercise) => expect(exercise.id, isNotEmpty),
      );
    });

    test('should propagate DatabaseFailure from repository', () async {
      // Arrange
      mockRepository.failureToReturn = DatabaseFailure('Database error');

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        name: 'Exercise',
        type: ExerciseType.strength,
        date: DateTime.now(),
        sets: 3,
        reps: 10,
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

