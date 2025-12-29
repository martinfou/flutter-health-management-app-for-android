/// Photo type enumeration for progress photos
enum PhotoType {
  front,
  side,
  back;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case PhotoType.front:
        return 'Front';
      case PhotoType.side:
        return 'Side';
      case PhotoType.back:
        return 'Back';
    }
  }
}

