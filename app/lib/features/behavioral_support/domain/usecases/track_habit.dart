import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit.dart';
import 'package:health_app/features/behavioral_support/domain/repositories/behavioral_repository.dart';

/// Use case for tracking habit completion
/// 
/// Records when a habit is completed, updates streaks, and saves the habit.
/// Handles streak calculation logic (consecutive days).
class TrackHabitUseCase {
  /// Behavioral repository
  final BehavioralRepository repository;

  /// Creates a TrackHabitUseCase
  TrackHabitUseCase(this.repository);

  /// Execute the use case
  /// 
  /// Tracks habit completion for the specified date (or today if not provided).
  /// Updates current streak and longest streak if applicable.
  /// 
  /// Returns [NotFoundFailure] if habit doesn't exist.
  /// Returns [ValidationFailure] if date is invalid.
  /// Returns [DatabaseFailure] if save operation fails.
  Future<Result<Habit>> call({
    required String habitId,
    DateTime? completedDate,
  }) async {
    // Use today if date not provided
    final date = completedDate ?? DateTime.now();
    final dateOnly = DateTime(date.year, date.month, date.day);

    // Validate date is not in future
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (dateOnly.isAfter(today)) {
      return Left(ValidationFailure('Cannot track habit completion in the future'));
    }

    // Get existing habit
    final habitResult = await repository.getHabit(habitId);
    if (habitResult.isLeft()) {
      return habitResult.fold(
        (failure) => Left(failure),
        (_) => throw StateError('Unexpected success'),
      );
    }

    final habit = habitResult.fold(
      (_) => throw StateError('Unexpected failure'),
      (h) => h,
    );

    // Check if already completed on this date
    if (habit.isCompletedOnDate(dateOnly)) {
      // Return existing habit without changes
      return Right(habit);
    }

    // Add completion date
    final updatedCompletedDates = List<DateTime>.from(habit.completedDates)
      ..add(dateOnly)
      ..sort((a, b) => b.compareTo(a)); // Sort descending (newest first)

    // Calculate streaks
    final streakResult = _calculateStreaks(updatedCompletedDates);
    final updatedCurrentStreak = streakResult['current'] as int;
    final updatedLongestStreak = streakResult['longest'] as int;

    // Create updated habit
    final updatedHabit = habit.copyWith(
      completedDates: updatedCompletedDates,
      currentStreak: updatedCurrentStreak,
      longestStreak: updatedLongestStreak > habit.longestStreak
          ? updatedLongestStreak
          : habit.longestStreak,
      updatedAt: DateTime.now(),
    );

    // Save updated habit
    return await repository.updateHabit(updatedHabit);
  }

  /// Calculate current and longest streaks from completed dates
  /// 
  /// Returns a map with 'current' and 'longest' streak values.
  Map<String, int> _calculateStreaks(List<DateTime> completedDates) {
    if (completedDates.isEmpty) {
      return {'current': 0, 'longest': 0};
    }

    // Convert to date-only (remove time component) and sort descending
    final dateOnlyList = completedDates
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet() // Remove duplicates
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending (newest first)

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calculate current streak (consecutive days from today backwards)
    int currentStreak = 0;
    DateTime? expectedDate = today;
    
    for (final date in dateOnlyList) {
      if (date.isAtSameMomentAs(expectedDate!)) {
        currentStreak++;
        expectedDate = expectedDate.subtract(Duration(days: 1));
      } else if (date.isBefore(expectedDate)) {
        // Gap found, streak broken
        break;
      }
      // If date is after expected, continue (might be future dates we're ignoring)
    }

    // Calculate longest streak (any consecutive period)
    int longestStreak = 1;
    int tempStreak = 1;
    
    for (int i = 0; i < dateOnlyList.length - 1; i++) {
      final currentDate = dateOnlyList[i];
      final nextDate = dateOnlyList[i + 1];
      final diff = currentDate.difference(nextDate).inDays;
      
      if (diff == 1) {
        // Consecutive day
        tempStreak++;
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
      } else {
        // Streak broken, reset
        tempStreak = 1;
      }
    }

    return {
      'current': currentStreak,
      'longest': longestStreak,
    };
  }
}

