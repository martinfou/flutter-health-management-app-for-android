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

  /// Current weight in kilograms
  @HiveField(7)
  late double weight;

  /// Fitness goals
  @HiveField(8)
  late List<String> fitnessGoals;

  /// Dietary approach
  @HiveField(9)
  late String dietaryApproach;

  /// Food dislikes
  @HiveField(10)
  late List<String> dislikes;

  /// Allergies
  @HiveField(11)
  late List<String> allergies;

  /// Health conditions
  @HiveField(12)
  late List<String> healthConditions;

  /// Whether cloud sync is enabled
  @HiveField(13)
  late bool syncEnabled;

  /// Creation timestamp
  @HiveField(14)
  late DateTime createdAt;

  /// Last update timestamp
  @HiveField(15)
  late DateTime updatedAt;

  /// Convert to domain entity
  /// 
  /// Safely handles type conversions in case of data migration issues.
  UserProfile toEntity() {
    // Safe type conversion helpers
    double safeDouble(dynamic value, double defaultValue) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
      return defaultValue;
    }

    bool safeBool(dynamic value, bool defaultValue) {
      if (value is bool) return value;
      if (value is int) return value != 0;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return defaultValue;
    }

    List<String> safeStringList(dynamic value) {
      if (value is List<String>) return value;
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    return UserProfile(
      id: id.toString(),
      name: name.toString(),
      email: email.toString(),
      dateOfBirth: dateOfBirth,
      gender: Gender.values.firstWhere(
        (g) => g.name == gender.toString(),
        orElse: () => Gender.other,
      ),
      height: safeDouble(height, 170.0), // Default to 170cm if invalid
      weight: safeDouble(weight, 75.0), // Default to 75kg if invalid
      targetWeight: safeDouble(targetWeight, 70.0), // Default to 70kg if invalid
      fitnessGoals: safeStringList(fitnessGoals),
      dietaryApproach: dietaryApproach.toString(),
      dislikes: safeStringList(dislikes),
      allergies: safeStringList(allergies),
      healthConditions: safeStringList(healthConditions),
      syncEnabled: safeBool(syncEnabled, false),
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
      ..weight = entity.weight
      ..targetWeight = entity.targetWeight
      ..fitnessGoals = entity.fitnessGoals
      ..dietaryApproach = entity.dietaryApproach
      ..dislikes = entity.dislikes
      ..allergies = entity.allergies
      ..healthConditions = entity.healthConditions
      ..syncEnabled = entity.syncEnabled
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;
    return model;
  }
}

