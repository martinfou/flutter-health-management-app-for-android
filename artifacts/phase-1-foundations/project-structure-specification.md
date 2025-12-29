# Project Structure Specification

## Overview

This document defines the complete folder organization and file structure for the Flutter Health Management App for Android. The structure follows Feature-First Clean Architecture principles, ensuring clear separation of concerns, testability, and maintainability.

**Reference**: This structure is based on the architecture defined in `artifacts/phase-1-foundations/architecture-documentation.md` and technical decisions in `artifacts/requirements.md`.

## Root Directory Structure

```
flutter-health-management-app-for-android/
├── android/                    # Android platform-specific code
├── ios/                        # iOS platform-specific code (not used for MVP)
├── lib/                        # Main application code
├── test/                       # Test files (mirrors lib/ structure)
├── integration_test/          # End-to-end integration tests
├── docs/                       # Project documentation
├── artifacts/                  # Orchestration artifacts and specifications
├── reference-material/         # Health domain reference materials
├── pubspec.yaml               # Flutter dependencies
├── analysis_options.yaml      # Linter configuration
├── README.md                  # Project README
└── .gitignore                 # Git ignore rules
```

## Main Application Code (`lib/`)

### Core Structure

```
lib/
├── core/                      # Shared utilities, constants, widgets
│   ├── constants/
│   ├── errors/
│   ├── network/              # Network utilities (post-MVP)
│   ├── llm/                  # LLM abstraction layer (post-MVP)
│   ├── utils/
│   ├── widgets/
│   └── providers/            # Global Riverpod providers
├── features/                  # Feature modules (Feature-First Architecture)
│   ├── health_tracking/
│   ├── nutrition_management/
│   ├── exercise_management/
│   ├── medication_management/
│   ├── behavioral_support/
│   ├── analytics_insights/
│   └── llm_integration/      # LLM integration feature (post-MVP)
├── main.dart                 # Application entry point
└── app.dart                  # Root app widget with Riverpod setup
```

## Core Layer (`lib/core/`)

### Purpose

The core layer contains shared utilities, constants, error handling, widgets, and infrastructure that is used across all features. This layer has no dependencies on feature modules.

### Structure

```
lib/core/
├── constants/
│   ├── app_constants.dart           # App-wide constants
│   ├── health_constants.dart        # Health domain constants
│   ├── ui_constants.dart            # UI-related constants
│   └── api_constants.dart           # API endpoints (post-MVP)
├── errors/
│   ├── failures.dart                # Failure classes for error handling
│   ├── exceptions.dart              # Custom exceptions
│   └── error_handler.dart           # Global error handler
├── network/                         # Network utilities (post-MVP)
│   ├── api_client.dart              # HTTP client wrapper
│   ├── interceptors.dart             # Request/response interceptors
│   └── network_info.dart            # Network connectivity checker
├── llm/                             # LLM abstraction layer (post-MVP)
│   ├── llm_provider.dart            # LLM provider interface
│   ├── llm_provider_factory.dart    # Provider factory
│   ├── llm_config.dart              # LLM configuration
│   ├── adapters/
│   │   ├── deepseek_adapter.dart    # DeepSeek API adapter
│   │   ├── openai_adapter.dart      # OpenAI API adapter
│   │   ├── anthropic_adapter.dart   # Anthropic API adapter
│   │   └── ollama_adapter.dart      # Ollama adapter
│   └── models/
│       ├── llm_request.dart         # LLM request model
│       └── llm_response.dart        # LLM response model
├── utils/
│   ├── date_utils.dart              # Date manipulation utilities
│   ├── validation_utils.dart        # Input validation utilities
│   ├── calculation_utils.dart       # Calculation helpers
│   └── format_utils.dart             # Formatting utilities
├── widgets/
│   ├── loading_indicator.dart       # Loading spinner widget
│   ├── error_widget.dart            # Error display widget
│   ├── empty_state_widget.dart      # Empty state widget
│   └── custom_button.dart           # Reusable button widget
└── providers/
    ├── database_provider.dart        # Hive database provider
    ├── llm_provider.dart             # LLM service provider (post-MVP)
    └── config_provider.dart          # App configuration provider
```

### Core Files Description

#### Constants

- **app_constants.dart**: App-wide constants (app name, version, etc.)
- **health_constants.dart**: Health domain constants (KPI thresholds, alert limits, etc.)
- **ui_constants.dart**: UI constants (padding, spacing, animation durations)
- **api_constants.dart**: API endpoints and configuration (post-MVP)

#### Errors

