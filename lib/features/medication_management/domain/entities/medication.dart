import 'package:health_app/features/medication_management/domain/entities/medication_frequency.dart';
import 'package:health_app/features/medication_management/domain/entities/time_of_day.dart';

/// Medication domain entity
/// 
/// Represents medication tracking and management.
/// This is a pure Dart class with no external dependencies.
class Medication {
  /// Unique identifier (UUID)
  final String id;

  /// User ID (FK to UserProfile)
  final String userId;

  /// Medication name
  final String name;

  /// Dosage description
  final String dosage;

  /// Frequency of medication
  final MedicationFrequency frequency;

  /// List of times medication is taken
  final List<TimeOfDay> times;

  /// Start date
  final DateTime startDate;

  /// End date (null if active)
  final DateTime? endDate;

  /// Whether reminder is enabled
  final bool reminderEnabled;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Creates a Medication
  Medication({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.times,
    required this.startDate,
    this.endDate,
    this.reminderEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if medication is active
  bool get isActive {
    if (endDate == null) return true;
    return DateTime.now().isBefore(endDate!);
  }

  /// Create a copy with updated fields
  Medication copyWith({
    String? id,
    String? userId,
    String? name,
    String? dosage,
    MedicationFrequency? frequency,
    List<TimeOfDay>? times,
    DateTime? startDate,
    DateTime? endDate,
    bool? reminderEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Medication &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          name == other.name &&
          dosage == other.dosage &&
          frequency == other.frequency &&
          times == other.times &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          reminderEnabled == other.reminderEnabled;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      name.hashCode ^
      dosage.hashCode ^
      frequency.hashCode ^
      times.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      reminderEnabled.hashCode;

  @override
  String toString() {
    return 'Medication(id: $id, name: $name, dosage: $dosage, frequency: $frequency, isActive: $isActive)';
  }
}

