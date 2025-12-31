import 'package:hive/hive.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal_type.dart';

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

  /// Default constructor for Hive
  MealModel();

  /// Convert to domain entity
  Meal toEntity() {
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
    );
  }

  /// Create from domain entity
  factory MealModel.fromEntity(Meal entity) {
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
      ..createdAt = entity.createdAt;
    return model;
  }
}

