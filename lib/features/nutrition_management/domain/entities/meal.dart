import 'package:health_app/features/nutrition_management/domain/entities/meal_type.dart';

/// Meal domain entity
/// 
/// Represents meal logging and nutrition tracking.
/// This is a pure Dart class with no external dependencies.
class Meal {
  /// Unique identifier (UUID)
  final String id;

  /// User ID (FK to UserProfile)
  final String userId;

  /// Date of the meal
  final DateTime date;

  /// Type of meal
  final MealType mealType;

  /// Meal name
  final String name;

  /// Protein in grams
  final double protein;

  /// Fats in grams
  final double fats;

  /// Net carbs in grams
  final double netCarbs;

  /// Total calories
  final double calories;

  /// List of ingredients
  final List<String> ingredients;

  /// Recipe ID (FK to Recipe, nullable)
  final String? recipeId;

  /// Creation timestamp
  final DateTime createdAt;

  /// Creates a Meal
  Meal({
    required this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.name,
    required this.protein,
    required this.fats,
    required this.netCarbs,
    required this.calories,
    required this.ingredients,
    this.recipeId,
    required this.createdAt,
  });

  /// Calculate macro percentages
  Map<String, double> get macroPercentages {
    if (calories == 0) {
      return {'protein': 0, 'fats': 0, 'carbs': 0};
    }
    
    final proteinCal = protein * 4;
    final fatsCal = fats * 9;
    final carbsCal = netCarbs * 4;
    
    return {
      'protein': (proteinCal / calories) * 100,
      'fats': (fatsCal / calories) * 100,
      'carbs': (carbsCal / calories) * 100,
    };
  }

  /// Create a copy with updated fields
  Meal copyWith({
    String? id,
    String? userId,
    DateTime? date,
    MealType? mealType,
    String? name,
    double? protein,
    double? fats,
    double? netCarbs,
    double? calories,
    List<String>? ingredients,
    String? recipeId,
    DateTime? createdAt,
  }) {
    return Meal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      name: name ?? this.name,
      protein: protein ?? this.protein,
      fats: fats ?? this.fats,
      netCarbs: netCarbs ?? this.netCarbs,
      calories: calories ?? this.calories,
      ingredients: ingredients ?? this.ingredients,
      recipeId: recipeId ?? this.recipeId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Meal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          date == other.date &&
          mealType == other.mealType &&
          name == other.name &&
          protein == other.protein &&
          fats == other.fats &&
          netCarbs == other.netCarbs &&
          calories == other.calories &&
          ingredients == other.ingredients &&
          recipeId == other.recipeId;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      date.hashCode ^
      mealType.hashCode ^
      name.hashCode ^
      protein.hashCode ^
      fats.hashCode ^
      netCarbs.hashCode ^
      calories.hashCode ^
      ingredients.hashCode ^
      recipeId.hashCode;

  @override
  String toString() {
    return 'Meal(id: $id, name: $name, mealType: $mealType, calories: $calories, protein: $protein, fats: $fats, netCarbs: $netCarbs)';
  }
}

