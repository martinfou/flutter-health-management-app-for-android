import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/nutrition_management/data/repositories/nutrition_repository_impl.dart';
import 'package:health_app/features/nutrition_management/data/datasources/local/nutrition_local_datasource.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal_type.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe_difficulty.dart';

// Mock data source
class MockNutritionLocalDataSource implements NutritionLocalDataSource {
  Meal? mealToReturn;
  List<Meal>? mealsToReturn;
  Recipe? recipeToReturn;
  List<Recipe>? recipesToReturn;
  Failure? failureToReturn;
  Meal? savedMeal;
  Recipe? savedRecipe;
  String? deletedId;

  @override
  Future<Either<Failure, Meal>> getMeal(String id) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    if (mealToReturn == null) {
      return Left(NotFoundFailure('Meal'));
    }
    return Right(mealToReturn!);
  }

  @override
  Future<Either<Failure, List<Meal>>> getMealsByUserId(String userId) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(mealsToReturn ?? []);
  }

  @override
  Future<Either<Failure, List<Meal>>> getMealsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(mealsToReturn ?? []);
  }

  @override
  Future<Either<Failure, List<Meal>>> getMealsByDate(
    String userId,
    DateTime date,
  ) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(mealsToReturn ?? []);
  }

  @override
  Future<Either<Failure, List<Meal>>> getMealsByMealType(
    String userId,
    DateTime date,
    String mealType,
  ) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(mealsToReturn ?? []);
  }

  @override
  Future<Either<Failure, Meal>> saveMeal(Meal meal) async {
    savedMeal = meal;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(meal);
  }

  @override
  Future<Either<Failure, Meal>> updateMeal(Meal meal) async {
    savedMeal = meal;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(meal);
  }

  @override
  Future<Either<Failure, void>> deleteMeal(String id) async {
    deletedId = id;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, Recipe>> getRecipe(String id) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    if (recipeToReturn == null) {
      return Left(NotFoundFailure('Recipe'));
    }
    return Right(recipeToReturn!);
  }

  @override
  Future<Either<Failure, List<Recipe>>> getAllRecipes() async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(recipesToReturn ?? []);
  }

  @override
  Future<Either<Failure, List<Recipe>>> searchRecipes(String query) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(recipesToReturn ?? []);
  }

  @override
  Future<Either<Failure, List<Recipe>>> getRecipesByTags(
    List<String> tags,
  ) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(recipesToReturn ?? []);
  }

  @override
  Future<Either<Failure, Recipe>> saveRecipe(Recipe recipe) async {
    savedRecipe = recipe;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(recipe);
  }

  @override
  Future<Either<Failure, Recipe>> updateRecipe(Recipe recipe) async {
    savedRecipe = recipe;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(recipe);
  }

  @override
  Future<Either<Failure, void>> deleteRecipe(String id) async {
    deletedId = id;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return const Right(null);
  }
}

