import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/core/utils/date_utils.dart';
import 'package:health_app/core/constants/health_constants.dart';

void main() {
  group('DateUtils', () {
    group('startOfDay', () {
      test('should return start of day (00:00:00)', () {
        // Arrange
        final date = DateTime(2024, 1, 15, 14, 30, 45);

        // Act
        final result = DateUtils.startOfDay(date);

        // Assert
        expect(result.year, 2024);
        expect(result.month, 1);
        expect(result.day, 15);
        expect(result.hour, 0);
        expect(result.minute, 0);
        expect(result.second, 0);
      });
    });

    group('endOfDay', () {
      test('should return end of day (23:59:59)', () {
        // Arrange
        final date = DateTime(2024, 1, 15, 14, 30, 45);

        // Act
        final result = DateUtils.endOfDay(date);

        // Assert
        expect(result.year, 2024);
        expect(result.month, 1);
        expect(result.day, 15);
        expect(result.hour, 23);
        expect(result.minute, 59);
        expect(result.second, 59);
      });
    });

    group('daysAgo', () {
      test('should return date N days ago', () {
        // Arrange
        final date = DateTime(2024, 1, 15);
        final days = 7;

        // Act
        final result = DateUtils.daysAgo(date, days);

        // Assert
        expect(result, DateTime(2024, 1, 8));
      });
    });

    group('daysFrom', () {
      test('should return date N days from now', () {
        // Arrange
        final date = DateTime(2024, 1, 15);
        final days = 7;

        // Act
        final result = DateUtils.daysFrom(date, days);

        // Assert
        expect(result, DateTime(2024, 1, 22));
      });
    });

    group('isWithinLastDays', () {
      test('should return true when date is within last N days', () {
        // Arrange
        final reference = DateTime(2024, 1, 15);
        final date = DateTime(2024, 1, 12); // 3 days ago
        final days = 7;

        // Act
        final result = DateUtils.isWithinLastDays(date, reference, days);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when date is before the window', () {
        // Arrange
        final reference = DateTime(2024, 1, 15);
        final date = DateTime(2024, 1, 5); // 10 days ago
        final days = 7;

        // Act
        final result = DateUtils.isWithinLastDays(date, reference, days);

        // Assert
        expect(result, isFalse);
      });

      test('should return true when date is on the boundary', () {
        // Arrange
        final reference = DateTime(2024, 1, 15);
        final date = DateTime(2024, 1, 9); // Exactly 6 days ago (within 7-day window)
        final days = 7;

        // Act
        final result = DateUtils.isWithinLastDays(date, reference, days);

        // Assert
        expect(result, isTrue);
      });
    });

    group('get7DayWindowStart', () {
      test('should return start date for 7-day window', () {
        // Arrange
        final endDate = DateTime(2024, 1, 15);

        // Act
        final result = DateUtils.get7DayWindowStart(endDate);

        // Assert
        expect(result, DateTime(2024, 1, 9)); // 6 days before (inclusive)
      });
    });

    group('get7DayWindowDates', () {
      test('should return all dates in 7-day window', () {
        // Arrange
        final endDate = DateTime(2024, 1, 15);

        // Act
        final result = DateUtils.get7DayWindowDates(endDate);

        // Assert
        expect(result.length, HealthConstants.movingAverageDays);
        expect(result.first, DateTime(2024, 1, 9));
        expect(result.last, DateTime(2024, 1, 15));
      });
    });

    group('isIn7DayWindow', () {
      test('should return true when date is in 7-day window', () {
        // Arrange
        final endDate = DateTime(2024, 1, 15);
        final date = DateTime(2024, 1, 12);

        // Act
        final result = DateUtils.isIn7DayWindow(date, endDate);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when date is before window', () {
        // Arrange
        final endDate = DateTime(2024, 1, 15);
        final date = DateTime(2024, 1, 8);

        // Act
        final result = DateUtils.isIn7DayWindow(date, endDate);

        // Assert
        expect(result, isFalse);
      });

      test('should return true when date is on boundary', () {
        // Arrange
        final endDate = DateTime(2024, 1, 15);
        final date = DateTime(2024, 1, 9); // Start of window

        // Act
        final result = DateUtils.isIn7DayWindow(date, endDate);

        // Assert
        expect(result, isTrue);
      });
    });

    group('getPlateauWindowStart', () {
      test('should return start date for plateau window (21 days)', () {
        // Arrange
        final endDate = DateTime(2024, 1, 15);

        // Act
        final result = DateUtils.getPlateauWindowStart(endDate);

        // Assert
        expect(result, DateTime(2023, 12, 26)); // 20 days before (inclusive)
      });
    });

    group('isInPlateauWindow', () {
      test('should return true when date is in plateau window', () {
        // Arrange
        final endDate = DateTime(2024, 1, 15);
        final date = DateTime(2024, 1, 5);

        // Act
        final result = DateUtils.isInPlateauWindow(date, endDate);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when date is before plateau window', () {
        // Arrange
        final endDate = DateTime(2024, 1, 15);
        final date = DateTime(2023, 12, 25);

        // Act
        final result = DateUtils.isInPlateauWindow(date, endDate);

        // Assert
        expect(result, isFalse);
      });
    });

    group('startOfWeek', () {
      test('should return Monday for any day in week', () {
        // Arrange
        final date = DateTime(2024, 1, 15); // Monday

        // Act
        final result = DateUtils.startOfWeek(date);

        // Assert
        expect(result.weekday, 1); // Monday
        expect(result.day, 15);
      });

      test('should return Monday when date is Sunday', () {
        // Arrange
        // January 14, 2024 is actually a Sunday
        final date = DateTime(2024, 1, 14); // Sunday

        // Act
        final result = DateUtils.startOfWeek(date);

        // Assert
        expect(result.weekday, 1); // Monday
        // The start of week for Sunday should be the previous Monday (Jan 8)
        expect(result.day, 8);
      });
    });

    group('endOfWeek', () {
      test('should return Sunday for any day in week', () {
        // Arrange
        final date = DateTime(2024, 1, 15); // Monday

        // Act
        final result = DateUtils.endOfWeek(date);

        // Assert
        expect(result.weekday, 7); // Sunday
        expect(result.day, 21);
      });
    });

    group('isSameDay', () {
      test('should return true when dates are on same day', () {
        // Arrange
        final date1 = DateTime(2024, 1, 15, 10, 30);
        final date2 = DateTime(2024, 1, 15, 14, 45);

        // Act
        final result = DateUtils.isSameDay(date1, date2);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when dates are on different days', () {
        // Arrange
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 1, 16);

        // Act
        final result = DateUtils.isSameDay(date1, date2);

        // Assert
        expect(result, isFalse);
      });
    });

    group('isToday', () {
      test('should return true when date is today', () {
        // Arrange
        final date = DateTime.now();

        // Act
        final result = DateUtils.isToday(date);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when date is not today', () {
        // Arrange
        final date = DateTime.now().subtract(Duration(days: 1));

        // Act
        final result = DateUtils.isToday(date);

        // Assert
        expect(result, isFalse);
      });
    });

    group('isYesterday', () {
      test('should return true when date is yesterday', () {
        // Arrange
        final date = DateTime.now().subtract(Duration(days: 1));

        // Act
        final result = DateUtils.isYesterday(date);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when date is not yesterday', () {
        // Arrange
        final date = DateTime.now();

        // Act
        final result = DateUtils.isYesterday(date);

        // Assert
        expect(result, isFalse);
      });
    });

    group('daysBetween', () {
      test('should calculate days between two dates (inclusive)', () {
        // Arrange
        final start = DateTime(2024, 1, 10);
        final end = DateTime(2024, 1, 15);

        // Act
        final result = DateUtils.daysBetween(start, end);

        // Assert
        expect(result, 6); // 10, 11, 12, 13, 14, 15
      });

      test('should return 1 when dates are the same', () {
        // Arrange
        final start = DateTime(2024, 1, 15);
        final end = DateTime(2024, 1, 15);

        // Act
        final result = DateUtils.daysBetween(start, end);

        // Assert
        expect(result, 1);
      });
    });

    group('areConsecutive', () {
      test('should return true when dates are consecutive (next day)', () {
        // Arrange
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 1, 16);

        // Act
        final result = DateUtils.areConsecutive(date1, date2);

        // Assert
        expect(result, isTrue);
      });

      test('should return true when dates are consecutive (previous day)', () {
        // Arrange
        final date1 = DateTime(2024, 1, 16);
        final date2 = DateTime(2024, 1, 15);

        // Act
        final result = DateUtils.areConsecutive(date1, date2);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when dates are not consecutive', () {
        // Arrange
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 1, 17);

        // Act
        final result = DateUtils.areConsecutive(date1, date2);

        // Assert
        expect(result, isFalse);
      });
    });

    group('startOfMonth', () {
      test('should return first day of month', () {
        // Arrange
        final date = DateTime(2024, 1, 15);

        // Act
        final result = DateUtils.startOfMonth(date);

        // Assert
        expect(result.year, 2024);
        expect(result.month, 1);
        expect(result.day, 1);
      });
    });

    group('endOfMonth', () {
      test('should return last day of month', () {
        // Arrange
        final date = DateTime(2024, 1, 15);

        // Act
        final result = DateUtils.endOfMonth(date);

        // Assert
        expect(result.year, 2024);
        expect(result.month, 1);
        expect(result.day, 31);
        expect(result.hour, 23);
        expect(result.minute, 59);
        expect(result.second, 59);
      });

      test('should handle February correctly', () {
        // Arrange
        final date = DateTime(2024, 2, 15);

        // Act
        final result = DateUtils.endOfMonth(date);

        // Assert
        expect(result.day, 29); // 2024 is a leap year
      });
    });
  });
}

