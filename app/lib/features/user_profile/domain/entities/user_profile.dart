import 'package:health_app/features/user_profile/domain/entities/gender.dart';

/// User profile domain entity
/// 
/// Represents user account and profile information.
/// This is a pure Dart class with no external dependencies.
class UserProfile {
  /// Unique identifier (UUID)
  final String id;

  /// User's full name
  final String name;

  /// User's email address
  final String email;

  /// Date of birth
  final DateTime dateOfBirth;

  /// Gender
  final Gender gender;

  /// Height in centimeters
  final double height;

  /// Current weight in kilograms
  final double weight;

  /// Target weight in kilograms
  final double targetWeight;

  /// List of fitness goals
  final List<String> fitnessGoals;

  /// Dietary approach (e.g., 'Keto', 'Vegan')
  final String dietaryApproach;

  /// List of food dislikes
  final List<String> dislikes;

  /// List of allergies
  final List<String> allergies;

  /// List of health conditions/limitations
  final List<String> healthConditions;

  /// Whether cloud sync is enabled (false for MVP)
  final bool syncEnabled;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Creates a UserProfile
  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.height,
    required this.weight,
    required this.targetWeight,
    this.fitnessGoals = const [],
    this.dietaryApproach = 'Standard',
    this.dislikes = const [],
    this.allergies = const [],
    this.healthConditions = const [],
    this.syncEnabled = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate age from date of birth
  int get age {
    final now = DateTime.now();
    return now.year -
        dateOfBirth.year -
        (now.month > dateOfBirth.month ||
                (now.month == dateOfBirth.month && now.day >= dateOfBirth.day)
            ? 0
            : 1);
  }

  /// Calculate BMI from target weight and height
  /// Returns null if height is invalid
  double? get bmi {
    if (height <= 0) return null;
    return targetWeight / ((height / 100) * (height / 100));
  }

  /// Create a copy with updated fields
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? dateOfBirth,
    Gender? gender,
    double? height,
    double? weight,
    double? targetWeight,
    List<String>? fitnessGoals,
    String? dietaryApproach,
    List<String>? dislikes,
    List<String>? allergies,
    List<String>? healthConditions,
    bool? syncEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      targetWeight: targetWeight ?? this.targetWeight,
      fitnessGoals: fitnessGoals ?? this.fitnessGoals,
      dietaryApproach: dietaryApproach ?? this.dietaryApproach,
      dislikes: dislikes ?? this.dislikes,
      allergies: allergies ?? this.allergies,
      healthConditions: healthConditions ?? this.healthConditions,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          dateOfBirth == other.dateOfBirth &&
          gender == other.gender &&
          height == other.height &&
          weight == other.weight &&
          targetWeight == other.targetWeight &&
          fitnessGoals == other.fitnessGoals &&
          dietaryApproach == other.dietaryApproach &&
          dislikes == other.dislikes &&
          allergies == other.allergies &&
          healthConditions == other.healthConditions &&
          syncEnabled == other.syncEnabled;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      dateOfBirth.hashCode ^
      gender.hashCode ^
      height.hashCode ^
      weight.hashCode ^
      targetWeight.hashCode ^
      fitnessGoals.hashCode ^
      dietaryApproach.hashCode ^
      dislikes.hashCode ^
      allergies.hashCode ^
      healthConditions.hashCode ^
      syncEnabled.hashCode;

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, email: $email, age: $age, gender: $gender, height: $height, weight: $weight, targetWeight: $targetWeight)';
  }
}

