import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/exercise_management/domain/entities/workout_plan.dart';

/// Use case for creating a workout plan
/// 
/// Validates workout plan data and creates a WorkoutPlan entity.
/// Note: Repository support for saving workout plans is not yet implemented
/// in the MVP. This use case validates and creates the plan structure.
class CreateWorkoutPlanUseCase {
  /// Creates a CreateWorkoutPlanUseCase
  CreateWorkoutPlanUseCase();

  /// Execute the use case
  /// 
  /// Validates the workout plan data and creates a WorkoutPlan entity.
  /// Generates an ID if not provided.
  /// 
  /// Returns [ValidationFailure] if validation fails.
  /// Returns [Right] with WorkoutPlan.
  Result<WorkoutPlan> call({
    required String userId,
    required String name,
    String? description,
    required List<WorkoutDay> days,
    required int durationWeeks,
    DateTime? startDate,
    String? id,
  }) {
    // Generate ID if not provided
    final planId = id ?? _generateId();
    final planStartDate = startDate ?? DateTime.now();

    // Validate the workout plan
    final validationResult = _validateWorkoutPlan(
      name: name,
      days: days,
      durationWeeks: durationWeeks,
    );
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Create workout plan entity
    final plan = WorkoutPlan(
      id: planId,
      userId: userId,
      name: name,
      description: description,
      days: days,
      startDate: planStartDate,
      durationWeeks: durationWeeks,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return Right(plan);
  }

  /// Validate workout plan data
  ValidationFailure? _validateWorkoutPlan({
    required String name,
    required List<WorkoutDay> days,
    required int durationWeeks,
  }) {
    // Validate name
    if (name.trim().isEmpty) {
      return ValidationFailure('Workout plan name cannot be empty');
    }

    // Validate days list
    if (days.isEmpty) {
      return ValidationFailure('Workout plan must have at least one day');
    }

    // Validate day names are unique
    final dayNames = days.map((day) => day.dayName.toLowerCase()).toList();
    final uniqueDayNames = dayNames.toSet();
    if (dayNames.length != uniqueDayNames.length) {
      return ValidationFailure('Workout plan cannot have duplicate day names');
    }

    // Validate duration
    if (durationWeeks < 1) {
      return ValidationFailure('Workout plan duration must be at least 1 week');
    }

    if (durationWeeks > 52) {
      return ValidationFailure('Workout plan duration cannot exceed 52 weeks');
    }

    // Validate each day
    for (final day in days) {
      if (day.dayName.trim().isEmpty) {
        return ValidationFailure('Day name cannot be empty');
      }

      // Day can have empty exercise list (rest day)
      // But if it has exercises, validate them
      if (day.exerciseIds.isNotEmpty) {
        // Check for duplicate exercise IDs in the same day
        final uniqueExerciseIds = day.exerciseIds.toSet();
        if (day.exerciseIds.length != uniqueExerciseIds.length) {
          return ValidationFailure(
            'Day ${day.dayName} cannot have duplicate exercise IDs',
          );
        }
      }

      // Validate estimated duration if provided
      if (day.estimatedDuration != null && day.estimatedDuration! < 0) {
        return ValidationFailure(
          'Estimated duration for ${day.dayName} cannot be negative',
        );
      }
    }

    return null;
  }

  /// Generate a unique ID for the workout plan
  String _generateId() {
    final now = DateTime.now();
    return 'workout-plan-${now.millisecondsSinceEpoch}-${now.microsecondsSinceEpoch}';
  }
}

