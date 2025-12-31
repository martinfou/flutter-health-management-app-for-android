import 'package:hive/hive.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe_difficulty.dart';

part 'recipe_model.g.dart';

/// Recipe Hive data model
/// 
/// Hive adapter for Recipe entity.
/// Uses typeId 6 as specified in database schema.
@HiveType(typeId: 6)
class RecipeModel extends HiveObject {
  /// Unique identifier (UUID)
  @HiveField(0)
  late String id;

  /// Recipe name
  @HiveField(1)
  late String name;

  /// Optional description
  @HiveField(2)
  String? description;

  /// Number of servings
  @HiveField(3)
  late int servings;

  /// Prep time in minutes
  @HiveField(4)
  late int prepTime;

  /// Cook time in minutes
  @HiveField(5)
  late int cookTime;

  /// Difficulty as string ('easy', 'medium', 'hard')
  @HiveField(6)
  late String difficulty;

  /// Protein per serving in grams
  @HiveField(7)
  late double protein;

  /// Fats per serving in grams
  @HiveField(8)
  late double fats;

  /// Net carbs per serving in grams
  @HiveField(9)
  late double netCarbs;

  /// Calories per serving
  @HiveField(10)
  late double calories;

  /// List of ingredients
  @HiveField(11)
  late List<String> ingredients;

  /// List of cooking instructions
  @HiveField(12)
  late List<String> instructions;

  /// List of tags
  @HiveField(13)
  late List<String> tags;

  /// Optional image URL
  @HiveField(14)
  String? imageUrl;

  /// Creation timestamp
  @HiveField(15)
  late DateTime createdAt;

  /// Last update timestamp
  @HiveField(16)
  late DateTime updatedAt;

  /// Default constructor for Hive
  RecipeModel();

  /// Convert to domain entity
  Recipe toEntity() {
    return Recipe(
      id: id,
      name: name,
      description: description,
      servings: servings,
      prepTime: prepTime,
      cookTime: cookTime,
      difficulty: RecipeDifficulty.values.firstWhere(
        (d) => d.name == difficulty,
        orElse: () => RecipeDifficulty.easy,
      ),
      protein: protein,
      fats: fats,
      netCarbs: netCarbs,
      calories: calories,
      ingredients: ingredients,
      instructions: instructions,
      tags: tags,
      imageUrl: imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory RecipeModel.fromEntity(Recipe entity) {
    final model = RecipeModel()
      ..id = entity.id
      ..name = entity.name
      ..description = entity.description
      ..servings = entity.servings
      ..prepTime = entity.prepTime
      ..cookTime = entity.cookTime
      ..difficulty = entity.difficulty.name
      ..protein = entity.protein
      ..fats = entity.fats
      ..netCarbs = entity.netCarbs
      ..calories = entity.calories
      ..ingredients = entity.ingredients
      ..instructions = entity.instructions
      ..tags = entity.tags
      ..imageUrl = entity.imageUrl
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;
    return model;
  }
}

