/// Eating reason category enumeration
enum EatingReasonCategory {
  physical,
  emotional,
  social;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case EatingReasonCategory.physical:
        return 'Physical';
      case EatingReasonCategory.emotional:
        return 'Emotional';
      case EatingReasonCategory.social:
        return 'Social';
    }
  }
}

