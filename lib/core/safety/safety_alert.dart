import 'package:health_app/core/safety/alert_type.dart';

/// Safety alert domain entity
/// 
/// Represents a clinical safety alert that should be displayed to the user.
/// This is a pure Dart class with no external dependencies.
class SafetyAlert {
  /// Alert type
  final AlertType type;

  /// Alert title
  final String title;

  /// Alert message
  final String message;

  /// Alert severity
  final AlertSeverity severity;

  /// Whether acknowledgment is required
  final bool requiresAcknowledgment;

  /// Whether alert can be dismissed
  final bool cannotDismiss;

  /// Optional timestamp when alert was triggered
  final DateTime? triggeredAt;

  /// Creates a SafetyAlert
  SafetyAlert({
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    required this.requiresAcknowledgment,
    required this.cannotDismiss,
    this.triggeredAt,
  });

  /// Create a copy with updated fields
  SafetyAlert copyWith({
    AlertType? type,
    String? title,
    String? message,
    AlertSeverity? severity,
    bool? requiresAcknowledgment,
    bool? cannotDismiss,
    DateTime? triggeredAt,
  }) {
    return SafetyAlert(
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      requiresAcknowledgment: requiresAcknowledgment ?? this.requiresAcknowledgment,
      cannotDismiss: cannotDismiss ?? this.cannotDismiss,
      triggeredAt: triggeredAt ?? this.triggeredAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SafetyAlert &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          title == other.title &&
          message == other.message &&
          severity == other.severity &&
          requiresAcknowledgment == other.requiresAcknowledgment &&
          cannotDismiss == other.cannotDismiss;

  @override
  int get hashCode =>
      type.hashCode ^
      title.hashCode ^
      message.hashCode ^
      severity.hashCode ^
      requiresAcknowledgment.hashCode ^
      cannotDismiss.hashCode;

  @override
  String toString() {
    return 'SafetyAlert(type: $type, title: $title, severity: $severity)';
  }
}

