# Testing Strategy

## Overview

This document defines the comprehensive testing strategy for the Flutter Health Management App for Android, targeting 80% minimum unit test coverage for business logic and 60% minimum widget test coverage for UI components.

**Reference**: 
- Requirements: `artifacts/requirements.md`
- Architecture: `artifacts/phase-1-foundations/architecture-documentation.md`
- Feature Specs: `artifacts/phase-2-features/`

## Test Coverage Requirements

### Unit Tests

**Target Coverage**: 80% minimum for business logic (domain layer)

**Focus Areas**:
- Use cases (business logic)
- Calculations (moving averages, macro calculations)
- Validations (data validation, business rules)
- Algorithms (plateau detection, baseline calculation)
- Domain entities (business logic methods)

**Test Location**: `test/unit/features/{feature}/domain/`

**Coverage Measurement**:
- Use `flutter test --coverage`
- Generate coverage report with `genhtml`
- Enforce 80% minimum coverage in CI/CD

### Widget Tests

**Target Coverage**: 60% minimum for UI components

**Focus Areas**:
- Custom widgets
- User interactions
- State management (Riverpod providers)
- Form validation UI
- Navigation flows

**Test Location**: `test/widget/features/{feature}/presentation/`

**Coverage Measurement**:
- Use `flutter test --coverage`
- Focus on custom widgets, not Material widgets
- Enforce 60% minimum coverage in CI/CD

### Integration Tests

**Target Coverage**: Critical user flows

**Focus Areas**:
- Complete user workflows
- Cross-module interactions
- Data persistence
- API integrations (post-MVP)

**Test Location**: `test/integration/`

### End-to-End Tests

**Target Coverage**: Key workflows

**Focus Areas**:
- Complete user journeys
- Multi-screen flows
- Real device testing

**Test Location**: `integration_test/`

## Test Organization

### Directory Structure

```
test/
├── unit/
│   ├── core/
│   │   ├── utils/
│   │   └── errors/
│   └── features/
│       ├── health_tracking/
│       │   ├── domain/
│       │   │   └── usecases/
│       │   └── data/
│       ├── nutrition_management/
│       └── exercise_management/
├── widget/
│   └── features/
│       ├── health_tracking/
│       │   └── presentation/
│       └── nutrition_management/
├── integration/
│   ├── health_tracking_flow_test.dart
│   └── nutrition_logging_flow_test.dart
└── fixtures/
    ├── health_metrics_fixture.dart
    ├── meals_fixture.dart
    └── workouts_fixture.dart
```

## Test Types

### Unit Tests

**Purpose**: Test individual units of code in isolation

**Testing Framework**: `flutter_test`

**Example**:
```dart
void main() {
  group('CalculateMovingAverage', () {
    test('should calculate 7-day average correctly', () {
      // Arrange
      final metrics = [
        HealthMetric(id: '1', date: DateTime.now().subtract(Duration(days: 6)), weight: 75.0),
        HealthMetric(id: '2', date: DateTime.now().subtract(Duration(days: 5)), weight: 74.8),
        // ... more test data
      ];
      final usecase = CalculateMovingAverage();
      
      // Act
      final result = usecase(metrics);
      
      // Assert
      expect(result, isNotNull);
      expect(result, closeTo(75.0, 0.1));
    });
  });
}
```

### Widget Tests

**Purpose**: Test UI components and user interactions

**Testing Framework**: `flutter_test`

**Example**:
```dart
void main() {
  testWidgets('WeightEntryPage displays correctly', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: WeightEntryPage(),
      ),
    );
    
    // Act & Assert
    expect(find.text('Weight Entry'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Save Weight'), findsOneWidget);
  });
}
```

### Integration Tests

**Purpose**: Test complete workflows across modules

**Testing Framework**: `integration_test`

