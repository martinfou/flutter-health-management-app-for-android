import 'package:hive/hive.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal_type.dart';
import 'package:health_app/features/nutrition_management/domain/entities/eating_reason.dart';

part 'meal_model.g.dart';

/// Meal Hive data model
///
/// Hive adapter for Meal entity.
/// Uses typeId 4 as specified in database schema.
@HiveType(typeId: 4)
class MealModel extends HiveObject {
  /// Unique identifier (UUID)
  @HiveField(0)
  late String id;

  /// User ID (FK to UserProfile)
  @HiveField(1)
  late String userId;

  /// Date of the meal
  @HiveField(2)
  late DateTime date;

  /// Meal type as string ('breakfast', 'lunch', 'dinner', 'snack')
  @HiveField(3)
  late String mealType;

  /// Meal name
  @HiveField(4)
  late String name;

  /// Protein in grams
  @HiveField(5)
  late double protein;

  /// Fats in grams
  @HiveField(6)
  late double fats;

  /// Net carbs in grams
  @HiveField(7)
  late double netCarbs;

  /// Total calories
  @HiveField(8)
  late double calories;

  /// List of ingredients
  @HiveField(9)
  late List<String> ingredients;

  /// Recipe ID (FK to Recipe, nullable)
  @HiveField(10)
  String? recipeId;

  /// Creation timestamp
  @HiveField(11)
  late DateTime createdAt;

  /// Hunger level before eating (0-10, nullable)
  @HiveField(12)
  int? hungerLevelBefore;

  /// Fullness level after eating (0-10, nullable)
  @HiveField(13)
  int? hungerLevelAfter;

  /// Timestamp when fullness after was measured (nullable)
  @HiveField(14)
  DateTime? fullnessAfterTimestamp;

  /// Eating reasons stored as enum names (nullable List<String>)
  /// null = not answered, empty list = explicitly no reasons
  @HiveField(15)
  List<String>? eatingReasons;

  /// Last update timestamp (for sync)
  @HiveField(16)
  DateTime? updatedAt;

  /// Deletion timestamp (soft delete)
  @HiveField(17)
  DateTime? deletedAt;

  /// Sync status (true if synced with backend)
  @HiveField(18)
  bool isSynced = false;

  /// Default constructor for Hive
  MealModel();

  /// Convert to domain entity
  Meal toEntity() {
    // Convert eating reasons from strings to enum values
    List<EatingReason>? eatingReasonsList;
    if (eatingReasons != null) {
      eatingReasonsList = eatingReasons!
          .map((name) {
            try {
              return EatingReason.values.firstWhere(
                (e) => e.name == name,
              );
            } catch (e) {
              // Skip invalid enum values (backward compatibility)
              return null;
            }
          })
          .whereType<EatingReason>()
          .toList();
    }

    return Meal(
      id: id,
      userId: userId,
      date: date,
      mealType: MealType.values.firstWhere(
        (m) => m.name == mealType,
        orElse: () => MealType.snack,
      ),
      name: name,
      protein: protein,
      fats: fats,
      netCarbs: netCarbs,
      calories: calories,
      ingredients: ingredients,
      recipeId: recipeId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      isSynced: isSynced,
      hungerLevelBefore: hungerLevelBefore,
      hungerLevelAfter: hungerLevelAfter,
      fullnessAfterTimestamp: fullnessAfterTimestamp,
      eatingReasons: eatingReasonsList,
    );
  }

  /// Create from domain entity
  factory MealModel.fromEntity(Meal entity) {
    // Convert eating reasons from enum values to strings
    List<String>? eatingReasonsList;
    if (entity.eatingReasons != null) {
      eatingReasonsList = entity.eatingReasons!.map((e) => e.name).toList();
    }

    final model = MealModel()
      ..id = entity.id
      ..userId = entity.userId
      ..date = entity.date
      ..mealType = entity.mealType.name
      ..name = entity.name
      ..protein = entity.protein
      ..fats = entity.fats
      ..netCarbs = entity.netCarbs
      ..calories = entity.calories
      ..ingredients = entity.ingredients
      ..recipeId = entity.recipeId
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..deletedAt = entity.deletedAt
      ..isSynced = entity.isSynced
      ..hungerLevelBefore = entity.hungerLevelBefore
      ..hungerLevelAfter = entity.hungerLevelAfter
      ..fullnessAfterTimestamp = entity.fullnessAfterTimestamp
      ..eatingReasons = eatingReasonsList;
    return model;
  }

  /// Create from JSON (API response)
  factory MealModel.fromJson(Map<String, dynamic> json) {
    final model = MealModel()
      ..id = (json['client_id'] ?? json['id']).toString()
      ..userId = json['user_id'].toString()
      ..date = DateTime.parse(json['date'] as String)
      ..mealType = json['meal_type'] as String
      ..name = json['name'] as String
      ..protein = double.tryParse(json['protein_g']?.toString() ?? '') ?? 0.0
      ..fats = double.tryParse(json['fats_g']?.toString() ?? '') ?? 0.0
      ..netCarbs = double.tryParse(json['carbs_g']?.toString() ?? '') ?? 0.0
      ..calories = double.tryParse(json['calories']?.toString() ?? '') ?? 0.0
      ..ingredients = (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          []
      ..hungerLevelBefore = int.tryParse(json['hunger_before']?.toString() ?? '')
      ..hungerLevelAfter = int.tryParse(json['hunger_after']?.toString() ?? '')
      ..eatingReasons = (json['eating_reasons'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList()
      ..createdAt = DateTime.parse(json['created_at'] as String)
      ..updatedAt = json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null
      ..deletedAt = json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null
      ..isSynced = true;
    return model;
  }

  /// Convert to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'client_id': id, // Map id to client_id
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format for API
      'meal_type': mealType,
      'name': name,
      'protein_g': protein,
      'fats_g': fats,
      'carbs_g': netCarbs, // Map netCarbs to carbs_g for API
      'calories': calories,
      'ingredients': ingredients,
      'hunger_before': hungerLevelBefore,
      'hunger_after': hungerLevelAfter,
      'eating_reasons': eatingReasons,
      'notes': null, // Add notes field if needed
      'created_at': createdAt.toIso8601String(),
      'updated_at': (updatedAt ?? createdAt).toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
