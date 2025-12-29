import 'package:health_app/features/health_tracking/domain/entities/photo_type.dart';

/// Progress photo domain entity
/// 
/// Represents a progress photo linked to a health metric.
/// This is a pure Dart class with no external dependencies.
class ProgressPhoto {
  /// Unique identifier (UUID)
  final String id;

  /// Health metric ID (FK to HealthMetric)
  final String healthMetricId;

  /// Photo type
  final PhotoType photoType;

  /// Path to image file in app storage
  final String imagePath;

  /// Date of the photo
  final DateTime date;

  /// Creation timestamp
  final DateTime createdAt;

  /// Creates a ProgressPhoto
  ProgressPhoto({
    required this.id,
    required this.healthMetricId,
    required this.photoType,
    required this.imagePath,
    required this.date,
    required this.createdAt,
  });

  /// Create a copy with updated fields
  ProgressPhoto copyWith({
    String? id,
    String? healthMetricId,
    PhotoType? photoType,
    String? imagePath,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return ProgressPhoto(
      id: id ?? this.id,
      healthMetricId: healthMetricId ?? this.healthMetricId,
      photoType: photoType ?? this.photoType,
      imagePath: imagePath ?? this.imagePath,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressPhoto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          healthMetricId == other.healthMetricId &&
          photoType == other.photoType &&
          imagePath == other.imagePath &&
          date == other.date;

  @override
  int get hashCode =>
      id.hashCode ^
      healthMetricId.hashCode ^
      photoType.hashCode ^
      imagePath.hashCode ^
      date.hashCode;

  @override
  String toString() {
    return 'ProgressPhoto(id: $id, healthMetricId: $healthMetricId, photoType: $photoType, date: $date)';
  }
}

