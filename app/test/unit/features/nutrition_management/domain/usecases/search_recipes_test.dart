import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe_difficulty.dart';
import 'package:health_app/features/nutrition_management/domain/repositories/nutrition_repository.dart';
import 'package:health_app/features/nutrition_management/domain/usecases/search_recipes.dart';

// Manual mock for NutritionRepository
class MockNutritionRepository implements NutritionRepository {
  String? lastSearchQuery;
  List<Recipe>? recipesToReturn;
  Failure? failureToReturn;

  @override
  Future<Result<List<Recipe>>> searchRecipes(String query) async {
    lastSearchQuery = query;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(recipesToReturn ?? []);
  }

  @override
  Future<Result<Meal>> getMeal(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Meal>>> getMealsByUserId(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Meal>>> getMealsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Meal>>> getMealsByDate(String userId, DateTime date) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Meal>>> getMealsByMealType(
    String userId,
    DateTime date,
    String mealType,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<Meal>> saveMeal(Meal meal) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<Meal>> updateMeal(Meal meal) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteMeal(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<Recipe>> getRecipe(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Recipe>>> getAllRecipes() async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Recipe>>> getRecipesByTags(List<String> tags) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<Recipe>> saveRecipe(Recipe recipe) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<Recipe>> updateRecipe(Recipe recipe) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteRecipe(String id) async {
    throw UnimplementedError();
  }
}

void main() {
  late SearchRecipesUseCase useCase;
  late MockNutritionRepository mockRepository;

  setUp(() {
    mockRepository = MockNutritionRepository();
    useCase = SearchRecipesUseCase(mockRepository);
  });

  group('SearchRecipesUseCase', () {
    test('should search recipes successfully', () async {
      // Arrange
      final now = DateTime.now();
      final recipes = [
        Recipe(
          id: 'recipe-1',
          name: 'Chicken Salad',
          description: 'Healthy chicken salad',
          servings: 4,
          prepTime: 15,
          cookTime: 0,
          difficulty: RecipeDifficulty.easy,
          protein: 30.0,
          fats: 20.0,
          netCarbs: 10.0,
          calories: 350.0,
          ingredients: ['chicken', 'lettuce'],
          instructions: ['Mix ingredients'],
          tags: ['healthy', 'low-carb'],
          createdAt: now,
          updatedAt: now,
        ),
      ];
      mockRepository.recipesToReturn = recipes;
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call('chicken');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (foundRecipes) {
          expect(foundRecipes.length, 1);
          expect(foundRecipes[0].name, 'Chicken Salad');
        },
      );
      expect(mockRepository.lastSearchQuery, 'chicken');
    });

    test('should return ValidationFailure when query is empty', () async {
      // Act
      final result = await useCase.call('   ');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('cannot be empty'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should propagate DatabaseFailure from repository', () async {
      // Arrange
      mockRepository.failureToReturn = DatabaseFailure('Database error');

      // Act
      final result = await useCase.call('chicken');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Database error');
        },
        (_) => fail('Should return DatabaseFailure'),
      );
    });

    group('searchLocal', () {
      test('should search recipes by name', () {
        // Arrange
        final now = DateTime.now();
        final recipes = [
          Recipe(
            id: 'recipe-1',
            name: 'Chicken Salad',
            description: 'Healthy salad',
            servings: 4,
            prepTime: 15,
            cookTime: 0,
            difficulty: RecipeDifficulty.easy,
            protein: 30.0,
            fats: 20.0,
            netCarbs: 10.0,
            calories: 350.0,
            ingredients: ['chicken'],
            instructions: ['Mix'],
            tags: [],
            createdAt: now,
            updatedAt: now,
          ),
          Recipe(
            id: 'recipe-2',
            name: 'Beef Steak',
            description: 'Grilled steak',
            servings: 2,
            prepTime: 10,
            cookTime: 20,
            difficulty: RecipeDifficulty.medium,
            protein: 50.0,
            fats: 40.0,
            netCarbs: 5.0,
            calories: 600.0,
            ingredients: ['beef'],
            instructions: ['Grill'],
            tags: [],
            createdAt: now,
            updatedAt: now,
          ),
        ];

        // Act
        final result = useCase.searchLocal(recipes, 'chicken');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (foundRecipes) {
            expect(foundRecipes.length, 1);
            expect(foundRecipes[0].name, 'Chicken Salad');
          },
        );
      });

      test('should search recipes by description', () {
        // Arrange
        final now = DateTime.now();
        final recipes = [
          Recipe(
            id: 'recipe-1',
            name: 'Salad',
            description: 'Healthy chicken salad',
            servings: 4,
            prepTime: 15,
            cookTime: 0,
            difficulty: RecipeDifficulty.easy,
            protein: 30.0,
            fats: 20.0,
            netCarbs: 10.0,
            calories: 350.0,
            ingredients: ['chicken'],
            instructions: ['Mix'],
            tags: [],
            createdAt: now,
            updatedAt: now,
          ),
        ];

        // Act
        final result = useCase.searchLocal(recipes, 'healthy');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (foundRecipes) {
            expect(foundRecipes.length, 1);
            expect(foundRecipes[0].name, 'Salad');
          },
        );
      });

      test('should search recipes by ingredients', () {
        // Arrange
        final now = DateTime.now();
        final recipes = [
          Recipe(
            id: 'recipe-1',
            name: 'Salad',
            description: 'Healthy salad',
            servings: 4,
            prepTime: 15,
            cookTime: 0,
            difficulty: RecipeDifficulty.easy,
            protein: 30.0,
            fats: 20.0,
            netCarbs: 10.0,
            calories: 350.0,
            ingredients: ['chicken', 'lettuce', 'tomato'],
            instructions: ['Mix'],
            tags: [],
            createdAt: now,
            updatedAt: now,
          ),
        ];

        // Act
        final result = useCase.searchLocal(recipes, 'lettuce');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (foundRecipes) {
            expect(foundRecipes.length, 1);
            expect(foundRecipes[0].name, 'Salad');
          },
        );
      });

      test('should search recipes by tags', () {
        // Arrange
        final now = DateTime.now();
        final recipes = [
          Recipe(
            id: 'recipe-1',
            name: 'Salad',
            description: 'Healthy salad',
            servings: 4,
            prepTime: 15,
            cookTime: 0,
            difficulty: RecipeDifficulty.easy,
            protein: 30.0,
            fats: 20.0,
            netCarbs: 10.0,
            calories: 350.0,
            ingredients: ['chicken'],
            instructions: ['Mix'],
            tags: ['low-carb', 'healthy'],
            createdAt: now,
            updatedAt: now,
          ),
        ];

        // Act
        final result = useCase.searchLocal(recipes, 'low-carb');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (foundRecipes) {
            expect(foundRecipes.length, 1);
            expect(foundRecipes[0].name, 'Salad');
          },
        );
      });

      test('should perform case-insensitive search', () {
        // Arrange
        final now = DateTime.now();
        final recipes = [
          Recipe(
            id: 'recipe-1',
            name: 'Chicken Salad',
            description: 'Healthy salad',
            servings: 4,
            prepTime: 15,
            cookTime: 0,
            difficulty: RecipeDifficulty.easy,
            protein: 30.0,
            fats: 20.0,
            netCarbs: 10.0,
            calories: 350.0,
            ingredients: ['chicken'],
            instructions: ['Mix'],
            tags: [],
            createdAt: now,
            updatedAt: now,
          ),
        ];

        // Act
        final result = useCase.searchLocal(recipes, 'CHICKEN');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (foundRecipes) {
            expect(foundRecipes.length, 1);
          },
        );
      });

      test('should return empty list when no matches', () {
        // Arrange
        final now = DateTime.now();
        final recipes = [
          Recipe(
            id: 'recipe-1',
            name: 'Chicken Salad',
            description: 'Healthy salad',
            servings: 4,
            prepTime: 15,
            cookTime: 0,
            difficulty: RecipeDifficulty.easy,
            protein: 30.0,
            fats: 20.0,
            netCarbs: 10.0,
            calories: 350.0,
            ingredients: ['chicken'],
            instructions: ['Mix'],
            tags: [],
            createdAt: now,
            updatedAt: now,
          ),
        ];

        // Act
        final result = useCase.searchLocal(recipes, 'beef');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (foundRecipes) {
            expect(foundRecipes.isEmpty, true);
          },
        );
      });

      test('should return empty list when recipes list is empty', () {
        // Arrange
        final recipes = <Recipe>[];

        // Act
        final result = useCase.searchLocal(recipes, 'chicken');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (foundRecipes) {
            expect(foundRecipes.isEmpty, true);
          },
        );
      });

      test('should return ValidationFailure when query is empty', () {
        // Arrange
        final now = DateTime.now();
        final recipes = [
          Recipe(
            id: 'recipe-1',
            name: 'Chicken Salad',
            description: 'Healthy salad',
            servings: 4,
            prepTime: 15,
            cookTime: 0,
            difficulty: RecipeDifficulty.easy,
            protein: 30.0,
            fats: 20.0,
            netCarbs: 10.0,
            calories: 350.0,
            ingredients: ['chicken'],
            instructions: ['Mix'],
            tags: [],
            createdAt: now,
            updatedAt: now,
          ),
        ];

        // Act
        final result = useCase.searchLocal(recipes, '   ');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('cannot be empty'));
          },
          (_) => fail('Should return ValidationFailure'),
        );
      });
    });
  });
}

