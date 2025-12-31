import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/core/utils/calculation_utils.dart';

void main() {
  group('CalculationUtils', () {
    group('calculate7DayMovingAverage', () {
      test('should return null when insufficient data (< 7 entries)', () {
        // Arrange
        final values = [75.0, 74.8, 75.2];

        // Act
        final result = CalculationUtils.calculate7DayMovingAverage(values);

        // Assert
        expect(result, isNull);
      });

      test('should calculate average correctly with exactly 7 days', () {
        // Arrange
        final values = [75.0, 74.8, 75.2, 74.9, 75.1, 74.7, 75.0];

        // Act
        final result = CalculationUtils.calculate7DayMovingAverage(values);

        // Assert
        expect(result, isNotNull);
        expect(result, closeTo(75.0, 0.1));
      });

      test('should calculate average correctly with more than 7 days', () {
        // Arrange
        final values = [75.0, 74.8, 75.2, 74.9, 75.1, 74.7, 75.0, 75.3];

        // Act
        final result = CalculationUtils.calculate7DayMovingAverage(values);

        // Assert
        expect(result, isNotNull);
        expect(result, closeTo(75.0, 0.1));
      });

      test('should round to 1 decimal place', () {
        // Arrange
        final values = [75.0, 75.0, 75.0, 75.0, 75.0, 75.0, 75.33];

        // Act
        final result = CalculationUtils.calculate7DayMovingAverage(values);

        // Assert
        expect(result, isNotNull);
        expect(result, 75.0);
      });
    });

    group('calculatePercentage', () {
      test('should calculate percentage correctly', () {
        // Arrange
        final value = 25.0;
        final total = 100.0;

        // Act
        final result = CalculationUtils.calculatePercentage(value, total);

        // Assert
        expect(result, 25.0);
      });

      test('should return 0.0 when total is 0', () {
        // Arrange
        final value = 25.0;
        final total = 0.0;

        // Act
        final result = CalculationUtils.calculatePercentage(value, total);

        // Assert
        expect(result, 0.0);
      });

      test('should handle decimal percentages', () {
        // Arrange
        final value = 33.33;
        final total = 100.0;

        // Act
        final result = CalculationUtils.calculatePercentage(value, total);

        // Assert
        expect(result, closeTo(33.33, 0.01));
      });
    });

    group('caloriesFromProtein', () {
      test('should calculate calories from protein (4 cal/g)', () {
        // Arrange
        final grams = 30.0;

        // Act
        final result = CalculationUtils.caloriesFromProtein(grams);

        // Assert
        expect(result, 120.0);
      });
    });

    group('caloriesFromCarbs', () {
      test('should calculate calories from carbs (4 cal/g)', () {
        // Arrange
        final grams = 20.0;

        // Act
        final result = CalculationUtils.caloriesFromCarbs(grams);

        // Assert
        expect(result, 80.0);
      });
    });

    group('caloriesFromFat', () {
      test('should calculate calories from fat (9 cal/g)', () {
        // Arrange
        final grams = 25.0;

        // Act
        final result = CalculationUtils.caloriesFromFat(grams);

        // Assert
        expect(result, 225.0);
      });
    });

    group('totalCaloriesFromMacros', () {
      test('should calculate total calories from all macros', () {
        // Arrange
        final proteinGrams = 30.0; // 120 cal
        final carbsGrams = 20.0; // 80 cal
        final fatGrams = 25.0; // 225 cal

        // Act
        final result = CalculationUtils.totalCaloriesFromMacros(
          proteinGrams: proteinGrams,
          carbsGrams: carbsGrams,
          fatGrams: fatGrams,
        );

        // Assert
        expect(result, 425.0);
      });
    });

    group('proteinPercentageOfCalories', () {
      test('should calculate protein percentage correctly', () {
        // Arrange
        final proteinGrams = 30.0; // 120 cal
        final totalCalories = 400.0;

        // Act
        final result = CalculationUtils.proteinPercentageOfCalories(
          proteinGrams,
          totalCalories,
        );

        // Assert
        expect(result, 30.0);
      });

      test('should return 0.0 when total calories is 0', () {
        // Arrange
        final proteinGrams = 30.0;
        final totalCalories = 0.0;

        // Act
        final result = CalculationUtils.proteinPercentageOfCalories(
          proteinGrams,
          totalCalories,
        );

        // Assert
        expect(result, 0.0);
      });
    });

    group('carbsPercentageOfCalories', () {
      test('should calculate carbs percentage correctly', () {
        // Arrange
        final carbsGrams = 20.0; // 80 cal
        final totalCalories = 400.0;

        // Act
        final result = CalculationUtils.carbsPercentageOfCalories(
          carbsGrams,
          totalCalories,
        );

        // Assert
        expect(result, 20.0);
      });
    });

    group('fatPercentageOfCalories', () {
      test('should calculate fat percentage correctly', () {
        // Arrange
        final fatGrams = 25.0; // 225 cal
        final totalCalories = 450.0;

        // Act
        final result = CalculationUtils.fatPercentageOfCalories(
          fatGrams,
          totalCalories,
        );

        // Assert
        expect(result, 50.0);
      });
    });

    group('calculateWeightChange', () {
      test('should calculate weight change correctly', () {
        // Arrange
        final currentWeight = 75.0;
        final previousWeight = 76.0;

        // Act
        final result = CalculationUtils.calculateWeightChange(
          currentWeight,
          previousWeight,
        );

        // Assert
        expect(result, -1.0);
      });

      test('should return null when current weight is null', () {
        // Arrange
        final currentWeight = null;
        final previousWeight = 76.0;

        // Act
        final result = CalculationUtils.calculateWeightChange(
          currentWeight,
          previousWeight,
        );

        // Assert
        expect(result, isNull);
      });

      test('should return null when previous weight is null', () {
        // Arrange
        final currentWeight = 75.0;
        final previousWeight = null;

        // Act
        final result = CalculationUtils.calculateWeightChange(
          currentWeight,
          previousWeight,
        );

        // Assert
        expect(result, isNull);
      });
    });

    group('calculateWeightChangePercentage', () {
      test('should calculate weight change percentage correctly', () {
        // Arrange
        final currentWeight = 75.0;
        final previousWeight = 76.0;

        // Act
        final result = CalculationUtils.calculateWeightChangePercentage(
          currentWeight,
          previousWeight,
        );

        // Assert
        expect(result, closeTo(-1.32, 0.01)); // (75-76)/76 * 100
      });

      test('should return null when current weight is null', () {
        // Arrange
        final currentWeight = null;
        final previousWeight = 76.0;

        // Act
        final result = CalculationUtils.calculateWeightChangePercentage(
          currentWeight,
          previousWeight,
        );

        // Assert
        expect(result, isNull);
      });

      test('should return null when previous weight is 0', () {
        // Arrange
        final currentWeight = 75.0;
        final previousWeight = 0.0;

        // Act
        final result = CalculationUtils.calculateWeightChangePercentage(
          currentWeight,
          previousWeight,
        );

        // Assert
        expect(result, isNull);
      });
    });

    group('calculateWeeklyWeightLossRate', () {
      test('should calculate weekly weight loss rate correctly', () {
        // Arrange
        final currentWeight = 75.0;
        final previousWeight = 76.0;
        final daysBetween = 7;

        // Act
        final result = CalculationUtils.calculateWeeklyWeightLossRate(
          currentWeight,
          previousWeight,
          daysBetween,
        );

        // Assert
        expect(result, -1.0); // -1 kg over 7 days = -1 kg/week
      });

      test('should return null when daysBetween is 0', () {
        // Arrange
        final currentWeight = 75.0;
        final previousWeight = 76.0;
        final daysBetween = 0;

        // Act
        final result = CalculationUtils.calculateWeeklyWeightLossRate(
          currentWeight,
          previousWeight,
          daysBetween,
        );

        // Assert
        expect(result, isNull);
      });

      test('should round to 2 decimal places', () {
        // Arrange
        final currentWeight = 75.0;
        final previousWeight = 76.0;
        final daysBetween = 14; // -1 kg over 14 days = -0.5 kg/week

        // Act
        final result = CalculationUtils.calculateWeeklyWeightLossRate(
          currentWeight,
          previousWeight,
          daysBetween,
        );

        // Assert
        expect(result, -0.5);
      });
    });

    group('calculateBMI', () {
      test('should calculate BMI correctly', () {
        // Arrange
        final weightKg = 75.0;
        final heightCm = 175.0; // 1.75m

        // Act
        final result = CalculationUtils.calculateBMI(weightKg, heightCm);

        // Assert
        expect(result, closeTo(24.5, 0.1)); // 75 / (1.75^2) = 24.49
      });

      test('should return null when weight is null', () {
        // Arrange
        final weightKg = null;
        final heightCm = 175.0;

        // Act
        final result = CalculationUtils.calculateBMI(weightKg, heightCm);

        // Assert
        expect(result, isNull);
      });

      test('should return null when height is 0', () {
        // Arrange
        final weightKg = 75.0;
        final heightCm = 0.0;

        // Act
        final result = CalculationUtils.calculateBMI(weightKg, heightCm);

        // Assert
        expect(result, isNull);
      });

      test('should round to 1 decimal place', () {
        // Arrange
        final weightKg = 75.0;
        final heightCm = 175.0;

        // Act
        final result = CalculationUtils.calculateBMI(weightKg, heightCm);

        // Assert
        expect(result, 24.5);
      });
    });

    group('calculateAverage', () {
      test('should calculate average correctly', () {
        // Arrange
        final values = [75.0, 74.8, 75.2, 74.9, 75.1];

        // Act
        final result = CalculationUtils.calculateAverage(values);

        // Assert
        expect(result, closeTo(75.0, 0.1));
      });

      test('should return null when list is empty', () {
        // Arrange
        final values = <double>[];

        // Act
        final result = CalculationUtils.calculateAverage(values);

        // Assert
        expect(result, isNull);
      });
    });

    group('calculateMin', () {
      test('should find minimum value', () {
        // Arrange
        final values = [75.0, 74.8, 75.2, 74.9, 75.1];

        // Act
        final result = CalculationUtils.calculateMin(values);

        // Assert
        expect(result, 74.8);
      });

      test('should return null when list is empty', () {
        // Arrange
        final values = <double>[];

        // Act
        final result = CalculationUtils.calculateMin(values);

        // Assert
        expect(result, isNull);
      });
    });

    group('calculateMax', () {
      test('should find maximum value', () {
        // Arrange
        final values = [75.0, 74.8, 75.2, 74.9, 75.1];

        // Act
        final result = CalculationUtils.calculateMax(values);

        // Assert
        expect(result, 75.2);
      });

      test('should return null when list is empty', () {
        // Arrange
        final values = <double>[];

        // Act
        final result = CalculationUtils.calculateMax(values);

        // Assert
        expect(result, isNull);
      });
    });

    group('areValuesWithinTolerance', () {
      test('should return true when values are within tolerance', () {
        // Arrange
        final values = [75.0, 75.1, 75.0, 75.2];
        final tolerance = 0.5;

        // Act
        final result = CalculationUtils.areValuesWithinTolerance(
          values,
          tolerance,
        );

        // Assert
        expect(result, isTrue);
      });

      test('should return false when values exceed tolerance', () {
        // Arrange
        final values = [75.0, 76.0, 75.0, 75.2];
        final tolerance = 0.5;

        // Act
        final result = CalculationUtils.areValuesWithinTolerance(
          values,
          tolerance,
        );

        // Assert
        expect(result, isFalse);
      });

      test('should return false when list is empty', () {
        // Arrange
        final values = <double>[];
        final tolerance = 0.5;

        // Act
        final result = CalculationUtils.areValuesWithinTolerance(
          values,
          tolerance,
        );

        // Assert
        expect(result, isFalse);
      });
    });
  });
}

