/// Goal status enumeration
enum GoalStatus {
  inProgress,
  completed,
  paused,
  cancelled;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case GoalStatus.inProgress:
        return 'In Progress';
      case GoalStatus.completed:
        return 'Completed';
      case GoalStatus.paused:
        return 'Paused';
      case GoalStatus.cancelled:
        return 'Cancelled';
    }
  }
}

