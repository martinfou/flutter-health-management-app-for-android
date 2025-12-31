import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/constants/health_constants.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal_type.dart';
import 'package:health_app/features/nutrition_management/domain/entities/eating_reason.dart';
import 'package:health_app/features/nutrition_management/domain/repositories/nutrition_repository.dart';

/// Use case for logging a meal
/// 
/// Validates meal data and saves it to the repository.
/// Validates net carbs limit (40g), calories range, and required fields.
class LogMealUseCase {
  /// Nutrition repository
  final NutritionRepository repository;

  /// Creates a LogMealUseCase
  LogMealUseCase(this.repository);

  /// Execute the use case
  /// 
  /// Validates the meal data and saves it. Generates an ID if not provided.
  /// 
  /// Returns [ValidationFailure] if validation fails.
  /// Returns [DatabaseFailure] if save operation fails.
  Future<Result<Meal>> call({
    required String userId,
    required MealType mealType,
    required String name,
    required double protein,
    required double fats,
    required double netCarbs,
    required double calories,
    required List<String> ingredients,
    String? recipeId,
    DateTime? date,
    String? id,
    int? hungerLevelBefore,
    int? hungerLevelAfter,
    DateTime? fullnessAfterTimestamp,
    List<EatingReason>? eatingReasons,
  }) async {
    // Generate ID if not provided
    final mealId = id ?? _generateId();
    final mealDate = date ?? DateTime.now();

    // Validate the meal
    final validationResult = _validateMeal(
      protein: protein,
      fats: fats,
      netCarbs: netCarbs,
      calories: calories,
      name: name,
      ingredients: ingredients,
      hungerLevelBefore: hungerLevelBefore,
      hungerLevelAfter: hungerLevelAfter,
      eatingReasons: eatingReasons,
    );
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Auto-set fullnessAfterTimestamp if hungerLevelAfter is provided but timestamp is not
    final finalFullnessAfterTimestamp = fullnessAfterTimestamp ??
        (hungerLevelAfter != null ? DateTime.now() : null);

    // Create meal entity
    final meal = Meal(
      id: mealId,
      userId: userId,
      date: mealDate,
      mealType: mealType,
      name: name,
      protein: protein,
      fats: fats,
      netCarbs: netCarbs,
      calories: calories,
      ingredients: ingredients,
      recipeId: recipeId,
      createdAt: DateTime.now(),
      hungerLevelBefore: hungerLevelBefore,
      hungerLevelAfter: hungerLevelAfter,
      fullnessAfterTimestamp: finalFullnessAfterTimestamp,
      eatingReasons: eatingReasons,
    );

    // Save to repository
    return await repository.saveMeal(meal);
  }

  /// Validate meal data
  ValidationFailure? _validateMeal({
    required double protein,
    required double fats,
    required double netCarbs,
    required double calories,
    required String name,
    required List<String> ingredients,
    int? hungerLevelBefore,
    int? hungerLevelAfter,
    List<EatingReason>? eatingReasons,
  }) {
    // Validate name
    if (name.trim().isEmpty) {
      return ValidationFailure('Meal name cannot be empty');
    }

    // Validate net carbs limit (40g absolute maximum)
    if (netCarbs > 40.0) {
      return ValidationFailure(
        'Net carbs exceed 40g limit. Current: ${netCarbs.toStringAsFixed(1)}g',
      );
    }

    // Validate calories are non-negative (individual meals can be any positive value)
    // Daily calorie limits should be checked at the daily summary level, not per meal
    if (calories < 0.0) {
      return ValidationFailure('Calories cannot be negative');
    }

    // Validate macros are non-negative
    if (protein < 0) {
      return ValidationFailure('Protein cannot be negative');
    }
    if (fats < 0) {
      return ValidationFailure('Fats cannot be negative');
    }
    if (netCarbs < 0) {
      return ValidationFailure('Net carbs cannot be negative');
    }

    // Validate ingredients list
    if (ingredients.isEmpty) {
      return ValidationFailure('Meal must have at least one ingredient');
    }

    // Validate that calories match macro calculations (with tolerance)
    final calculatedCalories = (protein * HealthConstants.caloriesPerGramProtein) +
        (fats * HealthConstants.caloriesPerGramFat) +
        (netCarbs * HealthConstants.caloriesPerGramCarbs);

    final tolerance = 10.0; // Allow 10 calorie tolerance for rounding
    if ((calculatedCalories - calories).abs() > tolerance) {
      return ValidationFailure(
        'Calories do not match macro calculations. Expected: ${calculatedCalories.toStringAsFixed(1)}, Got: ${calories.toStringAsFixed(1)}',
      );
    }

    // Validate hunger levels (0-10 range if provided)
    if (hungerLevelBefore != null) {
      if (hungerLevelBefore < 0 || hungerLevelBefore > 10) {
        return ValidationFailure(
          'Hunger level before must be between 0 and 10. Got: $hungerLevelBefore',
        );
      }
    }

    if (hungerLevelAfter != null) {
      if (hungerLevelAfter < 0 || hungerLevelAfter > 10) {
        return ValidationFailure(
          'Hunger level after must be between 0 and 10. Got: $hungerLevelAfter',
        );
      }
    }

    // Validate eating reasons (all must be valid enum values if provided)
    // Empty list is valid (user explicitly chose none)
    if (eatingReasons != null) {
      // All reasons should be valid enum values (empty list is OK)
      // This is automatically validated by the type system, but we can add explicit checks if needed
    }

    return null;
  }

  /// Generate a unique ID for the meal
  String _generateId() {
    final now = DateTime.now();
    return 'meal-${now.millisecondsSinceEpoch}-${now.microsecondsSinceEpoch}';
  }
}

