import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe.dart';

/// Type alias for repository result
typedef MealResult = Result<Meal>;
typedef MealListResult = Result<List<Meal>>;
typedef RecipeResult = Result<Recipe>;
typedef RecipeListResult = Result<List<Recipe>>;

/// Nutrition repository interface
/// 
/// Defines the contract for nutrition data operations (meals and recipes).
/// Implementation is in the data layer.
abstract class NutritionRepository {
  /// Get meal by ID
  /// 
  /// Returns [NotFoundFailure] if meal doesn't exist.
  Future<MealResult> getMeal(String id);

  /// Get all meals for a user
  Future<MealListResult> getMealsByUserId(String userId);

  /// Get meals for a date range
  Future<MealListResult> getMealsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get meals for a specific date
  Future<MealListResult> getMealsByDate(String userId, DateTime date);

  /// Get meals by meal type for a date
  Future<MealListResult> getMealsByMealType(
    String userId,
    DateTime date,
    String mealType,
  );

  /// Save meal
  /// 
  /// Creates new meal or updates existing one.
  /// Returns [ValidationFailure] if meal data is invalid.
  Future<MealResult> saveMeal(Meal meal);

  /// Update meal
  /// 
  /// Updates existing meal.
  /// Returns [NotFoundFailure] if meal doesn't exist.
  Future<MealResult> updateMeal(Meal meal);

  /// Delete meal
  /// 
  /// Returns [NotFoundFailure] if meal doesn't exist.
  Future<Result<void>> deleteMeal(String id);

  /// Get recipe by ID
  /// 
  /// Returns [NotFoundFailure] if recipe doesn't exist.
  Future<RecipeResult> getRecipe(String id);

  /// Get all recipes
  Future<RecipeListResult> getAllRecipes();

  /// Search recipes by name or description
  Future<RecipeListResult> searchRecipes(String query);

  /// Get recipes by tags
  Future<RecipeListResult> getRecipesByTags(List<String> tags);

  /// Save recipe
  /// 
  /// Creates new recipe or updates existing one.
  /// Returns [ValidationFailure] if recipe data is invalid.
  Future<RecipeResult> saveRecipe(Recipe recipe);

  /// Update recipe
  /// 
  /// Updates existing recipe.
  /// Returns [NotFoundFailure] if recipe doesn't exist.
  Future<RecipeResult> updateRecipe(Recipe recipe);

  /// Delete recipe
  /// 
  /// Returns [NotFoundFailure] if recipe doesn't exist.
  Future<Result<void>> deleteRecipe(String id);
}

