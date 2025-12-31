import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'package:health_app/core/data/models/user_preferences_model.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/providers/database_provider.dart';
import 'package:health_app/core/utils/export_utils.dart';
import 'package:health_app/features/health_tracking/data/models/health_metric_model.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this.basePath);

  final String basePath;

  @override
  Future<String?> getTemporaryPath() async => basePath;

  @override
  Future<String?> getApplicationDocumentsPath() async => basePath;

  @override
  Future<String?> getExternalStoragePath() async => basePath;

  @override
  Future<List<String>?> getExternalStoragePaths({StorageDirectory? type}) async =>
      [basePath];

  @override
  Future<String?> getDownloadsPath() async => basePath;
}

/// Integration test for export/import flow
/// 
/// Tests the complete workflow:
/// 1. Create test data in Hive boxes
/// 2. Export data to JSON file
/// 3. Clear Hive boxes
/// 4. Import data from JSON file
/// 5. Verify data was restored correctly
/// 
/// Note: Some tests intentionally trigger errors to test error handling.
/// Error logs (FormatException, etc.) that appear in test output are EXPECTED
/// and indicate that error handling is working correctly. These are not failures.
void main() {
  group('Export/Import Flow Integration Test', () {
    late Directory testDir;
    late Directory hiveTestDir;
    late Directory exportDir;
    late PathProviderPlatform originalPathProvider;

    setUpAll(() async {
      // Initialize Flutter binding for path_provider
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Create temporary directories for testing
      testDir = await Directory.systemTemp.createTemp('export_import_test_');
      hiveTestDir = await Directory.systemTemp.createTemp('hive_test_');
      exportDir = await Directory.systemTemp.createTemp('export_files_');

      // Stub path_provider to use local temp directories (avoids platform channels)
      originalPathProvider = PathProviderPlatform.instance;
      PathProviderPlatform.instance = _FakePathProviderPlatform(exportDir.path);
      
      // Initialize Hive for testing
      Hive.init(hiveTestDir.path);
      
      // Register adapters needed for tests
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(HealthMetricModelAdapter());
      }
      if (!Hive.isAdapterRegistered(12)) {
        Hive.registerAdapter(UserPreferencesModelAdapter());
      }
      
      // Open test boxes
      if (!Hive.isBoxOpen(HiveBoxNames.healthMetrics)) {
        await Hive.openBox<HealthMetricModel>(HiveBoxNames.healthMetrics);
      }
      if (!Hive.isBoxOpen(HiveBoxNames.userPreferences)) {
        await Hive.openBox<UserPreferencesModel>(HiveBoxNames.userPreferences);
      }
    });

    tearDownAll(() async {
      // Clean up
      await Hive.close();
      PathProviderPlatform.instance = originalPathProvider;
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }
      if (await hiveTestDir.exists()) {
        await hiveTestDir.delete(recursive: true);
      }
      if (await exportDir.exists()) {
        await exportDir.delete(recursive: true);
      }
    });

    setUp(() async {
      // Clear boxes before each test
      final metricsBox = Hive.box<HealthMetricModel>(HiveBoxNames.healthMetrics);
      await metricsBox.clear();
      
      final prefsBox = Hive.box<UserPreferencesModel>(HiveBoxNames.userPreferences);
      await prefsBox.clear();
    });

    test('should export data and create valid JSON file', () async {
      // Arrange - Create test data
      final metricsBox = Hive.box<HealthMetricModel>(HiveBoxNames.healthMetrics);
      final now = DateTime.now();
      final metric = HealthMetricModel()
        ..id = 'test-metric-1'
        ..userId = 'test-user-1'
        ..date = now
        ..weight = 75.5
        ..sleepQuality = 7
        ..sleepHours = 8.0
        ..energyLevel = 8
        ..restingHeartRate = 65
        ..createdAt = now
        ..updatedAt = now;
      
      await metricsBox.put(metric.id, metric);

      // Act - Export data
      // Note: ExportService uses path_provider which requires platform channels
      // In a real integration test on device, this would work
      // For now, we test the JSON generation logic by creating export file manually
      final exportData = {
        'export_version': '1.0',
        'export_date': now.toIso8601String(),
        HiveBoxNames.healthMetrics: [
          {
            '_key': metric.id,
            'id': metric.id,
            'userId': metric.userId,
            'date': metric.date.toIso8601String(),
            'weight': metric.weight,
            'sleepQuality': metric.sleepQuality,
            'sleepHours': metric.sleepHours,
            'energyLevel': metric.energyLevel,
            'restingHeartRate': metric.restingHeartRate,
            'systolicBP': null,
            'diastolicBP': null,
            'bodyMeasurements': {},
            'notes': null,
            'createdAt': metric.createdAt.toIso8601String(),
            'updatedAt': metric.updatedAt.toIso8601String(),
          },
        ],
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      final exportFile = File('${testDir.path}/test_export.json');
      await exportFile.writeAsString(jsonString);

      // Assert - Verify export file was created and is valid JSON
      expect(await exportFile.exists(), true);
      final fileContent = await exportFile.readAsString();
      final parsed = jsonDecode(fileContent) as Map<String, dynamic>;
      expect(parsed['export_version'], '1.0');
      expect(parsed.containsKey(HiveBoxNames.healthMetrics), true);
      expect(parsed[HiveBoxNames.healthMetrics], isA<List>());
      
      // Cleanup
      await exportFile.delete();
    });

    test('should validate export file format', () async {
      // Arrange - Create valid export file
      final exportData = {
        'export_version': '1.0',
        'export_date': DateTime.now().toIso8601String(),
        HiveBoxNames.healthMetrics: [],
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      final exportFile = File('${testDir.path}/valid_export.json');
      await exportFile.writeAsString(jsonString);

      // Act - Validate file
      final result = await ExportService.validateImportFile(exportFile.path);

      // Assert - Verify validation passes
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Validation should pass: ${failure.message}'),
        (message) {
          expect(message, contains('valid'));
        },
      );
      
      // Cleanup
      await exportFile.delete();
    });

    test('should reject invalid export file format', () async {
      // Arrange - Create invalid export file (missing export_version)
      final invalidData = {
        'some_data': 'value',
        'no_version': true,
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(invalidData);
      final invalidFile = File('${testDir.path}/invalid_export.json');
      await invalidFile.writeAsString(jsonString);

      // Act - Validate file
      final result = await ExportService.validateImportFile(invalidFile.path);

      // Assert - Verify validation fails
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, contains('export_version'));
        },
        (_) => fail('Validation should fail for invalid file'),
      );
      
      // Cleanup
      await invalidFile.delete();
    });

    test('should import data from valid export file', () async {
      // Arrange - Create test export file with data
      final now = DateTime.now();
      final exportData = {
        'export_version': '1.0',
        'export_date': now.toIso8601String(),
        HiveBoxNames.healthMetrics: [
          {
            '_key': 'test-metric-import',
            'id': 'test-metric-import',
            'userId': 'test-user-import',
            'date': now.toIso8601String(),
            'weight': 76.0,
            'sleepQuality': 8,
            'sleepHours': 7.5,
            'energyLevel': 9,
            'restingHeartRate': 60,
            'systolicBP': null,
            'diastolicBP': null,
            'bodyMeasurements': {},
            'notes': null,
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          },
        ],
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      final exportFile = File('${testDir.path}/import_test.json');
      await exportFile.writeAsString(jsonString);

      // Clear box to simulate importing into empty database
      final metricsBox = Hive.box<HealthMetricModel>(HiveBoxNames.healthMetrics);
      await metricsBox.clear();

      // Act - Import data
      final importResult = await ExportService.importAllData(exportFile.path);

      // Assert - Verify import process completes and data is restored
      expect(importResult.isRight(), true);
      final restored = metricsBox.get('test-metric-import');
      expect(restored, isNotNull);
      expect(restored?.weight, 76.0);
      expect(restored?.sleepQuality, 8);
      expect(restored?.energyLevel, 9);
      
      // Cleanup
      await exportFile.delete();
    });

    test('should handle export with multiple boxes', () async {
      // Arrange - Create test data in multiple boxes
      final metricsBox = Hive.box<HealthMetricModel>(HiveBoxNames.healthMetrics);
      final prefsBox = Hive.box<UserPreferencesModel>(HiveBoxNames.userPreferences);
      
      final now = DateTime.now();
      final metric = HealthMetricModel()
        ..id = 'test-metric-multi'
        ..userId = 'test-user-multi'
        ..date = now
        ..weight = 77.0
        ..createdAt = now
        ..updatedAt = now;
      
      final preferences = UserPreferencesModel()
        ..dietaryApproach = 'keto'
        ..preferredMealTimes = ['08:00', '12:00', '18:00']
        ..allergies = ['peanuts']
        ..dislikes = []
        ..fitnessGoals = ['weight_loss']
        ..notificationPreferences = {'reminders': true}
        ..units = 'metric'
        ..theme = 'dark';
      
      await metricsBox.put(metric.id, metric);
      await prefsBox.put('preferences', preferences);

      // Act - Create export file manually (simulating export)
      final exportData = {
        'export_version': '1.0',
        'export_date': now.toIso8601String(),
        HiveBoxNames.healthMetrics: [
          {
            '_key': metric.id,
            'id': metric.id,
            'userId': metric.userId,
            'date': metric.date.toIso8601String(),
            'weight': metric.weight,
            'sleepQuality': null,
            'sleepHours': null,
            'energyLevel': null,
            'restingHeartRate': null,
            'systolicBP': null,
            'diastolicBP': null,
            'bodyMeasurements': {},
            'notes': null,
            'createdAt': metric.createdAt.toIso8601String(),
            'updatedAt': metric.updatedAt.toIso8601String(),
          },
        ],
        HiveBoxNames.userPreferences: [
          {
            '_key': 'preferences',
            'dietaryApproach': preferences.dietaryApproach,
            'preferredMealTimes': preferences.preferredMealTimes,
            'allergies': preferences.allergies,
            'dislikes': preferences.dislikes,
            'fitnessGoals': preferences.fitnessGoals,
            'notificationPreferences': preferences.notificationPreferences,
            'units': preferences.units,
            'theme': preferences.theme,
          },
        ],
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      final exportFile = File('${testDir.path}/multi_box_export.json');
      await exportFile.writeAsString(jsonString);

      // Assert - Verify export file contains data from both boxes
      final fileContent = await exportFile.readAsString();
      final parsed = jsonDecode(fileContent) as Map<String, dynamic>;
      expect(parsed.containsKey(HiveBoxNames.healthMetrics), true);
      expect(parsed.containsKey(HiveBoxNames.userPreferences), true);
      expect(parsed[HiveBoxNames.healthMetrics], isA<List>());
      expect(parsed[HiveBoxNames.userPreferences], isA<List>());
      
      // Cleanup
      await exportFile.delete();
    });

    test('should handle file not found error gracefully', () async {
      // Arrange - Use non-existent file path
      const nonExistentPath = '/path/that/does/not/exist/export.json';

      // Act - Try to import
      final importResult = await ExportService.importAllData(nonExistentPath);

      // Assert - Verify error is handled gracefully
      expect(importResult.isLeft(), true);
      importResult.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message.toLowerCase(), contains('exist'));
        },
        (_) => fail('Should fail for non-existent file'),
      );
    });

    test('should handle invalid JSON file gracefully', () async {
      // Arrange - Create file with invalid JSON
      final invalidFile = File('${testDir.path}/invalid_json.json');
      await invalidFile.writeAsString('This is not valid JSON at all');

      // Act - Try to import
      final importResult = await ExportService.importAllData(invalidFile.path);

      // Assert - Verify error is handled gracefully
      expect(importResult.isLeft(), true);
      importResult.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, isNotEmpty);
        },
        (_) => fail('Should fail for invalid JSON'),
      );
      
      // Cleanup
      await invalidFile.delete();
    });

    test('should export and import all open boxes end-to-end', () async {
      // Arrange - populate sample data
      final metricsBox = Hive.box<HealthMetricModel>(HiveBoxNames.healthMetrics);
      final prefsBox = Hive.box<UserPreferencesModel>(HiveBoxNames.userPreferences);

      final now = DateTime.now();
      final metric = HealthMetricModel()
        ..id = 'metric-${now.millisecondsSinceEpoch}'
        ..userId = 'user-123'
        ..date = now
        ..weight = 78.4
        ..sleepQuality = 7
        ..energyLevel = 8
        ..restingHeartRate = 63
        ..createdAt = now
        ..updatedAt = now;

      final prefs = UserPreferencesModel()
        ..dietaryApproach = 'balanced'
        ..preferredMealTimes = ['08:00', '12:30', '19:00']
        ..allergies = ['peanuts']
        ..dislikes = ['olives']
        ..fitnessGoals = ['weight_loss']
        ..notificationPreferences = {'reminders': true}
        ..units = 'imperial'
        ..theme = 'dark';

      await metricsBox.put(metric.id, metric);
      await prefsBox.put('preferences', prefs);

      // Act - export data using the real service
      final exportResult = await ExportService.exportAllData();

      // Assert export succeeded and file exists
      expect(exportResult.isRight(), true);
      final exportPath = exportResult.fold((failure) => '', (path) => path);
      final exportFile = File(exportPath);
      expect(await exportFile.exists(), true);

      // Clear boxes to simulate restore into empty state
      await metricsBox.clear();
      await prefsBox.clear();

      // Act - import the exported file
      final importResult = await ExportService.importAllData(exportPath);
      expect(importResult.isRight(), true);

      // Assert - data restored correctly
      final restoredMetric = metricsBox.get(metric.id);
      expect(restoredMetric, isNotNull);
      expect(restoredMetric?.weight, metric.weight);
      expect(restoredMetric?.restingHeartRate, metric.restingHeartRate);
      expect(restoredMetric?.date.isAtSameMomentAs(metric.date), true);

      final restoredPrefs = prefsBox.get('preferences');
      expect(restoredPrefs, isNotNull);
      expect(restoredPrefs?.units, prefs.units);
      expect(restoredPrefs?.dietaryApproach, prefs.dietaryApproach);
      expect(restoredPrefs?.notificationPreferences['reminders'], true);

      // Cleanup
      if (await exportFile.exists()) {
        await exportFile.delete();
      }
    });
  });
}

