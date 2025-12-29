import 'package:hive/hive.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_log.dart';

part 'medication_log_model.g.dart';

/// MedicationLog Hive data model
/// 
/// Hive adapter for MedicationLog entity.
/// Uses typeId 3 as specified in database schema.
@HiveType(typeId: 3)
class MedicationLogModel extends HiveObject {
  /// Unique identifier (UUID)
  @HiveField(0)
  late String id;

  /// Medication ID (FK to Medication)
  @HiveField(1)
  late String medicationId;

  /// When medication was taken
  @HiveField(2)
  late DateTime takenAt;

  /// Dosage taken
  @HiveField(3)
  late String dosage;

  /// Optional notes
  @HiveField(4)
  String? notes;

  /// Creation timestamp
  @HiveField(5)
  late DateTime createdAt;

  /// Default constructor for Hive
  MedicationLogModel();

  /// Convert to domain entity
  MedicationLog toEntity() {
    return MedicationLog(
      id: id,
      medicationId: medicationId,
      takenAt: takenAt,
      dosage: dosage,
      notes: notes,
      createdAt: createdAt,
    );
  }

  /// Create from domain entity
  factory MedicationLogModel.fromEntity(MedicationLog entity) {
    final model = MedicationLogModel()
      ..id = entity.id
      ..medicationId = entity.medicationId
      ..takenAt = entity.takenAt
      ..dosage = entity.dosage
      ..notes = entity.notes
      ..createdAt = entity.createdAt;
    return model;
  }
}

