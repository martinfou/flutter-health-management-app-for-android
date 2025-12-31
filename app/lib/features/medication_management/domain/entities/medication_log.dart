/// Medication log domain entity
/// 
/// Represents a log entry for when medication was taken.
/// This is a pure Dart class with no external dependencies.
class MedicationLog {
  /// Unique identifier (UUID)
  final String id;

  /// Medication ID (FK to Medication)
  final String medicationId;

  /// When medication was taken
  final DateTime takenAt;

  /// Dosage taken
  final String dosage;

  /// Optional notes
  final String? notes;

  /// Creation timestamp
  final DateTime createdAt;

  /// Creates a MedicationLog
  MedicationLog({
    required this.id,
    required this.medicationId,
    required this.takenAt,
    required this.dosage,
    this.notes,
    required this.createdAt,
  });

  /// Create a copy with updated fields
  MedicationLog copyWith({
    String? id,
    String? medicationId,
    DateTime? takenAt,
    String? dosage,
    String? notes,
    DateTime? createdAt,
  }) {
    return MedicationLog(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      takenAt: takenAt ?? this.takenAt,
      dosage: dosage ?? this.dosage,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationLog &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          medicationId == other.medicationId &&
          takenAt == other.takenAt &&
          dosage == other.dosage &&
          notes == other.notes;

  @override
  int get hashCode =>
      id.hashCode ^
      medicationId.hashCode ^
      takenAt.hashCode ^
      dosage.hashCode ^
      notes.hashCode;

  @override
  String toString() {
    return 'MedicationLog(id: $id, medicationId: $medicationId, takenAt: $takenAt, dosage: $dosage)';
  }
}