**Example**:
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Complete weight entry flow', (WidgetTester tester) async {
    // Navigate to weight entry
    // Enter weight
    // Save
    // Verify saved
  });
}
```

## Test Data and Fixtures

### Health Metrics Fixtures

```dart
class HealthMetricsFixture {
  static HealthMetric createWeightMetric({
    double weight = 75.0,
    DateTime? date,
  }) {
    return HealthMetric(
      id: 'test-id',
      userId: 'test-user',
      date: date ?? DateTime.now(),
      weight: weight,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  static List<HealthMetric> create7DayWeightSeries() {
    return List.generate(7, (index) => createWeightMetric(
      weight: 75.0 - (index * 0.1),
      date: DateTime.now().subtract(Duration(days: 6 - index)),
    ));
  }
}
```

### Meal Fixtures

```dart
class MealsFixture {
  static Meal createMeal({
    double protein = 30.0,
    double fats = 40.0,
    double netCarbs = 20.0,
  }) {
    return Meal(
      id: 'test-meal-id',
      userId: 'test-user',
      date: DateTime.now(),
      mealType: MealType.breakfast,
      name: 'Test Meal',
      protein: protein,
      fats: fats,
      netCarbs: netCarbs,
      calories: (protein * 4) + (fats * 9) + (netCarbs * 4),
      ingredients: [],
      createdAt: DateTime.now(),
    );
  }
}
```

## Mock Objects

### Mock LLM Provider

```dart
class MockLLMProvider implements LLMProvider {
  @override
  Future<LLMResponse> generateCompletion(LLMRequest request) async {
    return LLMResponse(
      content: 'Mock response',
      tokensUsed: 100,
    );
  }
  
  @override
  String get providerName => 'mock';
  
  @override
  bool get supportsStreaming => false;
}
```

### Mock Repository

```dart
class MockHealthTrackingRepository implements HealthTrackingRepository {
  final List<HealthMetric> _metrics = [];
  
  @override
  Future<Either<Failure, HealthMetric>> saveHealthMetric(HealthMetric metric) async {
    _metrics.add(metric);
    return Right(metric);
  }
  
  @override
  Future<Either<Failure, List<HealthMetric>>> getHealthMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return Right(_metrics);
  }
}
```

### Mock Database

```dart
class MockHiveDatabase {
  final Map<String, dynamic> _data = {};
  
  Future<void> put(String key, dynamic value) async {
    _data[key] = value;
  }
  
  T? get<T>(String key) {
    return _data[key] as T?;
  }
  
