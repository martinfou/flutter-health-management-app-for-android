import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal_type.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe.dart';
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

    test('should return ValidationFailure when net carbs exceed 40g', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.breakfast,
        name: 'High Carb Meal',
        protein: 20.0,
        fats: 10.0,
        netCarbs: 45.0, // Exceeds 40g limit
        calories: 800.0, // Valid calories for testing net carbs validation
        ingredients: ['bread'],
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Net carbs exceed 40g limit'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when calories below minimum', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.breakfast,
        name: 'Low Calorie Meal',
        protein: 10.0,
        fats: 5.0,
        netCarbs: 5.0,
        calories: 100.0, // Below minimum
        ingredients: ['food'],
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Calories must be between'));
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return ValidationFailure when calories above maximum', () async {
      // Act
      final result = await useCase.call(
        userId: 'user-id',
        mealType: MealType.dinner,
        name: 'High Calorie Meal',
        protein: 100.0,
        fats: 200.0,
        netCarbs: 30.0,
        calories: 15000.0, // Above maximum
        ingredients: ['food'],
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Calories must be between'));
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
  });
}

