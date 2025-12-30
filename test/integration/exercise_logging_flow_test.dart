import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:health_app/core/providers/database_initializer.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise.dart';
import 'package:health_app/features/exercise_management/domain/entities/exercise_type.dart';
import 'package:health_app/features/exercise_management/domain/repositories/exercise_repository.dart';
import 'package:health_app/features/exercise_management/data/repositories/exercise_repository_impl.dart';
import 'package:health_app/features/exercise_management/data/datasources/local/exercise_local_datasource.dart';
import 'package:health_app/features/exercise_management/domain/usecases/log_workout.dart';
import 'package:health_app/features/exercise_management/domain/usecases/get_workout_history.dart';

/// Integration test for exercise logging flow
/// 
/// Tests the complete workflow:
/// 1. Log a workout
/// 2. View workout history
void main() {
  group('Exercise Logging Flow Integration Test', () {
    late ExerciseRepository repository;

    setUpAll(() async {
      // Initialize Hive for testing
      try {
        await DatabaseInitializer.initialize();
      } catch (e) {
        // If initialization fails, skip database-dependent tests
      }
    });

    setUp(() {
      final dataSource = ExerciseLocalDataSource();
      repository = ExerciseRepositoryImpl(dataSource);
    });

    test('should log workout and retrieve it', () async {
      // Arrange
      const userId = 'test-user-id';
      final testDate = DateTime.now();
      const exerciseName = 'Running';
      const duration = 30.0; // minutes
      const distance = 5.0; // km

      final exercise = Exercise(
        id: 'test-exercise-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        date: testDate,
        type: ExerciseType.cardio,
        name: exerciseName,
        muscleGroups: [],
        equipment: [],
        duration: duration.toInt(),
        distance: distance,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act - Save the exercise
      final saveResult = await repository.saveExercise(exercise);

      // Assert - Verify save was successful
      expect(saveResult.isRight(), true);
      saveResult.fold(
        (failure) => fail('Save should succeed, but got: ${failure.message}'),
        (savedExercise) {
          expect(savedExercise.id, exercise.id);
          expect(savedExercise.name, exerciseName);
          expect(savedExercise.duration, duration);
          expect(savedExercise.distance, distance);
          expect(savedExercise.userId, userId);
        },
      );

      // Act - Retrieve the exercise
      final getResult = await repository.getExercise(exercise.id);

      // Assert - Verify retrieval was successful
      expect(getResult.isRight(), true);
      getResult.fold(
        (failure) => fail('Get should succeed, but got: ${failure.message}'),
        (retrievedExercise) {
          expect(retrievedExercise.id, exercise.id);
          expect(retrievedExercise.name, exerciseName);
        },
      );
    });

    test('should use LogWorkoutUseCase to log workout', () async {
      // Arrange
      const userId = 'test-user-id';
      const exerciseName = 'Weight Training';
      const duration = 45.0;
      const sets = 3;
      const reps = 10;
      const weight = 50.0; // kg

      final useCase = LogWorkoutUseCase(repository);

      // Act - Log workout using use case
      final result = await useCase.call(
        userId: userId,
        type: ExerciseType.strength,
        name: exerciseName,
        date: DateTime.now(),
        duration: duration,
        sets: sets,
        reps: reps,
        weight: weight,
      );

      // Assert - Verify save was successful
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Use case should succeed: ${failure.message}'),
        (savedExercise) {
          expect(savedExercise.name, exerciseName);
          expect(savedExercise.duration, duration);
          expect(savedExercise.sets, sets);
          expect(savedExercise.reps, reps);
          expect(savedExercise.weight, weight);
          expect(savedExercise.userId, userId);
          expect(savedExercise.id.isNotEmpty, true); // ID should be generated
        },
      );
    });

    test('should retrieve workout history by date range', () async {
      // Arrange
      const userId = 'test-user-id';
      final now = DateTime.now();
      final dates = [
        now.subtract(Duration(days: 2)),
        now.subtract(Duration(days: 1)),
        now,
      ];

      // Save multiple exercises
      for (int i = 0; i < dates.length; i++) {
        final exercise = Exercise(
          id: 'test-exercise-$i-${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          date: dates[i],
          type: ExerciseType.cardio,
          name: 'Exercise $i',
          muscleGroups: [],
          equipment: [],
          duration: (30 + (i * 5)).toInt(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final result = await repository.saveExercise(exercise);
        expect(result.isRight(), true, reason: 'Exercise should be saved');
      }

      // Act - Retrieve exercises by date range
      final startDate = dates.first.subtract(Duration(days: 1));
      final endDate = dates.last.add(Duration(days: 1));
      final rangeResult = await repository.getExercisesByDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      // Assert - Verify exercises are retrieved
      expect(rangeResult.isRight(), true);
      rangeResult.fold(
        (failure) => fail('Get range should succeed: ${failure.message}'),
        (retrievedExercises) {
          expect(retrievedExercises.length, greaterThanOrEqualTo(3));
          // Verify all exercises belong to the user
          for (final exercise in retrievedExercises) {
            expect(exercise.userId, userId);
          }
        },
      );
    });

    test('should use GetWorkoutHistoryUseCase to get history', () async {
      // Arrange
      const userId = 'test-user-id';
      final useCase = GetWorkoutHistoryUseCase(repository);
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: 7));

      // Act - Get workout history
      final result = await useCase.call(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      // Assert - Verify history retrieval works
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Get history should succeed: ${failure.message}'),
        (exercises) {
          expect(exercises, isA<List<Exercise>>());
          // All exercises should be within date range
          for (final exercise in exercises) {
            expect(exercise.date.isAfter(startDate.subtract(Duration(days: 1))), true);
            expect(exercise.date.isBefore(endDate.add(Duration(days: 1))), true);
          }
        },
      );
    });

    test('should validate exercise data when logging', () async {
      // Arrange
      const userId = 'test-user-id';
      final useCase = LogWorkoutUseCase(repository);

      // Act - Try to log exercise with invalid data (empty name)
      final result = await useCase.call(
        userId: userId,
        type: ExerciseType.cardio,
        name: '', // Invalid: empty name
        date: DateTime.now(),
        duration: 30,
      );

      // Assert - Verify validation failure
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, anyOf(contains('name'), contains('Name')));
        },
        (_) => fail('Should fail validation for empty name'),
      );
    });
  });
}

