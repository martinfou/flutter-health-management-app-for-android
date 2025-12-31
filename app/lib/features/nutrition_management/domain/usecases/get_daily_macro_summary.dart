import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal.dart';
import 'package:health_app/features/nutrition_management/domain/usecases/calculate_macros.dart';

/// Use case for getting daily macro summary
/// 
/// Filters meals for a specific date and calculates macro totals
/// and percentages using CalculateMacrosUseCase.
class GetDailyMacroSummaryUseCase {
  /// Calculate macros use case
  final CalculateMacrosUseCase calculateMacrosUseCase;

  /// Creates a GetDailyMacroSummaryUseCase
  GetDailyMacroSummaryUseCase(this.calculateMacrosUseCase);

  /// Execute the use case
  /// 
  /// Filters meals for the specified date and calculates macro summary.
  /// 
  /// Returns [ValidationFailure] if input is invalid.
  /// Returns [Right] with MacroSummary for the date.
  Result<MacroSummary> call(List<Meal> meals, DateTime date) {
    // Validate input
    if (meals.isEmpty) {
      return Left(ValidationFailure('Meals list cannot be empty'));
    }

    // Filter meals for the specified date
    final dateOnly = DateTime(date.year, date.month, date.day);
    final dayMeals = meals.where((meal) {
      final mealDate = DateTime(meal.date.year, meal.date.month, meal.date.day);
      return mealDate.isAtSameMomentAs(dateOnly);
    }).toList();

    if (dayMeals.isEmpty) {
      // Return empty summary if no meals for the day
      return Right(MacroSummary(
        protein: 0.0,
        fats: 0.0,
        netCarbs: 0.0,
        calories: 0.0,
        proteinPercent: 0.0,
        fatsPercent: 0.0,
        carbsPercent: 0.0,
      ));
    }

    // Use CalculateMacrosUseCase to calculate summary
    return calculateMacrosUseCase.call(dayMeals);
  }
}

