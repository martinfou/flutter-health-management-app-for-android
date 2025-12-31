import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/core/utils/validation_utils.dart';
import 'package:health_app/core/constants/health_constants.dart';

void main() {
  group('ValidationUtils', () {
    group('validateWeightKg', () {
      test('should return null for valid weight', () {
        // Arrange
        final weight = 75.0;

        // Act
        final result = ValidationUtils.validateWeightKg(weight);

        // Assert
        expect(result, isNull);
      });

      test('should return error when weight is null', () {
        // Arrange
        final weight = null;

        // Act
        final result = ValidationUtils.validateWeightKg(weight);

        // Assert
        expect(result, isNotNull);
        expect(result, 'Weight is required');
      });

      test('should return error when weight is below minimum', () {
        // Arrange
        final weight = HealthConstants.minWeightKg - 1;

        // Act
        final result = ValidationUtils.validateWeightKg(weight);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('at least'));
      });

      test('should return error when weight exceeds maximum', () {
        // Arrange
        final weight = HealthConstants.maxWeightKg + 1;

        // Act
        final result = ValidationUtils.validateWeightKg(weight);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('not exceed'));
      });
    });

    group('validateWeightLbs', () {
      test('should return null for valid weight', () {
        // Arrange
        final weight = 165.0;

        // Act
        final result = ValidationUtils.validateWeightLbs(weight);

        // Assert
        expect(result, isNull);
      });

      test('should return error when weight is null', () {
        // Arrange
        final weight = null;

        // Act
        final result = ValidationUtils.validateWeightLbs(weight);

        // Assert
        expect(result, isNotNull);
        expect(result, 'Weight is required');
      });
    });

    group('validateHeightCm', () {
      test('should return null for valid height', () {
        // Arrange
        final height = 175.0;

        // Act
        final result = ValidationUtils.validateHeightCm(height);

        // Assert
        expect(result, isNull);
      });

      test('should return error when height is null', () {
        // Arrange
        final height = null;

        // Act
        final result = ValidationUtils.validateHeightCm(height);

        // Assert
        expect(result, isNotNull);
        expect(result, 'Height is required');
      });

      test('should return error when height is below minimum', () {
        // Arrange
        final height = HealthConstants.minHeightCm - 1;

        // Act
        final result = ValidationUtils.validateHeightCm(height);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('at least'));
      });
    });

    group('validateHeightInches', () {
      test('should return null for valid height', () {
        // Arrange
        final height = 69.0;

        // Act
        final result = ValidationUtils.validateHeightInches(height);

        // Assert
        expect(result, isNull);
      });

      test('should return error when height is null', () {
        // Arrange
        final height = null;

        // Act
        final result = ValidationUtils.validateHeightInches(height);

        // Assert
        expect(result, isNotNull);
        expect(result, 'Height is required');
      });
    });

    group('validateRestingHeartRate', () {
      test('should return null for valid heart rate', () {
        // Arrange
        final heartRate = 72;

        // Act
        final result = ValidationUtils.validateRestingHeartRate(heartRate);

        // Assert
        expect(result, isNull);
      });

      test('should return error when heart rate is null', () {
        // Arrange
        final heartRate = null;

        // Act
        final result = ValidationUtils.validateRestingHeartRate(heartRate);

        // Assert
        expect(result, isNotNull);
        expect(result, 'Resting heart rate is required');
      });

      test('should return error when heart rate is below minimum', () {
        // Arrange
        final heartRate = HealthConstants.minRestingHeartRate - 1;

        // Act
        final result = ValidationUtils.validateRestingHeartRate(heartRate);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('at least'));
      });

      test('should return error when heart rate exceeds maximum', () {
        // Arrange
        final heartRate = HealthConstants.maxRestingHeartRate + 1;

        // Act
        final result = ValidationUtils.validateRestingHeartRate(heartRate);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('not exceed'));
      });
    });

    group('validateSleepQuality', () {
      test('should return null for valid sleep quality', () {
        // Arrange
        final quality = 7;

        // Act
        final result = ValidationUtils.validateSleepQuality(quality);

        // Assert
        expect(result, isNull);
      });

      test('should return error when sleep quality is null', () {
        // Arrange
        final quality = null;

        // Act
        final result = ValidationUtils.validateSleepQuality(quality);

        // Assert
        expect(result, isNotNull);
        expect(result, 'Sleep quality is required');
      });

      test('should return error when sleep quality is below minimum', () {
        // Arrange
        final quality = HealthConstants.minSleepQuality - 1;

        // Act
        final result = ValidationUtils.validateSleepQuality(quality);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('at least'));
      });

      test('should return error when sleep quality exceeds maximum', () {
        // Arrange
        final quality = HealthConstants.maxSleepQuality + 1;

        // Act
        final result = ValidationUtils.validateSleepQuality(quality);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('not exceed'));
      });
    });

    group('validateDailyCalories', () {
      test('should return null for valid calories', () {
        // Arrange
        final calories = 2000;

        // Act
        final result = ValidationUtils.validateDailyCalories(calories);

        // Assert
        expect(result, isNull);
      });

      test('should return error when calories is null', () {
        // Arrange
        final calories = null;

        // Act
        final result = ValidationUtils.validateDailyCalories(calories);

        // Assert
        expect(result, isNotNull);
        expect(result, 'Calories are required');
      });

      test('should return error when calories is below minimum', () {
        // Arrange
        final calories = HealthConstants.minDailyCalories - 1;

        // Act
        final result = ValidationUtils.validateDailyCalories(calories);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('at least'));
      });
    });

    group('validateMacroPercentage', () {
      test('should return null for valid percentage', () {
        // Arrange
        final percentage = 35.0;

        // Act
        final result = ValidationUtils.validateMacroPercentage(percentage);

        // Assert
        expect(result, isNull);
      });

      test('should return error when percentage is null', () {
        // Arrange
        final percentage = null;

        // Act
        final result = ValidationUtils.validateMacroPercentage(percentage);

        // Assert
        expect(result, isNotNull);
        expect(result, 'Percentage is required');
      });

      test('should return error when percentage is below minimum', () {
        // Arrange
        final percentage = HealthConstants.minProteinPercentage - 1;

        // Act
        final result = ValidationUtils.validateMacroPercentage(percentage);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('at least'));
      });
    });

    group('validateMacroPercentagesSum', () {
      test('should return null when percentages sum to 100%', () {
        // Arrange
        final protein = 35.0;
        final carbs = 10.0;
        final fat = 55.0;

        // Act
        final result = ValidationUtils.validateMacroPercentagesSum(
          protein,
          carbs,
          fat,
        );

        // Assert
        expect(result, isNull);
      });

      test('should return null when percentages sum within tolerance', () {
        // Arrange
        final protein = 35.0;
        final carbs = 10.0;
        final fat = 54.0; // Sum = 99% (within 5% tolerance)

        // Act
        final result = ValidationUtils.validateMacroPercentagesSum(
          protein,
          carbs,
          fat,
        );

        // Assert
        expect(result, isNull);
      });

      test('should return error when percentages sum exceeds tolerance', () {
        // Arrange
        final protein = 50.0;
        final carbs = 30.0;
        final fat = 30.0; // Sum = 110% (exceeds 5% tolerance)

        // Act
        final result = ValidationUtils.validateMacroPercentagesSum(
          protein,
          carbs,
          fat,
        );

        // Assert
        expect(result, isNotNull);
        expect(result, contains('sum to approximately 100%'));
      });
    });

    group('validateNotNull', () {
      test('should return null when value is not null', () {
        // Arrange
        final value = 'test';

        // Act
        final result = ValidationUtils.validateNotNull(value, 'field');

        // Assert
        expect(result, isNull);
      });

      test('should return error when value is null', () {
        // Arrange
        final value = null;

        // Act
        final result = ValidationUtils.validateNotNull(value, 'fieldName');

        // Assert
        expect(result, isNotNull);
        expect(result, 'fieldName is required');
      });
    });

    group('validateNotEmpty', () {
      test('should return null when string is not empty', () {
        // Arrange
        final value = 'test';

        // Act
        final result = ValidationUtils.validateNotEmpty(value, 'field');

        // Assert
        expect(result, isNull);
      });

      test('should return error when string is null', () {
        // Arrange
        final value = null;

        // Act
        final result = ValidationUtils.validateNotEmpty(value, 'fieldName');

        // Assert
        expect(result, isNotNull);
        expect(result, 'fieldName is required');
      });

      test('should return error when string is empty', () {
        // Arrange
        final value = '';

        // Act
        final result = ValidationUtils.validateNotEmpty(value, 'fieldName');

        // Assert
        expect(result, isNotNull);
        expect(result, 'fieldName is required');
      });

      test('should return error when string is only whitespace', () {
        // Arrange
        final value = '   ';

        // Act
        final result = ValidationUtils.validateNotEmpty(value, 'fieldName');

        // Assert
        expect(result, isNotNull);
        expect(result, 'fieldName is required');
      });
    });

    group('validateStringLength', () {
      test('should return null when string length is within range', () {
        // Arrange
        final value = 'test';
        final minLength = 2;
        final maxLength = 10;

        // Act
        final result = ValidationUtils.validateStringLength(
          value,
          'field',
          minLength,
          maxLength,
        );

        // Assert
        expect(result, isNull);
      });

      test('should return error when string is null', () {
        // Arrange
        final value = null;
        final minLength = 2;
        final maxLength = 10;

        // Act
        final result = ValidationUtils.validateStringLength(
          value,
          'fieldName',
          minLength,
          maxLength,
        );

        // Assert
        expect(result, isNotNull);
        expect(result, 'fieldName is required');
      });

      test('should return error when string is too short', () {
        // Arrange
        final value = 'a';
        final minLength = 2;
        final maxLength = 10;

        // Act
        final result = ValidationUtils.validateStringLength(
          value,
          'fieldName',
          minLength,
          maxLength,
        );

        // Assert
        expect(result, isNotNull);
        expect(result, contains('at least'));
      });

      test('should return error when string is too long', () {
        // Arrange
        final value = 'a' * 11;
        final minLength = 2;
        final maxLength = 10;

        // Act
        final result = ValidationUtils.validateStringLength(
          value,
          'fieldName',
          minLength,
          maxLength,
        );

        // Assert
        expect(result, isNotNull);
        expect(result, contains('not exceed'));
      });
    });
  });
}

