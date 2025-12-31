import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe.dart';
import 'package:health_app/features/nutrition_management/domain/repositories/nutrition_repository.dart';
import 'package:health_app/features/nutrition_management/data/datasources/local/nutrition_local_datasource.dart';

/// Nutrition repository implementation
/// 
/// Implements the NutritionRepository interface using local data source.
class NutritionRepositoryImpl implements NutritionRepository {
  final NutritionLocalDataSource _localDataSource;

  NutritionRepositoryImpl(this._localDataSource);

  @override
  Future<MealResult> getMeal(String id) async {
    return await _localDataSource.getMeal(id);
  }

  @override
  Future<MealListResult> getMealsByUserId(String userId) async {
    return await _localDataSource.getMealsByUserId(userId);
  }

  @override
  Future<MealListResult> getMealsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Validation
    if (startDate.isAfter(endDate)) {
      return Left(
        ValidationFailure('Start date must be before or equal to end date'),
      );
    }

    return await _localDataSource.getMealsByDateRange(
      userId,
      startDate,
      endDate,
    );
  }

  @override
  Future<MealListResult> getMealsByDate(String userId, DateTime date) async {
    return await _localDataSource.getMealsByDate(userId, date);
  }

  @override
  Future<MealListResult> getMealsByMealType(
    String userId,
    DateTime date,
    String mealType,
  ) async {
    return await _localDataSource.getMealsByMealType(userId, date, mealType);
  }

  @override
  Future<MealResult> saveMeal(Meal meal) async {
    // Validation
    if (meal.name.isEmpty) {
      return Left(ValidationFailure('Meal name cannot be empty'));
    }
    if (meal.name.length > 200) {
      return Left(ValidationFailure('Meal name must be 200 characters or less'));
    }
    if (meal.protein < 0) {
      return Left(ValidationFailure('Protein cannot be negative'));
    }
    if (meal.fats < 0) {
      return Left(ValidationFailure('Fats cannot be negative'));
    }
    if (meal.netCarbs < 0) {
      return Left(ValidationFailure('Net carbs cannot be negative'));
    }
    if (meal.netCarbs >= 40) {
      return Left(
        ValidationFailure('Net carbs must be less than 40g for low-carb diet'),
      );
    }
    if (meal.calories < 0) {
      return Left(ValidationFailure('Calories cannot be negative'));
    }
    if (meal.date.isAfter(DateTime.now())) {
      return Left(ValidationFailure('Date cannot be in the future'));
    }

    return await _localDataSource.saveMeal(meal);
  }

  @override
  Future<MealResult> updateMeal(Meal meal) async {
    // Validation (same as save)
    if (meal.name.isEmpty) {
      return Left(ValidationFailure('Meal name cannot be empty'));
    }

    return await _localDataSource.updateMeal(meal);
  }

  @override
  Future<Result<void>> deleteMeal(String id) async {
    return await _localDataSource.deleteMeal(id);
  }

  @override
  Future<RecipeResult> getRecipe(String id) async {
    return await _localDataSource.getRecipe(id);
  }

  @override
  Future<RecipeListResult> getAllRecipes() async {
    return await _localDataSource.getAllRecipes();
  }

  @override
  Future<RecipeListResult> searchRecipes(String query) async {
    if (query.isEmpty) {
      return Left(ValidationFailure('Search query cannot be empty'));
    }

    return await _localDataSource.searchRecipes(query);
  }

  @override
  Future<RecipeListResult> getRecipesByTags(List<String> tags) async {
    if (tags.isEmpty) {
      return Left(ValidationFailure('Tags list cannot be empty'));
    }

    return await _localDataSource.getRecipesByTags(tags);
  }

  @override
  Future<RecipeResult> saveRecipe(Recipe recipe) async {
    // Validation
    if (recipe.name.isEmpty) {
      return Left(ValidationFailure('Recipe name cannot be empty'));
    }
    if (recipe.servings <= 0) {
      return Left(ValidationFailure('Servings must be greater than 0'));
    }
    if (recipe.prepTime < 0) {
      return Left(ValidationFailure('Prep time cannot be negative'));
    }
    if (recipe.cookTime < 0) {
      return Left(ValidationFailure('Cook time cannot be negative'));
    }
    if (recipe.ingredients.isEmpty) {
      return Left(ValidationFailure('Recipe must have at least one ingredient'));
    }
    if (recipe.instructions.isEmpty) {
      return Left(ValidationFailure('Recipe must have at least one instruction'));
    }

    return await _localDataSource.saveRecipe(recipe);
  }

  @override
  Future<RecipeResult> updateRecipe(Recipe recipe) async {
    // Validation (same as save)
    if (recipe.name.isEmpty) {
      return Left(ValidationFailure('Recipe name cannot be empty'));
    }

    return await _localDataSource.updateRecipe(recipe);
  }

  @override
  Future<Result<void>> deleteRecipe(String id) async {
    return await _localDataSource.deleteRecipe(id);
  }
}