- **failures.dart**: Failure classes using `fpdart` Either type
- **exceptions.dart**: Custom exception classes
- **error_handler.dart**: Global error handling and logging

#### Network (Post-MVP)

- **api_client.dart**: HTTP client wrapper with error handling
- **interceptors.dart**: Request/response interceptors (auth, logging)
- **network_info.dart**: Network connectivity checking

#### LLM (Post-MVP)

- **llm_provider.dart**: Abstract interface for LLM providers
- **llm_provider_factory.dart**: Factory for creating provider instances
- **llm_config.dart**: Configuration model for LLM settings
- **adapters/**: Provider-specific adapter implementations

#### Utils

- **date_utils.dart**: Date manipulation (7-day windows, date formatting)
- **validation_utils.dart**: Input validation (weight ranges, macro limits)
- **calculation_utils.dart**: Calculation helpers (moving averages, percentages)
- **format_utils.dart**: Formatting utilities (weight display, date formatting)

#### Widgets

- **loading_indicator.dart**: Reusable loading spinner
- **error_widget.dart**: Error display with retry option
- **empty_state_widget.dart**: Empty state display (no data)
- **custom_button.dart**: Reusable button with consistent styling

#### Providers

- **database_provider.dart**: Hive database instance provider
- **llm_provider.dart**: LLM service provider (post-MVP)
- **config_provider.dart**: App configuration provider

## Feature Modules (`lib/features/`)

### Feature Structure Pattern

Each feature follows the same three-layer structure:

```
lib/features/{feature_name}/
├── data/
│   ├── models/                    # Data transfer objects (DTOs)
│   ├── repositories/              # Repository implementations
│   └── datasources/               # Data sources (local, remote)
├── domain/
│   ├── entities/                  # Business entities
│   ├── repositories/              # Repository interfaces
│   └── usecases/                  # Business logic use cases
└── presentation/
    ├── pages/                     # Feature screens
    ├── widgets/                   # Feature-specific widgets
    └── providers/                 # Riverpod providers
```

### Health Tracking Feature

```
lib/features/health_tracking/
├── data/
│   ├── models/
│   │   ├── health_metric_model.dart        # HealthMetric DTO
│   │   ├── body_measurement_model.dart     # BodyMeasurement DTO
│   │   └── progress_photo_model.dart        # ProgressPhoto DTO
│   ├── repositories/
│   │   └── health_tracking_repository_impl.dart
│   └── datasources/
│       ├── local/
│       │   └── health_tracking_local_datasource.dart
│       └── remote/ (post-MVP)
│           └── health_tracking_remote_datasource.dart
├── domain/
│   ├── entities/
│   │   ├── health_metric.dart               # HealthMetric entity
│   │   ├── body_measurement.dart            # BodyMeasurement entity
│   │   └── progress_photo.dart              # ProgressPhoto entity
│   ├── repositories/
│   │   └── health_tracking_repository.dart  # Repository interface
│   └── usecases/
│       ├── calculate_moving_average.dart    # 7-day moving average
│       ├── detect_plateau.dart              # Plateau detection
│       ├── get_weight_trend.dart            # Weight trend analysis
│       └── save_health_metric.dart          # Save metric use case
└── presentation/
    ├── pages/
    │   ├── health_tracking_page.dart       # Main tracking screen
    │   ├── weight_entry_page.dart           # Weight entry screen
    │   ├── measurements_page.dart            # Body measurements screen
    │   └── progress_photos_page.dart        # Progress photos screen
    ├── widgets/
    │   ├── weight_chart_widget.dart         # Weight trend chart
    │   ├── metric_card_widget.dart          # Metric display card
    │   └── measurement_form_widget.dart      # Measurement entry form
    └── providers/
        ├── health_metrics_provider.dart      # Metrics list provider
        ├── weight_trend_provider.dart        # Weight trend provider
        └── moving_average_provider.dart      # Moving average provider
```

### Nutrition Management Feature

```
lib/features/nutrition_management/
├── data/
│   ├── models/
│   │   ├── meal_model.dart                  # Meal DTO
│   │   ├── food_item_model.dart             # FoodItem DTO
│   │   ├── recipe_model.dart                # Recipe DTO
│   │   └── macro_summary_model.dart         # MacroSummary DTO
│   ├── repositories/
│   │   └── nutrition_repository_impl.dart
│   └── datasources/
│       ├── local/
│       │   └── nutrition_local_datasource.dart
│       └── remote/ (post-MVP)
│           └── nutrition_remote_datasource.dart
├── domain/
│   ├── entities/
│   │   ├── meal.dart                        # Meal entity
│   │   ├── food_item.dart                   # FoodItem entity
│   │   ├── recipe.dart                      # Recipe entity
│   │   └── macro_summary.dart               # MacroSummary entity
│   ├── repositories/
│   │   └── nutrition_repository.dart        # Repository interface
│   └── usecases/
│       ├── calculate_macros.dart            # Macro calculation
│       ├── log_meal.dart                    # Log meal use case
│       ├── get_daily_macro_summary.dart     # Daily macro summary
│       └── search_recipes.dart              # Recipe search
└── presentation/
    ├── pages/
    │   ├── nutrition_page.dart              # Main nutrition screen
    │   ├── meal_logging_page.dart           # Meal logging screen
    │   ├── recipe_library_page.dart          # Recipe library screen
    │   └── macro_tracking_page.dart          # Macro tracking screen
    ├── widgets/
    │   ├── macro_chart_widget.dart          # Macro visualization
    │   ├── meal_card_widget.dart            # Meal display card
    │   └── recipe_card_widget.dart          # Recipe display card
    └── providers/
        ├── daily_meals_provider.dart         # Daily meals provider
        ├── macro_summary_provider.dart       # Macro summary provider
        └── recipes_provider.dart             # Recipes provider
```

### Exercise Management Feature

```
lib/features/exercise_management/
├── data/
│   ├── models/
│   │   ├── workout_model.dart               # Workout DTO
│   │   ├── exercise_model.dart              # Exercise DTO
│   │   └── workout_plan_model.dart          # WorkoutPlan DTO
│   ├── repositories/
│   │   └── exercise_repository_impl.dart
│   └── datasources/
│       ├── local/
│       │   └── exercise_local_datasource.dart
│       └── remote/ (post-MVP)
│           └── exercise_remote_datasource.dart
├── domain/
│   ├── entities/
│   │   ├── workout.dart                     # Workout entity
│   │   ├── exercise.dart                    # Exercise entity
│   │   └── workout_plan.dart                # WorkoutPlan entity
│   ├── repositories/
│   │   └── exercise_repository.dart         # Repository interface
│   └── usecases/
│       ├── create_workout_plan.dart         # Create workout plan
│       ├── log_workout.dart                  # Log workout use case
│       └── get_workout_history.dart          # Workout history
└── presentation/
    ├── pages/
    │   ├── exercise_page.dart               # Main exercise screen
    │   ├── workout_plan_page.dart            # Workout plan screen
    │   └── workout_logging_page.dart        # Workout logging screen
    ├── widgets/
    │   ├── workout_card_widget.dart         # Workout display card
    │   └── exercise_list_widget.dart        # Exercise list widget
    └── providers/
        ├── workout_plans_provider.dart       # Workout plans provider
        └── workout_history_provider.dart     # Workout history provider
```

### Medication Management Feature

```
lib/features/medication_management/
├── data/
│   ├── models/
│   │   ├── medication_model.dart            # Medication DTO
│   │   └── medication_log_model.dart        # MedicationLog DTO
│   ├── repositories/
│   │   └── medication_repository_impl.dart
│   └── datasources/
│       └── local/
│           └── medication_local_datasource.dart
├── domain/
│   ├── entities/
│   │   ├── medication.dart                  # Medication entity
│   │   └── medication_log.dart               # MedicationLog entity
│   ├── repositories/
│   │   └── medication_repository.dart       # Repository interface
│   └── usecases/
│       ├── add_medication.dart               # Add medication use case
│       ├── log_medication_dose.dart          # Log dose use case
│       └── check_medication_reminders.dart    # Reminder check
└── presentation/
    ├── pages/
    │   ├── medication_page.dart             # Main medication screen
    │   └── medication_logging_page.dart     # Medication logging screen
    ├── widgets/
    │   └── medication_card_widget.dart      # Medication display card
    └── providers/
        └── medications_provider.dart         # Medications provider
```

### Behavioral Support Feature

```
lib/features/behavioral_support/
├── data/
│   ├── models/
│   │   ├── habit_model.dart                 # Habit DTO
│   │   ├── goal_model.dart                  # Goal DTO
│   │   └── weekly_review_model.dart         # WeeklyReview DTO
│   ├── repositories/
│   │   └── behavioral_repository_impl.dart
│   └── datasources/
│       └── local/
│           └── behavioral_local_datasource.dart
├── domain/
│   ├── entities/
│   │   ├── habit.dart                       # Habit entity
│   │   ├── goal.dart                        # Goal entity
│   │   └── weekly_review.dart               # WeeklyReview entity
│   ├── repositories/
│   │   └── behavioral_repository.dart       # Repository interface
│   └── usecases/
│       ├── track_habit.dart                  # Track habit use case
│       ├── create_goal.dart                  # Create goal use case
│       └── generate_weekly_review.dart      # Weekly review (post-MVP LLM)
└── presentation/
    ├── pages/
    │   ├── behavioral_support_page.dart      # Main behavioral screen
    │   ├── habit_tracking_page.dart         # Habit tracking screen
    │   └── weekly_review_page.dart           # Weekly review screen
    ├── widgets/
    │   ├── habit_card_widget.dart           # Habit display card
    │   └── goal_progress_widget.dart        # Goal progress widget
    └── providers/
        ├── habits_provider.dart              # Habits provider
        └── weekly_review_provider.dart       # Weekly review provider
```

### Analytics & Insights Feature

```
lib/features/analytics_insights/
├── data/
│   ├── models/
│   │   └── trend_analysis_model.dart        # TrendAnalysis DTO
│   ├── repositories/
│   │   └── analytics_repository_impl.dart
│   └── datasources/
│       └── local/
│           └── analytics_local_datasource.dart
├── domain/
│   ├── entities/
│   │   └── trend_analysis.dart              # TrendAnalysis entity
│   ├── repositories/
│   │   └── analytics_repository.dart        # Repository interface
│   └── usecases/
│       ├── analyze_weight_trend.dart        # Weight trend analysis
│       ├── detect_plateau.dart              # Plateau detection
│       └── generate_progress_report.dart    # Progress report
└── presentation/
    ├── pages/
    │   └── analytics_page.dart              # Main analytics screen
    ├── widgets/
    │   ├── trend_chart_widget.dart          # Trend visualization
    │   └── progress_report_widget.dart      # Progress report widget
    └── providers/
        └── analytics_provider.dart          # Analytics provider
```

### LLM Integration Feature (Post-MVP)

```
lib/features/llm_integration/
├── data/
│   ├── models/
│   │   ├── llm_request_model.dart           # LLM request DTO
│   │   └── llm_response_model.dart         # LLM response DTO
│   └── repositories/
│       └── llm_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── llm_request.dart                 # LLM request entity
│   │   └── llm_response.dart                # LLM response entity
│   ├── repositories/
│   │   └── llm_repository.dart              # Repository interface
│   ├── services/
│   │   └── llm_service.dart                 # High-level LLM service
│   └── usecases/
│       ├── generate_weekly_review.dart      # Weekly review generation
│       ├── suggest_meals.dart               # Meal suggestion
│       └── adapt_workout.dart               # Workout adaptation
└── presentation/
    ├── pages/
    │   └── llm_chat_page.dart               # LLM chat interface
    ├── widgets/
    │   └── llm_response_widget.dart         # LLM response display
    └── providers/
        └── llm_service_provider.dart        # LLM service provider
```

## Test Structure (`test/`)

The test structure mirrors the `lib/` structure for easy navigation and maintenance.

### Test Organization

```
test/
├── unit/
│   ├── core/
│   │   ├── utils/
│   │   │   ├── date_utils_test.dart
│   │   │   ├── validation_utils_test.dart
│   │   │   └── calculation_utils_test.dart
│   │   └── errors/
│   │       └── failures_test.dart
│   └── features/
│       ├── health_tracking/
│       │   ├── data/
│       │   │   ├── repositories/
│       │   │   └── datasources/
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   └── usecases/
│       │   │       ├── calculate_moving_average_test.dart
│       │   │       └── detect_plateau_test.dart
│       │   └── presentation/
│       │       └── providers/
│       ├── nutrition_management/
│       ├── exercise_management/
│       └── ...
├── widget/
│   └── features/
│       ├── health_tracking/
│       │   ├── pages/
│       │   │   └── health_tracking_page_test.dart
│       │   └── widgets/
│       │       └── weight_chart_widget_test.dart
│       ├── nutrition_management/
│       └── ...
├── integration/
│   ├── health_tracking_flow_test.dart       # E2E health tracking
│   ├── nutrition_logging_flow_test.dart     # E2E nutrition logging
│   └── weekly_review_flow_test.dart         # E2E weekly review
└── fixtures/
    ├── health_metrics_fixture.dart          # Test data fixtures
    ├── meals_fixture.dart
    └── workouts_fixture.dart
```

### Test Coverage Requirements

- **Unit Tests**: 80% minimum coverage for business logic (domain layer)
- **Widget Tests**: 60% minimum coverage for UI components (presentation layer)
- **Integration Tests**: Critical user flows (weight entry, weekly review, sync operations)

## Documentation Structure (`docs/`)

```
docs/
├── architecture/                            # Architecture documentation
│   └── (references artifacts/phase-1-foundations/)
├── api/                                     # API documentation (post-MVP)
├── deployment/                              # Deployment guides
└── development/                             # Development guides
```

## Artifacts Structure (`artifacts/`)

```
artifacts/
├── requirements.md                          # Project requirements
├── orchestration-definition.md              # Orchestration structure
├── organization-schema.md                   # Artifact organization
├── phase-1-foundations/                     # Foundation artifacts
│   ├── architecture-documentation.md        # This architecture doc
│   ├── project-structure-specification.md   # This structure doc
│   ├── design-system-options.md
│   ├── wireframes.md
│   ├── component-specifications.md
│   ├── database-schema.md
│   ├── data-models.md
│   ├── health-domain-specifications.md
│   └── clinical-safety-protocols.md
├── phase-2-features/                        # Feature specifications
├── phase-3-integration/                    # Integration specifications
├── phase-4-testing/                         # Testing specifications
├── phase-5-management/                     # Management documentation
├── orchestration-analysis-report/           # Analysis reports
└── final-product/                           # Compiled final deliverables
```

## File Naming Conventions

### Files

- **snake_case**: All file names use snake_case
  - Example: `health_tracking_repository.dart`, `calculate_moving_average.dart`

### Classes

- **PascalCase**: All class names use PascalCase
  - Example: `HealthTrackingRepository`, `CalculateMovingAverage`

### Variables and Methods

- **camelCase**: Variables and methods use camelCase
  - Example: `calculateMovingAverage()`, `weightMetrics`

### Constants

- **lowerCamelCase with `k` prefix**: Constants use lowerCamelCase with `k` prefix
  - Example: `kDefaultMovingAverageDays`, `kMaxWeightValue`

### Private Members

- **camelCase with `_` prefix**: Private members use camelCase with `_` prefix
  - Example: `_calculateAverage()`, `_internalState`

### Folders

- **snake_case**: All folder names use snake_case
  - Example: `health_tracking/`, `nutrition_management/`

## Import Organization

### Import Order

1. Dart SDK imports
2. Flutter imports
3. Package imports (third-party)
4. Project imports (relative)

### Example

```dart
// Dart SDK
import 'dart:async';
import 'dart:math';

// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:riverpod/riverpod.dart';
import 'package:hive/hive.dart';
import 'package:fpdart/fpdart.dart';

// Project
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
```

## Code Organization Best Practices

### 1. Feature Independence

- Features should not import from other features
- Shared code goes in `lib/core/`
- Cross-feature communication via domain events or shared core services

### 2. Layer Dependencies

- Presentation layer can depend on domain and data layers
- Domain layer has no dependencies (pure Dart)
- Data layer can depend on domain entities

### 3. Provider Organization

- Global providers in `lib/core/providers/`
- Feature providers in `lib/features/{feature}/presentation/providers/`
- Use `family` providers for parameterized providers

### 4. Test Organization

- Mirror `lib/` structure in `test/`
- Keep test files close to source files (same relative path)
- Use fixtures for test data

### 5. Documentation

- Use Dartdoc for public APIs
- Inline comments for complex logic
- Architecture decisions documented in `artifacts/`

## Platform-Specific Code

### Android (`android/`)

```
android/
├── app/
│   ├── src/
│   │   └── main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/
│   │       └── res/
│   └── build.gradle
└── build.gradle
```

### iOS (`ios/`) - Not Used for MVP

iOS folder exists but is not actively developed for MVP (Android-only).

## Configuration Files

### Root Level

- **pubspec.yaml**: Flutter dependencies and project metadata
- **analysis_options.yaml**: Linter configuration (flutter_lints)
- **.gitignore**: Git ignore rules
- **README.md**: Project README with setup instructions

### Example pubspec.yaml Structure

```yaml
name: health_app
description: Flutter Health Management App for Android
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  riverpod: ^2.5.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  fpdart: ^1.1.0
  # ... other dependencies

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.0
  # ... other dev dependencies
```

## References

- **Architecture Documentation**: `artifacts/phase-1-foundations/architecture-documentation.md`
- **Requirements**: `artifacts/requirements.md` - Technical decisions and project structure preferences
- **Orchestration Definition**: `artifacts/orchestration-definition.md` - Overall orchestration structure

---

**Last Updated**: [Date]  
**Version**: 1.0  
**Status**: MVP Structure Complete

