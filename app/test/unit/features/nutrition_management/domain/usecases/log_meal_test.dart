import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal_type.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe.dart';
import 'package:health_app/features/nutrition_management/domain/entities/eating_reason.dart';
import 'package:health_app/features/nutrition_management/domain/repositories/nutrition_repository.dart';
import 'package:health_app/features/nutrition_management/domain/usecases/log_meal.dart';

// Manual mock for NutritionRepository
class MockNutritionRepository implements NutritionRepository {
  Meal? savedMeal;
  Failure? failureToReturn;

  @override
  Future<Result<Meal>> saveMeal(Meal meal) async {
    savedMeal = meal;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(meal);
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
  Future<Result<List<Recipe>>> searchRecipes(String query) async {
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
  late LogMealUseCase useCase;
  late MockNutritionRepository mockRepository;

  setUp(() {
    mockRepository = MockNutritionRepository();
    useCase = LogMealUseCase(mockRepository);
  });

  group('LogMealUseCase', () {
    test('should save meal successfully when valid', () async {
      // Arrange
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.breakfast,
        name: 'Breakfast',
        protein: 100.0, // 100*4 = 400 cal
        fats: 50.0, // 50*9 = 450 cal
        netCarbs: 10.0, // 10*4 = 40 cal
        calories: 890.0, // Total: 890 cal (matches calculated)
        ingredients: ['eggs', 'bacon'],
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (meal) {
          expect(meal.name, 'Breakfast');
          expect(meal.mealType, MealType.breakfast);
          expect(meal.protein, 100.0);
          expect(meal.fats, 50.0);
          expect(meal.netCarbs, 10.0);
          expect(meal.calories, 890.0);
          expect(meal.ingredients, ['eggs', 'bacon']);
          expect(meal.id, isNotEmpty);
        },
      );
      expect(mockRepository.savedMeal, isNotNull);
    });

    test('should generate ID when not provided', () async {
      // Arrange
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.lunch,
        name: 'Lunch',
        protein: 100.0, // 100*4 = 400
        fats: 50.0, // 50*9 = 450
        netCarbs: 15.0, // 15*4 = 60
        calories: 910.0, // Total: 910 (matches calculated)
        ingredients: ['chicken'],
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (meal) => expect(meal.id, isNotEmpty),
      );
    });

    test('should use provided date or default to now', () async {
      // Arrange
      mockRepository.failureToReturn = null;
      final customDate = DateTime(2024, 1, 15);

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.dinner,
        name: 'Dinner',
        protein: 100.0, // 100*4 = 400
        fats: 50.0, // 50*9 = 450
        netCarbs: 20.0, // 20*4 = 80
        calories: 930.0, // Total: 930 (matches calculated)
        ingredients: ['steak'],
        date: customDate,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (meal) {
          final mealDate = DateTime(meal.date.year, meal.date.month, meal.date.day);
          final expectedDate = DateTime(customDate.year, customDate.month, customDate.day);
          expect(mealDate, expectedDate);
        },
      );
    });

    test('should return ValidationFailure when name is empty', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.breakfast,
        name: '   ', // Empty after trim
        protein: 100.0, // 100*4 = 400
        fats: 50.0, // 50*9 = 450
        netCarbs: 10.0, // 10*4 = 40
        calories: 890.0, // Total: 890 (matches calculated, valid for testing name validation)
        ingredients: ['eggs'],
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('name cannot be empty'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should allow saving meal when net carbs exceed 40g (guideline, not hard limit)', () async {
      // Act
      // Calories: 20*4 + 10*9 + 45*4 = 80 + 90 + 180 = 350
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.breakfast,
        name: 'High Carb Meal',
        protein: 20.0,
        fats: 10.0,
        netCarbs: 45.0, // Exceeds 40g guideline (but should still save)
        calories: 350.0, // Matches calculated: 20*4 + 10*9 + 45*4 = 350
        ingredients: ['bread'],
      );

      // Assert - should succeed (40g is a guideline, not a hard validation)
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should allow saving meal with netCarbs > 40g: ${failure.message}'),
        (meal) {
          expect(meal.netCarbs, 45.0);
          expect(meal.name, 'High Carb Meal');
        },
      );
    });

    test('should return ValidationFailure when calories do not match macros', () async {
      // Arrange
      // Calculated calories: 10*4 + 5*9 + 5*4 = 40 + 45 + 20 = 105
      // Provided calories: 90.0 (difference is 15, exceeds tolerance of 10)
      
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.breakfast,
        name: 'Low Calorie Meal',
        protein: 10.0,
        fats: 5.0,
        netCarbs: 5.0,
        calories: 90.0, // Doesn't match calculated (105), difference 15 > tolerance 10
        ingredients: ['food'],
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Calories do not match macro calculations'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when calories do not match macros (high value)', () async {
      // Arrange
      // Calculated calories: 100*4 + 200*9 + 30*4 = 400 + 1800 + 120 = 2320
      // Provided calories: 15000.0 (doesn't match)
      
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.dinner,
        name: 'High Calorie Meal',
        protein: 100.0,
        fats: 200.0,
        netCarbs: 30.0,
        calories: 15000.0, // Doesn't match calculated (2320)
        ingredients: ['food'],
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Calories do not match macro calculations'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when protein is negative', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.breakfast,
        name: 'Meal',
        protein: -10.0, // Negative
        fats: 50.0,
        netCarbs: 10.0,
        calories: 800.0, // Valid calories range (protein validation happens after calories range check)
        ingredients: ['food'],
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Protein cannot be negative'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when ingredients list is empty', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.breakfast,
        name: 'Meal',
        protein: 30.0,
        fats: 20.0,
        netCarbs: 10.0,
        calories: 800.0, // Valid calories for testing ingredients validation
        ingredients: [], // Empty
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('must have at least one ingredient'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when calories do not match macros', () async {
      // Act
      // Macros: 30*4 + 20*9 + 10*4 = 120 + 180 + 40 = 340 calories
      // But calories is set to 800 (doesn't match, but >= 800 so range validation passes)
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.breakfast,
        name: 'Meal',
        protein: 30.0,
        fats: 20.0,
        netCarbs: 10.0,
        calories: 800.0, // Doesn't match calculated 340 (diff = 460 > 10 tolerance)
        ingredients: ['food'],
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Calories do not match macro calculations'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should accept calories within tolerance of calculated value', () async {
      // Arrange
      mockRepository.failureToReturn = null;
      // Macros: 30*4 + 20*9 + 10*4 = 120 + 180 + 40 = 340 calories
      // But we need >= 800, so let's use macros that calculate to >= 800
      // Example: 100*4 + 50*9 + 10*4 = 400 + 450 + 40 = 890 calories
      // Set to 895 (within 10 calorie tolerance)

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.breakfast,
        name: 'Meal',
        protein: 100.0,
        fats: 50.0,
        netCarbs: 10.0,
        calories: 895.0, // Within tolerance of calculated 890
        ingredients: ['food'],
      );

      // Assert
      expect(result.isRight(), true);
    });

    test('should save meal with recipe ID', () async {
      // Arrange
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.dinner,
        name: 'Recipe Meal',
        protein: 100.0, // 100*4 = 400
        fats: 50.0, // 50*9 = 450
        netCarbs: 20.0, // 20*4 = 80
        calories: 930.0, // Total: 930 (matches calculated)
        ingredients: ['ingredient1', 'ingredient2'],
        recipeId: 'recipe-123',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (meal) {
          expect(meal.recipeId, 'recipe-123');
        },
      );
    });

    test('should propagate DatabaseFailure from repository', () async {
      // Arrange
      mockRepository.failureToReturn = DatabaseFailure('Database error');

      // Act
      // Use macros that calculate to >= 800: 100*4 + 50*9 + 10*4 = 400 + 450 + 40 = 890
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.breakfast,
        name: 'Meal',
        protein: 100.0,
        fats: 50.0,
        netCarbs: 10.0,
        calories: 890.0, // Matches calculated value
        ingredients: ['food'],
      );

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

    test('should save meal with hunger levels and eating reasons', () async {
      // Arrange
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.lunch,
        name: 'Lunch with Context',
        protein: 100.0, // 100*4 = 400
        fats: 50.0, // 50*9 = 450
        netCarbs: 10.0, // 10*4 = 40
        calories: 890.0, // Total: 890 (matches calculated)
        ingredients: ['chicken', 'rice'],
        hungerLevelBefore: 3,
        hungerLevelAfter: 7,
        eatingReasons: [EatingReason.hungry, EatingReason.scheduled],
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (meal) {
          expect(meal.hungerLevelBefore, 3);
          expect(meal.hungerLevelAfter, 7);
          expect(meal.fullnessAfterTimestamp, isNotNull);
          expect(meal.eatingReasons, [EatingReason.hungry, EatingReason.scheduled]);
        },
      );
      expect(mockRepository.savedMeal?.hungerLevelBefore, 3);
      expect(mockRepository.savedMeal?.hungerLevelAfter, 7);
    });

    test('should save meal with only hunger level before', () async {
      // Arrange
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.breakfast,
        name: 'Breakfast',
        protein: 100.0,
        fats: 50.0,
        netCarbs: 10.0,
        calories: 890.0,
        ingredients: ['eggs'],
        hungerLevelBefore: 2,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (meal) {
          expect(meal.hungerLevelBefore, 2);
          expect(meal.hungerLevelAfter, isNull);
          expect(meal.fullnessAfterTimestamp, isNull);
        },
      );
    });

    test('should auto-set fullnessAfterTimestamp when hungerLevelAfter is provided', () async {
      // Arrange
      mockRepository.failureToReturn = null;
      final beforeTime = DateTime.now();

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.dinner,
        name: 'Dinner',
        protein: 100.0,
        fats: 50.0,
        netCarbs: 10.0,
        calories: 890.0,
        ingredients: ['steak'],
        hungerLevelAfter: 8,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (meal) {
          expect(meal.fullnessAfterTimestamp, isNotNull);
          expect(
            meal.fullnessAfterTimestamp!.isAfter(beforeTime) ||
            meal.fullnessAfterTimestamp!.isAtSameMomentAs(beforeTime),
            true,
          );
        },
      );
    });

    test('should return ValidationFailure when hungerLevelBefore is out of range', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.breakfast,
        name: 'Meal',
        protein: 100.0,
        fats: 50.0,
        netCarbs: 10.0,
        calories: 890.0,
        ingredients: ['food'],
        hungerLevelBefore: 11, // Out of range
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Hunger level before must be between 0 and 10'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when hungerLevelAfter is out of range', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.breakfast,
        name: 'Meal',
        protein: 100.0,
        fats: 50.0,
        netCarbs: 10.0,
        calories: 890.0,
        ingredients: ['food'],
        hungerLevelAfter: -1, // Out of range
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Hunger level after must be between 0 and 10'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should accept empty eating reasons list', () async {
      // Arrange
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.snack,
        name: 'Snack',
        protein: 100.0,
        fats: 50.0,
        netCarbs: 10.0,
        calories: 890.0,
        ingredients: ['nuts'],
        eatingReasons: [], // Empty list (explicitly no reasons)
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (meal) {
          expect(meal.eatingReasons, isEmpty);
        },
      );
    });

    test('should save meal without behavioral tracking fields (all optional)', () async {
      // Arrange
      mockRepository.failureToReturn = null;

      // Act
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.lunch,
        name: 'Simple Lunch',
        protein: 100.0,
        fats: 50.0,
        netCarbs: 10.0,
        calories: 890.0,
        ingredients: ['salad'],
        // No behavioral tracking fields
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (meal) {
          expect(meal.hungerLevelBefore, isNull);
          expect(meal.hungerLevelAfter, isNull);
          expect(meal.fullnessAfterTimestamp, isNull);
          expect(meal.eatingReasons, isNull);
        },
      );
    });
  });
}

