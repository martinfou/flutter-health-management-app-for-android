/// Recipe difficulty enumeration
enum RecipeDifficulty {
  easy,
  medium,
  hard;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case RecipeDifficulty.easy:
        return 'Easy';
      case RecipeDifficulty.medium:
        return 'Medium';
      case RecipeDifficulty.hard:
        return 'Hard';
    }
  }
}

