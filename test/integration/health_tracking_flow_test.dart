import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/pages/main_navigation_page.dart';
import 'package:health_app/core/providers/database_initializer.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/domain/repositories/health_tracking_repository.dart';
import 'package:health_app/features/health_tracking/data/repositories/health_tracking_repository_impl.dart';
import 'package:health_app/features/health_tracking/data/datasources/local/health_tracking_local_datasource.dart';
import 'package:health_app/features/health_tracking/data/models/health_metric_model.dart';
import 'package:health_app/core/providers/database_provider.dart';
import 'package:health_app/features/health_tracking/domain/usecases/save_health_metric.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_metrics_provider.dart';

/// Integration test for health tracking flow
/// 
/// Tests the complete workflow:
/// 1. Save weight entry
/// 2. Verify weight is saved
/// 3. Retrieve and verify weight metrics
void main() {
  group('Health Tracking Flow Integration Test', () {
    late ProviderContainer container;
    late HealthTrackingRepository repository;

    setUpAll(() async {
      // Initialize Hive for testing with a test directory
      // Use a temporary directory for test database
      final testDir = Directory.systemTemp.createTempSync('hive_test_');
      Hive.init(testDir.path);
      
      // Register adapters manually for testing
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(HealthMetricModelAdapter());
      }
      
      // Open test boxes with correct type
      if (!Hive.isBoxOpen(HiveBoxNames.healthMetrics)) {
        await Hive.openBox<HealthMetricModel>(HiveBoxNames.healthMetrics);
      }
    });

    setUp(() {
      container = ProviderContainer();
      final dataSource = HealthTrackingLocalDataSource();
      repository = HealthTrackingRepositoryImpl(dataSource);
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should save weight entry and retrieve it', (WidgetTester tester) async {
      // Arrange
      const userId = 'test-user-id';
      final testDate = DateTime.now();
      const testWeight = 75.5;

      // Create a test metric
      final metric = HealthMetric(
        id: 'test-metric-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        date: testDate,
        weight: testWeight,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act - Save the metric
      final saveResult = await repository.saveHealthMetric(metric);

      // Assert - Verify save was successful
      expect(saveResult.isRight(), true);
      saveResult.fold(
        (failure) {
          print('Save failed: ${failure.message}');
          fail('Save should succeed, but got: ${failure.message}');
        },
        (savedMetric) {
          expect(savedMetric.id, metric.id);
          expect(savedMetric.weight, testWeight);
          expect(savedMetric.userId, userId);
        },
      );

      // Act - Retrieve the metric
      final getResult = await repository.getHealthMetric(metric.id);

      // Assert - Verify retrieval was successful
      expect(getResult.isRight(), true);
      getResult.fold(
        (failure) => fail('Get should succeed, but got: ${failure.message}'),
        (retrievedMetric) {
          expect(retrievedMetric.id, metric.id);
          expect(retrievedMetric.weight, testWeight);
          expect(retrievedMetric.userId, userId);
        },
      );
    });

    testWidgets('should save multiple weight entries and retrieve by date range', (WidgetTester tester) async {
      // Arrange
      const userId = 'test-user-id';
      final now = DateTime.now();
      final dates = [
        now.subtract(Duration(days: 2)),
        now.subtract(Duration(days: 1)),
        now,
      ];
      final weights = [75.0, 74.8, 74.5];

      // Act - Save multiple metrics
      final savedMetrics = <HealthMetric>[];
      for (int i = 0; i < dates.length; i++) {
        final metric = HealthMetric(
          id: 'test-metric-$i-${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          date: dates[i],
          weight: weights[i],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final result = await repository.saveHealthMetric(metric);
        result.fold(
          (failure) => fail('Save should succeed: ${failure.message}'),
          (saved) => savedMetrics.add(saved),
        );
      }

      // Assert - Verify all metrics were saved
      expect(savedMetrics.length, 3);

      // Act - Retrieve metrics by date range
      final startDate = dates.first.subtract(Duration(days: 1));
      final endDate = dates.last.add(Duration(days: 1));
      final rangeResult = await repository.getHealthMetricsByDateRange(
        userId,
        startDate,
        endDate,
      );

      // Assert - Verify all metrics are retrieved
      expect(rangeResult.isRight(), true);
      rangeResult.fold(
        (failure) => fail('Get range should succeed: ${failure.message}'),
        (retrievedMetrics) {
          expect(retrievedMetrics.length, greaterThanOrEqualTo(3));
          // Verify weights are correct
          final retrievedWeights = retrievedMetrics
              .where((m) => m.weight != null)
              .map((m) => m.weight!)
              .toList();
          expect(retrievedWeights, containsAll(weights));
        },
      );
    });

    testWidgets('should use SaveHealthMetricUseCase to save weight', (WidgetTester tester) async {
      // Arrange
      const userId = 'test-user-id';
      final testDate = DateTime.now();
      const testWeight = 76.0;

      final useCase = SaveHealthMetricUseCase(repository);
      final metric = HealthMetric(
        id: '',
        userId: userId,
        date: testDate,
        weight: testWeight,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act - Save using use case
      final result = await useCase.call(metric);

      // Assert - Verify save was successful
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Use case should succeed: ${failure.message}'),
        (savedMetric) {
          expect(savedMetric.weight, testWeight);
          expect(savedMetric.userId, userId);
          expect(savedMetric.id.isNotEmpty, true); // ID should be generated
        },
      );
    });

    testWidgets('should validate weight range when saving', (WidgetTester tester) async {
      // Arrange
      const userId = 'test-user-id';
      final testDate = DateTime.now();
      const invalidWeight = 20.0; // Below minimum (30kg)

      final metric = HealthMetric(
        id: 'test-invalid',
        userId: userId,
        date: testDate,
        weight: invalidWeight,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act - Try to save invalid weight
      final result = await repository.saveHealthMetric(metric);

      // Assert - Verify validation failure
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, anyOf(contains('weight'), contains('Weight')));
        },
        (_) => fail('Should fail validation for weight below minimum'),
      );
    });
  });
}

