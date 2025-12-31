# Developer Setup Guide

## Overview

This guide provides step-by-step instructions for setting up the development environment for the Flutter Health Management App for Android.

## Prerequisites

### Required Software

- **Flutter SDK**: 3.24.0 or higher (LTS version)
  - Download from: https://flutter.dev/docs/get-started/install
  - Verify installation: `flutter doctor`

- **Dart SDK**: 3.3.0 or higher (included with Flutter)

- **Android Studio**: Latest version
  - Download from: https://developer.android.com/studio
  - Install Android SDK (API 24-34)
  - Install Flutter and Dart plugins

- **Android SDK**: 
  - Minimum: API 24 (Android 7.0 Nougat)
  - Target: API 34 (Android 14)
  - Install via Android Studio SDK Manager

- **Git**: For version control
  - Download from: https://git-scm.com/

### Optional Tools

- **VS Code**: With Flutter and Dart extensions
- **Android Device**: Physical device for testing (recommended)
- **Android Emulator**: For testing without physical device

## Initial Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd flutter-health-management-app-for-android
```

### 2. Install Dependencies

```bash
flutter pub get
```

This installs all packages defined in `pubspec.yaml`.

### 3. Run Code Generation

If Hive models require code generation:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Verify Setup

Run Flutter doctor to check your setup:

```bash
flutter doctor
```

Ensure all required components show as installed and configured.

### 5. Run the App

**On connected device/emulator**:
```bash
flutter run
```

**On specific device**:
```bash
flutter devices  # List available devices
flutter run -d <device-id>
```

**In debug mode** (default):
```bash
flutter run --debug
```

**In release mode**:
```bash
flutter run --release
```

## Project Structure

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App-wide constants
│   ├── errors/             # Error handling
│   ├── utils/              # Utility functions
│   ├── widgets/            # Reusable widgets
│   ├── providers/          # Global Riverpod providers
│   ├── pages/              # Core pages (Settings, Export, Import)
│   └── navigation/         # Navigation configuration
├── features/               # Feature modules
│   ├── health_tracking/    # Health tracking feature
│   ├── nutrition_management/  # Nutrition feature
│   ├── exercise_management/   # Exercise feature
│   ├── medication_management/ # Medication feature
│   ├── behavioral_support/    # Habits and goals
│   └── user_profile/          # User profile
└── main.dart               # App entry point

test/
├── unit/                   # Unit tests
├── widget/                 # Widget tests
└── integration/            # Integration tests
```

## Development Workflow

### Running Tests

**All Tests**:
```bash
flutter test
```

**Unit Tests Only**:
```bash
flutter test test/unit/
```

**Widget Tests Only**:
```bash
flutter test test/widget/
```

**Integration Tests Only**:
```bash
flutter test test/integration/
```

**Specific Test File**:
```bash
flutter test test/unit/core/utils/calculation_utils_test.dart
```

### Code Generation

When Hive models are modified, regenerate code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Watch mode (auto-regenerate on changes):
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Code Analysis

**Run Linter**:
```bash
flutter analyze
```

**Fix Auto-fixable Issues**:
```bash
dart fix --apply
```

### Coverage Reports

**Generate Coverage**:
```bash
flutter test --coverage
```

**View Coverage Report** (requires lcov):
```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
# or
xdg-open coverage/html/index.html  # Linux
```

## Building for Release

### Debug Build

```bash
flutter build apk --debug
```

### Release Build

**APK** (for direct installation):
```bash
flutter build apk --release
```

**App Bundle** (for Google Play Store):
```bash
flutter build appbundle --release
```

Output location: `build/app/outputs/`

### Signing Configuration

For release builds, configure app signing in:
- `android/app/build.gradle.kts`
- Create `android/key.properties` (not committed to git)

See `../../project-management/artifacts/deployment-guide.md` for detailed signing instructions.

## Architecture Guidelines

### Feature-First Clean Architecture

Each feature follows a three-layer architecture:

```
lib/features/{feature_name}/
├── data/              # Data layer
│   ├── models/        # DTOs
│   ├── repositories/  # Repository implementations
│   └── datasources/   # Data sources (local/remote)
├── domain/            # Domain layer (pure Dart)
│   ├── entities/     # Business entities
│   ├── repositories/ # Repository interfaces
│   └── usecases/     # Business logic
└── presentation/      # Presentation layer
    ├── pages/         # Screens
    ├── widgets/       # Feature widgets
    └── providers/     # Riverpod providers
```

### Dependency Rules

- **Presentation** → **Domain** → **Data**
- **Domain** has NO external dependencies
- Features must NOT import from other features
- Shared code goes in `lib/core/`

### State Management

Use **Riverpod** for state management:

- Global providers: `lib/core/providers/`
- Feature providers: `lib/features/{feature}/presentation/providers/`
- Use `ConsumerWidget` or `ConsumerStatefulWidget` for UI

### Error Handling

Always use `Either<Failure, T>` (from fpdart) for operations that can fail:

```dart
typedef Result<T> = Either<Failure, T>;

Future<Result<HealthMetric>> saveHealthMetric(HealthMetric metric) async {
  try {
    final saved = await repository.save(metric);
    return Right(saved);
  } on DatabaseException catch (e) {
    return Left(DatabaseFailure(e.message));
  }
}
```

## Common Tasks

### Adding a New Feature

1. Create feature directory: `lib/features/{feature_name}/`
2. Set up three-layer structure (data, domain, presentation)
3. Create entities, models, repositories, use cases
4. Implement UI with Riverpod providers
5. Add navigation routes
6. Write tests (unit, widget, integration)

### Adding a New Dependency

1. Add to `pubspec.yaml`:
   ```yaml
   dependencies:
     package_name: ^version
   ```

2. Install:
   ```bash
   flutter pub get
   ```

3. Update `pubspec.lock` (automatic)

### Database Changes

1. Modify Hive model (add `@HiveType` and `@HiveField`)
2. Update model adapter registration
3. Run code generation:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Update database initializer if needed
5. Write migration logic if schema changed

## Troubleshooting

### Flutter Doctor Issues

**Android License Issues**:
```bash
flutter doctor --android-licenses
```

**Missing Android SDK**:
- Open Android Studio
- Go to Settings > Appearance & Behavior > System Settings > Android SDK
- Install required SDK platforms and build tools

### Build Issues

**Clean Build**:
```bash
flutter clean
flutter pub get
flutter run
```

**Clear Build Cache**:
```bash
flutter clean
rm -rf build/
flutter pub get
```

### Dependency Issues

**Update Dependencies**:
```bash
flutter pub upgrade
```

**Clear Pub Cache**:
```bash
flutter pub cache repair
```

### Code Generation Issues

**Clean and Regenerate**:
```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

## Resources

- **Flutter Documentation**: https://flutter.dev/docs
- **Dart Documentation**: https://dart.dev/guides
- **Riverpod Documentation**: https://riverpod.dev/
- **Hive Documentation**: https://docs.hivedb.dev/
- **Project Architecture**: `../../project-management/artifacts/phase-1-foundations/architecture-documentation.md`
- **Testing Strategy**: `../../project-management/artifacts/phase-4-testing/testing-strategy.md`

## Getting Help

- Review project documentation in `../../project-management/artifacts/`
- Check `../../project-management/artifacts/phase-1-foundations/architecture-documentation.md` for architecture details
- See `../../project-management/artifacts/phase-4-testing/testing-strategy.md` for testing guidelines
- Refer to Flutter and Dart official documentation

---

**Last Updated**: 2025-01-02  
**Version**: 1.0  
**Status**: Developer Setup Guide Complete