  Future<void> delete(String key) async {
    _data.remove(key);
  }
}
```

## Testing Automation

### CI/CD Integration

**GitHub Actions Workflow**:
```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - run: flutter test integration_test/
      - uses: codecov/codecov-action@v2
```

### Coverage Reporting

**Requirements**:
- Generate coverage report on every test run
- Upload to code coverage service (Codecov)
- Enforce coverage thresholds in CI/CD
- Display coverage badges in README

## Performance Testing

Performance testing ensures the app meets performance benchmarks and provides a smooth user experience.

### Performance Benchmarks

**Specific Benchmarks**:

#### App Launch Time
- **Target**: < 2 seconds (cold start)
- **Measurement**: Time from app launch to main screen visible
- **Tools**: Flutter DevTools, Android Profiler
- **Test Conditions**: 
  - Cold start (app not in memory)
  - Warm start (app in background)
  - Device: Mid-range Android device (API 24+)

**Implementation**:
```dart
void main() {
  final stopwatch = Stopwatch()..start();
  
  runApp(MyApp());
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    stopwatch.stop();
    debugPrint('App launch time: ${stopwatch.elapsedMilliseconds}ms');
    
    if (stopwatch.elapsedMilliseconds > 2000) {
      debugPrint('⚠️ App launch exceeded 2 second target');
    }
  });
}
```

#### Screen Navigation
- **Target**: < 300ms for screen transitions
- **Measurement**: Time from navigation trigger to screen fully rendered
- **Test Conditions**: Navigate between main screens (Health Tracking, Nutrition, Exercise)
- **Acceptance Criteria**: Smooth 60 FPS animation

**Measurement**:
```dart
void navigateToScreen(String route) {
  final stopwatch = Stopwatch()..start();
  
  Navigator.pushNamed(context, route).then((_) {
    stopwatch.stop();
    debugPrint('Navigation to $route: ${stopwatch.elapsedMilliseconds}ms');
    
    if (stopwatch.elapsedMilliseconds > 300) {
      debugPrint('⚠️ Navigation exceeded 300ms target');
    }
  });
}
```

#### Data Loading Performance
- **Initial Load**: < 500ms for initial data load
- **Pagination Load**: < 200ms for next page
- **Database Query**: < 100ms for filtered queries
- **Test Data**: 
  - 1,000 health metrics
  - 500 meals
  - 200 exercises

**Measurement**:
```dart
Future<void> loadHealthMetrics() async {
  final stopwatch = Stopwatch()..start();
  
  final metrics = await repository.getHealthMetrics();
  
  stopwatch.stop();
  debugPrint('Data load time: ${stopwatch.elapsedMilliseconds}ms');
  
  if (stopwatch.elapsedMilliseconds > 500) {
    debugPrint('⚠️ Data load exceeded 500ms target');
  }
  
  return metrics;
}
```

#### Chart Rendering Performance
- **30 Days Data**: < 1 second for chart rendering
- **90 Days Data**: < 2 seconds for chart rendering
- **365 Days Data**: < 3 seconds for chart rendering (with data sampling)
- **Test Conditions**: Weight trend chart, macro chart

**Measurement**:
```dart
void renderChart(List<HealthMetric> metrics) {
  final stopwatch = Stopwatch()..start();
  
  // Render chart widget
  final chartWidget = WeightTrendChart(metrics: metrics);
  
  stopwatch.stop();
  debugPrint('Chart render time: ${stopwatch.elapsedMilliseconds}ms');
  
  if (stopwatch.elapsedMilliseconds > 1000) {
    debugPrint('⚠️ Chart rendering exceeded 1 second target');
  }
}
```

#### Image Loading Performance
- **Progress Photo Load**: < 500ms per image
- **Thumbnail Load**: < 200ms per thumbnail
- **Image Compression**: < 1 second for compression
- **Test Conditions**: 10 progress photos, various sizes

#### Calculation Performance
- **7-Day Moving Average**: < 50ms calculation time
- **Plateau Detection**: < 100ms for 21 days of data
- **Macro Calculation**: < 30ms for daily totals
- **Streak Calculation**: < 20ms per habit

**Measurement**:
```dart
double? calculate7DayAverage(List<HealthMetric> metrics) {
  final stopwatch = Stopwatch()..start();
  
  // Calculation logic
  final average = _calculateAverage(metrics);
  
  stopwatch.stop();
  debugPrint('7-day average calculation: ${stopwatch.elapsedMilliseconds}ms');
  
  if (stopwatch.elapsedMilliseconds > 50) {
    debugPrint('⚠️ Calculation exceeded 50ms target');
  }
  
  return average;
}
```

### Performance Test Scenarios

**1. Large Dataset Handling**:
- **Scenario**: App with 10,000+ health metrics
- **Tests**:
  - Load health metrics list (should use pagination)
  - Filter metrics by date range
  - Render charts with large datasets
  - Search through large datasets
- **Acceptance Criteria**: 
  - No UI freezing
  - Smooth scrolling
  - Acceptable load times (< 2 seconds for initial load)

**2. Concurrent Operations**:
- **Scenario**: Multiple operations happening simultaneously
- **Tests**:
  - Save health metric while loading chart data
  - Calculate averages while rendering UI
  - Sync data while user navigates
- **Acceptance Criteria**: 
  - No crashes
  - No UI freezing
  - All operations complete successfully

**3. Low-End Device Testing**:
- **Scenario**: Test on low-end Android device (API 24, 2GB RAM)
- **Tests**:
  - App launch time
  - Screen navigation
  - Data loading
  - Chart rendering
- **Acceptance Criteria**: 
  - Benchmarks acceptable for low-end device (2x target times)
  - No crashes or freezes
  - Acceptable user experience

### Memory Testing

**Memory Benchmarks**:
- **App Baseline**: < 100MB memory usage (idle state)
- **Active Use**: < 200MB memory usage (actively using app)
- **Peak Memory**: < 300MB memory usage (worst case scenario)
- **Memory Leaks**: No continuous memory growth over 30 minutes of use

**Requirements**:
- No memory leaks in long-running sessions
- Efficient image handling (progress photos)
- Proper disposal of resources
- Garbage collection doesn't cause UI jank

**Testing Method**:
```dart
void monitorMemoryUsage() {
  final observer = MemoryObserver();
  
  observer.startMonitoring();
  
  // Perform app operations
  
  observer.stopMonitoring();
  observer.generateReport();
}

