import 'package:hive/hive.dart';
import 'package:health_app/features/medication_management/domain/entities/medication.dart';
import 'package:health_app/features/medication_management/domain/entities/medication_frequency.dart';
import 'package:health_app/features/medication_management/domain/entities/time_of_day.dart';

part 'medication_model.g.dart';

/// Medication Hive data model
///
/// Hive adapter for Medication entity.
/// Uses typeId 2 as specified in database schema.
@HiveType(typeId: 2)
class MedicationModel extends HiveObject {
  /// Unique identifier (UUID)
  @HiveField(0)
  late String id;

  /// User ID (FK to UserProfile)
  @HiveField(1)
  late String userId;

  /// Medication name
  @HiveField(2)
  late String name;

  /// Dosage description
  @HiveField(3)
  late String dosage;

  /// Frequency as string ('daily', 'twiceDaily', etc.)
  @HiveField(4)
  late String frequency;

  /// List of time strings (e.g., ['08:00', '20:00'])
  @HiveField(5)
  late List<String> times;

  /// Start date
  @HiveField(6)
  late DateTime startDate;

  /// End date (null if active)
  @HiveField(7)
  DateTime? endDate;

  /// Whether reminder is enabled
  @HiveField(8)
  late bool reminderEnabled;

  /// Creation timestamp
  @HiveField(9)
  late DateTime createdAt;

  /// Last update timestamp
  @HiveField(10)
  late DateTime updatedAt;

  /// Default constructor for Hive
  MedicationModel();

  /// Convert to domain entity
  Medication toEntity() {
    return Medication(
      id: id,
      userId: userId,
      name: name,
      dosage: dosage,
      frequency: MedicationFrequency.values.firstWhere(
        (f) => f.name == frequency,
        orElse: () => MedicationFrequency.daily,
      ),
      times: times.map((t) => TimeOfDay.fromString(t)).toList(),
      startDate: startDate,
      endDate: endDate,
      reminderEnabled: reminderEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory MedicationModel.fromEntity(Medication entity) {
    final model = MedicationModel()
      ..id = entity.id
      ..userId = entity.userId
      ..name = entity.name
      ..dosage = entity.dosage
      ..frequency = entity.frequency.name
      ..times = entity.times.map((t) => t.toString()).toList()
      ..startDate = entity.startDate
      ..endDate = entity.endDate
      ..reminderEnabled = entity.reminderEnabled
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;
    return model;
  }

  /// Convert to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'dosage': dosage,
      'unit': '', // Add unit field if needed
      'frequency': frequency,
      'start_date':
          startDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'end_date': endDate?.toIso8601String().split('T')[0], // Nullable
      'active': endDate == null ||
          endDate!.isAfter(
              DateTime.now()), // Active if no end date or future end date
      'reminder_times': times, // API expects reminder_times array
      'notes': '', // Add notes field if needed
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
