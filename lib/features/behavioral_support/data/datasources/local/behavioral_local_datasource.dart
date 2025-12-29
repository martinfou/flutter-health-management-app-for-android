import 'package:hive_flutter/hive_flutter.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/providers/database_provider.dart';
import 'package:health_app/features/behavioral_support/data/models/habit_model.dart';
import 'package:health_app/features/behavioral_support/data/models/goal_model.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal.dart';

/// Local data source for Habit and Goal
/// 
/// Handles direct Hive database operations for habits and goals.
class BehavioralLocalDataSource {
  /// Get Hive box for habits
  Box<HabitModel> get _habitsBox {
    if (!Hive.isBoxOpen(HiveBoxNames.habits)) {
      throw DatabaseFailure('Habits box is not open');
    }
    return Hive.box<HabitModel>(HiveBoxNames.habits);
  }

  /// Get Hive box for goals
  Box<GoalModel> get _goalsBox {
    if (!Hive.isBoxOpen(HiveBoxNames.goals)) {
      throw DatabaseFailure('Goals box is not open');
    }
    return Hive.box<GoalModel>(HiveBoxNames.goals);
  }

  /// Get habit by ID
  Future<Result<Habit>> getHabit(String id) async {
    try {
      final box = _habitsBox;
      final model = box.get(id);
      
      if (model == null) {
        return Left(NotFoundFailure('Habit'));
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get habit: $e'));
    }
  }

  /// Get all habits for a user
  Future<Result<List<Habit>>> getHabitsByUserId(String userId) async {
    try {
      final box = _habitsBox;
      final models = box.values
          .where((model) => model.userId == userId)
          .map((model) => model.toEntity())
          .toList();
      
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get habits: $e'));
    }
  }

  /// Get habits by category
  Future<Result<List<Habit>>> getHabitsByCategory(
    String userId,
    String category,
  ) async {
    try {
      final box = _habitsBox;
      final models = box.values
          .where((model) =>
              model.userId == userId && model.category == category)
          .map((model) => model.toEntity())
          .toList();
      
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get habits by category: $e'));
    }
  }

  /// Save habit
  Future<Result<Habit>> saveHabit(Habit habit) async {
    try {
      final box = _habitsBox;
      final model = HabitModel.fromEntity(habit);
      await box.put(habit.id, model);
      return Right(habit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save habit: $e'));
    }
  }

  /// Update habit
  Future<Result<Habit>> updateHabit(Habit habit) async {
    try {
      final box = _habitsBox;
      final existing = box.get(habit.id);
      
      if (existing == null) {
        return Left(NotFoundFailure('Habit'));
      }

      final model = HabitModel.fromEntity(habit);
      await box.put(habit.id, model);
      return Right(habit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update habit: $e'));
    }
  }

  /// Delete habit
  Future<Result<void>> deleteHabit(String id) async {
    try {
      final box = _habitsBox;
      final model = box.get(id);
      
      if (model == null) {
        return Left(NotFoundFailure('Habit'));
      }

      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete habit: $e'));
    }
  }

  /// Get goal by ID
  Future<Result<Goal>> getGoal(String id) async {
    try {
      final box = _goalsBox;
      final model = box.get(id);
      
      if (model == null) {
        return Left(NotFoundFailure('Goal'));
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get goal: $e'));
    }
  }

  /// Get all goals for a user
  Future<Result<List<Goal>>> getGoalsByUserId(String userId) async {
    try {
      final box = _goalsBox;
      final models = box.values
          .where((model) => model.userId == userId)
          .map((model) => model.toEntity())
          .toList();
      
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get goals: $e'));
    }
  }

  /// Get goals by type
  Future<Result<List<Goal>>> getGoalsByType(
    String userId,
    String goalType,
  ) async {
    try {
      final box = _goalsBox;
      final models = box.values
          .where((model) =>
              model.userId == userId && model.type == goalType)
          .map((model) => model.toEntity())
          .toList();
      
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get goals by type: $e'));
    }
  }

  /// Get goals by status
  Future<Result<List<Goal>>> getGoalsByStatus(
    String userId,
    String status,
  ) async {
    try {
      final box = _goalsBox;
      final models = box.values
          .where((model) =>
              model.userId == userId && model.status == status)
          .map((model) => model.toEntity())
          .toList();
      
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get goals by status: $e'));
    }
  }

  /// Save goal
  Future<Result<Goal>> saveGoal(Goal goal) async {
    try {
      final box = _goalsBox;
      final model = GoalModel.fromEntity(goal);
      await box.put(goal.id, model);
      return Right(goal);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save goal: $e'));
    }
  }

  /// Update goal
  Future<Result<Goal>> updateGoal(Goal goal) async {
    try {
      final box = _goalsBox;
      final existing = box.get(goal.id);
      
      if (existing == null) {
        return Left(NotFoundFailure('Goal'));
      }

      final model = GoalModel.fromEntity(goal);
      await box.put(goal.id, model);
      return Right(goal);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update goal: $e'));
    }
  }

  /// Delete goal
  Future<Result<void>> deleteGoal(String id) async {
    try {
      final box = _goalsBox;
      final model = box.get(id);
      
      if (model == null) {
        return Left(NotFoundFailure('Goal'));
      }

      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete goal: $e'));
    }
  }
}

