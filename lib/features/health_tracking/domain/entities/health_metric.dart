/// Health metric domain entity
/// 
/// Represents daily health tracking data (weight, sleep, energy, heart rate, measurements).
/// This is a pure Dart class with no external dependencies.
class HealthMetric {
  /// Unique identifier (UUID)
  final String id;

  /// User ID (FK to UserProfile)
  final String userId;

  /// Date of the metric
  final DateTime date;

  /// Weight in kilograms (nullable)
  final double? weight;

  /// Sleep quality (1-10, nullable)
  final int? sleepQuality;

  /// Energy level (1-10, nullable)
  final int? energyLevel;

  /// Resting heart rate in BPM (nullable)
  final int? restingHeartRate;

  /// Body measurements map (waist, hips, neck, chest, thigh) in cm
  final Map<String, double>? bodyMeasurements;

  /// Optional notes
  final String? notes;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Creates a HealthMetric
  HealthMetric({
    required this.id,
    required this.userId,
    required this.date,
    this.weight,
    this.sleepQuality,
    this.energyLevel,
    this.restingHeartRate,
    this.bodyMeasurements,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if metric has any data
  bool get hasData {
    return weight != null ||
        sleepQuality != null ||
        energyLevel != null ||
        restingHeartRate != null ||
        (bodyMeasurements != null && bodyMeasurements!.isNotEmpty);
  }

  /// Create a copy with updated fields
  HealthMetric copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? weight,
    int? sleepQuality,
    int? energyLevel,
    int? restingHeartRate,
    Map<String, double>? bodyMeasurements,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthMetric(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      energyLevel: energyLevel ?? this.energyLevel,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      bodyMeasurements: bodyMeasurements ?? this.bodyMeasurements,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthMetric &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          date == other.date &&
          weight == other.weight &&
          sleepQuality == other.sleepQuality &&
          energyLevel == other.energyLevel &&
          restingHeartRate == other.restingHeartRate &&
          bodyMeasurements == other.bodyMeasurements &&
          notes == other.notes;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      date.hashCode ^
      weight.hashCode ^
      sleepQuality.hashCode ^
      energyLevel.hashCode ^
      restingHeartRate.hashCode ^
      bodyMeasurements.hashCode ^
      notes.hashCode;

  @override
  String toString() {
    return 'HealthMetric(id: $id, userId: $userId, date: $date, weight: $weight, sleepQuality: $sleepQuality, energyLevel: $energyLevel, restingHeartRate: $restingHeartRate)';
  }
}

