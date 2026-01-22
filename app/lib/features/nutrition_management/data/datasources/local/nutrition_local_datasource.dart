import 'package:hive_flutter/hive_flutter.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/providers/database_provider.dart';
import 'package:health_app/features/nutrition_management/data/models/meal_model.dart';
import 'package:health_app/features/nutrition_management/data/models/recipe_model.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe.dart';

/// Local data source for Meal and Recipe
///
/// Handles direct Hive database operations for meals and recipes.
class NutritionLocalDataSource {
  /// Get Hive box for meals
  Box<MealModel> get _mealsBox {
    if (!Hive.isBoxOpen(HiveBoxNames.meals)) {
      throw DatabaseFailure('Meals box is not open');
    }
    return Hive.box<MealModel>(HiveBoxNames.meals);
  }

  /// Get Hive box for recipes
  Box<RecipeModel> get _recipesBox {
    if (!Hive.isBoxOpen(HiveBoxNames.recipes)) {
      throw DatabaseFailure('Recipes box is not open');
    }
    return Hive.box<RecipeModel>(HiveBoxNames.recipes);
  }

  /// Get meal by ID
  Future<Result<Meal>> getMeal(String id) async {
    try {
      final box = _mealsBox;
      final model = box.get(id);

      if (model == null) {
        return Left(NotFoundFailure('Meal'));
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get meal: $e'));
    }
  }

  /// Get all meals for a user
  Future<Result<List<Meal>>> getMealsByUserId(String userId) async {
    try {
      final box = _mealsBox;
      final models = box.values
          .where((model) => model.userId == userId)
          .map((model) => model.toEntity())
          .toList();

      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get meals: $e'));
    }
  }

  /// Migrate meals to correct user ID (for meals created before authentication)
  Future<Result<void>> migrateMealsToUserId(String newUserId) async {
    try {
      final box = _mealsBox;
      final mealsToMigrate =
          box.values.where((model) => model.userId != newUserId).toList();

      if (mealsToMigrate.isEmpty) {
        return const Right(null);
      }

      for (final meal in mealsToMigrate) {
        meal.userId = newUserId;
        await meal.save();
      }

      print('Migrated ${mealsToMigrate.length} meals to userId: $newUserId');
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to migrate meals: $e'));
    }
  }

  /// Get meals for a date range
  Future<Result<List<Meal>>> getMealsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final box = _mealsBox;
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end =
          DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

      final models = box.values
          .where((model) {
            if (model.userId != userId) return false;
            final modelDate = DateTime(
              model.date.year,
              model.date.month,
              model.date.day,
            );
            return modelDate.isAfter(start.subtract(const Duration(days: 1))) &&
                modelDate.isBefore(end.add(const Duration(days: 1)));
          })
          .map((model) => model.toEntity())
          .toList();

      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get meals by date range: $e'));
    }
  }

  /// Get meals for a specific date
  Future<Result<List<Meal>>> getMealsByDate(
    String userId,
    DateTime date,
  ) async {
    try {
      final box = _mealsBox;
      final targetDate = DateTime(date.year, date.month, date.day);

      final models = box.values
          .where((model) {
            if (model.userId != userId) return false;
            final modelDate = DateTime(
              model.date.year,
              model.date.month,
              model.date.day,
            );
            return modelDate == targetDate;
          })
          .map((model) => model.toEntity())
          .toList();

      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get meals by date: $e'));
    }
  }

  /// Get meals by meal type for a date
  Future<Result<List<Meal>>> getMealsByMealType(
    String userId,
    DateTime date,
    String mealType,
  ) async {
    try {
      final box = _mealsBox;
      final targetDate = DateTime(date.year, date.month, date.day);

      final models = box.values
          .where((model) {
            if (model.userId != userId) return false;
            if (model.mealType != mealType) return false;
            final modelDate = DateTime(
              model.date.year,
              model.date.month,
              model.date.day,
            );
            return modelDate == targetDate;
          })
          .map((model) => model.toEntity())
          .toList();

      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get meals by meal type: $e'));
    }
  }

  /// Save meal
  Future<Result<Meal>> saveMeal(Meal meal) async {
    try {
      final box = _mealsBox;
      final model = MealModel.fromEntity(meal);
      await box.put(meal.id, model);
      return Right(meal);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save meal: $e'));
    }
  }

  /// Update meal
  Future<Result<Meal>> updateMeal(Meal meal) async {
    try {
      final box = _mealsBox;
      final existing = box.get(meal.id);

      if (existing == null) {
        return Left(NotFoundFailure('Meal'));
      }

      final model = MealModel.fromEntity(meal);
      await box.put(meal.id, model);
      return Right(meal);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update meal: $e'));
    }
  }

  /// Delete meal
  Future<Result<void>> deleteMeal(String id) async {
    try {
      final box = _mealsBox;
      final model = box.get(id);

      if (model == null) {
        return Left(NotFoundFailure('Meal'));
      }

      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete meal: $e'));
    }
  }

  /// Get recipe by ID
  Future<Result<Recipe>> getRecipe(String id) async {
    try {
      final box = _recipesBox;
      final model = box.get(id);

      if (model == null) {
        return Left(NotFoundFailure('Recipe'));
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get recipe: $e'));
    }
  }

  /// Get all recipes
  Future<Result<List<Recipe>>> getAllRecipes() async {
    try {
      final box = _recipesBox;
      final models = box.values.map((model) => model.toEntity()).toList();

      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get recipes: $e'));
    }
  }

  /// Search recipes by name or description
  Future<Result<List<Recipe>>> searchRecipes(String query) async {
    try {
      final box = _recipesBox;
      final lowerQuery = query.toLowerCase();
      final models = box.values
          .where((model) {
            final nameMatch = model.name.toLowerCase().contains(lowerQuery);
            final descMatch =
                model.description?.toLowerCase().contains(lowerQuery) ?? false;
            return nameMatch || descMatch;
          })
          .map((model) => model.toEntity())
          .toList();

      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Failed to search recipes: $e'));
    }
  }

  /// Get recipes by tags
  Future<Result<List<Recipe>>> getRecipesByTags(List<String> tags) async {
    try {
      final box = _recipesBox;
      final lowerTags = tags.map((t) => t.toLowerCase()).toSet();
      final models = box.values
          .where((model) {
            final modelTags = model.tags.map((t) => t.toLowerCase()).toSet();
            return lowerTags.intersection(modelTags).isNotEmpty;
          })
          .map((model) => model.toEntity())
          .toList();

      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get recipes by tags: $e'));
    }
  }

  /// Save recipe
  Future<Result<Recipe>> saveRecipe(Recipe recipe) async {
    try {
      final box = _recipesBox;
      final model = RecipeModel.fromEntity(recipe);
      await box.put(recipe.id, model);
      return Right(recipe);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save recipe: $e'));
    }
  }

  /// Update recipe
  Future<Result<Recipe>> updateRecipe(Recipe recipe) async {
    try {
      final box = _recipesBox;
      final existing = box.get(recipe.id);

      if (existing == null) {
        return Left(NotFoundFailure('Recipe'));
      }

      final model = RecipeModel.fromEntity(recipe);
      await box.put(recipe.id, model);
      return Right(recipe);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update recipe: $e'));
    }
  }

  /// Delete recipe
  Future<Result<void>> deleteRecipe(String id) async {
    try {
      final box = _recipesBox;
      final model = box.get(id);

      if (model == null) {
        return Left(NotFoundFailure('Recipe'));
      }

      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete recipe: $e'));
    }
  }

  /// Batch save meals with conflict resolution
  ///
  /// Saves multiple meals in a single operation for better performance.
  /// Uses timestamp-based conflict resolution: only overwrites local data if
  /// incoming meal is newer (has later updatedAt).
  ///
  /// This ensures that in case of concurrent edits, the latest version wins.
  Future<Result<List<Meal>>> saveMealsBatch(
    List<Meal> meals,
  ) async {
    try {
      final box = _mealsBox;
      final modelsMap = <String, MealModel>{};
      int skippedCount = 0;

      for (final meal in meals) {
        final existing = box.get(meal.id);

        // Conflict resolution: Compare timestamps
        if (existing != null) {
          // Only overwrite if incoming meal is newer
          if (meal.updatedAt.isBefore(existing.updatedAt)) {
            // Skip this meal - local version is newer
            skippedCount++;
            continue;
          }
        }

        // Either no existing record or incoming is newer - save it
        modelsMap[meal.id] = MealModel.fromEntity(meal);
      }

      // Use batch put operation
      await box.putAll(modelsMap);

      if (skippedCount > 0) {
        print('saveMealsBatch: Skipped $skippedCount meals (local versions are newer)');
      }

      return Right(meals);
    } catch (e) {
      return Left(DatabaseFailure('Failed to batch save meals: $e'));
    }
  }
}
