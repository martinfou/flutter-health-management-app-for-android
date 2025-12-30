import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal_type.dart';
import 'package:health_app/features/nutrition_management/domain/usecases/calculate_macros.dart';
import 'package:health_app/features/nutrition_management/domain/usecases/get_daily_macro_summary.dart';

void main() {
  late GetDailyMacroSummaryUseCase useCase;
  late CalculateMacrosUseCase calculateMacrosUseCase;

  setUp(() {
    calculateMacrosUseCase = CalculateMacrosUseCase();
    useCase = GetDailyMacroSummaryUseCase(calculateMacrosUseCase);
  });

  group('GetDailyMacroSummaryUseCase', () {
    test('should calculate summary for meals on specific date', () {
      // Arrange
      final targetDate = DateTime(2024, 1, 15);
      final otherDate = DateTime(2024, 1, 16);
      final meals = [
        Meal(
          id: 'meal-1',
          userId: 'user-id',
          date: targetDate,
          mealType: MealType.breakfast,
          name: 'Breakfast',
          protein: 30.0,
          fats: 20.0,
          netCarbs: 10.0,
          calories: 350.0,
          ingredients: ['eggs'],
          createdAt: targetDate,
        ),
        Meal(
          id: 'meal-2',
          userId: 'user-id',
          date: targetDate,
          mealType: MealType.lunch,
          name: 'Lunch',
          protein: 40.0,
          fats: 30.0,
          netCarbs: 15.0,
          calories: 550.0,
          ingredients: ['chicken'],
          createdAt: targetDate,
        ),
        Meal(
          id: 'meal-3',
          userId: 'user-id',
          date: otherDate, // Different date
          mealType: MealType.dinner,
          name: 'Dinner',
          protein: 50.0,
          fats: 40.0,
          netCarbs: 20.0,
          calories: 660.0,
          ingredients: ['steak'],
          createdAt: otherDate,
        ),
      ];

      // Act
      final result = useCase.call(meals, targetDate);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (summary) {
          // Should only include meals from targetDate
          expect(summary.protein, 70.0); // 30 + 40
          expect(summary.fats, 50.0); // 20 + 30
          expect(summary.netCarbs, 25.0); // 10 + 15
          expect(summary.calories, 900.0); // 350 + 550
        },
      );
    });

    test('should return empty summary when no meals for date', () {
      // Arrange
      final targetDate = DateTime(2024, 1, 15);
      final otherDate = DateTime(2024, 1, 16);
      final meals = [
        Meal(
          id: 'meal-1',
          userId: 'user-id',
          date: otherDate,
          mealType: MealType.breakfast,
          name: 'Breakfast',
          protein: 30.0,
          fats: 20.0,
          netCarbs: 10.0,
          calories: 350.0,
          ingredients: ['eggs'],
          createdAt: otherDate,
        ),
      ];

      // Act
      final result = useCase.call(meals, targetDate);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (summary) {
          expect(summary.protein, 0.0);
          expect(summary.fats, 0.0);
          expect(summary.netCarbs, 0.0);
          expect(summary.calories, 0.0);
          expect(summary.proteinPercent, 0.0);
          expect(summary.fatsPercent, 0.0);
          expect(summary.carbsPercent, 0.0);
        },
      );
    });

    test('should return ValidationFailure when meals list is empty', () {
      // Arrange
      final meals = <Meal>[];
      final date = DateTime.now();

      // Act
      final result = useCase.call(meals, date);

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

    test('should handle meals with different times on same date', () {
      // Arrange
      final targetDate = DateTime(2024, 1, 15);
      final meals = [
        Meal(
          id: 'meal-1',
          userId: 'user-id',
          date: DateTime(2024, 1, 15, 8, 0), // Morning
          mealType: MealType.breakfast,
          name: 'Breakfast',
          protein: 30.0,
          fats: 20.0,
          netCarbs: 10.0,
          calories: 350.0,
          ingredients: ['eggs'],
          createdAt: targetDate,
        ),
        Meal(
          id: 'meal-2',
          userId: 'user-id',
          date: DateTime(2024, 1, 15, 20, 0), // Evening
          mealType: MealType.dinner,
          name: 'Dinner',
          protein: 50.0,
          fats: 40.0,
          netCarbs: 20.0,
          calories: 660.0,
          ingredients: ['steak'],
          createdAt: targetDate,
        ),
      ];

      // Act
      final result = useCase.call(meals, targetDate);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (summary) {
          // Should include both meals (same date, different times)
          expect(summary.protein, 80.0);
          expect(summary.fats, 60.0);
          expect(summary.netCarbs, 30.0);
          expect(summary.calories, 1010.0);
        },
      );
    });

    test('should filter correctly across month boundaries', () {
      // Arrange
      final targetDate = DateTime(2024, 1, 31);
      final nextMonthDate = DateTime(2024, 2, 1);
      final meals = [
        Meal(
          id: 'meal-1',
          userId: 'user-id',
          date: targetDate,
          mealType: MealType.breakfast,
          name: 'Breakfast',
          protein: 30.0,
          fats: 20.0,
          netCarbs: 10.0,
          calories: 350.0,
          ingredients: ['eggs'],
          createdAt: targetDate,
        ),
        Meal(
          id: 'meal-2',
          userId: 'user-id',
          date: nextMonthDate,
          mealType: MealType.lunch,
          name: 'Lunch',
          protein: 40.0,
          fats: 30.0,
          netCarbs: 15.0,
          calories: 550.0,
          ingredients: ['chicken'],
          createdAt: nextMonthDate,
        ),
      ];

      // Act
      final result = useCase.call(meals, targetDate);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (summary) {
          // Should only include meal from targetDate (Jan 31)
          expect(summary.protein, 30.0);
          expect(summary.fats, 20.0);
          expect(summary.netCarbs, 10.0);
          expect(summary.calories, 350.0);
        },
      );
    });
  });
}

