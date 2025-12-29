import 'package:health_app/features/behavioral_support/domain/entities/goal_type.dart';
import 'package:health_app/features/behavioral_support/domain/entities/goal_status.dart';

/// Goal domain entity
/// 
/// Represents identity-based and behavior goals for health transformation.
/// This is a pure Dart class with no external dependencies.
class Goal {
  /// Unique identifier (UUID)
  final String id;

  /// User ID (FK to UserProfile)
  final String userId;

  /// Goal type
  final GoalType type;

  /// Goal description
  final String description;

  /// Text description of target (optional)
  final String? target;

  /// Numeric target value (optional)
  final double? targetValue;

  /// Current value
  final double currentValue;

  /// Optional deadline
  final DateTime? deadline;

  /// Link to health metric type (optional)
  final String? linkedMetric;

  /// Goal status
  final GoalStatus status;

  /// Completion timestamp (optional)
  final DateTime? completedAt;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Creates a Goal
  Goal({
    required this.id,
    required this.userId,
    required this.type,
    required this.description,
    this.target,
    this.targetValue,
    required this.currentValue,
    this.deadline,
    this.linkedMetric,
    required this.status,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate progress percentage
  double get progressPercentage {
    if (targetValue == null || targetValue == 0) return 0.0;
    return (currentValue / targetValue!).clamp(0.0, 1.0) * 100;
  }

  /// Check if goal is achieved
  bool get isAchieved {
    if (targetValue == null) return false;
    return currentValue >= targetValue!;
  }

  /// Days remaining until deadline
  int? get daysRemaining {
    if (deadline == null) return null;
    final now = DateTime.now();
    final difference = deadline!.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  /// Create a copy with updated fields
  Goal copyWith({
    String? id,
    String? userId,
    GoalType? type,
    String? description,
    String? target,
    double? targetValue,
    double? currentValue,
    DateTime? deadline,
    String? linkedMetric,
    GoalStatus? status,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      description: description ?? this.description,
      target: target ?? this.target,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      deadline: deadline ?? this.deadline,
      linkedMetric: linkedMetric ?? this.linkedMetric,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Goal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          type == other.type &&
          description == other.description &&
          target == other.target &&
          targetValue == other.targetValue &&
          currentValue == other.currentValue &&
          deadline == other.deadline &&
          linkedMetric == other.linkedMetric &&
          status == other.status &&
          completedAt == other.completedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      type.hashCode ^
      description.hashCode ^
      target.hashCode ^
      targetValue.hashCode ^
      currentValue.hashCode ^
      deadline.hashCode ^
      linkedMetric.hashCode ^
      status.hashCode ^
      completedAt.hashCode;

  @override
  String toString() {
    return 'Goal(id: $id, description: $description, type: $type, status: $status, progress: ${progressPercentage.toStringAsFixed(1)}%)';
  }
}

