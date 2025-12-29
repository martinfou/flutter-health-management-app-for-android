import 'package:hive/hive.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal_type.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal_status.dart';

part 'goal_model.g.dart';

/// Goal Hive data model
/// 
/// Hive adapter for Goal entity.
/// Uses typeId 14 as specified in database schema.
@HiveType(typeId: 14)
class GoalModel extends HiveObject {
  /// Unique identifier (UUID)
  @HiveField(0)
  late String id;

  /// User ID (FK to UserProfile)
  @HiveField(1)
  late String userId;

  /// Goal type as string ('identity', 'behavior', 'outcome')
  @HiveField(2)
  late String type;

  /// Goal description
  @HiveField(3)
  late String description;

  /// Text description of target (optional)
  @HiveField(4)
  String? target;

  /// Numeric target value (optional)
  @HiveField(5)
  double? targetValue;

  /// Current value
  @HiveField(6)
  late double currentValue;

  /// Optional deadline
  @HiveField(7)
  DateTime? deadline;

  /// Link to health metric type (optional)
  @HiveField(8)
  String? linkedMetric;

  /// Goal status as string ('inProgress', 'completed', etc.)
  @HiveField(9)
  late String status;

  /// Completion timestamp (optional)
  @HiveField(10)
  DateTime? completedAt;

  /// Creation timestamp
  @HiveField(11)
  late DateTime createdAt;

  /// Last update timestamp
  @HiveField(12)
  late DateTime updatedAt;

  /// Default constructor for Hive
  GoalModel();

  /// Convert to domain entity
  Goal toEntity() {
    return Goal(
      id: id,
      userId: userId,
      type: GoalType.values.firstWhere(
        (t) => t.name == type,
        orElse: () => GoalType.outcome,
      ),
      description: description,
      target: target,
      targetValue: targetValue,
      currentValue: currentValue,
      deadline: deadline,
      linkedMetric: linkedMetric,
      status: GoalStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => GoalStatus.inProgress,
      ),
      completedAt: completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory GoalModel.fromEntity(Goal entity) {
    final model = GoalModel()
      ..id = entity.id
      ..userId = entity.userId
      ..type = entity.type.name
      ..description = entity.description
      ..target = entity.target
      ..targetValue = entity.targetValue
      ..currentValue = entity.currentValue
      ..deadline = entity.deadline
      ..linkedMetric = entity.linkedMetric
      ..status = entity.status.name
      ..completedAt = entity.completedAt
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;
    return model;
  }
}

