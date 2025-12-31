import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/core/utils/unit_converter.dart';

void main() {
  group('UnitConverter', () {
    group('Weight Conversions', () {
      test('convertWeightMetricToImperial should convert kg to lb correctly', () {
        // Arrange
        const kg = 75.5;

        // Act
        final lb = UnitConverter.convertWeightMetricToImperial(kg);

        // Assert
        expect(lb, closeTo(166.4, 0.1)); // 75.5 kg ≈ 166.4 lb
      });

      test('convertWeightMetricToImperial should round to 1 decimal place', () {
        // Arrange
        const kg = 75.0;

        // Act
        final lb = UnitConverter.convertWeightMetricToImperial(kg);

        // Assert
        final stringValue = lb.toString();
        final decimalPart = stringValue.split('.')[1];
        expect(decimalPart.length, lessThanOrEqualTo(1));
      });

      test('convertWeightImperialToMetric should convert lb to kg correctly', () {
        // Arrange
        const lb = 165.0;

        // Act
        final kg = UnitConverter.convertWeightImperialToMetric(lb);

        // Assert
        expect(kg, closeTo(74.8, 0.1)); // 165 lb ≈ 74.8 kg
      });

      test('convertWeightImperialToMetric should round to 1 decimal place', () {
        // Arrange
        const lb = 165.0;

        // Act
        final kg = UnitConverter.convertWeightImperialToMetric(lb);

        // Assert
        final stringValue = kg.toString();
        final decimalPart = stringValue.split('.')[1];
        expect(decimalPart.length, lessThanOrEqualTo(1));
      });

      test('formatWeight should format metric weight correctly', () {
        // Arrange
        const kg = 75.5;

        // Act
        final formatted = UnitConverter.formatWeight(kg, false);

        // Assert
        expect(formatted, '75.5 kg');
      });

      test('formatWeight should format imperial weight correctly', () {
        // Arrange
        const kg = 75.5;

        // Act
        final formatted = UnitConverter.formatWeight(kg, true);

        // Assert
        expect(formatted, contains('lb'));
        expect(formatted, isNot(contains('kg')));
      });

      test('weight conversion should be reversible', () {
        // Arrange
        const originalKg = 75.5;

        // Act
        final lb = UnitConverter.convertWeightMetricToImperial(originalKg);
        final convertedBackKg = UnitConverter.convertWeightImperialToMetric(lb);

        // Assert
        expect(convertedBackKg, closeTo(originalKg, 0.1));
      });
    });

    group('Height Conversions', () {
      test('convertHeightMetricToImperial should convert cm to ft/in correctly', () {
        // Arrange
        const cm = 175.0; // 175 cm = 5'9"

        // Act
        final ftIn = UnitConverter.convertHeightMetricToImperial(cm);

        // Assert
        expect(ftIn.feet, 5);
        expect(ftIn.inches, 9);
      });

      test('convertHeightMetricToImperial should handle exact feet', () {
        // Arrange
        const cm = 182.88; // 6 feet exactly

        // Act
        final ftIn = UnitConverter.convertHeightMetricToImperial(cm);

        // Assert
        expect(ftIn.feet, 6);
        expect(ftIn.inches, 0);
      });

      test('convertHeightImperialToMetric should convert ft/in to cm correctly', () {
        // Arrange
        const feet = 5;
        const inches = 9; // 5'9" = 175 cm

        // Act
        final cm = UnitConverter.convertHeightImperialToMetric(feet, inches);

        // Assert
        expect(cm, closeTo(175.0, 1.0));
      });

      test('convertHeightImperialToMetric should handle inches >= 12', () {
        // Arrange
        const feet = 5;
        const inches = 12; // Should be treated as 6'0"

        // Act
        final cm = UnitConverter.convertHeightImperialToMetric(feet, inches);

        // Assert
        // Should convert correctly (5'12" = 6'0" = 182.88 cm)
        expect(cm, greaterThan(180.0));
      });

      test('formatHeight should format metric height correctly', () {
        // Arrange
        const cm = 175.0;

        // Act
        final formatted = UnitConverter.formatHeight(cm, false);

        // Assert
        expect(formatted, '175 cm');
      });

      test('formatHeight should format imperial height correctly', () {
        // Arrange
        const cm = 175.0;

        // Act
        final formatted = UnitConverter.formatHeight(cm, true);

        // Assert
        expect(formatted, contains("'"));
        expect(formatted, contains('"'));
        expect(formatted, isNot(contains('cm')));
      });

      test('height conversion should be approximately reversible', () {
        // Arrange
        const originalCm = 175.0;

        // Act
        final ftIn = UnitConverter.convertHeightMetricToImperial(originalCm);
        final convertedBackCm = UnitConverter.convertHeightImperialToMetric(
          ftIn.feet,
          ftIn.inches,
        );

        // Assert
        // Rounding may cause slight differences, so allow 2 cm tolerance
        expect(convertedBackCm, closeTo(originalCm, 2.0));
      });
    });

    group('Length Conversions', () {
      test('convertLengthMetricToImperial should convert cm to in correctly', () {
        // Arrange
        const cm = 81.3; // 81.3 cm ≈ 32.0 in

        // Act
        final inches = UnitConverter.convertLengthMetricToImperial(cm);

        // Assert
        expect(inches, closeTo(32.0, 0.1));
      });

      test('convertLengthMetricToImperial should round to 1 decimal place', () {
        // Arrange
        const cm = 81.3;

        // Act
        final inches = UnitConverter.convertLengthMetricToImperial(cm);

        // Assert
        final stringValue = inches.toString();
        final decimalPart = stringValue.split('.')[1];
        expect(decimalPart.length, lessThanOrEqualTo(1));
      });

      test('convertLengthImperialToMetric should convert in to cm correctly', () {
        // Arrange
        const inches = 32.0; // 32 in = 81.28 cm

        // Act
        final cm = UnitConverter.convertLengthImperialToMetric(inches);

        // Assert
        expect(cm, closeTo(81.3, 0.1));
      });

      test('convertLengthImperialToMetric should round to 1 decimal place', () {
        // Arrange
        const inches = 32.0;

        // Act
        final cm = UnitConverter.convertLengthImperialToMetric(inches);

        // Assert
        final stringValue = cm.toString();
        final decimalPart = stringValue.split('.')[1];
        expect(decimalPart.length, lessThanOrEqualTo(1));
      });

      test('formatLength should format metric length correctly', () {
        // Arrange
        const cm = 81.3;

        // Act
        final formatted = UnitConverter.formatLength(cm, false);

        // Assert
        expect(formatted, '81.3 cm');
      });

      test('formatLength should format imperial length correctly', () {
        // Arrange
        const cm = 81.3;

        // Act
        final formatted = UnitConverter.formatLength(cm, true);

        // Assert
        expect(formatted, contains('in'));
        expect(formatted, isNot(contains('cm')));
      });

      test('length conversion should be reversible', () {
        // Arrange
        const originalCm = 81.3;

        // Act
        final inches = UnitConverter.convertLengthMetricToImperial(originalCm);
        final convertedBackCm = UnitConverter.convertLengthImperialToMetric(inches);

        // Assert
        expect(convertedBackCm, closeTo(originalCm, 0.1));
      });
    });

    group('Unit Label Helpers', () {
      test('getWeightUnitLabel should return kg for metric', () {
        expect(UnitConverter.getWeightUnitLabel(false), 'kg');
      });

      test('getWeightUnitLabel should return lb for imperial', () {
        expect(UnitConverter.getWeightUnitLabel(true), 'lb');
      });

      test('getHeightUnitLabel should return cm for metric', () {
        expect(UnitConverter.getHeightUnitLabel(false), 'cm');
      });

      test('getHeightUnitLabel should return ft/in for imperial', () {
        expect(UnitConverter.getHeightUnitLabel(true), 'ft/in');
      });

      test('getLengthUnitLabel should return cm for metric', () {
        expect(UnitConverter.getLengthUnitLabel(false), 'cm');
      });

      test('getLengthUnitLabel should return in for imperial', () {
        expect(UnitConverter.getLengthUnitLabel(true), 'in');
      });
    });

    group('Validation Helpers', () {
      test('getMinWeight should return 30 kg for metric', () {
        final min = UnitConverter.getMinWeight(false);
        expect(min, 30.0);
      });

      test('getMinWeight should return ~66 lb for imperial', () {
        final min = UnitConverter.getMinWeight(true);
        expect(min, closeTo(66.0, 1.0));
      });

      test('getMaxWeight should return 300 kg for metric', () {
        final max = UnitConverter.getMaxWeight(false);
        expect(max, 300.0);
      });

      test('getMaxWeight should return ~660 lb for imperial', () {
        final max = UnitConverter.getMaxWeight(true);
        expect(max, closeTo(660.0, 5.0));
      });

      test('getMinHeight should return 100 cm for metric', () {
        final min = UnitConverter.getMinHeight(false);
        expect(min, 100.0);
      });

      test('getMinHeight should return ~39 in for imperial', () {
        final min = UnitConverter.getMinHeight(true);
        expect(min, closeTo(39.0, 1.0));
      });

      test('getMaxHeight should return 250 cm for metric', () {
        final max = UnitConverter.getMaxHeight(false);
        expect(max, 250.0);
      });

      test('getMaxHeight should return ~98 in for imperial', () {
        final max = UnitConverter.getMaxHeight(true);
        expect(max, closeTo(98.0, 2.0));
      });
    });

    group('Edge Cases', () {
      test('should handle zero weight', () {
        final lb = UnitConverter.convertWeightMetricToImperial(0.0);
        expect(lb, 0.0);
      });

      test('should handle zero height', () {
        final ftIn = UnitConverter.convertHeightMetricToImperial(0.0);
        expect(ftIn.feet, 0);
        expect(ftIn.inches, 0);
      });

      test('should handle very large weight values', () {
        const kg = 500.0;
        final lb = UnitConverter.convertWeightMetricToImperial(kg);
        expect(lb, greaterThan(1000.0));
      });

      test('should handle very large height values', () {
        const cm = 300.0;
        final ftIn = UnitConverter.convertHeightMetricToImperial(cm);
        expect(ftIn.feet, greaterThan(8));
      });
    });
  });

  group('FeetInches', () {
    test('toString should format correctly', () {
      final ftIn = FeetInches(feet: 5, inches: 9);
      expect(ftIn.toString(), "5'9\"");
    });

    test('should handle zero feet', () {
      final ftIn = FeetInches(feet: 0, inches: 6);
      expect(ftIn.toString(), "0'6\"");
    });

    test('should handle zero inches', () {
      final ftIn = FeetInches(feet: 6, inches: 0);
      expect(ftIn.toString(), "6'0\"");
    });

    test('equality should work correctly', () {
      final ftIn1 = FeetInches(feet: 5, inches: 9);
      final ftIn2 = FeetInches(feet: 5, inches: 9);
      final ftIn3 = FeetInches(feet: 5, inches: 10);

      expect(ftIn1 == ftIn2, true);
      expect(ftIn1 == ftIn3, false);
    });
  });
}

