import 'package:hive/hive.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit.dart';
import 'package:health_app/features/behavioral_support/domain/entities/habit_category.dart';

part 'habit_model.g.dart';

/// Habit Hive data model
/// 
/// Hive adapter for Habit entity.
/// Uses typeId 13 as specified in database schema.
@HiveType(typeId: 13)
class HabitModel extends HiveObject {
  /// Unique identifier (UUID)
  @HiveField(0)
  late String id;

  /// User ID (FK to UserProfile)
  @HiveField(1)
  late String userId;

  /// Habit name
  @HiveField(2)
  late String name;

  /// Category as string ('nutrition', 'exercise', etc.)
  @HiveField(3)
  late String category;

  /// Optional description
  @HiveField(4)
  String? description;

  /// List of dates when habit was completed
  @HiveField(5)
  late List<DateTime> completedDates;

  /// Current streak (consecutive days)
  @HiveField(6)
  late int currentStreak;

  /// Longest streak achieved
  @HiveField(7)
  late int longestStreak;

  /// Start date
  @HiveField(8)
  late DateTime startDate;

  /// Creation timestamp
  @HiveField(9)
  late DateTime createdAt;

  /// Last update timestamp
  @HiveField(10)
  late DateTime updatedAt;

  /// Default constructor for Hive
  HabitModel();

  /// Convert to domain entity
  Habit toEntity() {
    return Habit(
      id: id,
      userId: userId,
      name: name,
      category: HabitCategory.values.firstWhere(
        (c) => c.name == category,
        orElse: () => HabitCategory.other,
      ),
      description: description,
      completedDates: completedDates,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      startDate: startDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory HabitModel.fromEntity(Habit entity) {
    final model = HabitModel()
      ..id = entity.id
      ..userId = entity.userId
      ..name = entity.name
      ..category = entity.category.name
      ..description = entity.description
      ..completedDates = List.from(entity.completedDates)
      ..currentStreak = entity.currentStreak
      ..longestStreak = entity.longestStreak
      ..startDate = entity.startDate
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;
    return model;
  }
}

