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

  /// Energy level (1-10, nullable)
  @HiveField(5)
  int? energyLevel;

  /// Resting heart rate in BPM (nullable)
  @HiveField(6)
  int? restingHeartRate;

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
      energyLevel: energyLevel,
      restingHeartRate: restingHeartRate,
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
      ..energyLevel = entity.energyLevel
      ..restingHeartRate = entity.restingHeartRate
      ..bodyMeasurements = entity.bodyMeasurements
      ..notes = entity.notes
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;
    return model;
  }
}

