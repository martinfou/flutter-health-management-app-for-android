import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal.dart';

/// Type alias for repository result
typedef HabitResult = Result<Habit>;
typedef HabitListResult = Result<List<Habit>>;
typedef GoalResult = Result<Goal>;
typedef GoalListResult = Result<List<Goal>>;

/// Behavioral repository interface
/// 
/// Defines the contract for behavioral support data operations (habits and goals).
/// Implementation is in the data layer.
abstract class BehavioralRepository {
  /// Get habit by ID
  /// 
  /// Returns [NotFoundFailure] if habit doesn't exist.
  Future<HabitResult> getHabit(String id);

  /// Get all habits for a user
  Future<HabitListResult> getHabitsByUserId(String userId);

  /// Get habits by category
  Future<HabitListResult> getHabitsByCategory(String userId, String category);

  /// Save habit
  /// 
  /// Creates new habit or updates existing one.
  /// Returns [ValidationFailure] if habit data is invalid.
  Future<HabitResult> saveHabit(Habit habit);

  /// Update habit
  /// 
  /// Updates existing habit.
  /// Returns [NotFoundFailure] if habit doesn't exist.
  Future<HabitResult> updateHabit(Habit habit);

  /// Delete habit
  /// 
  /// Returns [NotFoundFailure] if habit doesn't exist.
  Future<Result<void>> deleteHabit(String id);

  /// Get goal by ID
  /// 
  /// Returns [NotFoundFailure] if goal doesn't exist.
  Future<GoalResult> getGoal(String id);

  /// Get all goals for a user
  Future<GoalListResult> getGoalsByUserId(String userId);

  /// Get goals by type
  Future<GoalListResult> getGoalsByType(String userId, String goalType);

  /// Get goals by status
  Future<GoalListResult> getGoalsByStatus(String userId, String status);

  /// Save goal
  /// 
  /// Creates new goal or updates existing one.
  /// Returns [ValidationFailure] if goal data is invalid.
  Future<GoalResult> saveGoal(Goal goal);

  /// Update goal
  /// 
  /// Updates existing goal.
  /// Returns [NotFoundFailure] if goal doesn't exist.
  Future<GoalResult> updateGoal(Goal goal);

  /// Delete goal
  /// 
  /// Returns [NotFoundFailure] if goal doesn't exist.
  Future<Result<void>> deleteGoal(String id);
}

