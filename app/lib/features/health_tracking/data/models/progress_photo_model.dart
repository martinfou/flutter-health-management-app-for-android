import 'package:hive/hive.dart';
import 'package:health_app/features/health_tracking/domain/entities/progress_photo.dart';
import 'package:health_app/features/health_tracking/domain/entities/photo_type.dart';

part 'progress_photo_model.g.dart';

/// ProgressPhoto Hive data model
/// 
/// Hive adapter for ProgressPhoto entity.
/// Uses typeId 10 as specified in database schema.
@HiveType(typeId: 10)
class ProgressPhotoModel extends HiveObject {
  /// Unique identifier (UUID)
  @HiveField(0)
  late String id;

  /// Health metric ID (FK to HealthMetric)
  @HiveField(1)
  late String healthMetricId;

  /// Photo type as string ('front', 'side', 'back')
  @HiveField(2)
  late String photoType;

  /// Path to image file in app storage
  @HiveField(3)
  late String imagePath;

  /// Date of the photo
  @HiveField(4)
  late DateTime date;

  /// Creation timestamp
  @HiveField(5)
  late DateTime createdAt;

  /// Default constructor for Hive
  ProgressPhotoModel();

  /// Convert to domain entity
  ProgressPhoto toEntity() {
    return ProgressPhoto(
      id: id,
      healthMetricId: healthMetricId,
      photoType: PhotoType.values.firstWhere(
        (p) => p.name == photoType,
        orElse: () => PhotoType.front,
      ),
      imagePath: imagePath,
      date: date,
      createdAt: createdAt,
    );
  }

  /// Create from domain entity
  factory ProgressPhotoModel.fromEntity(ProgressPhoto entity) {
    final model = ProgressPhotoModel()
      ..id = entity.id
      ..healthMetricId = entity.healthMetricId
      ..photoType = entity.photoType.name
      ..imagePath = entity.imagePath
      ..date = entity.date
      ..createdAt = entity.createdAt;
    return model;
  }
}

