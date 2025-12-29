/// Medication frequency enumeration
enum MedicationFrequency {
  daily,
  twiceDaily,
  threeTimesDaily,
  weekly,
  asNeeded;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case MedicationFrequency.daily:
        return 'Once Daily';
      case MedicationFrequency.twiceDaily:
        return 'Twice Daily';
      case MedicationFrequency.threeTimesDaily:
        return 'Three Times Daily';
      case MedicationFrequency.weekly:
        return 'Weekly';
      case MedicationFrequency.asNeeded:
        return 'As Needed';
    }
  }
}

