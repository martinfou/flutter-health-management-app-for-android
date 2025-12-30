# Contribution Guide

## Overview

This guide outlines how to contribute to the Flutter Health Management App for Android project. We welcome contributions that improve the app's functionality, fix bugs, enhance documentation, or add new features.

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Follow project coding standards
- Write clear, maintainable code
- Test your changes thoroughly

## Development Workflow

### Branch Strategy

**Feature Branch Workflow** - All development on feature branches:

- **Feature**: `feature/FR-XXX-short-description`
- **Bug Fix**: `bugfix/BF-XXX-short-description`
- **Hotfix**: `hotfix/critical-issue-description`
- **Chore**: `chore/description`

**NEVER work directly on master/main branch.**

### Creating a Branch

```bash
# Update main branch
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/FR-042-7-day-moving-average

# Or bug fix branch
git checkout -b bugfix/BF-015-weight-chart-crash
```

### Making Changes

1. **Follow Architecture Patterns**:
   - Use feature-first clean architecture
   - Keep domain layer pure (no external dependencies)
   - Follow dependency rules (Presentation → Domain → Data)

2. **Follow Naming Conventions**:
   - Files: `snake_case.dart`
   - Classes: `PascalCase`
   - Variables/Methods: `camelCase`
   - Constants: `lowerCamelCase` with `k` prefix

3. **Write Tests**:
   - Unit tests for business logic (80% coverage target)
   - Widget tests for UI components (60% coverage target)
   - Integration tests for critical flows

4. **Follow Error Handling**:
   - Use `Either<Failure, T>` for operations that can fail
   - Never throw exceptions in domain layer
   - Return `Result<T>` from repositories and use cases

### Commit Messages

Follow the **CRISPE Framework** for commit messages:

```
<type>(<scope>): <subject>

<business-focused paragraph explaining why and user impact>

<technical paragraph with bullet points>
- Technical implementation detail 1
- Technical implementation detail 2
- Dependencies or system interactions
- Performance considerations

<footer with task reference>
```

**Commit Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`, `build`

**Commit Scopes**: `health-tracking`, `nutrition`, `exercise`, `core`, `llm` (post-MVP)

**Example**:
```
feat(health-tracking): Add 7-day moving average calculation

Users need to see meaningful weight trends that account for daily fluctuations. The 7-day moving average provides a smoothed view of weight progress, reducing anxiety from daily weight variations and helping users stay motivated.

- Implement CalculateMovingAverage use case with 7-day window
- Add MovingAverageCalculator utility service
- Update weight entry screen to display moving average
- Add "Insufficient data" message when less than 7 days of data
- Update HealthTrackingRepository to fetch historical data
- Add unit tests for edge cases (empty data, single day, etc.)

Refs FR-042
```

### Before Committing

Run these checks:

```bash
# Run linter
flutter analyze

# Run tests
flutter test

# Check test coverage
flutter test --coverage

# Fix auto-fixable issues
dart fix --apply
```

### Pull Request Process

1. **Update Your Branch**:
   ```bash
   git checkout main
   git pull origin main
   git checkout your-feature-branch
   git rebase main  # or merge main into your branch
   ```

2. **Create Pull Request**:
   - Use clear, descriptive title
   - Include description of changes
   - Reference related issues/tasks (e.g., "Refs FR-042")
   - List testing performed
   - Include screenshots for UI changes

3. **PR Checklist**:
   - [ ] Code follows architecture patterns
   - [ ] Tests written and passing
   - [ ] Test coverage maintained (80% unit, 60% widget)
   - [ ] No linter warnings
   - [ ] Error handling implemented
   - [ ] Documentation updated (if needed)
   - [ ] Commit messages follow CRISPE framework

4. **Code Review**:
   - Address review feedback
   - Update PR as needed
   - Ensure all CI checks pass

## Coding Standards

### File Organization

```dart
// 1. Dart SDK imports
import 'dart:async';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports
import 'package:riverpod/riverpod.dart';
import 'package:hive/hive.dart';

// 4. Project imports
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
```

### Type Safety

- Avoid `dynamic` types
- Use explicit types when type is not obvious
- Always handle null cases explicitly

### Error Handling

```dart
// Good: Use Either<Failure, T>
Future<Result<HealthMetric>> saveHealthMetric(HealthMetric metric) async {
  try {
    final saved = await repository.save(metric);
    return Right(saved);
  } on DatabaseException catch (e) {
    return Left(DatabaseFailure(e.message));
  }
}

