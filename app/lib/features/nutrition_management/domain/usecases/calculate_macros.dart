import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/constants/health_constants.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal.dart';

/// Macro summary result
class MacroSummary {
  /// Total protein in grams
  final double protein;

  /// Total fats in grams
  final double fats;

  /// Total net carbs in grams
  final double netCarbs;

  /// Total calories
  final double calories;

  /// Protein percentage of total calories
  final double proteinPercent;

  /// Fats percentage of total calories
  final double fatsPercent;

  /// Net carbs percentage of total calories
  final double carbsPercent;

  MacroSummary({
    required this.protein,
    required this.fats,
    required this.netCarbs,
    required this.calories,
    required this.proteinPercent,
    required this.fatsPercent,
    required this.carbsPercent,
  });
}

/// Use case for calculating macro totals and percentages
/// 
/// Calculates daily macro totals from a list of meals and computes
/// percentages based on calories (protein/carbs: 4 cal/g, fats: 9 cal/g).
class CalculateMacrosUseCase {
  /// Creates a CalculateMacrosUseCase
  CalculateMacrosUseCase();

  /// Execute the use case
  /// 
  /// Sums up all macros from the provided meals and calculates
  /// percentages based on total calories.
  /// 
  /// Returns [ValidationFailure] if input is invalid.
  /// Returns [Right] with MacroSummary.
  Result<MacroSummary> call(List<Meal> meals) {
    // Validate input
    if (meals.isEmpty) {
      return Left(ValidationFailure('Meals list cannot be empty'));
    }

    // Calculate totals
    double totalProtein = 0;
    double totalFats = 0;
    double totalNetCarbs = 0;
    double totalCalories = 0;

    for (final meal in meals) {
      totalProtein += meal.protein;
      totalFats += meal.fats;
      totalNetCarbs += meal.netCarbs;
      totalCalories += meal.calories;
    }

    // Validate net carbs limit
    if (totalNetCarbs > 40.0) {
      return Left(ValidationFailure(
        'Net carbs exceed 40g limit. Current: ${totalNetCarbs.toStringAsFixed(1)}g',
      ));
    }

    // Calculate percentages by calories
    final proteinPercent = totalCalories > 0
        ? (totalProtein * HealthConstants.caloriesPerGramProtein / totalCalories) * 100
        : 0.0;

    final fatsPercent = totalCalories > 0
        ? (totalFats * HealthConstants.caloriesPerGramFat / totalCalories) * 100
        : 0.0;

    final carbsPercent = totalCalories > 0
        ? (totalNetCarbs * HealthConstants.caloriesPerGramCarbs / totalCalories) * 100
        : 0.0;

    // Round to 1 decimal place
    final roundedProtein = double.parse(totalProtein.toStringAsFixed(1));
    final roundedFats = double.parse(totalFats.toStringAsFixed(1));
    final roundedNetCarbs = double.parse(totalNetCarbs.toStringAsFixed(1));
    final roundedCalories = double.parse(totalCalories.toStringAsFixed(1));
    final roundedProteinPercent = double.parse(proteinPercent.toStringAsFixed(1));
    final roundedFatsPercent = double.parse(fatsPercent.toStringAsFixed(1));
    final roundedCarbsPercent = double.parse(carbsPercent.toStringAsFixed(1));

    return Right(MacroSummary(
      protein: roundedProtein,
      fats: roundedFats,
      netCarbs: roundedNetCarbs,
      calories: roundedCalories,
      proteinPercent: roundedProteinPercent,
      fatsPercent: roundedFatsPercent,
      carbsPercent: roundedCarbsPercent,
    ));
  }
}

