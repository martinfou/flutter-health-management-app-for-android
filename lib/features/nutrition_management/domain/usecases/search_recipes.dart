import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe.dart';
import 'package:health_app/features/nutrition_management/domain/repositories/nutrition_repository.dart';

/// Use case for searching recipes
/// 
/// Searches recipes by name, description, or ingredients.
/// Performs case-insensitive search across multiple fields.
class SearchRecipesUseCase {
  /// Nutrition repository
  final NutritionRepository repository;

  /// Creates a SearchRecipesUseCase
  SearchRecipesUseCase(this.repository);

  /// Execute the use case
  /// 
  /// Searches recipes using the repository's search method.
  /// The repository handles the actual search logic.
  /// 
  /// Returns [ValidationFailure] if query is invalid.
  /// Returns [Right] with list of matching recipes.
  Future<Result<List<Recipe>>> call(String query) async {
    // Validate query
    if (query.trim().isEmpty) {
      return Left(ValidationFailure('Search query cannot be empty'));
    }

    // Search using repository
    return await repository.searchRecipes(query);
  }

  /// Search recipes locally (alternative implementation)
  /// 
  /// This method can be used if you have all recipes in memory
  /// and want to perform local search without repository call.
  /// 
  /// Returns [ValidationFailure] if query is invalid.
  /// Returns [Right] with list of matching recipes.
  Result<List<Recipe>> searchLocal(List<Recipe> recipes, String query) {
    // Validate query
    if (query.trim().isEmpty) {
      return Left(ValidationFailure('Search query cannot be empty'));
    }

    if (recipes.isEmpty) {
      return Right([]);
    }

    // Normalize query for case-insensitive search
    final normalizedQuery = query.toLowerCase().trim();

    // Filter recipes that match query in name, description, ingredients, or tags
    final matchingRecipes = recipes.where((recipe) {
      // Search in name
      if (recipe.name.toLowerCase().contains(normalizedQuery)) {
        return true;
      }

      // Search in description
      if (recipe.description != null &&
          recipe.description!.toLowerCase().contains(normalizedQuery)) {
        return true;
      }

      // Search in ingredients
      final matchingIngredient = recipe.ingredients.any(
        (ingredient) => ingredient.toLowerCase().contains(normalizedQuery),
      );
      if (matchingIngredient) {
        return true;
      }

      // Search in tags
      final matchingTag = recipe.tags.any(
        (tag) => tag.toLowerCase().contains(normalizedQuery),
      );
      if (matchingTag) {
        return true;
      }

      return false;
    }).toList();

    return Right(matchingRecipes);
  }
}

