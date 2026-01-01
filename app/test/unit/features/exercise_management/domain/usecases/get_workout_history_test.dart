import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise_type.dart';
import 'package:health_app/features/exercise_management/domain/repositories/exercise_repository.dart';
import 'package:health_app/features/exercise_management/domain/usecases/get_workout_history.dart';

// Manual mock for ExerciseRepository
class MockExerciseRepository implements ExerciseRepository {
  String? lastUserId;
  DateTime? lastStartDate;
  DateTime? lastEndDate;
  List<Exercise>? exercisesToReturn;
  Failure? failureToReturn;

  @override
  Future<Result<List<Exercise>>> getExercisesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    lastUserId = userId;
    lastStartDate = startDate;
    lastEndDate = endDate;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(exercisesToReturn ?? []);
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
  Future<Result<Exercise>> saveExercise(Exercise exercise) async {
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
  late GetWorkoutHistoryUseCase useCase;
  late MockExerciseRepository mockRepository;

  setUp(() {
    mockRepository = MockExerciseRepository();
    useCase = GetWorkoutHistoryUseCase(mockRepository);
  });

  group('GetWorkoutHistoryUseCase', () {
    test('should get workout history successfully', () async {
      // Arrange
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: 7));
      final endDate = now;
      final exercises = [
        Exercise(
          id: 'exercise-1',
          userId: 'user-id',
          name: 'Bench Press',
          type: ExerciseType.strength,
          muscleGroups: [],
          equipment: [],
          date: now.subtract(Duration(days: 2)),
          createdAt: now,
          updatedAt: now,
        ),
        Exercise(
          id: 'exercise-2',
          userId: 'user-id',
          name: 'Running',
          type: ExerciseType.cardio,
          muscleGroups: [],
          equipment: [],
          date: now.subtract(Duration(days: 1)),
          createdAt: now,
          updatedAt: now,
        ),
      ];
      mockRepository.exercisesToReturn = exercises;
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        startDate: startDate,
        endDate: endDate,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (history) {
          expect(history.length, 2);
          // Should be sorted by date (newest first)
          // Workout history only includes exercises with dates (templates filtered out)
          expect(history[0].date!.isAfter(history[1].date!), true);
        },
      );
      expect(mockRepository.lastUserId, 'user-id');
      expect(mockRepository.lastStartDate, startDate);
      expect(mockRepository.lastEndDate, endDate);
    });

