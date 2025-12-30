import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal_status.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal_type.dart';
import 'package:health_app/features/behavioral_support/domain/repositories/behavioral_repository.dart';

/// Use case for creating a goal
/// 
/// Validates goal data and creates a Goal entity.
/// Validates description, target values, and date ranges.
class CreateGoalUseCase {
  /// Behavioral repository
  final BehavioralRepository repository;

  /// Creates a CreateGoalUseCase
  CreateGoalUseCase(this.repository);

  /// Execute the use case
  /// 
  /// Validates the goal data and creates a Goal entity. Generates an ID if not provided.
  /// 
  /// Returns [ValidationFailure] if validation fails.
  /// Returns [DatabaseFailure] if save operation fails.
  Future<Result<Goal>> call({
    required String userId,
    required GoalType type,
    required String description,
    String? target,
    double? targetValue,
    double? currentValue,
    DateTime? deadline,
    String? linkedMetric,
    String? id,
  }) async {
    // Generate ID if not provided
    final goalId = id ?? _generateId();
    final initialCurrentValue = currentValue ?? 0.0;

    // Validate the goal
    final validationResult = _validateGoal(
      description: description,
      targetValue: targetValue,
      currentValue: initialCurrentValue,
      deadline: deadline,
    );
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Create goal entity
    final goal = Goal(
      id: goalId,
      userId: userId,
      type: type,
      description: description,
      target: target,
      targetValue: targetValue,
      currentValue: initialCurrentValue,
      deadline: deadline,
      linkedMetric: linkedMetric,
      status: GoalStatus.inProgress,
      completedAt: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save to repository
    return await repository.saveGoal(goal);
  }

  /// Validate goal data
  ValidationFailure? _validateGoal({
    required String description,
    double? targetValue,
    required double currentValue,
    DateTime? deadline,
  }) {
    // Validate description
    if (description.trim().isEmpty) {
      return ValidationFailure('Goal description cannot be empty');
    }

    if (description.length > 500) {
      return ValidationFailure('Goal description cannot exceed 500 characters');
    }

    // Validate target value if provided
    if (targetValue != null && targetValue < 0) {
      return ValidationFailure('Target value cannot be negative');
    }

    // Validate current value
    if (currentValue < 0) {
      return ValidationFailure('Current value cannot be negative');
    }

    // Validate deadline is not in the past if provided
    if (deadline != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final deadlineOnly = DateTime(deadline.year, deadline.month, deadline.day);
      
      if (deadlineOnly.isBefore(today)) {
        return ValidationFailure('Goal deadline cannot be in the past');
      }
    }

    return null;
  }

  /// Generate a unique ID for the goal
  String _generateId() {
    final now = DateTime.now();
    return 'goal-${now.millisecondsSinceEpoch}-${now.microsecondsSinceEpoch}';
  }
}