class MemoryObserver {
  final List<int> memorySamples = [];
  Timer? _timer;
  
  void startMonitoring() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      final memory = _getCurrentMemoryUsage();
      memorySamples.add(memory);
      
      if (memory > 300 * 1024 * 1024) { // 300MB
        debugPrint('⚠️ High memory usage: ${memory ~/ 1024 ~/ 1024}MB');
      }
    });
  }
  
  void stopMonitoring() {
    _timer?.cancel();
  }
  
  void generateReport() {
    if (memorySamples.isEmpty) return;
    
    final avg = memorySamples.reduce((a, b) => a + b) / memorySamples.length;
    final max = memorySamples.reduce((a, b) => a > b ? a : b);
    final min = memorySamples.reduce((a, b) => a < b ? a : b);
    
    debugPrint('Memory Usage Report:');
    debugPrint('  Average: ${(avg ~/ 1024 ~/ 1024)}MB');
    debugPrint('  Max: ${(max ~/ 1024 ~/ 1024)}MB');
    debugPrint('  Min: ${(min ~/ 1024 ~/ 1024)}MB');
  }
  
  int _getCurrentMemoryUsage() {
    // Use Dart VM service or platform-specific APIs
    return 0; // Placeholder
  }
}
```

### Load Testing

**Load Test Scenarios**:

**1. Large Dataset Queries**:
- **Test**: Query 10,000+ health metrics
- **Requirements**:
  - Efficient queries with large datasets
  - Pagination works correctly
  - No memory overflow
- **Acceptance Criteria**: Query completes in < 1 second

**2. Large List Rendering**:
- **Test**: Render list with 1,000+ items
- **Requirements**:
  - Smooth scrolling (60 FPS)
  - Lazy loading works correctly
  - No memory issues
- **Acceptance Criteria**: Smooth scrolling, no jank

**3. Concurrent Data Operations**:
- **Test**: Multiple users/app instances (simulated)
- **Requirements**:
  - Database handles concurrent reads/writes
  - No data corruption
  - Acceptable performance
- **Acceptance Criteria**: All operations complete successfully

### Performance Testing Tools

**Flutter DevTools**:
- Performance view for frame rendering
- Memory view for memory profiling
- Timeline view for performance analysis

**Android Profiler**:
- CPU profiling
- Memory profiling
- Network profiling (post-MVP)

**Custom Performance Monitoring**:
- Track key performance metrics
- Log performance issues
- Alert on performance degradation

### Performance Regression Testing

**Baseline Metrics**:
- Establish baseline performance metrics
- Store baseline in version control
- Compare against baseline on each release

**Regression Detection**:
- Automatically detect performance regressions
- Alert on significant performance degradation (> 20% slower)
- Require investigation before release

## Accessibility Testing

### WCAG 2.1 AA Compliance

**Requirements**:
- Color contrast: 4.5:1 minimum for normal text
- Touch targets: 48x48dp minimum
- Screen reader support: All interactive elements labeled
- Keyboard navigation: All features accessible via keyboard

### Testing Tools

- Flutter's `Semantics` widget testing
- Screen reader testing (TalkBack)
- High contrast mode testing
- Text scaling testing (up to 200%)

## Test Execution

### Local Testing

**Commands**:
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/features/health_tracking/domain/usecases/calculate_moving_average_test.dart

# Run integration tests
flutter test integration_test/
```

### CI/CD Testing

**Automated Execution**:
- Run on every push
- Run on pull requests
- Block merge if tests fail
- Block merge if coverage below threshold

## References

- **Requirements**: `artifacts/requirements.md`
- **Architecture**: `artifacts/phase-1-foundations/architecture-documentation.md`
- **Test Specs**: `artifacts/phase-4-testing/test-specifications.md`

---

**Last Updated**: [Date]  
**Version**: 1.0  
**Status**: Testing Strategy Complete

