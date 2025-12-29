import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal.dart';
import 'package:health_app/features/behavioral_support/domain/repositories/behavioral_repository.dart';
import 'package:health_app/features/behavioral_support/data/datasources/local/behavioral_local_datasource.dart';

/// Behavioral repository implementation
/// 
/// Implements the BehavioralRepository interface using local data source.
class BehavioralRepositoryImpl implements BehavioralRepository {
  final BehavioralLocalDataSource _localDataSource;

  BehavioralRepositoryImpl(this._localDataSource);

  @override
  Future<HabitResult> getHabit(String id) async {
    return await _localDataSource.getHabit(id);
  }

  @override
  Future<HabitListResult> getHabitsByUserId(String userId) async {
    return await _localDataSource.getHabitsByUserId(userId);
  }

  @override
  Future<HabitListResult> getHabitsByCategory(
    String userId,
    String category,
  ) async {
    return await _localDataSource.getHabitsByCategory(userId, category);
  }

  @override
  Future<HabitResult> saveHabit(Habit habit) async {
    // Validation
    if (habit.name.isEmpty) {
      return Left(ValidationFailure('Habit name cannot be empty'));
    }
    if (habit.name.length > 100) {
      return Left(ValidationFailure('Habit name must be 100 characters or less'));
    }
    if (habit.description != null && habit.description!.length > 500) {
      return Left(ValidationFailure('Description must be 500 characters or less'));
    }
    if (habit.startDate.isAfter(DateTime.now())) {
      return Left(ValidationFailure('Start date cannot be in the future'));
    }

    return await _localDataSource.saveHabit(habit);
  }

  @override
  Future<HabitResult> updateHabit(Habit habit) async {
    // Validation (same as save)
    if (habit.name.isEmpty) {
      return Left(ValidationFailure('Habit name cannot be empty'));
    }

    return await _localDataSource.updateHabit(habit);
  }

  @override
  Future<Result<void>> deleteHabit(String id) async {
    return await _localDataSource.deleteHabit(id);
  }

  @override
  Future<GoalResult> getGoal(String id) async {
    return await _localDataSource.getGoal(id);
  }

  @override
  Future<GoalListResult> getGoalsByUserId(String userId) async {
    return await _localDataSource.getGoalsByUserId(userId);
  }

  @override
  Future<GoalListResult> getGoalsByType(String userId, String goalType) async {
    return await _localDataSource.getGoalsByType(userId, goalType);
  }

  @override
  Future<GoalListResult> getGoalsByStatus(String userId, String status) async {
    return await _localDataSource.getGoalsByStatus(userId, status);
  }

  @override
  Future<GoalResult> saveGoal(Goal goal) async {
    // Validation
    if (goal.description.isEmpty) {
      return Left(ValidationFailure('Goal description cannot be empty'));
    }
    if (goal.description.length > 500) {
      return Left(ValidationFailure('Goal description must be 500 characters or less'));
    }
    if (goal.targetValue != null && goal.targetValue! <= 0) {
      return Left(ValidationFailure('Target value must be greater than 0 if provided'));
    }
    if (goal.currentValue < 0) {
      return Left(ValidationFailure('Current value cannot be negative'));
    }
    if (goal.deadline != null && goal.deadline!.isBefore(DateTime.now())) {
      return Left(ValidationFailure('Deadline must be in the future if provided'));
    }

    return await _localDataSource.saveGoal(goal);
  }

  @override
  Future<GoalResult> updateGoal(Goal goal) async {
    // Validation (same as save)
    if (goal.description.isEmpty) {
      return Left(ValidationFailure('Goal description cannot be empty'));
    }

    return await _localDataSource.updateGoal(goal);
  }

  @override
  Future<Result<void>> deleteGoal(String id) async {
    return await _localDataSource.deleteGoal(id);
  }
}

