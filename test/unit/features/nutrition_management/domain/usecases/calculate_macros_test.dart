import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal_type.dart';
import 'package:health_app/features/nutrition_management/domain/usecases/calculate_macros.dart';

void main() {
  late CalculateMacrosUseCase useCase;

  setUp(() {
    useCase = CalculateMacrosUseCase();
  });

  group('CalculateMacrosUseCase', () {
    test('should calculate macros correctly from meals', () {
      // Arrange
      final now = DateTime.now();
      final meals = [
        Meal(
          id: 'meal-1',
          userId: 'user-id',
          date: now,
          mealType: MealType.breakfast,
          name: 'Breakfast',
          protein: 30.0,
          fats: 20.0,
          netCarbs: 10.0,
          calories: 350.0,
          ingredients: ['eggs', 'bacon'],
          createdAt: now,
        ),
        Meal(
          id: 'meal-2',
          userId: 'user-id',
          date: now,
          mealType: MealType.lunch,
          name: 'Lunch',
          protein: 40.0,
          fats: 30.0,
          netCarbs: 15.0,
          calories: 550.0,
          ingredients: ['chicken', 'vegetables'],
          createdAt: now,
        ),
      ];

      // Act
      final result = useCase.call(meals);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (summary) {
          expect(summary.protein, 70.0);
          expect(summary.fats, 50.0);
          expect(summary.netCarbs, 25.0);
          expect(summary.calories, 900.0);
          // Protein: 70g * 4 = 280 cal / 900 = 31.1%
          expect(summary.proteinPercent, closeTo(31.1, 0.1));
          // Fats: 50g * 9 = 450 cal / 900 = 50.0%
          expect(summary.fatsPercent, closeTo(50.0, 0.1));
          // Carbs: 25g * 4 = 100 cal / 900 = 11.1%
          expect(summary.carbsPercent, closeTo(11.1, 0.1));
        },
      );
    });

    test('should return ValidationFailure when meals list is empty', () {
      // Arrange
      final meals = <Meal>[];

      // Act
      final result = useCase.call(meals);

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

    test('should return ValidationFailure when net carbs exceed 40g', () {
      // Arrange
      final now = DateTime.now();
      final meals = [
        Meal(
          id: 'meal-1',
          userId: 'user-id',
          date: now,
          mealType: MealType.breakfast,
          name: 'High Carb Meal',
          protein: 20.0,
          fats: 10.0,
          netCarbs: 45.0, // Exceeds 40g limit
          calories: 330.0,
          ingredients: ['bread', 'pasta'],
          createdAt: now,
        ),
      ];

      // Act
      final result = useCase.call(meals);

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

    test('should calculate percentages correctly with zero calories', () {
      // Arrange
      final now = DateTime.now();
      final meals = [
        Meal(
          id: 'meal-1',
          userId: 'user-id',
          date: now,
          mealType: MealType.breakfast,
          name: 'Zero Calorie Meal',
          protein: 0.0,
          fats: 0.0,
          netCarbs: 0.0,
          calories: 0.0,
          ingredients: ['water'],
          createdAt: now,
        ),
      ];

      // Act
      final result = useCase.call(meals);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (summary) {
          expect(summary.proteinPercent, 0.0);
          expect(summary.fatsPercent, 0.0);
          expect(summary.carbsPercent, 0.0);
        },
      );
    });

    test('should round values to 1 decimal place', () {
      // Arrange
      final now = DateTime.now();
      final meals = [
        Meal(
          id: 'meal-1',
          userId: 'user-id',
          date: now,
          mealType: MealType.breakfast,
          name: 'Meal',
          protein: 33.333333,
          fats: 22.222222,
          netCarbs: 11.111111,
          calories: 444.444444,
          ingredients: ['food'],
          createdAt: now,
        ),
      ];

      // Act
      final result = useCase.call(meals);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (summary) {
          // Check that values are rounded to 1 decimal place
          final proteinString = summary.protein.toString();
          final fatsString = summary.fats.toString();
          final netCarbsString = summary.netCarbs.toString();
          expect(proteinString.split('.').length, 2);
          expect(fatsString.split('.').length, 2);
          expect(netCarbsString.split('.').length, 2);
          expect(proteinString.split('.')[1].length, lessThanOrEqualTo(1));
          expect(fatsString.split('.')[1].length, lessThanOrEqualTo(1));
          expect(netCarbsString.split('.')[1].length, lessThanOrEqualTo(1));
        },
      );
    });

    test('should handle single meal correctly', () {
      // Arrange
      final now = DateTime.now();
      final meals = [
        Meal(
          id: 'meal-1',
          userId: 'user-id',
          date: now,
          mealType: MealType.dinner,
          name: 'Dinner',
          protein: 50.0,
          fats: 40.0,
          netCarbs: 20.0,
          calories: 660.0, // 50*4 + 40*9 + 20*4 = 200 + 360 + 80 = 640
          ingredients: ['steak', 'butter', 'vegetables'],
          createdAt: now,
        ),
      ];

      // Act
      final result = useCase.call(meals);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (summary) {
          expect(summary.protein, 50.0);
          expect(summary.fats, 40.0);
          expect(summary.netCarbs, 20.0);
          expect(summary.calories, 660.0);
        },
      );
    });

    test('should calculate correct percentages for target macros', () {
      // Arrange
      // Target: 35% protein, 55% fats, 10% carbs
      // For 1000 calories: 350 cal protein (87.5g), 550 cal fats (61.1g), 100 cal carbs (25g)
      final now = DateTime.now();
      final meals = [
        Meal(
          id: 'meal-1',
          userId: 'user-id',
          date: now,
          mealType: MealType.breakfast,
          name: 'Target Macros Meal',
          protein: 87.5,
          fats: 61.1,
          netCarbs: 25.0,
          calories: 1000.0,
          ingredients: ['protein', 'fats', 'carbs'],
          createdAt: now,
        ),
      ];

      // Act
      final result = useCase.call(meals);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (summary) {
          expect(summary.proteinPercent, closeTo(35.0, 0.5));
          expect(summary.fatsPercent, closeTo(55.0, 0.5));
          expect(summary.carbsPercent, closeTo(10.0, 0.5));
        },
      );
    });
  });
}

