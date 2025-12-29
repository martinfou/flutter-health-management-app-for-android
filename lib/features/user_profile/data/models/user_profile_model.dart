import 'package:hive/hive.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:health_app/features/user_profile/domain/entities/gender.dart';

part 'user_profile_model.g.dart';

/// UserProfile Hive data model
/// 
/// Hive adapter for UserProfile entity.
/// Uses typeId 0 as specified in database schema.
@HiveType(typeId: 0)
class UserProfileModel extends HiveObject {
  /// Unique identifier (UUID)
  @HiveField(0)
  late String id;

  /// User's full name
  @HiveField(1)
  late String name;

  /// User's email address
  @HiveField(2)
  late String email;

  /// Date of birth
  @HiveField(3)
  late DateTime dateOfBirth;

  /// Gender as string ('male', 'female', 'other')
  @HiveField(4)
  late String gender;

  /// Height in centimeters
  @HiveField(5)
  late double height;

  /// Target weight in kilograms
  @HiveField(6)
  late double targetWeight;

  /// Whether cloud sync is enabled
  @HiveField(7)
  late bool syncEnabled;

  /// Creation timestamp
  @HiveField(8)
  late DateTime createdAt;

  /// Last update timestamp
  @HiveField(9)
  late DateTime updatedAt;

  /// Convert to domain entity
  UserProfile toEntity() {
    return UserProfile(
      id: id,
      name: name,
      email: email,
      dateOfBirth: dateOfBirth,
      gender: Gender.values.firstWhere(
        (g) => g.name == gender,
        orElse: () => Gender.other,
      ),
      height: height,
      targetWeight: targetWeight,
      syncEnabled: syncEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Default constructor for Hive
  UserProfileModel();

  /// Create from domain entity
  factory UserProfileModel.fromEntity(UserProfile entity) {
    final model = UserProfileModel()
      ..id = entity.id
      ..name = entity.name
      ..email = entity.email
      ..dateOfBirth = entity.dateOfBirth
      ..gender = entity.gender.name
      ..height = entity.height
      ..targetWeight = entity.targetWeight
      ..syncEnabled = entity.syncEnabled
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;
    return model;
  }
}

