/// Enum representing different data types that can be synced
enum SyncDataType {
  healthMetrics,
  meals,
  exercises,
  medications,
  medicationLogs,
  goals,
  habits,
  progressPhotos,
}

extension SyncDataTypeExt on SyncDataType {
  /// Human-readable name for the data type
  String get displayName {
    switch (this) {
      case SyncDataType.healthMetrics:
        return 'Health Metrics';
      case SyncDataType.meals:
        return 'Meals';
      case SyncDataType.exercises:
        return 'Exercises';
      case SyncDataType.medications:
        return 'Medications';
      case SyncDataType.medicationLogs:
        return 'Medication Logs';
      case SyncDataType.goals:
        return 'Goals';
      case SyncDataType.habits:
        return 'Habits';
      case SyncDataType.progressPhotos:
        return 'Progress Photos';
    }
  }

  /// Icon name for the data type
  String get iconName {
    switch (this) {
      case SyncDataType.healthMetrics:
        return 'favorite';
      case SyncDataType.meals:
        return 'restaurant';
      case SyncDataType.exercises:
        return 'fitness_center';
      case SyncDataType.medications:
        return 'medication';
      case SyncDataType.medicationLogs:
        return 'schedule';
      case SyncDataType.goals:
        return 'target';
      case SyncDataType.habits:
        return 'habit';
      case SyncDataType.progressPhotos:
        return 'image';
    }
  }
}
