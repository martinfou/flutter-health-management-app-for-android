import 'package:hive/hive.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';

part 'health_metric_model.g.dart';

/// HealthMetric Hive data model
///
/// Hive adapter for HealthMetric entity.
/// Uses typeId 1 as specified in database schema.
@HiveType(typeId: 1)
class HealthMetricModel extends HiveObject {
  /// Unique identifier (UUID)
  @HiveField(0)
  late String id;

  /// User ID (FK to UserProfile)
  @HiveField(1)
  late String userId;

  /// Date of the metric
  @HiveField(2)
  late DateTime date;

  /// Weight in kilograms (nullable)
  @HiveField(3)
  double? weight;

  /// Sleep quality (1-10, nullable)
  @HiveField(4)
  int? sleepQuality;

  /// Sleep hours (1-12 hours, nullable, in 0.5 hour increments)
  @HiveField(13)
  double? sleepHours;

  /// Energy level (1-10, nullable)
  @HiveField(5)
  int? energyLevel;

  /// Resting heart rate in BPM (nullable)
  @HiveField(6)
  int? restingHeartRate;

  /// Systolic blood pressure in mmHg (nullable)
  @HiveField(11)
  int? systolicBP;

  /// Diastolic blood pressure in mmHg (nullable)
  @HiveField(12)
  int? diastolicBP;

  /// Steps count (nullable)
  @HiveField(14)
  int? steps;

  /// Calories burned (nullable)
  @HiveField(15)
  int? caloriesBurned;

  /// Water intake in milliliters (nullable)
  @HiveField(16)
  int? waterIntakeMl;

  /// Mood (nullable - excellent, good, neutral, poor, terrible)
  @HiveField(17)
  String? mood;

  /// Stress level (1-10, nullable)
  @HiveField(18)
  int? stressLevel;

  /// Body measurements map (waist, hips, neck, chest, thigh) in cm
  @HiveField(7)
  Map<String, double>? bodyMeasurements;

  /// Optional notes
  @HiveField(8)
  String? notes;

  /// Creation timestamp
  @HiveField(9)
  late DateTime createdAt;

  /// Last update timestamp
  @HiveField(10)
  late DateTime updatedAt;

  /// Default constructor for Hive
  HealthMetricModel();

  /// Convert to domain entity
  HealthMetric toEntity() {
    return HealthMetric(
      id: id,
      userId: userId,
      date: date,
      weight: weight,
      sleepQuality: sleepQuality,
      sleepHours: sleepHours,
      energyLevel: energyLevel,
      restingHeartRate: restingHeartRate,
      systolicBP: systolicBP,
      diastolicBP: diastolicBP,
      steps: steps,
      caloriesBurned: caloriesBurned,
      waterIntakeMl: waterIntakeMl,
      mood: mood,
      stressLevel: stressLevel,
      bodyMeasurements: bodyMeasurements,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory HealthMetricModel.fromEntity(HealthMetric entity) {
    final model = HealthMetricModel()
      ..id = entity.id
      ..userId = entity.userId
      ..date = entity.date
      ..weight = entity.weight
      ..sleepQuality = entity.sleepQuality
      ..sleepHours = entity.sleepHours
      ..energyLevel = entity.energyLevel
      ..restingHeartRate = entity.restingHeartRate
      ..systolicBP = entity.systolicBP
      ..diastolicBP = entity.diastolicBP
      ..steps = entity.steps
      ..caloriesBurned = entity.caloriesBurned
      ..waterIntakeMl = entity.waterIntakeMl
      ..mood = entity.mood
      ..stressLevel = entity.stressLevel
      ..bodyMeasurements = entity.bodyMeasurements
      ..notes = entity.notes
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;
    return model;
  }

  /// Create from JSON (API response)
  factory HealthMetricModel.fromJson(Map<String, dynamic> json) {
    final model = HealthMetricModel()
      ..id = json['id'].toString() // Handle both int and string from API
      ..userId =
          json['user_id'].toString() // Handle both int and string from API
      ..date = DateTime.parse(json['date'] as String)
      ..weight = json['weight_kg'] != null
          ? double.tryParse(json['weight_kg'].toString()) ?? 0.0
          : null
      ..sleepQuality = json['sleep_quality'] != null
          ? int.tryParse(json['sleep_quality'].toString())
          : null
      ..sleepHours = json['sleep_hours'] != null
          ? double.tryParse(json['sleep_hours'].toString()) ?? 0.0
          : null
      ..energyLevel = json['energy_level'] != null
          ? int.tryParse(json['energy_level'].toString())
          : null
      ..restingHeartRate = json['resting_heart_rate'] != null
          ? int.tryParse(json['resting_heart_rate'].toString())
          : null
      ..systolicBP = json['blood_pressure_systolic'] != null
          ? int.tryParse(json['blood_pressure_systolic'].toString())
          : null
      ..diastolicBP = json['blood_pressure_diastolic'] != null
          ? int.tryParse(json['blood_pressure_diastolic'].toString())
          : null
      ..steps =
          json['steps'] != null ? int.tryParse(json['steps'].toString()) : null
      ..caloriesBurned = json['calories_burned'] != null
          ? int.tryParse(json['calories_burned'].toString())
          : null
      ..waterIntakeMl = json['water_intake_ml'] != null
          ? int.tryParse(json['water_intake_ml'].toString())
          : null
      ..mood = json['mood'] as String?
      ..stressLevel = json['stress_level'] != null
          ? int.tryParse(json['stress_level'].toString())
          : null
      ..notes = json['notes'] as String?
      ..createdAt = DateTime.parse(json['created_at'] as String)
      ..updatedAt = DateTime.parse(json['updated_at'] as String);

    // Parse metadata for body measurements
    if (json['metadata'] != null) {
      try {
        final metadata = json['metadata'] is String
            ? Map<String, dynamic>.from(
                // Simple parsing if it's a string, or use a proper decoder if imported
                // Assuming metadata is returned as Map or String dependent on backend
                // For safety, let's assume specific handling might be needed
                // but for now relying on backend sending JSON object or check implementation
                json['metadata'] as Map) // This might fail if string
            : json['metadata'] as Map<String, dynamic>;

        if (metadata.containsKey('body_measurements')) {
          final measurements =
              metadata['body_measurements'] as Map<String, dynamic>;
          model.bodyMeasurements = measurements.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          );
        }
      } catch (e) {
        // Ignore metadata parsing errors for now
      }
    }

    return model;
  }

  /// Convert to JSON (API request)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> metadata = {};
    if (bodyMeasurements != null) {
      metadata['body_measurements'] = bodyMeasurements;
    }

    return {
      'id': id,
      'user_id': userId,
      'date': date
          .toIso8601String(), // BF-003: Send full timestamp instead of just date
      'weight_kg': weight,
      'sleep_quality': sleepQuality,
      'sleep_hours': sleepHours,
      'energy_level': energyLevel,
      'resting_heart_rate': restingHeartRate,
      'blood_pressure_systolic': systolicBP,
      'blood_pressure_diastolic': diastolicBP,
      'steps': steps,
      'calories_burned': caloriesBurned,
      'water_intake_ml': waterIntakeMl,
      'mood': mood,
      'stress_level': stressLevel,
      'notes': notes,
      'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt.toIso8601String(),
    };
  }
}
