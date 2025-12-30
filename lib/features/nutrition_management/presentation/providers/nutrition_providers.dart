import 'package:riverpod/riverpod.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe.dart';
import 'package:health_app/features/nutrition_management/domain/usecases/calculate_macros.dart';
import 'package:health_app/features/nutrition_management/domain/usecases/log_meal.dart';
import 'package:health_app/features/nutrition_management/presentation/providers/nutrition_repository_provider.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';

/// Provider for CalculateMacrosUseCase
final calculateMacrosUseCaseProvider = Provider<CalculateMacrosUseCase>((ref) {
  return CalculateMacrosUseCase();
});

/// Provider for LogMealUseCase
final logMealUseCaseProvider = Provider<LogMealUseCase>((ref) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return LogMealUseCase(repository);
});

/// Provider for getting daily meals for a specific date
/// 
/// Uses family provider to accept date parameter.
/// Returns empty list if no user profile found or error occurs.
final dailyMealsProvider =
    FutureProvider.family<List<Meal>, DateTime>((ref, date) async {
  try {
    // Get user profile to get userId
    final userProfileRepo = ref.watch(userProfileRepositoryProvider);
    final userResult = await userProfileRepo.getCurrentUserProfile();

    return userResult.fold(
      (failure) {
        // Return empty list if user not found
        return <Meal>[];
      },
      (userProfile) async {
        // Get meals for the date
        final nutritionRepo = ref.watch(nutritionRepositoryProvider);
        final dateOnly = DateTime(date.year, date.month, date.day);
        final result = await nutritionRepo.getMealsByDate(
          userProfile.id,
          dateOnly,
        );

        return result.fold(
          (failure) {
            // Return empty list on error
            return <Meal>[];
          },
          (meals) => meals,
        );
      },
    );
  } catch (e) {
    // Return empty list on exception
    return <Meal>[];
  }
});

/// Provider for getting macro summary for a specific date
/// 
/// Uses family provider to accept date parameter.
/// Calculates macro summary from meals for that date.
/// Returns empty summary if no meals or error occurs.
final macroSummaryProvider = Provider.family<MacroSummary, DateTime>(
  (ref, date) {
    // Get meals for the date
    final mealsAsync = ref.watch(dailyMealsProvider(date));

    return mealsAsync.when(
      data: (meals) {
        if (meals.isEmpty) {
          // Return empty summary if no meals
          return MacroSummary(
            protein: 0.0,
            fats: 0.0,
            netCarbs: 0.0,
            calories: 0.0,
            proteinPercent: 0.0,
            fatsPercent: 0.0,
            carbsPercent: 0.0,
          );
        }

        // Use CalculateMacrosUseCase directly since GetDailyMacroSummaryUseCase
        // requires non-empty meals list (which we've already checked)
        final useCase = ref.watch(calculateMacrosUseCaseProvider);
        final result = useCase.call(meals);

        return result.fold(
          (failure) {
            // Return empty summary on error
            return MacroSummary(
              protein: 0.0,
              fats: 0.0,
              netCarbs: 0.0,
              calories: 0.0,
              proteinPercent: 0.0,
              fatsPercent: 0.0,
              carbsPercent: 0.0,
            );
          },
          (summary) => summary,
        );
      },
      loading: () {
        // Return empty summary while loading
        return MacroSummary(
          protein: 0.0,
          fats: 0.0,
          netCarbs: 0.0,
          calories: 0.0,
          proteinPercent: 0.0,
          fatsPercent: 0.0,
          carbsPercent: 0.0,
        );
      },
      error: (error, stack) {
        // Return empty summary on error
        return MacroSummary(
          protein: 0.0,
          fats: 0.0,
          netCarbs: 0.0,
          calories: 0.0,
          proteinPercent: 0.0,
          fatsPercent: 0.0,
          carbsPercent: 0.0,
        );
      },
    );
  },
);

/// Provider for getting all recipes
/// 
/// Returns all recipes from the repository.
/// Returns empty list if error occurs.
final recipesProvider = FutureProvider<List<Recipe>>((ref) async {
  try {
    final nutritionRepo = ref.watch(nutritionRepositoryProvider);
    final result = await nutritionRepo.getAllRecipes();

    return result.fold(
      (failure) {
        // Return empty list on error
        return <Recipe>[];
      },
      (recipes) => recipes,
    );
  } catch (e) {
    // Return empty list on exception
    return <Recipe>[];
  }
});

