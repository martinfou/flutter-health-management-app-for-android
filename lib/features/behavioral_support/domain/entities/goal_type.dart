/// Goal type enumeration
enum GoalType {
  identity,
  behavior,
  outcome;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case GoalType.identity:
        return 'Identity Goal';
      case GoalType.behavior:
        return 'Behavior Goal';
      case GoalType.outcome:
        return 'Outcome Goal';
    }
  }
}

