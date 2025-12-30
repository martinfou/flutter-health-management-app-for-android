import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/exercise_management/data/repositories/exercise_repository_impl.dart';
import 'package:health_app/features/exercise_management/data/datasources/local/exercise_local_datasource.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise_type.dart';

// Mock data source
class MockExerciseLocalDataSource implements ExerciseLocalDataSource {
  Exercise? exerciseToReturn;
  List<Exercise>? exercisesToReturn;
  Failure? failureToReturn;
  Exercise? savedExercise;
  String? deletedId;

  @override
  Future<Either<Failure, Exercise>> getExercise(String id) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    if (exerciseToReturn == null) {
      return Left(NotFoundFailure('Exercise'));
    }
    return Right(exerciseToReturn!);
  }

  @override
  Future<Either<Failure, List<Exercise>>> getExercisesByUserId(
    String userId,
  ) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(exercisesToReturn ?? []);
  }

  @override
  Future<Either<Failure, List<Exercise>>> getExercisesByDateRange(
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
  Future<Either<Failure, List<Exercise>>> getExercisesByDate(
    String userId,
    DateTime date,
  ) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(exercisesToReturn ?? []);
  }

  @override
  Future<Either<Failure, List<Exercise>>> getExercisesByType(
    String userId,
    String exerciseType,
  ) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(exercisesToReturn ?? []);
  }

  @override
  Future<Either<Failure, Exercise>> saveExercise(Exercise exercise) async {
    savedExercise = exercise;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(exercise);
  }

  @override
  Future<Either<Failure, Exercise>> updateExercise(
    Exercise exercise,
  ) async {
    savedExercise = exercise;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(exercise);
  }

  @override
  Future<Either<Failure, void>> deleteExercise(String id) async {
    deletedId = id;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return const Right(null);
  }
}

void main() {
  late ExerciseRepositoryImpl repository;
  late MockExerciseLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockExerciseLocalDataSource();
    repository = ExerciseRepositoryImpl(mockDataSource);
  });

  group('getExercisesByDateRange', () {
    test('should return validation failure when start date is after end date',
        () async {
      // Arrange
      final startDate = DateTime(2024, 1, 15);
      final endDate = DateTime(2024, 1, 10);

      // Act
      final result = await repository.getExercisesByDateRange(
        'user-1',
        startDate,
        endDate,
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            contains('Start date must be before or equal to end date'),
          );
        },
        (_) => fail('Should fail'),
      );
    });
  });

  group('saveExercise', () {
    test('should return validation failure when exercise name is empty',
        () async {
      // Arrange
      final exercise = Exercise(
        id: 'test-id',
        userId: 'user-1',
        name: '', // Empty name
        type: ExerciseType.strength,
        muscleGroups: [],
        equipment: [],
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveExercise(exercise);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Exercise name cannot be empty'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return validation failure when duration <= 0', () async {
      // Arrange
      final exercise = Exercise(
        id: 'test-id',
        userId: 'user-1',
        name: 'Test Exercise',
        type: ExerciseType.strength,
        muscleGroups: [],
        equipment: [],
        duration: 0, // <= 0
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveExercise(exercise);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            contains('Duration must be greater than 0 if provided'),
          );
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return validation failure when sets <= 0', () async {
      // Arrange
      final exercise = Exercise(
        id: 'test-id',
        userId: 'user-1',
        name: 'Test Exercise',
        type: ExerciseType.strength,
        muscleGroups: [],
        equipment: [],
        sets: 0, // <= 0
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveExercise(exercise);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            contains('Sets must be greater than 0 if provided'),
          );
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return validation failure when date is in future', () async {
      // Arrange
      final exercise = Exercise(
        id: 'test-id',
        userId: 'user-1',
        name: 'Test Exercise',
        type: ExerciseType.strength,
        muscleGroups: [],
        equipment: [],
        date: DateTime.now().add(Duration(days: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveExercise(exercise);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Date cannot be in the future'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should save valid exercise', () async {
      // Arrange
      final exercise = Exercise(
        id: 'test-id',
        userId: 'user-1',
        name: 'Test Exercise',
        type: ExerciseType.strength,
        muscleGroups: ['chest'],
        equipment: ['dumbbells'],
        sets: 3,
        reps: 10,
        weight: 80.0,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveExercise(exercise);

      // Assert
      expect(result.isRight(), isTrue);
      expect(mockDataSource.savedExercise, isNotNull);
      expect(mockDataSource.savedExercise!.id, 'test-id');
    });
  });
}

