/// Gender enumeration
enum Gender {
  male,
  female,
  other;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }
}

