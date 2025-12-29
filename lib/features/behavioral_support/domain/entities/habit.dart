import 'package:health_app/features/behavioral_support/domain/entities/habit_category.dart';

/// Habit domain entity
/// 
/// Represents habit tracking and streak management for behavioral support.
/// This is a pure Dart class with no external dependencies.
class Habit {
  /// Unique identifier (UUID)
  final String id;

  /// User ID (FK to UserProfile)
  final String userId;

  /// Habit name
  final String name;

  /// Habit category
  final HabitCategory category;

  /// Optional description
  final String? description;

  /// List of dates when habit was completed
  final List<DateTime> completedDates;

  /// Current streak (consecutive days)
  final int currentStreak;

  /// Longest streak achieved
  final int longestStreak;

  /// Start date
  final DateTime startDate;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Creates a Habit
  Habit({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    this.description,
    required this.completedDates,
    required this.currentStreak,
    required this.longestStreak,
    required this.startDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if habit is completed today
  bool isCompletedToday() {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    return completedDates.any((date) =>
        date.year == todayOnly.year &&
        date.month == todayOnly.month &&
        date.day == todayOnly.day);
  }

  /// Check if habit is completed on specific date
  bool isCompletedOnDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return completedDates.any((completedDate) =>
        completedDate.year == dateOnly.year &&
        completedDate.month == dateOnly.month &&
        completedDate.day == dateOnly.day);
  }

  /// Create a copy with updated fields
  Habit copyWith({
    String? id,
    String? userId,
    String? name,
    HabitCategory? category,
    String? description,
    List<DateTime>? completedDates,
    int? currentStreak,
    int? longestStreak,
    DateTime? startDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      completedDates: completedDates ?? this.completedDates,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      startDate: startDate ?? this.startDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          name == other.name &&
          category == other.category &&
          description == other.description &&
          completedDates == other.completedDates &&
          currentStreak == other.currentStreak &&
          longestStreak == other.longestStreak &&
          startDate == other.startDate;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      name.hashCode ^
      category.hashCode ^
      description.hashCode ^
      completedDates.hashCode ^
      currentStreak.hashCode ^
      longestStreak.hashCode ^
      startDate.hashCode;

  @override
  String toString() {
    return 'Habit(id: $id, name: $name, category: $category, currentStreak: $currentStreak, longestStreak: $longestStreak)';
  }
}

