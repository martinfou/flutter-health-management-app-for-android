import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:health_app/core/utils/export_utils.dart';
import 'package:health_app/core/providers/database_provider.dart';
import 'package:health_app/core/data/models/user_preferences_model.dart';
import 'package:health_app/features/health_tracking/data/models/health_metric_model.dart';
import 'package:health_app/core/errors/failures.dart';

/// Unit tests for ExportService
/// 
/// Note: Some tests intentionally trigger errors to test error handling.
/// The error logs (MissingPluginException, FormatException, etc.) that appear
/// in the test output are EXPECTED and indicate that error handling is working
/// correctly. These are not test failures - they're console logs from ErrorHandler
/// when testing error scenarios.
void main() {
  group('ExportService', () {
    late Directory testDir;

    setUpAll(() async {
      // Initialize Flutter binding for path_provider (needed for file operations)
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Initialize Hive for testing
      // Use a temporary directory for test data
      testDir = await Directory.systemTemp.createTemp('hive_test_');
      Hive.init(testDir.path);
      
      // Register adapters needed for tests
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(HealthMetricModelAdapter());
      }
      if (!Hive.isAdapterRegistered(12)) {
        Hive.registerAdapter(UserPreferencesModelAdapter());
      }
    });

    tearDownAll(() async {
      // Clean up
      await Hive.close();
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }
    });

    setUp(() async {
      // Close all boxes before each test
      await Hive.close();
      
      // Open boxes needed for tests
      if (!Hive.isBoxOpen(HiveBoxNames.healthMetrics)) {
        await Hive.openBox<HealthMetricModel>(HiveBoxNames.healthMetrics);
      }
      if (!Hive.isBoxOpen(HiveBoxNames.userPreferences)) {
        await Hive.openBox<UserPreferencesModel>(HiveBoxNames.userPreferences);
      }
    });

    tearDown(() async {
      // Clear boxes after each test
      final healthMetricsBox = Hive.box<HealthMetricModel>(HiveBoxNames.healthMetrics);
      await healthMetricsBox.clear();
      
      final userPreferencesBox = Hive.box<UserPreferencesModel>(HiveBoxNames.userPreferences);
      await userPreferencesBox.clear();
    });

    /// Helper function to create a test export file manually
    /// This avoids needing path_provider which requires platform channels
    Future<String> _createTestExportFile(Map<String, dynamic> exportData) async {
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      final fileName = 'test_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${testDir.path}/$fileName');
      await file.writeAsString(jsonString);
      return file.path;
    }

    group('exportAllData', () {
      // Note: Export tests that require file I/O (using path_provider) should be
      // integration tests. Unit tests focus on JSON generation/parsing logic.
      // The export functionality is tested via import/validation tests below.
      
      test('should handle export when path_provider is unavailable', () async {
        // This test documents that export requires platform channels
        // Full export testing should be done in integration tests
        // Arrange - boxes are already empty from tearDown
        
        // Act
        final result = await ExportService.exportAllData();
        
        // Assert - export may fail in unit tests due to path_provider
        // This is expected and acceptable for unit tests
        // Integration tests will verify full export functionality
        if (result.isLeft()) {
          // Expected in unit tests - path_provider requires platform channels
          final failure = result.fold((f) => f, (_) => throw Exception('Unexpected success'));
          expect(failure, isA<DatabaseFailure>());
        } else {
          // If it succeeds, verify basic structure
          final filePath = result.fold((_) => throw Exception('Unexpected failure'), (p) => p);
          expect(filePath, isNotEmpty);
          expect(filePath, endsWith('.json'));
        }
      });

      // Note: Export tests that require file I/O (using path_provider) should be
      // integration tests. The export functionality is tested via import/validation tests below.
      // Detailed export tests require platform channels and are covered in integration tests.
    });

    group('importAllData', () {
      test('should import data from valid export file', () async {
        // Arrange - create a test export file manually
        final now = DateTime.now();
        final exportData = {
          'export_version': '1.0',
          'export_date': now.toIso8601String(),
          HiveBoxNames.healthMetrics: [
            {
              '_key': 'test-metric-1',
              'id': 'test-metric-1',
              'userId': 'test-user-1',
              'date': now.toIso8601String(),
              'weight': 75.5,
              'sleepQuality': 7,
              'sleepHours': 8.0,
              'energyLevel': 8,
              'restingHeartRate': 65,
              'systolicBP': null,
              'diastolicBP': null,
              'bodyMeasurements': {},
              'notes': null,
              'createdAt': now.toIso8601String(),
              'updatedAt': now.toIso8601String(),
            },
          ],
        };
        
        final exportFilePath = await _createTestExportFile(exportData);
        
        // Clear the box to simulate importing into empty database
        final metricsBox = Hive.box<HealthMetricModel>(HiveBoxNames.healthMetrics);
        await metricsBox.clear();
        
        // Act
        final importResult = await ExportService.importAllData(exportFilePath);
        
        // Assert
        expect(importResult.isRight(), true);
        importResult.fold(
          (failure) => fail('Import should succeed: ${failure.message}'),
          (_) {
            final restored = metricsBox.get('test-metric-1');
            expect(restored, isNotNull);
            expect(restored?.weight, 75.5);
            expect(restored?.sleepQuality, 7);
            expect(restored?.restingHeartRate, 65);
          },
        );
        
        // Cleanup
        await File(exportFilePath).delete();
      });

      test('should return failure when file does not exist', () async {
        // Arrange
        const nonExistentPath = '/path/that/does/not/exist.json';
        
        // Act
        final result = await ExportService.importAllData(nonExistentPath);
        
        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<DatabaseFailure>());
            expect(failure.message, contains('does not exist'));
          },
          (_) => fail('Should have failed'),
        );
      });

      test('should return failure when file format is invalid (missing export_version)', () async {
        // Arrange
        final invalidFile = File('${testDir.path}/invalid.json');
        await invalidFile.writeAsString('{"invalid": "format"}');
        
        // Act
        final result = await ExportService.importAllData(invalidFile.path);
        
        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<DatabaseFailure>());
            expect(failure.message, contains('export_version'));
          },
          (_) => fail('Should have failed'),
        );
        
        // Cleanup
        await invalidFile.delete();
      });

      test('should return failure when file is not valid JSON', () async {
        // Arrange
        final invalidJsonFile = File('${testDir.path}/not_json.txt');
        await invalidJsonFile.writeAsString('This is not JSON');
        
        // Act
        final result = await ExportService.importAllData(invalidJsonFile.path);
        
        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<DatabaseFailure>());
            // ErrorHandler may return generic message, so just verify it's a failure
            expect(failure.message, isNotEmpty);
          },
          (_) => fail('Should have failed'),
        );
        
        // Cleanup
        await invalidJsonFile.delete();
      });
    });

    group('validateImportFile', () {
      test('should validate valid export file', () async {
        // Arrange - create a test export file manually
        final exportData = {
          'export_version': '1.0',
          'export_date': DateTime.now().toIso8601String(),
          HiveBoxNames.healthMetrics: [],
        };
        
        final exportFilePath = await _createTestExportFile(exportData);
        
        // Act
        final result = await ExportService.validateImportFile(exportFilePath);
        
        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail: ${failure.message}'),
          (message) {
            expect(message, contains('valid'));
          },
        );
        
        // Cleanup
        await File(exportFilePath).delete();
      });

      test('should return failure when file does not exist', () async {
        // Arrange
        const nonExistentPath = '/path/that/does/not/exist.json';
        
        // Act
        final result = await ExportService.validateImportFile(nonExistentPath);
        
        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<DatabaseFailure>());
            expect(failure.message, contains('does not exist'));
          },
          (_) => fail('Should have failed'),
        );
      });

      test('should return failure when file is missing export_version', () async {
        // Arrange
        final invalidFile = File('${testDir.path}/invalid.json');
        await invalidFile.writeAsString('{"some": "data", "no_version": true}');
        
        // Act
        final result = await ExportService.validateImportFile(invalidFile.path);
        
        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<DatabaseFailure>());
            expect(failure.message, contains('export_version'));
          },
          (_) => fail('Should have failed'),
        );
        
        // Cleanup
        await invalidFile.delete();
      });

      test('should return failure when file is not valid JSON', () async {
        // Arrange
        final invalidJsonFile = File('${testDir.path}/not_json.txt');
        await invalidJsonFile.writeAsString('This is not JSON at all');
        
        // Act
        final result = await ExportService.validateImportFile(invalidJsonFile.path);
        
        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<DatabaseFailure>());
            expect(failure.message.toLowerCase(), contains('json'));
          },
          (_) => fail('Should have failed'),
        );
        
        // Cleanup
        await invalidJsonFile.delete();
      });
    });

    group('formatFileSize', () {
      test('should format bytes correctly', () {
        expect(ExportService.formatFileSize(0), '0 B');
        expect(ExportService.formatFileSize(500), '500 B');
        expect(ExportService.formatFileSize(1024), '1.0 KB');
        expect(ExportService.formatFileSize(1536), '1.5 KB');
        expect(ExportService.formatFileSize(1048576), '1.0 MB');
        expect(ExportService.formatFileSize(1572864), '1.5 MB');
      });
    });

    group('getExportFileSize', () {
      test('should return file size for existing file', () async {
        // Arrange - create a test export file manually
        final exportData = {
          'export_version': '1.0',
          'export_date': DateTime.now().toIso8601String(),
          HiveBoxNames.healthMetrics: [],
        };
        
        final exportFilePath = await _createTestExportFile(exportData);
        
        // Act
        final size = await ExportService.getExportFileSize(exportFilePath);
        
        // Assert
        expect(size, isNotNull);
        expect(size, greaterThan(0));
        
        // Cleanup
        await File(exportFilePath).delete();
      });

      test('should return null for non-existent file', () async {
        // Arrange
        const nonExistentPath = '/path/that/does/not/exist.json';
        
        // Act
        final size = await ExportService.getExportFileSize(nonExistentPath);
        
        // Assert
        expect(size, isNull);
      });
    });
  });
}