void main() {
  late NutritionRepositoryImpl repository;
  late MockNutritionLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockNutritionLocalDataSource();
    repository = NutritionRepositoryImpl(mockDataSource);
  });

  group('getMealsByDateRange', () {
    test('should return validation failure when start date is after end date',
        () async {
      // Arrange
      final startDate = DateTime(2024, 1, 15);
      final endDate = DateTime(2024, 1, 10);

      // Act
      final result = await repository.getMealsByDateRange(
        'user-1',
        startDate,
        endDate,
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            contains('Start date must be before or equal to end date'),
          );
        },
        (_) => fail('Should fail'),
      );
    });
  });

  group('saveMeal', () {
    test('should return validation failure when meal name is empty', () async {
      // Arrange
      final meal = Meal(
        id: 'test-id',
        userId: 'user-1',
        date: DateTime.now(),
        mealType: MealType.breakfast,
        name: '', // Empty name
        protein: 30.0,
        fats: 25.0,
        netCarbs: 5.0,
        calories: 305.0,
        ingredients: [],
        createdAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveMeal(meal);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Meal name cannot be empty'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return validation failure when net carbs >= 40g', () async {
      // Arrange
      final meal = Meal(
        id: 'test-id',
        userId: 'user-1',
        date: DateTime.now(),
        mealType: MealType.breakfast,
        name: 'Test Meal',
        protein: 30.0,
        fats: 25.0,
        netCarbs: 40.0, // >= 40g
        calories: 305.0,
        ingredients: [],
        createdAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveMeal(meal);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Net carbs must be less than 40g'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return validation failure when date is in future', () async {
      // Arrange
      final meal = Meal(
        id: 'test-id',
        userId: 'user-1',
        date: DateTime.now().add(Duration(days: 1)),
        mealType: MealType.breakfast,
        name: 'Test Meal',
        protein: 30.0,
        fats: 25.0,
        netCarbs: 5.0,
        calories: 305.0,
        ingredients: [],
        createdAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveMeal(meal);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Date cannot be in the future'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should save valid meal', () async {
      // Arrange
      final meal = Meal(
        id: 'test-id',
        userId: 'user-1',
        date: DateTime.now(),
        mealType: MealType.breakfast,
        name: 'Test Meal',
        protein: 30.0,
        fats: 25.0,
        netCarbs: 5.0,
        calories: 305.0,
        ingredients: [],
        createdAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveMeal(meal);

      // Assert
      expect(result.isRight(), isTrue);
      expect(mockDataSource.savedMeal, isNotNull);
      expect(mockDataSource.savedMeal!.id, 'test-id');
    });
  });

  group('searchRecipes', () {
    test('should return validation failure when query is empty', () async {
      // Act
      final result = await repository.searchRecipes('');

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Search query cannot be empty'));
        },
        (_) => fail('Should fail'),
      );
    });
  });

  group('getRecipesByTags', () {
    test('should return validation failure when tags list is empty', () async {
      // Act
      final result = await repository.getRecipesByTags([]);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Tags list cannot be empty'));
        },
        (_) => fail('Should fail'),
      );
    });
  });

  group('saveRecipe', () {
    test('should return validation failure when recipe name is empty',
        () async {
      // Arrange
      final recipe = Recipe(
        id: 'test-id',
        name: '', // Empty name
        servings: 4,
        prepTime: 10,
        cookTime: 20,
        difficulty: RecipeDifficulty.easy,
        protein: 30.0,
        fats: 25.0,
        netCarbs: 5.0,
        calories: 305.0,
        ingredients: ['ingredient1'],
        instructions: ['instruction1'],
        tags: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveRecipe(recipe);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Recipe name cannot be empty'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return validation failure when servings <= 0', () async {
      // Arrange
      final recipe = Recipe(
        id: 'test-id',
        name: 'Test Recipe',
        servings: 0, // <= 0
        prepTime: 10,
        cookTime: 20,
        difficulty: RecipeDifficulty.easy,
        protein: 30.0,
        fats: 25.0,
        netCarbs: 5.0,
        calories: 305.0,
        ingredients: ['ingredient1'],
        instructions: ['instruction1'],
        tags: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveRecipe(recipe);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Servings must be greater than 0'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return validation failure when ingredients list is empty',
        () async {
      // Arrange
      final recipe = Recipe(
        id: 'test-id',
        name: 'Test Recipe',
        servings: 4,
        prepTime: 10,
        cookTime: 20,
        difficulty: RecipeDifficulty.easy,
        protein: 30.0,
        fats: 25.0,
        netCarbs: 5.0,
        calories: 305.0,
        ingredients: [], // Empty
        instructions: ['instruction1'],
        tags: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveRecipe(recipe);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            contains('Recipe must have at least one ingredient'),
          );
        },
        (_) => fail('Should fail'),
      );
    });

    test('should save valid recipe', () async {
      // Arrange
      final recipe = Recipe(
        id: 'test-id',
        name: 'Test Recipe',
        servings: 4,
        prepTime: 10,
        cookTime: 20,
        difficulty: RecipeDifficulty.easy,
        protein: 30.0,
        fats: 25.0,
        netCarbs: 5.0,
        calories: 305.0,
        ingredients: ['ingredient1'],
        instructions: ['instruction1'],
        tags: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.saveRecipe(recipe);

      // Assert
      expect(result.isRight(), isTrue);
      expect(mockDataSource.savedRecipe, isNotNull);
      expect(mockDataSource.savedRecipe!.id, 'test-id');
    });
  });
}

