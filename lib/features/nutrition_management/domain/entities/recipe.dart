import 'package:health_app/features/nutrition_management/domain/entities/recipe_difficulty.dart';

/// Recipe domain entity
/// 
/// Represents a recipe in the recipe library (pre-populated).
/// This is a pure Dart class with no external dependencies.
class Recipe {
  /// Unique identifier (UUID)
  final String id;

  /// Recipe name
  final String name;

  /// Optional description
  final String? description;

  /// Number of servings
  final int servings;

  /// Prep time in minutes
  final int prepTime;

  /// Cook time in minutes
  final int cookTime;

  /// Difficulty level
  final RecipeDifficulty difficulty;

  /// Protein per serving in grams
  final double protein;

  /// Fats per serving in grams
  final double fats;

  /// Net carbs per serving in grams
  final double netCarbs;

  /// Calories per serving
  final double calories;

  /// List of ingredients
  final List<String> ingredients;

  /// List of cooking instructions
  final List<String> instructions;

  /// List of tags
  final List<String> tags;

  /// Optional image URL
  final String? imageUrl;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Creates a Recipe
  Recipe({
    required this.id,
    required this.name,
    this.description,
    required this.servings,
    required this.prepTime,
    required this.cookTime,
    required this.difficulty,
    required this.protein,
    required this.fats,
    required this.netCarbs,
    required this.calories,
    required this.ingredients,
    required this.instructions,
    required this.tags,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Total time (prep + cook) in minutes
  int get totalTime => prepTime + cookTime;

  /// Create a copy with updated fields
  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    int? servings,
    int? prepTime,
    int? cookTime,
    RecipeDifficulty? difficulty,
    double? protein,
    double? fats,
    double? netCarbs,
    double? calories,
    List<String>? ingredients,
    List<String>? instructions,
    List<String>? tags,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      servings: servings ?? this.servings,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      difficulty: difficulty ?? this.difficulty,
      protein: protein ?? this.protein,
      fats: fats ?? this.fats,
      netCarbs: netCarbs ?? this.netCarbs,
      calories: calories ?? this.calories,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipe &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          servings == other.servings &&
          prepTime == other.prepTime &&
          cookTime == other.cookTime &&
          difficulty == other.difficulty &&
          protein == other.protein &&
          fats == other.fats &&
          netCarbs == other.netCarbs &&
          calories == other.calories &&
          ingredients == other.ingredients &&
          instructions == other.instructions &&
          tags == other.tags &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      servings.hashCode ^
      prepTime.hashCode ^
      cookTime.hashCode ^
      difficulty.hashCode ^
      protein.hashCode ^
      fats.hashCode ^
      netCarbs.hashCode ^
      calories.hashCode ^
      ingredients.hashCode ^
      instructions.hashCode ^
      tags.hashCode ^
      imageUrl.hashCode;

  @override
  String toString() {
    return 'Recipe(id: $id, name: $name, servings: $servings, totalTime: $totalTime, difficulty: $difficulty)';
  }
}

