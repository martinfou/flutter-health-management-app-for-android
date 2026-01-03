import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal_type.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe_difficulty.dart';
import 'package:health_app/features/nutrition_management/domain/repositories/nutrition_repository.dart';
import 'package:health_app/features/nutrition_management/domain/usecases/calculate_macros.dart';
import 'package:health_app/features/nutrition_management/presentation/providers/nutrition_providers.dart';
import 'package:health_app/features/nutrition_management/presentation/providers/nutrition_repository_provider.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:health_app/features/user_profile/domain/entities/gender.dart';
import 'package:health_app/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';

// Mock for NutritionRepository
class MockNutritionRepository implements NutritionRepository {
  List<Meal>? mealsToReturn;
  List<Recipe>? recipesToReturn;
  Failure? failureToReturn;

  @override
  Future<MealResult> getMeal(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<MealListResult> getMealsByUserId(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<MealListResult> getMealsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<MealListResult> getMealsByDate(String userId, DateTime date) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(mealsToReturn ?? []);
  }

  @override
  Future<MealListResult> getMealsByMealType(
    String userId,
    DateTime date,
    String mealType,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<MealResult> saveMeal(Meal meal) async {
    throw UnimplementedError();
  }

  @override
  Future<MealResult> updateMeal(Meal meal) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteMeal(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<RecipeResult> getRecipe(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<RecipeListResult> getAllRecipes() async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(recipesToReturn ?? []);
  }

  @override
  Future<RecipeListResult> searchRecipes(String query) async {
    throw UnimplementedError();
  }

  @override
  Future<RecipeListResult> getRecipesByTags(List<String> tags) async {
    throw UnimplementedError();
  }

  @override
  Future<RecipeResult> saveRecipe(Recipe recipe) async {
    throw UnimplementedError();
  }

  @override
  Future<RecipeResult> updateRecipe(Recipe recipe) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteRecipe(String id) async {
    throw UnimplementedError();
  }
}

// Mock for UserProfileRepository
class MockUserProfileRepository implements UserProfileRepository {
  UserProfile? profileToReturn;
  Failure? failureToReturn;

  @override
  Future<UserProfileResult> getUserProfile(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<UserProfileResult> getCurrentUserProfile() async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    if (profileToReturn == null) {
      return Left(NotFoundFailure('UserProfile'));
    }
    return Right(profileToReturn!);
  }

  @override
  Future<UserProfileResult> saveUserProfile(UserProfile profile) async {
    throw UnimplementedError();
  }

  @override
  Future<UserProfileResult> updateUserProfile(UserProfile profile) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteUserProfile(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<bool>> userProfileExists(String id) async {
    throw UnimplementedError();
  }
}

void main() {
  late MockNutritionRepository mockNutritionRepository;
  late MockUserProfileRepository mockUserProfileRepository;
  late ProviderContainer container;

  setUp(() {
    mockNutritionRepository = MockNutritionRepository();
    mockUserProfileRepository = MockUserProfileRepository();

    container = ProviderContainer(
      overrides: [
        nutritionRepositoryProvider.overrideWithValue(mockNutritionRepository),
        userProfileRepositoryProvider.overrideWithValue(mockUserProfileRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('dailyMealsProvider', () {
    test('should return meals when user exists and has meals', () async {
      // Arrange
      final profile = UserProfile(
        id: 'user-123',
        name: 'Test User',
        email: 'test@example.com',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175.0,
        weight: 70.0,
        targetWeight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockUserProfileRepository.profileToReturn = profile;

      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day);
      final meals = [
        Meal(
          id: 'meal-1',
          userId: 'user-123',
          date: date,
          mealType: MealType.breakfast,
          name: 'Breakfast',
          protein: 20.0,
          fats: 30.0,
          netCarbs: 10.0,
          calories: 350.0,
          ingredients: ['eggs', 'bacon'],
          createdAt: now,
        ),
        Meal(
          id: 'meal-2',
          userId: 'user-123',
          date: date,
          mealType: MealType.lunch,
          name: 'Lunch',
          protein: 25.0,
          fats: 35.0,
          netCarbs: 15.0,
          calories: 450.0,
          ingredients: ['chicken', 'vegetables'],
          createdAt: now,
        ),
      ];
      mockNutritionRepository.mealsToReturn = meals;

      // Act
      final result = await container.read(dailyMealsProvider(date).future);

      // Assert
      expect(result, hasLength(2));
      expect(result[0].id, 'meal-1');
      expect(result[1].id, 'meal-2');
    });

    test('should return empty list when user not found', () async {
      // Arrange
      mockUserProfileRepository.profileToReturn = null;
      mockUserProfileRepository.failureToReturn = NotFoundFailure('UserProfile');

      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day);

      // Act
      final result = await container.read(dailyMealsProvider(date).future);

      // Assert
      expect(result, isEmpty);
    });

    test('should return empty list when repository returns failure', () async {
      // Arrange
      final profile = UserProfile(
        id: 'user-123',
        name: 'Test User',
        email: 'test@example.com',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175.0,
        weight: 70.0,
        targetWeight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockUserProfileRepository.profileToReturn = profile;
      mockNutritionRepository.failureToReturn = DatabaseFailure('Database error');

      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day);

      // Act
      final result = await container.read(dailyMealsProvider(date).future);

      // Assert
      expect(result, isEmpty);
    });

    test('should return empty list when no meals exist', () async {
      // Arrange
      final profile = UserProfile(
        id: 'user-123',
        name: 'Test User',
        email: 'test@example.com',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175.0,
        weight: 70.0,
        targetWeight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockUserProfileRepository.profileToReturn = profile;
      mockNutritionRepository.mealsToReturn = [];

      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day);

      // Act
      final result = await container.read(dailyMealsProvider(date).future);

      // Assert
      expect(result, isEmpty);
    });
  });

  group('macroSummaryProvider', () {
    test('should calculate macro summary from meals', () async {
      // Arrange
      final profile = UserProfile(
        id: 'user-123',
        name: 'Test User',
        email: 'test@example.com',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175.0,
        weight: 70.0,
        targetWeight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockUserProfileRepository.profileToReturn = profile;

      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day);
      final meals = [
        Meal(
          id: 'meal-1',
          userId: 'user-123',
          date: date,
          mealType: MealType.breakfast,
          name: 'Breakfast',
          protein: 20.0, // 80 calories
          fats: 30.0, // 270 calories
          netCarbs: 10.0, // 40 calories
          calories: 390.0, // Total
          ingredients: ['eggs', 'bacon'],
          createdAt: now,
        ),
        Meal(
          id: 'meal-2',
          userId: 'user-123',
          date: date,
          mealType: MealType.lunch,
          name: 'Lunch',
          protein: 25.0, // 100 calories
          fats: 35.0, // 315 calories
          netCarbs: 15.0, // 60 calories
          calories: 475.0, // Total
          ingredients: ['chicken', 'vegetables'],
          createdAt: now,
        ),
      ];
      mockNutritionRepository.mealsToReturn = meals;

      // Act - wait for dailyMealsProvider to complete first
      await container.read(dailyMealsProvider(date).future);
      final summary = container.read(macroSummaryProvider(date));

      // Assert
      expect(summary.protein, 45.0); // 20 + 25
      expect(summary.fats, 65.0); // 30 + 35
      expect(summary.netCarbs, 25.0); // 10 + 15
      expect(summary.calories, 865.0); // 390 + 475
      // Check percentages: protein = (180/865) * 100 ≈ 20.8%, fats = (585/865) * 100 ≈ 67.6%, carbs = (100/865) * 100 ≈ 11.6%
      expect(summary.proteinPercent, closeTo(20.8, 0.2));
      expect(summary.fatsPercent, closeTo(67.6, 0.2));
      expect(summary.carbsPercent, closeTo(11.6, 0.2));
    });

    test('should return empty summary when no meals', () async {
      // Arrange
      final profile = UserProfile(
        id: 'user-123',
        name: 'Test User',
        email: 'test@example.com',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175.0,
        weight: 70.0,
        targetWeight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockUserProfileRepository.profileToReturn = profile;
      mockNutritionRepository.mealsToReturn = [];

      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day);

      // Act - wait for dailyMealsProvider to complete first
      await container.read(dailyMealsProvider(date).future);
      final summary = container.read(macroSummaryProvider(date));

      // Assert
      expect(summary.protein, 0.0);
      expect(summary.fats, 0.0);
      expect(summary.netCarbs, 0.0);
      expect(summary.calories, 0.0);
      expect(summary.proteinPercent, 0.0);
      expect(summary.fatsPercent, 0.0);
      expect(summary.carbsPercent, 0.0);
    });
  });

  group('recipesProvider', () {
    test('should return recipes when available', () async {
      // Arrange
      final now = DateTime.now();
      final recipes = [
        Recipe(
          id: 'recipe-1',
          name: 'Grilled Chicken',
          description: 'Delicious grilled chicken',
          servings: 4,
          prepTime: 10,
          cookTime: 20,
          difficulty: RecipeDifficulty.easy,
          protein: 30.0,
          fats: 10.0,
          netCarbs: 5.0,
          calories: 200.0,
          ingredients: ['chicken', 'olive oil'],
          instructions: ['Cook chicken'],
          tags: ['high-protein', 'low-carb'],
          createdAt: now,
          updatedAt: now,
        ),
        Recipe(
          id: 'recipe-2',
          name: 'Salmon Salad',
          description: 'Fresh salmon salad',
          servings: 2,
          prepTime: 15,
          cookTime: 0,
          difficulty: RecipeDifficulty.easy,
          protein: 25.0,
          fats: 15.0,
          netCarbs: 8.0,
          calories: 250.0,
          ingredients: ['salmon', 'lettuce'],
          instructions: ['Prepare salad'],
          tags: ['fish', 'salad'],
          createdAt: now,
          updatedAt: now,
        ),
      ];
      mockNutritionRepository.recipesToReturn = recipes;

      // Act
      final result = await container.read(recipesProvider.future);

      // Assert
      expect(result, hasLength(2));
      expect(result[0].id, 'recipe-1');
      expect(result[1].id, 'recipe-2');
    });

    test('should return empty list when repository returns failure', () async {
      // Arrange
      mockNutritionRepository.failureToReturn = DatabaseFailure('Database error');

      // Act
      final result = await container.read(recipesProvider.future);

      // Assert
      expect(result, isEmpty);
    });

    test('should return empty list when no recipes exist', () async {
      // Arrange
      mockNutritionRepository.recipesToReturn = [];

      // Act
      final result = await container.read(recipesProvider.future);

      // Assert
      expect(result, isEmpty);
    });
  });

  group('calculateMacrosUseCaseProvider', () {
    test('should provide CalculateMacrosUseCase instance', () {
      // Act
      final useCase = container.read(calculateMacrosUseCaseProvider);

      // Assert
      expect(useCase, isNotNull);
      expect(useCase, isA<CalculateMacrosUseCase>());
    });
  });
}

