import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:health_app/core/providers/database_initializer.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal_type.dart';
import 'package:health_app/features/nutrition_management/domain/repositories/nutrition_repository.dart';
import 'package:health_app/features/nutrition_management/data/repositories/nutrition_repository_impl.dart';
import 'package:health_app/features/nutrition_management/data/datasources/local/nutrition_local_datasource.dart';
import 'package:health_app/features/nutrition_management/domain/usecases/log_meal.dart';
import 'package:health_app/features/nutrition_management/domain/usecases/calculate_macros.dart';
import 'package:health_app/features/nutrition_management/domain/usecases/search_recipes.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe.dart';

/// Integration test for nutrition logging flow
/// 
/// Tests the complete workflow:
/// 1. Log a meal
/// 2. View macros summary
/// 3. Search recipes
void main() {
  group('Nutrition Logging Flow Integration Test', () {
    late NutritionRepository repository;

    setUpAll(() async {
      // Initialize Hive for testing
      try {
        await DatabaseInitializer.initialize();
      } catch (e) {
        // If initialization fails, skip database-dependent tests
      }
    });

    setUp(() {
      final dataSource = NutritionLocalDataSource();
      repository = NutritionRepositoryImpl(dataSource);
    });

    test('should log meal and retrieve it', () async {
      // Arrange
      const userId = 'test-user-id';
      final testDate = DateTime.now();
      const protein = 30.0;
      const fats = 40.0;
      const netCarbs = 20.0;
      final calories = (protein * 4) + (fats * 9) + (netCarbs * 4); // 560

      final meal = Meal(
        id: 'test-meal-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        date: testDate,
        mealType: MealType.breakfast,
        name: 'Test Breakfast',
        protein: protein,
        fats: fats,
        netCarbs: netCarbs,
        calories: calories,
        ingredients: ['Eggs', 'Bacon', 'Toast'],
        createdAt: DateTime.now(),
      );

      // Act - Save the meal
      final saveResult = await repository.saveMeal(meal);

      // Assert - Verify save was successful
      expect(saveResult.isRight(), true);
      saveResult.fold(
        (failure) => fail('Save should succeed, but got: ${failure.message}'),
        (savedMeal) {
          expect(savedMeal.id, meal.id);
          expect(savedMeal.name, 'Test Breakfast');
          expect(savedMeal.protein, protein);
          expect(savedMeal.fats, fats);
          expect(savedMeal.netCarbs, netCarbs);
          expect(savedMeal.calories, calories);
        },
      );

      // Act - Retrieve the meal
      final getResult = await repository.getMeal(meal.id);

      // Assert - Verify retrieval was successful
      expect(getResult.isRight(), true);
      getResult.fold(
        (failure) => fail('Get should succeed, but got: ${failure.message}'),
        (retrievedMeal) {
          expect(retrievedMeal.id, meal.id);
          expect(retrievedMeal.name, 'Test Breakfast');
        },
      );
    });

    test('should use LogMealUseCase to log meal', () async {
      // Arrange
      const userId = 'test-user-id';
      const protein = 25.0;
      const fats = 30.0;
      const netCarbs = 15.0;
      final calories = (protein * 4) + (fats * 9) + (netCarbs * 4); // 490

      final useCase = LogMealUseCase(repository);

      // Act - Log meal using use case
      final result = await useCase.call(
        userId: userId,
        mealType: MealType.lunch,
        name: 'Test Lunch',
        protein: protein,
        fats: fats,
        netCarbs: netCarbs,
        calories: calories,
        ingredients: ['Chicken', 'Rice', 'Vegetables'],
      );

      // Assert - Verify save was successful
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Use case should succeed: ${failure.message}'),
        (savedMeal) {
          expect(savedMeal.name, 'Test Lunch');
          expect(savedMeal.protein, protein);
          expect(savedMeal.userId, userId);
          expect(savedMeal.id.isNotEmpty, true); // ID should be generated
        },
      );
    });

    test('should calculate macros from multiple meals', () async {
      // Arrange
      const userId = 'test-user-id';
      final testDate = DateTime.now();
      final meals = [
        Meal(
          id: 'meal-1',
          userId: userId,
          date: testDate,
          mealType: MealType.breakfast,
          name: 'Breakfast',
          protein: 20.0,
          fats: 15.0,
          netCarbs: 30.0,
          calories: 305.0,
          ingredients: [],
          createdAt: DateTime.now(),
        ),
        Meal(
          id: 'meal-2',
          userId: userId,
          date: testDate,
          mealType: MealType.lunch,
          name: 'Lunch',
          protein: 30.0,
          fats: 25.0,
          netCarbs: 40.0,
          calories: 505.0,
          ingredients: [],
          createdAt: DateTime.now(),
        ),
      ];

      // Save meals
      for (final meal in meals) {
        final result = await repository.saveMeal(meal);
        expect(result.isRight(), true, reason: 'Meal should be saved');
      }

      // Act - Calculate macros
      final useCase = CalculateMacrosUseCase();
      final result = useCase.call(meals);

      // Assert - Verify macro calculation
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Calculation should succeed: ${failure.message}'),
        (summary) {
          expect(summary.protein, 50.0);
          expect(summary.fats, 40.0);
          expect(summary.netCarbs, 70.0);
          expect(summary.calories, 810.0);
        },
      );
    });

    test('should search recipes by name', () async {
      // Arrange
      final useCase = SearchRecipesUseCase(repository);

      // Act - Search recipes
      final result = await useCase.call('chicken');

      // Assert - Verify search works (may return empty list if no recipes)
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Search should succeed: ${failure.message}'),
        (recipes) {
          // Search should succeed even if no results
          expect(recipes, isA<List<Recipe>>());
        },
      );
    });

    test('should validate meal data when logging', () async {
      // Arrange
      const userId = 'test-user-id';
      final useCase = LogMealUseCase(repository);

      // Act - Try to log meal with invalid data (empty name)
      final result = await useCase.call(
        userId: userId,
        mealType: MealType.dinner,
        name: '', // Invalid: empty name
        protein: 20.0,
        fats: 15.0,
        netCarbs: 10.0,
        calories: 215.0,
        ingredients: ['Food'],
      );

      // Assert - Verify validation failure
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, anyOf(contains('name'), contains('Name')));
        },
        (_) => fail('Should fail validation for empty name'),
      );
    });
  });
}