    test('should filter by exercise type when provided', () async {
      // Arrange
      final now = DateTime.now();
      final exercises = [
        Exercise(
          id: 'exercise-1',
          userId: 'user-id',
          name: 'Bench Press',
          type: ExerciseType.strength,
          muscleGroups: [],
          equipment: [],
          date: now,
          createdAt: now,
          updatedAt: now,
        ),
        Exercise(
          id: 'exercise-2',
          userId: 'user-id',
          name: 'Running',
          type: ExerciseType.cardio,
          muscleGroups: [],
          equipment: [],
          date: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      mockRepository.exercisesToReturn = exercises;
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        startDate: now.subtract(Duration(days: 1)),
        endDate: now,
        exerciseType: 'strength',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (history) {
          expect(history.length, 1);
          expect(history[0].type, ExerciseType.strength);
        },
      );
    });

    test('should return ValidationFailure when start date is after end date', () async {
      // Act
      final now = DateTime.now();
      final result = await useCase.call(
        userId: 'user-id',
        startDate: now,
        endDate: now.subtract(Duration(days: 1)), // End before start
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Start date must be before'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should sort exercises by date newest first', () async {
      // Arrange
      final now = DateTime.now();
      final exercises = [
        Exercise(
          id: 'exercise-1',
          userId: 'user-id',
          name: 'Old Exercise',
          type: ExerciseType.strength,
          muscleGroups: [],
          equipment: [],
          date: now.subtract(Duration(days: 5)),
          createdAt: now,
          updatedAt: now,
        ),
        Exercise(
          id: 'exercise-2',
          userId: 'user-id',
          name: 'New Exercise',
          type: ExerciseType.strength,
          muscleGroups: [],
          equipment: [],
          date: now,
          createdAt: now,
          updatedAt: now,
        ),
        Exercise(
          id: 'exercise-3',
          userId: 'user-id',
          name: 'Middle Exercise',
          type: ExerciseType.strength,
          muscleGroups: [],
          equipment: [],
          date: now.subtract(Duration(days: 2)),
          createdAt: now,
          updatedAt: now,
        ),
      ];
      mockRepository.exercisesToReturn = exercises;
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        startDate: now.subtract(Duration(days: 7)),
        endDate: now,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (history) {
          expect(history.length, 3);
          // Should be sorted newest first
          expect(history[0].name, 'New Exercise');
          expect(history[1].name, 'Middle Exercise');
          expect(history[2].name, 'Old Exercise');
        },
      );
    });

    test('should return empty list when no exercises found', () async {
      // Arrange
      mockRepository.exercisesToReturn = [];
      mockRepository.failureToReturn = null;

      // Act
      final now = DateTime.now();
      final result = await useCase.call(
        userId: 'user-id',
        startDate: now.subtract(Duration(days: 7)),
        endDate: now,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (history) {
          expect(history.isEmpty, true);
        },
      );
    });

    test('should propagate DatabaseFailure from repository', () async {
      // Arrange
      mockRepository.failureToReturn = DatabaseFailure('Database error');

      // Act
      final now = DateTime.now();
      final result = await useCase.call(
        userId: 'user-id',
        startDate: now.subtract(Duration(days: 7)),
        endDate: now,
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

    group('getByDate', () {
      test('should get exercises for a specific date', () async {
        // Arrange
        final targetDate = DateTime(2024, 1, 15);
        final exercises = [
          Exercise(
            id: 'exercise-1',
            userId: 'user-id',
            name: 'Exercise',
            type: ExerciseType.strength,
            muscleGroups: [],
            equipment: [],
            date: targetDate,
            createdAt: targetDate,
            updatedAt: targetDate,
          ),
        ];
        mockRepository.exercisesToReturn = exercises;
        mockRepository.failureToReturn = null;

        // Act
        final result = await useCase.getByDate(
          userId: 'user-id',
          date: targetDate,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (history) {
            expect(history.length, 1);
            // Workout history only includes exercises with dates (templates filtered out)
            final exerciseDate = DateTime(
              history[0].date!.year,
              history[0].date!.month,
              history[0].date!.day,
            );
            final expectedDate = DateTime(
              targetDate.year,
              targetDate.month,
              targetDate.day,
            );
            expect(exerciseDate, expectedDate);
          },
        );
      });

      test('should filter by type when using getByDate', () async {
        // Arrange
        final targetDate = DateTime(2024, 1, 15);
        final exercises = [
          Exercise(
            id: 'exercise-1',
            userId: 'user-id',
            name: 'Strength',
            type: ExerciseType.strength,
            muscleGroups: [],
            equipment: [],
            date: targetDate,
            createdAt: targetDate,
            updatedAt: targetDate,
          ),
          Exercise(
            id: 'exercise-2',
            userId: 'user-id',
            name: 'Cardio',
            type: ExerciseType.cardio,
            muscleGroups: [],
            equipment: [],
            date: targetDate,
            createdAt: targetDate,
            updatedAt: targetDate,
          ),
        ];
        mockRepository.exercisesToReturn = exercises;
        mockRepository.failureToReturn = null;

        // Act
        final result = await useCase.getByDate(
          userId: 'user-id',
          date: targetDate,
          exerciseType: 'cardio',
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (history) {
            expect(history.length, 1);
            expect(history[0].type, ExerciseType.cardio);
          },
        );
      });
    });
  });
}