// Bad: Throwing exceptions in domain layer
Future<HealthMetric> saveHealthMetric(HealthMetric metric) async {
  if (metric.weight <= 0) {
    throw Exception('Invalid weight'); // Don't do this
  }
  return await repository.save(metric);
}
```

### State Management

```dart
// Use Riverpod providers
final healthMetricsProvider = FutureProvider<List<HealthMetric>>((ref) async {
  final repository = ref.watch(healthTrackingRepositoryProvider);
  return await repository.getHealthMetrics();
});

// Use ConsumerWidget for UI
class HealthTrackingPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(healthMetricsProvider);
    // ...
  }
}
```

### Testing

```dart
// Unit test example
void main() {
  group('CalculateMovingAverage', () {
    test('should calculate 7-day average correctly', () {
      // Arrange
      final metrics = [...];
      final usecase = CalculateMovingAverage();
      
      // Act
      final result = usecase(metrics);
      
      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (average) => expect(average, closeTo(75.0, 0.1)),
      );
    });
  });
}
```

## Documentation

### Code Documentation

- Document public APIs with Dartdoc comments
- Add inline comments for complex logic
- Explain "why" not just "what"

```dart
/// Calculates the 7-day moving average of weight metrics.
/// 
/// Returns the average weight over the last 7 days (inclusive of today).
/// Returns [ValidationFailure] if metrics list is empty or has insufficient data.
/// 
/// The moving average helps smooth out daily weight fluctuations and provides
/// a more accurate view of weight trends.
Result<double> calculate7DayAverage(List<HealthMetric> metrics) {
  // Implementation
}
```

### Updating Documentation

- Update relevant documentation when adding features
- Keep architecture documentation current
- Update user documentation for user-facing changes
- Update API documentation for API changes (post-MVP)

## Testing Requirements

### Coverage Targets

- **Unit Tests**: 80% minimum coverage
- **Widget Tests**: 60% minimum coverage
- **Integration Tests**: Critical user flows

### Test Organization

Mirror `lib/` structure in `test/`:

```
test/
├── unit/
│   ├── core/
│   └── features/{feature}/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── widget/
│   └── features/{feature}/presentation/
└── integration/
```

### Running Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/unit/core/utils/calculation_utils_test.dart

# With coverage
flutter test --coverage
```

## Feature Development

### Adding a New Feature

1. **Create Feature Branch**:
   ```bash
   git checkout -b feature/FR-XXX-feature-name
   ```

2. **Set Up Feature Structure**:
   ```
   lib/features/{feature_name}/
   ├── data/
   ├── domain/
   └── presentation/
   ```

3. **Implement Feature**:
   - Start with domain layer (entities, use cases)
   - Implement data layer (models, repositories)
   - Build presentation layer (pages, widgets, providers)

4. **Write Tests**:
   - Unit tests for use cases
   - Widget tests for UI
   - Integration tests for flows

5. **Update Documentation**:
   - Update relevant docs
   - Add feature to user documentation if user-facing

6. **Create Pull Request**:
   - Follow PR process above
   - Reference feature request (FR-XXX)

## Bug Fixes

### Reporting Bugs

Create a bug fix document in `artifacts/phase-5-management/bug-fixes/`:

- Use template from `artifacts/phase-5-management/product-backlog-structure.md`
- Include steps to reproduce
- Describe expected vs actual behavior
- Include environment details

### Fixing Bugs

1. **Create Bug Fix Branch**:
   ```bash
   git checkout -b bugfix/BF-XXX-bug-description
   ```

2. **Fix the Bug**:
   - Identify root cause
   - Implement fix
   - Write tests to prevent regression
   - Update documentation if needed

3. **Test the Fix**:
   - Verify bug is fixed
   - Run all tests
   - Check for regressions

4. **Create Pull Request**:
   - Reference bug (BF-XXX)
   - Describe fix
   - Include testing performed

## Questions?

- Review project documentation in `artifacts/`
- Check architecture documentation: `artifacts/phase-1-foundations/architecture-documentation.md`
- See coding standards in repository rules
- Ask in project discussions/chat

---

**Last Updated**: 2025-01-02  
**Version**: 1.0  
**Status**: Contribution Guide Complete

