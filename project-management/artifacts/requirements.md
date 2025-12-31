# Orchestration Requirements: Flutter Health Management App for Android

## Quick Reference

### Key Decisions
- **State Management**: Riverpod (default)
- **Database**: Hive (default) for local, MySQL for sync
- **Architecture**: Feature-First Clean Architecture
- **LLM Provider**: DeepSeek (default, recommended for cost-effectiveness), easily switchable
- **Backend**: DreamHost PHP/MySQL (selected)
- **Min Android**: API 24 (Android 7.0 Nougat)
- **Target Android**: API 34 (Android 14)

### Key File Locations
- Code: `lib/features/{feature}/`
- Tests: `test/features/{feature}/`
- Docs: `docs/` or `artifacts/`
- Reference: `reference-material/artifacts/`
- Backend: DreamHost PHP API endpoints

### Key Processes
- Git: Feature branch → PR → Review → Merge
- Sprint: User stories → Tasks → Implementation → Test
- Backlog: Not Started → In Progress → Completed
- Sync: Local-first → PHP API → MySQL

### Key Contacts/References
- See "Reference Material Index" for health domain knowledge
- See "CRISPE Framework" sections for process prompts
- See "Multi-Device Sync Recommendations" for backend architecture

**Note**: Throughout this document, `[Date]` placeholders in templates and examples are intentional and should remain as placeholders. `[Date]` placeholders in actual documentation sections (outside of templates/examples) should be replaced with actual dates during development and implementation.

---

## Initial Description

The user wants to create a Flutter mobile application for Android that helps users manage their global health with a primary focus on weight loss. The app should provide comprehensive health tracking, guidance, and support tools.

### Core Objectives
- **Platform**: Flutter application targeting Android
- **Primary Focus**: Weight loss management and tracking
- **Scope**: Global health management (holistic approach beyond just weight)
- **Reference Material**: The user has extensive reference material in `reference-material/artifacts/` that contains detailed health management strategies, including:
  - Clinical safety protocols and medication management
  - Nutrition blueprints and gourmet low-carb recipes
  - Exercise/movement architecture
  - Behavioral strategies and habit formation
  - Biometric tracking frameworks
  - Sleep and recovery protocols
  - Weekly progress tracking systems

### Key Features (Inferred from Reference Material)
Based on the reference material provided, the app should likely include:
- **Health Tracking**: Weight, body measurements, body composition, resting heart rate, sleep quality, energy levels
- **Nutrition Management**: Meal planning, recipe collection (especially low-carb/gourmet options), macro tracking, food logging
- **Exercise & Movement**: Workout plans, activity tracking, progressive movement programs, joint safety considerations
- **Medication Management**: Tracking medications (e.g., Wellbutrin, Ozempic), side effect monitoring, medication timing
- **Behavioral Support**: Habit tracking, identity-based goal setting, progress visualization, motivational content
- **Clinical Safety**: Red flag monitoring, health alerts, safety protocols
- **Progress Analytics**: Trend analysis (7-day moving averages), plateau detection, non-scale victories tracking
- **Weekly Check-ins**: Interactive progress reviews, reflection questions, journey documentation

### Technical Considerations
- **Framework**: Flutter (cross-platform, but Android-focused initially)
- **Data Storage**: Local storage for user data, potentially cloud sync
- **Integration**: Health data integration (Google Fit, Health Connect)
- **LLM Integration**: Cost-effective large language model API integration for weekly reviews and intelligent health insights
- **UI/UX**: Modern, intuitive interface for health tracking
- **Offline Capability**: Core features should work offline (LLM features require internet connection)

### Target User Profile (From Reference Material Context)
- Adults managing weight loss goals
- Users on medications that affect appetite/metabolism
- People with sedentary lifestyles who need movement support
- Users interested in low-carb nutrition approaches
- Individuals seeking holistic health management

## Reference Material Index

The following reference materials are available in `reference-material/artifacts/`:

### Foundations Phase (Reference Material)
- `phase-1-foundations/nutrition-blueprint.md` - Macro targets, food lists, meal strategies
- `phase-1-foundations/biometrics-framework.md` - Tracking schedules, KPI definitions, data interpretation
- `phase-1-foundations/clinical-safety-protocol.md` - Safety protocols, red flags, medication guidelines

### Execution Phase (Reference Material)
- `phase-2-execution/gourmet-recipe-collection.md` - Low-carb recipes with nutritional info
- `phase-2-execution/behavioral-strategy.md` - Habit formation, identity-based goals
- `phase-2-execution/movement-architecture.md` - Exercise plans, joint safety, progressive programs

### Sustainability Phase (Reference Material)
- `phase-3-sustainability/sleep-recovery-protocol.md` - Sleep optimization, recovery strategies
- `phase-3-sustainability/weekly-progress-tracker.md` - Weekly check-in format, reflection questions

### Final Product
- `final-product/weight-loss-master-plan.md` - Complete integrated plan

### When to Reference
- **Implementing health tracking**: Reference `biometrics-framework.md` for tracking schedules, KPI definitions, and data interpretation logic
- **Implementing nutrition**: Reference `nutrition-blueprint.md` for macro targets and `gourmet-recipe-collection.md` for recipes
- **Implementing exercise**: Reference `movement-architecture.md` for exercise plans and joint safety considerations
- **Implementing safety**: Reference `clinical-safety-protocol.md` for safety protocols and red flag detection
- **Implementing weekly reviews**: Reference `weekly-progress-tracker.md` for check-in format and reflection questions
- **Overall health strategy**: Reference `weight-loss-master-plan.md` for integrated approach

## Detailed Feature Requirements (Based on Reference Material)

### 1. Health Tracking Module
- **Daily Tracking**: Weight (with 7-day moving average), sleep quality (1-10 scale), energy levels (1-10 scale)
- **Weekly Tracking**: Body measurements (waist, hips, neck, chest, thigh), side effect monitoring
- **Monthly Tracking**: Progress photos (front, side, back), body fat % trends
- **KPIs & NSVs**: Resting heart rate tracking, strength/stamina metrics, clothing fit tracking, appetite suppression levels
- **Data Visualization**: Trend charts, moving averages, plateau detection (weight unchanged for 3 consecutive weeks AND measurements unchanged)

### 2. Nutrition Management Module
- **Macro Tracking**: Protein, fats, net carbs tracking (target: 35% protein by calories, 55% fats by calories, net carbs <40g absolute maximum)
- **Food Logging**: Daily meal logging with macro breakdown
- **Recipe Collection**: Gourmet low-carb recipes with nutritional information
- **Meal Planning**: Weekly meal planning and shopping lists with LLM-powered suggestions based on preferences, goals, and progress
- **Sale-Based Meal Planning**: LLM-powered meal plan generation based on current grocery store sales and promotions, prioritizing cost-effective ingredients while maintaining macro targets and dietary preferences
- **LLM-Powered Meal Suggestions**: LLM integration to suggest personalized meal plans and recipe modifications based on user preferences, dietary restrictions, and health goals
- **Medication-Aware Nutrition**: Protein-first eating strategy, volume management for medication side effects

### 3. Exercise & Movement Module
- **Workout Plans**: Progressive strength training (Push/Pull splits), Zone-2 cardio programs
- **LLM-Powered Workout Adaptation**: LLM integration to suggest workout modifications based on progress, feedback, joint concerns, and available equipment
- **Activity Tracking**: Integration with Google Fit/Health Connect for step counting and activity monitoring
- **Joint Safety**: Low-impact exercise recommendations, movement modifications
- **Desk Reset Reminders**: Notifications for movement breaks during sedentary work
- **Exercise Library**: Exercise database with instructions and modifications

### 4. Medication Management Module
- **Medication Tracking**: Log medications (e.g., Wellbutrin, Ozempic) with timing
- **Side Effect Monitoring**: Track nausea, heart rate changes, sleep quality impacts
- **Safety Alerts**: Red flag warnings (see Clinical Safety Rules below for specific thresholds and durations)
- **Medication Reminders**: Dosing schedules and timing optimization

### 5. Behavioral Support Module
- **Habit Tracking**: Daily habit check-ins and streak tracking
- **Goal Setting**: Identity-based goal setting (not just weight, but health identity)
- **Progress Visualization**: Charts, graphs, milestone celebrations
- **Weekly Check-ins**: Interactive reflection questions, progress reviews with LLM-powered insights and personalized feedback via LLM API
- **LLM-Powered Coaching**: LLM integration for personalized weekly review summaries, motivational insights, and adaptive recommendations based on user progress
- **Journey Documentation**: Personal health journey log with notes and reflections, enhanced with AI-generated insights

### 6. Clinical Safety Module
- **Safety Protocols**: Red flag detection and alerts
- **Health Alerts**: Warnings for concerning metrics (see Clinical Safety Rules below)
- **Pause Protocol**: Guidance for when to pause and consult healthcare providers
- **Clinical Guidelines**: Evidence-based safety recommendations

**Clinical Safety Rules** (Unified Specifications):
- **Resting Heart Rate Alert**: If resting heart rate > 100 BPM for 3 consecutive days → show safety alert
- **Rapid Weight Loss Alert**: If weight loss > 4 lbs/week (1.8 kg/week) for 2 consecutive weeks → show safety alert
- **Poor Sleep Alert**: If sleep quality < 4/10 for 5 consecutive days → show safety alert
- **Elevated Heart Rate Alert**: If resting heart rate increases by > 20 BPM from baseline for 3 days → show safety alert
  - **Baseline Definition**: Baseline is calculated as the average resting heart rate from the first 7 days of tracking. If less than 7 days of data exist, baseline is established after 7 days of tracking. Baseline is recalculated monthly to account for fitness improvements, but alerts use the most recent baseline calculation.

### 7. Analytics & Insights Module
- **Trend Analysis**: 7-day moving averages, long-term trends
- **Plateau Detection**: Automatic identification of weight loss plateaus
- **Progress Reports**: Weekly and monthly progress summaries with AI-generated insights and recommendations
- **Predictive Analytics**: Projected goal achievement dates based on current trends
- **LLM-Powered Insights**: LLM integration to analyze patterns, provide personalized recommendations, and generate contextual health insights from user data

### 8. Content Management
- **Recipe Database**: Curated collection of gourmet low-carb recipes
- **Exercise Library**: Exercise database with videos/instructions
- **Educational Content**: Health tips, behavioral strategies, clinical information
- **Content Updates**: System for adding new recipes, exercises, and educational materials

## Module Implementation Examples

### Health Tracking Module

**Example Data Model**:
```dart
class HealthMetric {
  final String id;
  final DateTime date;
  final double? weight; // kg
  final int? sleepQuality; // 1-10
  final int? energyLevel; // 1-10
  final Map<String, double>? bodyMeasurements; // waist, hips, neck, chest, thigh
  final int? restingHeartRate; // bpm
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class MovingAverageCalculator {
  static double? calculate7DayAverage(List<HealthMetric> metrics) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(Duration(days: 7));
    
    // Filter to only include metrics from the last 7 days (inclusive of boundary dates)
    final recentMetrics = metrics
        .where((m) => !m.date.isBefore(sevenDaysAgo) && m.weight != null)
        .toList();
    
    if (recentMetrics.length < 7) return null;
    
    final weights = recentMetrics
        .map((m) => m.weight!)
        .toList();
    
    if (weights.isEmpty) return null;
    return weights.reduce((a, b) => a + b) / weights.length;
  }
}
```

**Example UI Component**:
- Weight entry screen: Numeric input with date picker, shows 7-day average below input
- Trend chart: Line chart showing weight over time with moving average overlay
- Progress photo: Grid view with front/side/back photos, tap to view full screen

**Example Business Logic**:
- Plateau detection: If weight unchanged for 3 consecutive weeks AND measurements unchanged → trigger plateau alert
- Red flag detection: See Clinical Safety Rules section for unified specifications
- Moving average: Calculate 7-day average for weight trends, ignore daily fluctuations

### Nutrition Management Module

**Example Data Model**:
```dart
class Meal {
  final String id;
  final DateTime date;
  final MealType type; // breakfast, lunch, dinner, snack
  final String name;
  final double protein; // grams
  final double fats; // grams
  final double netCarbs; // grams
  final double calories;
  final List<String> ingredients;
}

class MacroTracker {
  static bool isWithinTargets(Meal meal, MacroTargets targets) {
    // Calculate macro percentages by calories (not by weight)
    // Protein and carbs: 4 calories/gram, Fats: 9 calories/gram
    final proteinCalories = meal.protein * 4;
    final fatsCalories = meal.fats * 9;
    final carbsCalories = meal.netCarbs * 4;
    final totalCalories = proteinCalories + fatsCalories + carbsCalories;
    
    if (totalCalories == 0) return false;
    
    final proteinPercent = (proteinCalories / totalCalories) * 100;
    final fatsPercent = (fatsCalories / totalCalories) * 100;
    final carbsPercent = (carbsCalories / totalCalories) * 100;
    
    return proteinPercent >= targets.proteinMin &&
           fatsPercent >= targets.fatsMin &&
           meal.netCarbs <= targets.maxNetCarbs;
  }
}
```

### Medication Management Module

**Example Data Model**:
```dart
class Medication {
  final String id;
  final String name;
  final String dosage;
  final MedicationFrequency frequency;
  final List<TimeOfDay> times;
  final DateTime startDate;
  final DateTime? endDate;
  final bool reminderEnabled;
  final List<SideEffect> sideEffects;
}

class MedicationReminder {
  static List<Notification> generateReminders(Medication medication) {
    final List<Notification> reminders = [];
    
    if (!medication.reminderEnabled) return reminders;
    
    final now = DateTime.now();
    
    for (final timeOfDay in medication.times) {
      var reminderTime = DateTime(
        now.year,
        now.month,
        now.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
      
      // If time has passed today, schedule for tomorrow
      if (reminderTime.isBefore(now)) {
        reminderTime = reminderTime.add(Duration(days: 1));
      }
      
      reminders.add(Notification(
        id: '${medication.id}_${timeOfDay.hour}_${timeOfDay.minute}',
        title: 'Medication Reminder',
        body: 'Time to take ${medication.name} (${medication.dosage})',
        scheduledTime: reminderTime,
        repeatDaily: medication.frequency == MedicationFrequency.daily,
      ));
    }
    
    return reminders;
  }
}
```

## Technical Architecture Requirements

### Data Storage
- **Local Database**: Hive (default) for offline-first data storage
- **Data Models**: User profile, health metrics, meals, exercises, medications, habits, progress logs
- **Data Sync**: Optional cloud sync for multi-device access using DreamHost PHP/MySQL backend (see Multi-Device Sync Recommendations below)
- **Sync Backend**: DreamHost PHP REST API with MySQL database for data storage
- **Sync Timeline**: Sync feature is planned for Post-MVP Phase 1 (Implementation Phase 2), not required for MVP

#### Data Model Specifications

**Core Entities**:

**UserProfile**:
```dart
{
  "id": "string (UUID)",
  "name": "string",
  "email": "string (unique)",
  "dateOfBirth": "DateTime",
  "gender": "enum (male, female, other)",
  "height": "double (cm)",
  "targetWeight": "double (kg)",
  "medications": "List<Medication>",
  "preferences": "UserPreferences",
  "syncEnabled": "bool",
  "createdAt": "DateTime",
  "updatedAt": "DateTime"
}
```

**HealthMetric**:
```dart
{
  "id": "string (UUID)",
  "userId": "string (FK)",
  "date": "DateTime",
  "weight": "double? (kg)",
  "sleepQuality": "int? (1-10)",
  "energyLevel": "int? (1-10)",
  "restingHeartRate": "int? (bpm)",
  "bodyMeasurements": "Map<String, double>?",
  "notes": "string?",
  "createdAt": "DateTime",
  "updatedAt": "DateTime"
}
```

**Medication**:
```dart
{
  "id": "string (UUID)",
  "userId": "string (FK)",
  "name": "string",
  "dosage": "string",
  "frequency": "enum (daily, twice_daily, weekly, etc.)",
  "times": "List<TimeOfDay>",
  "startDate": "DateTime",
  "endDate": "DateTime?",
  "reminderEnabled": "bool",
  "sideEffects": "List<SideEffect>",
  "createdAt": "DateTime",
  "updatedAt": "DateTime"
}
```

**Meal**:
```dart
{
  "id": "string (UUID)",
  "userId": "string (FK)",
  "date": "DateTime",
  "mealType": "enum (breakfast, lunch, dinner, snack)",
  "name": "string",
  "protein": "double (grams)",
  "fats": "double (grams)",
  "netCarbs": "double (grams)",
  "calories": "double",
  "ingredients": "List<String>",
  "recipeId": "string? (FK to recipe)",
  "createdAt": "DateTime"
}
```

**MacroTargets**:
```dart
{
  "proteinMin": "double (percentage, e.g., 35.0)",
  "fatsMin": "double (percentage, e.g., 55.0)",
  "maxNetCarbs": "double (grams, e.g., 40.0)"
}
```

**Exercise**:
```dart
{
  "id": "string (UUID)",
  "userId": "string (FK)",
  "name": "string",
  "type": "enum (strength, cardio, flexibility, other)",
  "muscleGroups": "List<String>",
  "equipment": "List<String>",
  "duration": "int? (minutes)",
  "sets": "int?",
  "reps": "int?",
  "weight": "double? (kg)",
  "distance": "double? (km)",
  "date": "DateTime",
  "notes": "string?",
  "createdAt": "DateTime",
  "updatedAt": "DateTime"
}
```

**Recipe**:
```dart
{
  "id": "string (UUID)",
  "name": "string",
  "description": "string?",
  "servings": "int",
  "prepTime": "int (minutes)",
  "cookTime": "int (minutes)",
  "difficulty": "enum (easy, medium, hard)",
  "protein": "double (grams per serving)",
  "fats": "double (grams per serving)",
  "netCarbs": "double (grams per serving)",
  "calories": "double (per serving)",
  "ingredients": "List<String>",
  "instructions": "List<String>",
  "tags": "List<String>",
  "imageUrl": "string?",
  "createdAt": "DateTime",
  "updatedAt": "DateTime"
}
```

**SaleItem**:
```dart
{
  "id": "string (UUID)",
  "name": "string",
  "category": "string (e.g., produce, meat, dairy, pantry)",
  "store": "string (store name)",
  "regularPrice": "double",
  "salePrice": "double",
  "discountPercent": "double",
  "unit": "string (e.g., lb, oz, each)",
  "validFrom": "DateTime",
  "validTo": "DateTime",
  "description": "string?",
  "imageUrl": "string?",
  "source": "enum (api, manual, scraped)",
  "createdAt": "DateTime",
  "updatedAt": "DateTime"
}
```

**MealPlan**:
```dart
{
  "id": "string (UUID)",
  "userId": "string (FK)",
  "weekStartDate": "DateTime",
  "weekEndDate": "DateTime",
  "dailyMeals": "Map<DateTime, List<MealPlanDay>>",
  "shoppingList": "List<ShoppingListItem>",
  "estimatedWeeklyCost": "double",
  "totalSavings": "double",
  "saleItemsUsed": "List<String> (SaleItem IDs)",
  "mealPrepSuggestions": "List<String>",
  "createdAt": "DateTime",
  "updatedAt": "DateTime"
}
```

**ShoppingListItem**:
```dart
{
  "id": "string (UUID)",
  "mealPlanId": "string (FK)",
  "name": "string",
  "category": "string",
  "quantity": "double",
  "unit": "string",
  "estimatedPrice": "double",
  "isOnSale": "bool",
  "saleItemId": "string? (FK to SaleItem)",
  "store": "string?",
  "notes": "string?",
  "purchased": "bool",
  "purchasedAt": "DateTime?"
}
```

**SideEffect**:
```dart
{
  "id": "string (UUID)",
  "medicationId": "string (FK)",
  "name": "string",
  "severity": "enum (mild, moderate, severe)",
  "startDate": "DateTime",
  "endDate": "DateTime?",
  "notes": "string?",
  "createdAt": "DateTime"
}
```

**UserPreferences**:
```dart
{
  "dietaryApproach": "enum (low_carb, keto, balanced, etc.)",
  "preferredMealTimes": "List<TimeOfDay>",
  "allergies": "List<String>",
  "dislikes": "List<String>",
  "fitnessGoals": "List<String>",
  "notificationPreferences": "Map<String, bool>",
  "units": "enum (metric, imperial)",
  "theme": "enum (light, dark, system)"
}
```

**ProgressPhoto**:
```dart
{
  "id": "string (UUID)",
  "healthMetricId": "string (FK)",
  "photoType": "enum (front, side, back)",
  "imagePath": "string",
  "date": "DateTime",
  "createdAt": "DateTime"
}
```

**MedicationLog**:
```dart
{
  "id": "string (UUID)",
  "medicationId": "string (FK)",
  "takenAt": "DateTime",
  "dosage": "string",
  "notes": "string?",
  "createdAt": "DateTime"
}
```

**Enums**:
```dart
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack
}

enum MedicationFrequency {
  daily,
  twiceDaily,
  threeTimesDaily,
  weekly,
  asNeeded
}

enum TimeOfDay {
  morning,
  afternoon,
  evening,
  night
}
```

**Relationships**:
- UserProfile 1:N HealthMetric
- UserProfile 1:N Medication
- UserProfile 1:N Meal
- UserProfile 1:N Exercise
- UserProfile 1:N MealPlan
- UserProfile 1:1 UserPreferences
- HealthMetric 1:1 ProgressPhoto (optional)
- Medication 1:N MedicationLog
- Medication 1:N SideEffect
- Meal N:1 Recipe (optional)
- MealPlan 1:N ShoppingListItem
- ShoppingListItem N:1 SaleItem (optional)
- MealPlan N:N SaleItem (many-to-many via saleItemsUsed)

#### Validation Rules

**Health Metrics**:
- **Weight**: 20-500 kg (reasonable human range)
- **Sleep Quality**: 1-10 (integer, required if provided)
- **Energy Level**: 1-10 (integer, required if provided)
- **Resting Heart Rate**: 40-200 bpm (reasonable range)
- **Body Measurements**: All positive numbers, reasonable ranges:
  - Waist: 50-200 cm
  - Hips: 60-250 cm
  - Neck: 25-60 cm
  - Chest: 70-200 cm
  - Thigh: 30-100 cm

**Medication**:
- **Name**: Required, 1-100 characters
- **Dosage**: Required, 1-50 characters
- **Times**: At least one time required, max 10 times per day
- **Start Date**: Required, cannot be in future
- **End Date**: Optional, must be after start date if provided

**Nutrition**:
- **Daily Macro Percentages (by calories)**: Must sum to approximately 100% (with tolerance for rounding, ±5%)
  - Protein: Minimum 35% of total calories
  - Fats: Minimum 55% of total calories
  - Net Carbs: Capped at 40g absolute maximum (not a percentage target)
- **Individual Meals**: Should aim for target ratios but don't need to sum to exactly 100% (daily totals are what matter)
- **Net Carbs**: Must be < 40g absolute for low-carb diet validation
- **Calories**: 800-5000 kcal/day (safety limits)

**User Profile**:
- **Email**: Valid email format, unique
- **Height**: 50-300 cm (reasonable human range)
- **Target Weight**: 20-500 kg (reasonable range)
- **Date of Birth**: Cannot be in future, must be reasonable age (13-120 years)

**Validation Error Messages**:
- Use clear, actionable messages
- Show field-specific errors
- Provide examples when helpful (e.g., "Weight must be between 20-500 kg")
- Use consistent formatting across all validation errors

#### Error Handling Patterns

**Error Types**:
```dart
// core/errors/failures.dart
abstract class Failure {
  final String message;
  Failure(this.message);
}

class NetworkFailure extends Failure {
  NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;
  ValidationFailure(super.message, this.fieldErrors);
}

class LLMProviderFailure extends Failure {
  LLMProviderFailure(super.message);
}

class DatabaseFailure extends Failure {
  DatabaseFailure(super.message);
}

class SyncFailure extends Failure {
  SyncFailure(super.message);
}
```

**Error Handling Strategy**:
- **UI Layer**: Show user-friendly messages, log technical details
- **Domain Layer**: Return `Either<Failure, Success>` using `fpdart` package
- **Data Layer**: Catch exceptions, convert to Failure objects

**Example Pattern**:
```dart
import 'package:fpdart/fpdart.dart';

Future<Either<Failure, HealthMetric>> getHealthMetric(String id) async {
  try {
    final metric = await repository.getById(id);
    return Right(metric);
  } on NetworkException catch (e) {
    return Left(NetworkFailure(e.message));
  } on CacheException catch (e) {
    return Left(CacheFailure(e.message));
  } on ValidationException catch (e) {
    return Left(ValidationFailure(e.message, e.fieldErrors));
  }
}
```

**User-Facing Error Messages**:
- Network errors: "Unable to connect. Please check your internet connection."
- Validation errors: Show specific field errors with clear guidance
- LLM errors: "Unable to generate insights. Please try again later."
- Sync errors: "Sync failed. Your data is saved locally and will sync when connection is restored."
- Database errors: "Unable to save data. Please try again."

#### Multi-Device Sync Recommendations (POST-MVP)

**⚠️ POST-MVP FEATURE - NOT REQUIRED FOR MVP (Implementation Phase 2)**

**Context**: Users may want to access their health data across multiple devices (phone, tablet, etc.). Sync must be optional, privacy-preserving, and respect the offline-first architecture.

**Requirements**:
- **Privacy-First**: Data stored securely on server with HTTPS/SSL
- **Optional**: User must explicitly opt-in to sync
- **Offline-First**: App works fully offline, sync happens in background
- **Cost-Effective**: Reasonable costs for individual users
- **Secure**: HTTPS/SSL for data in transit, secure authentication (JWT)
- **Conflict Resolution**: Handle data conflicts when same record modified on multiple devices

**Selected Solution**: DreamHost PHP/MySQL Backend

##### DreamHost PHP/MySQL Backend (Selected)
**Why**: Maximum privacy and control, cost-effective if hosting already available

**Features**:
- Full control over data storage
- PHP backend with MySQL database
- Secure HTTPS/SSL communication
- Self-hostable on DreamHost

**DreamHost Hosting Options**:
- **Shared Hosting**: PHP backend with MySQL database (selected)
- **VPS Hosting**: Full control, can run Docker containers, any stack (if needed)
- **Dedicated Server**: Maximum performance and control (if needed)
- **Database**: MySQL included with DreamHost hosting plans

**Implementation** (DreamHost - Selected):
- Build REST API backend using PHP
- Use DreamHost MySQL database
- Store data as JSON in MySQL
- Conflict resolution: Timestamp-based (last write wins) or custom merge
- Use HTTPS/SSL (DreamHost provides free SSL certificates)
- JWT authentication for secure API access

**Selected Stack on DreamHost**:
- **Backend**: PHP 8.1+ (REST API)
- **Database**: MySQL (via DreamHost)
- **API**: REST API with JWT authentication
- **Storage**: JSON data in MySQL database
- **SSL**: Free Let's Encrypt SSL via DreamHost
- **Framework**: Slim Framework 4.x (recommended) - lightweight, perfect for REST APIs, works great on shared hosting

#### PHP Framework Recommendation: Slim Framework

**Recommended Framework**: **Slim Framework 4.x**

**Why Slim Framework**:
1. **Lightweight**: Minimal overhead, perfect for REST APIs (~2MB footprint)
2. **Shared Hosting Compatible**: Works perfectly on DreamHost shared hosting
3. **REST API Focused**: Built specifically for building REST APIs
4. **Easy Deployment**: Simple file structure, no complex configuration
5. **Modern PHP**: Uses PSR standards, dependency injection container included
6. **Security**: Built-in security features, middleware support
7. **Active Development**: Well-maintained, good documentation
8. **Learning Curve**: Easy to learn, minimal boilerplate

**Alternative Options** (if needed):
- **Plain PHP**: Maximum control, but more development effort
- **Lumen**: Laravel's micro-framework, more features but heavier
- **CodeIgniter 4**: Lightweight, works on shared hosting, but less modern

**Slim Framework Structure** (Recommended):
```
api/
├── public/
│   └── index.php (entry point)
├── src/
│   ├── Middleware/
│   │   ├── AuthMiddleware.php (JWT validation)
│   │   └── CorsMiddleware.php
│   ├── Controllers/
│   │   ├── HealthMetricsController.php
│   │   ├── MedicationsController.php
│   │   └── AuthController.php
│   ├── Services/
│   │   └── DatabaseService.php
│   └── Models/
│       └── User.php
├── config/
│   ├── database.php
│   └── app.php
├── vendor/ (Composer dependencies)
└── composer.json
```

**Slim Framework Example**:
```php
<?php
// public/index.php
use Slim\Factory\AppFactory;
use Slim\Middleware\ErrorMiddleware;

require __DIR__ . '/../vendor/autoload.php';

$app = AppFactory::create();

// Add middleware
$app->add(new AuthMiddleware());
$app->add(new CorsMiddleware());

// Routes
$app->post('/api/health-metrics', HealthMetricsController::class . ':sync');
$app->get('/api/health-metrics', HealthMetricsController::class . ':fetch');
$app->post('/api/auth/login', AuthController::class . ':login');

$app->run();
```

**Slim Framework Benefits for This Project**:
- **JWT Authentication**: Easy to implement with middleware
- **Route Organization**: Clean route definitions
- **Dependency Injection**: Built-in container for services
- **Error Handling**: Built-in error handling and logging
- **Middleware**: Easy to add authentication, CORS, validation
- **PSR Standards**: Follows PHP standards, easy to maintain

**Installation** (via Composer):
```bash
composer require slim/slim:"^4.0"
composer require slim/psr7
composer require firebase/php-jwt  # For JWT authentication
composer require vlucas/phpdotenv  # For environment variables
```

**DreamHost Compatibility**:
- Works perfectly on DreamHost shared hosting
- No special server configuration needed
- Can use Composer (available on DreamHost)
- Simple `.htaccess` configuration for routing

**Pros**:
- Full control over infrastructure
- No vendor lock-in
- Cost-effective if already have DreamHost hosting
- Can use existing DreamHost database
- Free SSL certificates included
- Can scale as needed

**Cons**:
- Most development effort
- Need to maintain backend infrastructure
- Need to handle backups, security updates
- More complex conflict resolution
- Requires backend development skills

**DreamHost Cost Considerations**:
- If already have hosting: **$0 additional cost** (just use existing resources)
- Shared hosting: ~$3-10/month (if not already owned)
- VPS: ~$13-120/month depending on resources
- Database: Usually included with hosting plans

**Selected Solution**: DreamHost PHP/MySQL Backend

**Rationale**:
1. **Cost**: $0 additional cost (using existing DreamHost hosting)
2. **Privacy**: Maximum control over data storage and access
3. **Flexibility**: Full control over stack, database, and infrastructure
4. **Existing Resources**: Leveraging existing DreamHost database and hosting
5. **No Vendor Lock-in**: Own your infrastructure completely
6. **PHP/MySQL**: Well-supported on DreamHost shared hosting, easy to deploy
7. **Security**: HTTPS/SSL for data in transit, JWT authentication, secure password hashing

**Technology Stack**:
- **Backend**: PHP (8.1+ recommended)
- **Database**: MySQL (via DreamHost)
- **API**: REST API with JSON
- **Authentication**: JWT tokens
- **Security**: HTTPS/SSL for data in transit, JWT authentication
- **SSL**: Free Let's Encrypt SSL via DreamHost

**Implementation Strategy**:

**DreamHost PHP/MySQL Backend** (Selected Solution):

**Flutter Client**:
```dart
// Flutter client - Direct sync to backend
class DreamHostSyncService {
  final String apiBaseUrl = 'https://your-domain.dreamhost.com/api';
  
  Future<void> syncHealthMetric(HealthMetric metric) async {
    // Upload data directly to DreamHost Slim Framework backend
    final response = await http.post(
      Uri.parse('$apiBaseUrl/health-metrics'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': metric.id,
        'data': metric.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      }),
    );
    
    if (response.statusCode != 200) {
      throw SyncException('Failed to sync: ${response.body}');
    }
  }
  
  // Download data from server
  Future<List<HealthMetric>> fetchSyncData() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/health-metrics'),
      headers: {'Authorization': 'Bearer $authToken'},
    );
    
    final List<dynamic> data = jsonDecode(response.body)['data'];
    return data.map((e) => 
      HealthMetric.fromJson(e['data'])
    ).toList();
  }
}
```

**PHP Backend Example** (Slim Framework on DreamHost):

**Slim Framework Setup** (`public/index.php`):
```php
<?php
use Slim\Factory\AppFactory;
use Slim\Middleware\ErrorMiddleware;

require __DIR__ . '/../vendor/autoload.php';

$app = AppFactory::create();

// Add CORS middleware (applies to all routes)
$app->add(new \App\Middleware\CorsMiddleware());

// Public routes (no authentication required)
$app->post('/api/auth/login', \App\Controllers\AuthController::class . ':login');
$app->post('/api/auth/register', \App\Controllers\AuthController::class . ':register');

// Protected routes (require authentication)
$app->group('', function ($group) {
    $group->post('/api/health-metrics', \App\Controllers\HealthMetricsController::class . ':sync');
    $group->get('/api/health-metrics', \App\Controllers\HealthMetricsController::class . ':fetch');
})->add(new \App\Middleware\AuthMiddleware());

$errorMiddleware = $app->addErrorMiddleware(true, true, true);
$app->run();
```

**DatabaseService Example** (`src/Services/DatabaseService.php`):
```php
<?php
namespace App\Services;

use mysqli;
use mysqli_stmt;

class DatabaseService {
    private $connection;
    
    public function __construct() {
        $host = getenv('DB_HOST') ?: 'localhost';
        $username = getenv('DB_USER');
        $password = getenv('DB_PASSWORD');
        $database = getenv('DB_NAME');
        
        $this->connection = new mysqli($host, $username, $password, $database);
        
        if ($this->connection->connect_error) {
            throw new \Exception('Database connection failed: ' . $this->connection->connect_error);
        }
        
        $this->connection->set_charset('utf8mb4');
    }
    
    public function prepare(string $query): mysqli_stmt {
        $stmt = $this->connection->prepare($query);
        if (!$stmt) {
            throw new \Exception('Prepare failed: ' . $this->connection->error);
        }
        return $stmt;
    }
    
    public function query(string $query) {
        $result = $this->connection->query($query);
        if (!$result) {
            throw new \Exception('Query failed: ' . $this->connection->error);
        }
        return $result;
    }
    
    public function getConnection(): mysqli {
        return $this->connection;
    }
    
    public function close(): void {
        $this->connection->close();
    }
}
```

**Controller Example** (`src/Controllers/HealthMetricsController.php`):
```php
<?php
namespace App\Controllers;

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use App\Services\DatabaseService;

class HealthMetricsController {
    private $db;
    
    public function __construct(DatabaseService $db) {
        $this->db = $db;
    }
    
    public function sync(Request $request, Response $response): Response {
        try {
            $body = $request->getBody()->getContents();
            $data = json_decode($body, true);
            
            // Input validation
            if (json_last_error() !== JSON_ERROR_NONE) {
                $response->getBody()->write(json_encode([
                    'error' => 'Invalid JSON',
                    'message' => json_last_error_msg()
                ]));
                return $response->withStatus(400)->withHeader('Content-Type', 'application/json');
            }
            
            if (!isset($data['id']) || !isset($data['data']) || !isset($data['updated_at'])) {
                $response->getBody()->write(json_encode([
                    'error' => 'Missing required fields',
                    'message' => 'id, data, and updated_at are required'
                ]));
                return $response->withStatus(400)->withHeader('Content-Type', 'application/json');
            }
            
            $user = $request->getAttribute('user'); // From AuthMiddleware
            if (!$user || !isset($user['id'])) {
                $response->getBody()->write(json_encode([
                    'error' => 'Unauthorized',
                    'message' => 'User authentication required'
                ]));
                return $response->withStatus(401)->withHeader('Content-Type', 'application/json');
            }
            
            $id = $data['id'];
            $metric_data = json_encode($data['data']); // Store as JSON
            $updated_at = $data['updated_at'];
            $user_id = $user['id'];
            
            // Store JSON data in MySQL
            $stmt = $this->db->prepare(
                "INSERT INTO health_metrics (id, user_id, data, updated_at) 
                 VALUES (?, ?, ?, ?) 
                 ON DUPLICATE KEY UPDATE data = ?, updated_at = ?"
            );
            $stmt->bind_param('ssssss', $id, $user_id, $metric_data, $updated_at, 
                              $metric_data, $updated_at);
            
            if (!$stmt->execute()) {
                throw new \Exception('Database operation failed: ' . $stmt->error);
            }
            
            $stmt->close();
            
            $response->getBody()->write(json_encode(['success' => true]));
            return $response->withHeader('Content-Type', 'application/json');
            
        } catch (\Exception $e) {
            error_log('HealthMetricsController::sync error: ' . $e->getMessage());
            $response->getBody()->write(json_encode([
                'error' => 'Internal server error',
                'message' => 'Failed to sync health metric'
            ]));
            return $response->withStatus(500)->withHeader('Content-Type', 'application/json');
        }
    }
    
    public function fetch(Request $request, Response $response): Response {
        try {
            $user = $request->getAttribute('user'); // From AuthMiddleware
            if (!$user || !isset($user['id'])) {
                $response->getBody()->write(json_encode([
                    'error' => 'Unauthorized',
                    'message' => 'User authentication required'
                ]));
                return $response->withStatus(401)->withHeader('Content-Type', 'application/json');
            }
            
            $user_id = $user['id'];
            
            $stmt = $this->db->prepare(
                "SELECT id, data, updated_at 
                 FROM health_metrics 
                 WHERE user_id = ? 
                 ORDER BY updated_at DESC"
            );
            $stmt->bind_param('s', $user_id);
            
            if (!$stmt->execute()) {
                throw new \Exception('Database query failed: ' . $stmt->error);
            }
            
            $result = $stmt->get_result();
            
            $metrics = [];
            while ($row = $result->fetch_assoc()) {
                $decoded_data = json_decode($row['data'], true);
                if (json_last_error() !== JSON_ERROR_NONE) {
                    error_log('Failed to decode JSON for metric ' . $row['id']);
                    continue;
                }
                
                $metrics[] = [
                    'id' => $row['id'],
                    'data' => $decoded_data,
                    'updated_at' => $row['updated_at']
                ];
            }
            
            $stmt->close();
            
            $response->getBody()->write(json_encode(['data' => $metrics]));
            return $response->withHeader('Content-Type', 'application/json');
            
        } catch (\Exception $e) {
            error_log('HealthMetricsController::fetch error: ' . $e->getMessage());
            $response->getBody()->write(json_encode([
                'error' => 'Internal server error',
                'message' => 'Failed to fetch health metrics'
            ]));
            return $response->withStatus(500)->withHeader('Content-Type', 'application/json');
        }
    }
}
```

**JWT Authentication Middleware** (`src/Middleware/AuthMiddleware.php`):
```php
<?php
namespace App\Middleware;

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface as RequestHandler;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class AuthMiddleware implements MiddlewareInterface {
    public function process(Request $request, RequestHandler $handler): Response {
        $token = $request->getHeaderLine('Authorization');
        $token = str_replace('Bearer ', '', $token);
        
        if (!$token) {
            $response = new \Slim\Psr7\Response();
            $response->getBody()->write(json_encode(['error' => 'Unauthorized']));
            return $response->withStatus(401)->withHeader('Content-Type', 'application/json');
        }
        
        try {
            $decoded = JWT::decode($token, new Key(getenv('JWT_SECRET'), 'HS256'));
            $request = $request->withAttribute('user', (array)$decoded);
            return $handler->handle($request);
        } catch (\Exception $e) {
            $response = new \Slim\Psr7\Response();
            $response->getBody()->write(json_encode(['error' => 'Invalid token']));
            return $response->withStatus(401)->withHeader('Content-Type', 'application/json');
        }
    }
}
?>
```

**MySQL Database Schema** (DreamHost):
```sql
-- Users table
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Health metrics table (stores JSON data)
CREATE TABLE health_metrics (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    data JSON NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_updated (user_id, updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Similar tables for other data types (medications, exercises, etc.)
CREATE TABLE medications (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    data JSON NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_updated (user_id, updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Sync Architecture**:
1. **Local-First**: All data stored locally in Hive
2. **Background Sync**: Sync happens in background when online
3. **Conflict Resolution**: Timestamp-based (last write wins) or merge strategy
4. **User Control**: User can enable/disable sync, choose what to sync
5. **Incremental Sync**: Only sync changed records (use `updated_at` timestamps)
6. **Security**: HTTPS/SSL for data in transit, JWT authentication for API access

**Security Considerations**:
- HTTPS/SSL for all API communication (DreamHost provides free SSL certificates)
- JWT authentication for secure API access
- Password hashing using bcrypt or Argon2 for user authentication
- SQL injection prevention using prepared statements
- Input validation and sanitization on both client and server
- Rate limiting to prevent abuse

**Cost Estimation** (DreamHost PHP/MySQL):

**DreamHost PHP/MySQL** (Selected Solution):
- **Additional Cost**: $0 (using existing DreamHost hosting and MySQL database)
- **If need to purchase**: Shared hosting ~$3-10/month (includes MySQL)
- **Database**: MySQL included with DreamHost hosting plans
- **SSL**: Free Let's Encrypt certificates included via DreamHost
- **Backend Development**: One-time development effort (no ongoing service fees)
- **Maintenance**: Minimal (PHP and MySQL are well-supported on DreamHost)

**Migration Path** (DreamHost PHP/MySQL):
1. **MVP Phase**: Implement local-only storage (Hive) - current requirement
2. **Post-MVP Phase 1 (Implementation Phase 2)**: Set up DreamHost PHP backend and MySQL database schema
3. **Post-MVP Phase 2 (Implementation Phase 3)**: Implement PHP REST API endpoints for sync operations
4. **Post-MVP Phase 3 (Implementation Phase 4)**: Implement JWT authentication for PHP backend
5. **Post-MVP Phase 4 (Implementation Phase 5)**: Add conflict resolution (timestamp-based for MySQL)
6. **Post-MVP Phase 5 (Implementation Phase 6)**: Add incremental sync and error handling
7. **Post-MVP Phase 6 (Implementation Phase 7)**: Add user controls (enable/disable sync, selective sync)
8. **Post-MVP Phase 7 (Implementation Phase 8)**: Set up HTTPS/SSL certificates (DreamHost provides free SSL)

### Platform & Framework
- **Primary Platform**: Android (minimum SDK 24, target SDK 34)
- **Framework**: Flutter with Dart
- **State Management**: Riverpod (default)
- **Architecture Pattern**: Feature-First Clean Architecture (default)
- **LLM API Abstraction**: Provider pattern or adapter interface to allow easy switching between different LLM API providers/models (OpenAI, Anthropic, open-source alternatives, etc.) without code changes

#### Project Structure

**Directory Layout**:
```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── utils/
│   └── widgets/ (shared widgets)
├── features/
│   ├── health_tracking/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── datasources/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── widgets/
│   │       └── providers/
│   ├── nutrition_management/
│   ├── exercise_management/
│   ├── medication_management/
│   ├── behavioral_support/
│   ├── analytics_insights/
│   └── llm_integration/
│       ├── providers/
│       ├── adapters/
│       └── prompts/
├── main.dart
└── app.dart
```

**Naming Conventions**:
- **Files**: snake_case (e.g., `health_tracking_repository.dart`)
- **Classes**: PascalCase (e.g., `HealthTrackingRepository`)
- **Variables/Methods**: camelCase (e.g., `calculateMovingAverage`)
- **Constants**: lowerCamelCase with `k` prefix (e.g., `kDefaultMovingAverageDays`)
- **Private members**: camelCase with `_` prefix (e.g., `_calculateAverage`)
- **Folders**: snake_case (e.g., `health_tracking/`)
- **Backend PHP files**: kebab-case (e.g., `health-metrics.php`)

### Integrations
- **Health Platforms**: Google Fit, Health Connect (Android)
- **Wearables**: Support for fitness trackers and smart scales (via health platform APIs)
- **Notifications**: Local notifications for medication reminders, check-ins, movement breaks
- **Grocery Store APIs**: Integration with grocery store APIs or web scraping for current sale items and promotions (e.g., Kroger API, Walmart API, Maxi/Loblaw for Quebec, or manual sale data entry)
- **LLM API Integration**: Cost-effective large language model API (DeepSeek recommended, or OpenAI GPT, Anthropic Claude, open-source alternatives) for:
  - Weekly review generation and personalized feedback
  - Intelligent analysis of health trends and patterns
  - Adaptive recommendations based on user progress
  - Contextual health insights and coaching
  - Meal plan suggestions based on preferences and goals
  - Sale-based meal planning that prioritizes discounted ingredients
  - Exercise plan modifications based on progress and feedback
  - Behavioral coaching and habit formation support
  - Interactive chat for feature requests and bug reports (guides users through structured questions to create complete requests)
- **LLM API Provider Abstraction**: 
  - Abstract interface/contract for LLM API calls to enable easy switching between providers
  - Configuration-based model selection (runtime configuration, not code changes)
  - Support for multiple providers simultaneously (e.g., primary and fallback)
  - Provider-specific implementations (DeepSeek adapter, OpenAI adapter, Anthropic adapter, Ollama adapter, etc.)
  - Unified API interface that abstracts provider differences
  - Easy addition of new LLM providers without modifying core application code

#### Grocery Store Integration: Maxi (Quebec)

**Context**: Maxi is a major grocery chain in Quebec, Canada, owned by Loblaw Companies Limited. For Quebec-based users, integrating Maxi's sale data is essential for cost-effective meal planning.

**Current API Status**:
- **No Public API**: Maxi/Loblaw does not currently provide a public API for accessing sales data or promotional information
- **Digital Initiatives**: Loblaw has invested in digital transformation (Microsoft AI partnerships, PC Optimum loyalty program) but no public developer API exists yet
- **Contact Information**: Maxi contact page: https://www.maxi.com/contact-us/

**Integration Options** (in order of preference):

1. **Direct Partnership** (Recommended - Long-term):
   - Contact Loblaw Companies Limited directly to explore partnership opportunities
   - Inquire about private API access or data-sharing agreements
   - Potential benefits: Official data access, reliable updates, legal compliance
   - Contact: Loblaw Companies Limited (https://www.loblaw.ca/)

2. **Web Scraping** (Short-term solution):
   - Scrape Maxi's weekly flyer from maxi.com or maxiclic.com
   - Extract sale items, prices, and promotion dates
   - **Important**: Must comply with Maxi's Terms of Service and robots.txt
   - **Legal Considerations**: Review Quebec/Canadian data scraping laws, respect rate limits
   - **Implementation**: Use Flutter web scraping libraries (e.g., `html` package) or backend scraping service
   - **Caching**: Cache sale data locally for offline access and to reduce scraping frequency

3. **Third-Party Services** (Alternative):
   - Some third-party services offer grocery data scraping APIs (e.g., iWeb Data Scraping)
   - **Considerations**: Legal/ethical implications, data accuracy, cost, reliability
   - **Recommendation**: Use only if legally compliant and as fallback option

4. **Manual Entry** (Fallback):
   - Allow users to manually enter sale items they see in Maxi flyers
   - Simple form interface for entering: item name, price, discount, valid dates
   - Community sharing: Users can optionally share sale data with other app users
   - **Advantages**: No legal concerns, user-controlled, works offline
   - **Disadvantages**: Requires user effort, may be incomplete

**Recommended Implementation Strategy**:
1. **MVP Phase**: Implement manual entry system for sale items
2. **Post-MVP Phase 1 (Maxi Integration Phase 2)**: Develop web scraping solution for Maxi flyer (with legal review)
3. **Post-MVP Phase 2 (Maxi Integration Phase 3)**: Contact Loblaw for potential partnership/API access
4. **Post-MVP Phase 3 (Maxi Integration Phase 4)**: If partnership available, migrate to official API

**Technical Requirements for Maxi Integration**:
- **Data Source**: Maxi weekly flyer (maxi.com or maxiclic.com)
- **Update Frequency**: Weekly (flyers typically update weekly)
- **Data Fields**: Item name, category, regular price, sale price, discount %, valid dates, store location
- **Language Support**: French (Quebec) and English
- **Caching**: Cache sale data for 7 days, refresh weekly
- **Offline Support**: Store cached sale data locally for offline meal planning
- **Error Handling**: Graceful fallback to manual entry if scraping fails

**Maxi-Specific Data Model Considerations**:
- Store location (Maxi stores in Quebec)
- Bilingual support (French/English product names)
- Quebec-specific pricing (CAD, tax considerations)
- Seasonal promotions (Quebec holidays, seasonal items)

**Legal & Compliance**:
- Review Maxi's Terms of Service before implementing web scraping
- Respect robots.txt and rate limits
- Comply with Quebec/Canadian data protection laws
- Consider user privacy when sharing sale data
- Provide clear attribution if using scraped data

#### LLM API Interface Specification

**Abstract Interface**:
```dart
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';

abstract class LLMProvider {
  Future<Either<LLMProviderFailure, String>> generateWeeklyReview({
    required Map<String, dynamic> healthData,
    required String userId,
  });
  
  Future<Either<LLMProviderFailure, String>> generateMealSuggestion({
    required Map<String, dynamic> preferences,
    required List<String> dietaryRestrictions,
    required Map<String, dynamic> progress,
  });
  
  Future<Either<LLMProviderFailure, String>> generateWorkoutAdaptation({
    required Map<String, dynamic> currentPlan,
    required Map<String, dynamic> progress,
    required List<String> constraints,
  });
  
  Future<Either<LLMProviderFailure, String>> generateFeatureRequest({
    required Map<String, dynamic> conversationHistory,
  });
  
  Future<Either<LLMProviderFailure, String>> generateBugReport({
    required Map<String, dynamic> conversationHistory,
  });
}
```

**Note**: The interface uses `Either<LLMProviderFailure, String>` to properly handle errors, matching the error handling pattern used elsewhere in the codebase. This allows for proper error propagation and handling without throwing exceptions.

**Provider Adapters**:
- `DeepSeekProvider implements LLMProvider` (default, recommended)
- `OpenAIProvider implements LLMProvider`
- `AnthropicProvider implements LLMProvider`
- `OllamaProvider implements LLMProvider`

**Configuration**:
```dart
class LLMConfig {
  final String provider; // 'deepseek', 'openai', 'anthropic', 'ollama'
  final String? apiKey;
  final String? model; // 'deepseek-chat' (default), 'gpt-4o-mini', 'claude-3-haiku', etc.
  final int maxTokens;
  final double temperature;
  final bool enableCaching;
}
```

**DeepSeek Advantages**:
- **Cost**: Extremely cost-effective (often 10x cheaper than OpenAI for similar quality)
- **API Compatibility**: OpenAI-compatible API, easy to integrate (can use OpenAI SDK with DeepSeek endpoint)
- **Quality**: Excellent quality for health coaching, meal planning, and workout suggestions
- **Performance**: Fast response times, good for real-time features
- **Availability**: Reliable service with good uptime
- **Model**: DeepSeek Chat (deepseek-chat) - optimized for conversational AI
- **Integration**: Can use `openai_dart` package with DeepSeek endpoint URL

**DeepSeek Implementation Example**:
```dart
// Using OpenAI-compatible package with DeepSeek endpoint
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';

class DeepSeekProvider implements LLMProvider {
  final String apiKey;
  final String baseUrl = 'https://api.deepseek.com/v1'; // DeepSeek API endpoint
  
  Future<Either<LLMProviderFailure, String>> generateWeeklyReview({
    required Map<String, dynamic> healthData,
    required String userId,
  }) async {
    try {
      final client = OpenAIClient(
        apiKey: apiKey,
        baseUrl: baseUrl, // Use DeepSeek endpoint
      );
      
      final response = await client.chat.completions.create(
        model: 'deepseek-chat',
        messages: [
          {'role': 'system', 'content': 'You are a health coach...'},
          {'role': 'user', 'content': formatHealthData(healthData)},
        ],
        temperature: 0.7,
        maxTokens: 500,
      );
      
      return Right(response.choices.first.message.content);
    } on NetworkException catch (e) {
      return Left(LLMProviderFailure('Network error: ${e.message}'));
    } on RateLimitException catch (e) {
      return Left(LLMProviderFailure('Rate limit exceeded: ${e.message}'));
    } catch (e) {
      return Left(LLMProviderFailure('LLM API error: ${e.toString()}'));
    }
  }
  
  // Similar error handling for other methods...
}
```

**Error Handling**:
- Network errors → retry with exponential backoff (max 3 retries)
- Rate limit errors → queue request, retry after delay
- Invalid response → fallback to default message or cached response
- Provider unavailable → automatically fallback to next provider (DeepSeek → OpenAI → Anthropic)

### UI/UX Requirements
- **Design System**: Modern, clean, health-focused design
- **Mockup Format**: All UI mockups and wireframes must be created using ASCII art in markdown files (not image files or design tool exports)
- **Accessibility**: WCAG compliance, screen reader support
- **Offline-First**: Core features work without internet connection
- **Performance**: Smooth animations, fast data loading, efficient battery usage

#### ASCII Art Mockup Format Specification

**Context**: UI/UX mockups must be created using ASCII art to ensure they are readable in plain text format, version-controllable, and can be easily generated by LLMs without requiring image generation tools.

**Format Requirements**:
- Use monospace-friendly characters: `│`, `─`, `┌`, `┐`, `└`, `┘`, `├`, `┤`, `┬`, `┴`, `║`, `═`, `╔`, `╗`, `╚`, `╝`
- Use simple characters for content: `[ ]`, `( )`, `|`, `-`, `_`
- Use text labels to indicate UI elements
- Keep mockups readable at standard terminal width (80-120 characters)
- Include annotations explaining components

**Example ASCII Mockup Format**:

```markdown
## Weight Entry Screen Mockup

┌─────────────────────────────────────────┐
│  ← Back          Weight Entry          │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────┐  │
│  │  Today's Weight                 │  │
│  │  ┌───────────────────────────┐  │  │
│  │  │  75.5                     │  │  │
│  │  │  kg                       │  │  │
│  │  └───────────────────────────┘  │  │
│  └─────────────────────────────────┘  │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │  7-Day Average: 75.2 kg         │  │
│  │  ─────────────────────────────  │  │
│  │  Trend: ↓ 0.3 kg this week      │  │
│  └─────────────────────────────────┘  │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │  [Select Date]                   │  │
│  └─────────────────────────────────┘  │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │         [Save Weight]            │  │
│  └─────────────────────────────────┘  │
│                                         │
└─────────────────────────────────────────┘
```

**Note**: The ASCII art mockup content should be placed directly in the markdown file. The example above shows the format - the mockup content (the ASCII art itself) goes directly in the markdown without being wrapped in code blocks. Code blocks (triple backticks) are only used for code examples, not for ASCII art mockups.

**Component Legend**:
- `┌─┐│└┘` = Screen borders and containers
- `[ ]` = Buttons or input fields
- Text labels = UI element descriptions
- `─` = Separators or dividers

**Mockup Requirements**:
- Each screen should have a clear ASCII representation
- Include component annotations below the mockup
- Show different states (empty, filled, error) when relevant
- Include navigation flow between screens
- Specify colors using text labels (e.g., "[Primary Button]" or "[Green Background]")
- Include spacing and layout information in annotations

**File Organization**:
- Create separate markdown files for each screen: `{screen-name}-mockup.md`
- Store in `artifacts/design/mockups/` or `docs/design/mockups/`
- Include wireframes, component specifications, and user flows in ASCII format

### Privacy & Security
- **Data Privacy**: All health data stored locally by default
- **Security**: HTTPS/SSL for data in transit, secure authentication (JWT)
- **LLM API Privacy**: Health data sent to LLM API should be anonymized/minimized, with user consent and clear privacy controls
- **No Cloud Requirement**: Core app features function fully without cloud services (privacy-first approach), LLM features require internet but should minimize data exposure
- **Compliance**: Consider health data privacy regulations (user's jurisdiction), especially regarding LLM data processing

### Technical Decisions & Defaults

**Framework & Platform**:
- **Flutter Version**: 3.24.0 (LTS) or latest stable
- **Dart Version**: 3.3.0 or compatible
- **Minimum Android SDK**: 24 (Android 7.0 Nougat) - supports 95%+ devices
- **Target Android SDK**: 34 (Android 14)
- **State Management**: Riverpod (default) - provides better type safety and testing than Provider
- **Architecture Pattern**: Feature-First Clean Architecture (default)
- **Database**: Hive (default) - better performance than SQLite for Flutter, simpler API
- **Dependency Injection**: Riverpod (built-in) - no separate DI framework needed

**LLM Integration**:
- **Default LLM Provider**: DeepSeek (highly cost-effective, excellent quality, OpenAI-compatible API)
- **Fallback Provider**: OpenAI GPT-4o-mini (if DeepSeek unavailable)
- **Alternative Providers**: Anthropic Claude 3 Haiku, Ollama (for offline development/testing)
- **Prompt Caching**: Enabled by default (reduce costs)
- **Rate Limiting**: 10 requests/minute per user (default)
- **Why DeepSeek**: Extremely cost-effective (often 10x cheaper than OpenAI), OpenAI-compatible API, excellent quality for health coaching use cases

**Backend**:
- **Backend Language**: PHP 8.1+ (DreamHost)
- **Framework**: Slim Framework 4.x (recommended) - lightweight, perfect for REST APIs
- **Database**: MySQL (DreamHost)
- **API Style**: REST API with JSON
- **Authentication**: JWT tokens (using firebase/php-jwt)
- **Security**: HTTPS/SSL for data in transit, JWT authentication

**Code Quality**:
- **Linter**: flutter_lints (latest)
- **Test Coverage Target**: 80% minimum for business logic, 60% minimum for UI
- **Documentation**: Dartdoc for public APIs, inline comments for complex logic

### Development Practices & Standards
- **Version Control**: Git with conventional commit standards
- **Commit Message Standards**: Follow CRISPE Framework Prompt for generating commit messages (see below)
- **Git Workflow**: Follow CRISPE Framework Prompt for branch, pull request, code review, and merge processes (see below)
- **Sprint Planning**: Follow CRISPE Framework Prompt for creating sprint planning documents (see below)
- **Feature Request & Bug Fix Process**: Follow CRISPE Framework Prompt for managing feature requests and bug fixes (see below)
- **Interactive LLM Chat**: Use CRISPE Framework Prompt for interactive feature request and bug fix creation via LLM chat (see below)
- **Backlog Management**: Maintain product backlog with status tracking (Not Started → In Progress → Completed)
- **Agile Methodology**: Scrum framework with sprint-based development cycles
- **Code Quality**: Follow Flutter/Dart best practices and linting rules
- **Code Review**: Mandatory code review process with approval requirements
- **Documentation**: Inline code documentation and README files for each module

#### Testing Specifications

**Test Structure**:
```
test/
├── unit/
│   ├── features/
│   │   ├── health_tracking/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── nutrition/
│   │   ├── exercise/
│   │   └── ...
│   └── core/
├── widget/
│   └── features/
│       └── [mirror lib structure]
├── integration/
└── fixtures/ (test data)
```

**Test Coverage Requirements**:
- **Unit Tests**: 80% minimum coverage for business logic (domain layer)
- **Widget Tests**: All custom widgets, 60% minimum coverage for UI components
- **Integration Tests**: Critical user flows (weight entry, weekly review, sync operations)

**Example Test Pattern**:
```dart
// test/unit/features/health_tracking/domain/usecases/calculate_moving_average_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/features/health_tracking/domain/usecases/calculate_moving_average.dart';

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
    
    test('should return null if less than 7 days of data', () {
      final metrics = [/* only 3 days of data */];
      final usecase = CalculateMovingAverage();
      final result = usecase(metrics);
      expect(result, isNull);
    });
  });
}
```

**Mock Requirements**:
- Mock LLM providers for testing (use `MockLLMProvider`)
- Mock database for repository tests (use in-memory Hive or mocks)
- Mock network for API tests (use `http_mock_adapter` or similar)
- Mock PHP backend responses for sync tests

#### LLM Prompt Templates

**Weekly Review Prompt Template**:
```
You are a health coach analyzing a user's weekly health data.

User Data:
- Weight: {weight} kg (7-day average: {average})
- Sleep Quality: {sleepQuality}/10
- Energy Level: {energyLevel}/10
- Exercise: {exerciseSummary}
- Nutrition: {nutritionSummary}
- Medications: {medications}
- Progress: {progressSummary}

Generate a personalized weekly review that:
1. Highlights progress and achievements
2. Identifies areas for improvement
3. Provides 2-3 actionable recommendations
4. Uses encouraging, supportive tone
5. References the user's health goals and medication considerations

Keep response under 300 words.
```

**Meal Suggestion Prompt Template**:
```
You are a nutritionist helping with meal planning.

User Preferences:
- Dietary Approach: Low-carb (<40g net carbs)
- Target Macros: 35% protein, 55% fats, net carbs <40g absolute maximum (not percentage-based)
- Medications: {medications} (consider protein-first strategy)
- Preferences: {preferences}
- Available Ingredients: {availableIngredients}
- Sale Items This Week: {saleItems} (prioritize these items for cost savings)

Generate 3 meal suggestions for {mealType} that:
1. Meet macro targets
2. Are gourmet and flavorful
3. Consider medication interactions
4. Include preparation time and difficulty
5. Prioritize sale items when possible to maximize cost savings
6. Use available ingredients when possible

Format as JSON with: name, ingredients, instructions, macros (protein, fats, netCarbs, calories), prepTime, difficulty, estimatedCost, saleItemsUsed.
```

**Sale-Based Meal Planning Prompt Template**:
```
You are a nutritionist creating a cost-effective weekly meal plan based on current grocery store sales.

User Preferences:
- Dietary Approach: Low-carb (<40g net carbs)
- Target Macros: 35% protein, 55% fats, net carbs <40g absolute maximum (not percentage-based)
- Medications: {medications} (consider protein-first strategy)
- Preferences: {preferences}
- Budget Considerations: {budgetInfo}

Current Sale Items This Week:
{saleItems} (each item includes: name, price, discount, store, category)

Generate a 7-day meal plan that:
1. Maximizes use of sale items to reduce grocery costs
2. Meets daily macro targets (35% protein, 55% fats, <40g net carbs)
3. Provides variety and gourmet flavors
4. Considers medication interactions (protein-first strategy)
5. Minimizes food waste by reusing ingredients across meals
6. Includes estimated total weekly grocery cost
7. Provides shopping list organized by store section/category

Format as JSON with: dailyMeals (breakfast, lunch, dinner, snacks), weeklyShoppingList (with sale items highlighted), estimatedWeeklyCost, totalSavings, mealPrepSuggestions.
```

**Workout Adaptation Prompt Template**:
```
You are an exercise physiologist adapting workout plans.

Current Plan: {currentPlan}
User Progress: {progress}
Constraints: {constraints} (joint issues, equipment, time)
Goals: {goals}

Suggest workout modifications that:
1. Address current progress and feedback
2. Respect joint safety and constraints
3. Maintain progressive overload
4. Consider available equipment
5. Fit within time constraints

Format as JSON with: exercises, sets, reps, restPeriods, modifications, rationale.
```

**Feature Request Chat Prompt**: See "Interactive LLM Chat for Feature Requests & Bug Fixes" section below.

#### Git Commit Message Standards (CRISPE Framework)

**Context**: You are working in a professional software development environment where clear, consistent commit messages are essential for code review, debugging, and project history tracking. The team follows conventional commit standards to maintain a clean, searchable git history.

**Role**: Act as an expert Git practitioner and version control specialist with deep knowledge of conventional commit specifications, semantic versioning, and git best practices.

**Instruction**: Generate a professional, well-structured commit message that follows conventional commit standards. Analyze the provided code changes and create a commit message with a proper type, optional scope, clear subject line, detailed body, and footer when applicable.

**Subject**: Git commit message generation and version control documentation.

**Preset**: 
- Title: Must contain the task number or ID in the footer (e.g., "Refs FR-042" or "Closes #42"), followed by a short business description in the subject line
- First paragraph: Use business language that describes why the changes were made and how they will help users or improve the business value. Focus on the benefits and impact from a business perspective.
- Second paragraph: Use technical language geared toward programmers and technical stakeholders. Use bullet points to list:
  - Technical implementation details
  - Code changes and architecture decisions
  - Dependencies or system interactions
  - Performance considerations or optimizations
  - Any technical trade-offs or considerations
- Format: `<type>(<scope>): <subject>`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`, `build`, `revert`
- Subject line: Maximum 50 characters, imperative mood, capitalized, no period (task number goes in footer, not subject)
- Body: First paragraph (business-focused), blank line, second paragraph (technical bullets)
- Footer: Reference issues/PRs with task number (e.g., "Refs FR-042" or "Closes #42")
- Tone: Professional, concise, clear
- Structure: Type header, blank line, business paragraph, blank line, technical paragraph (bullets), blank line, footer

**Exception**: 
- Do not include implementation details in the subject line
- Do not use past tense ("Added" → use "Add")
- Do not exceed character limits
- Do not skip the body for non-trivial changes
- Do not include personal opinions or emotional language

**Example Commit Message Format**:
```
feat(health-tracking): Add 7-day moving average calculation

This enhancement improves user experience by providing more accurate 
weight trend visualization, reducing anxiety from daily weight fluctuations. 
Users can now see meaningful progress trends that account for natural 
body weight variations, leading to better adherence and motivation.

- Implemented MovingAverageCalculator service with 7-day window
- Added WeightTrendRepository method to fetch historical data
- Created WeightTrendChart widget using fl_chart library
- Added unit tests for moving average calculation edge cases
- Performance: O(n) time complexity with efficient sliding window algorithm
- Data: Requires minimum 7 days of weight entries for calculation

Closes #42
```

#### Git Workflow Process (Branch, Pull Request, Code Review, Merge)

**Context**: You are working in a professional software development environment using Git for version control. The team follows a structured git workflow with feature branches, pull requests, code reviews, and controlled merges to maintain code quality, enable collaboration, and preserve a clean project history.

**Role**: Act as an expert Git workflow specialist and code review coordinator with deep knowledge of branching strategies, pull request best practices, code review processes, and merge procedures. You ensure all code changes follow the established workflow and quality standards.

**Instruction**: When provided with a feature request, bug fix, or code change, guide the creation of a feature branch, pull request with proper description, code review checklist, and merge process. Ensure all steps follow the defined workflow and quality gates.

**Subject**: Git branching strategy, pull request creation, code review process, merge procedures, branch naming conventions, PR templates, and code review checklists.

**Preset**:
- **Branch Naming**: `feature/FR-XXX-short-description`, `bugfix/BF-XXX-short-description`, `hotfix/description`, `chore/description`
- **Branch Strategy**: Feature branch workflow (branch from `main`, merge back via PR)
- **Pull Request Status**: 🟡 Draft → 🟢 Ready for Review → 🔵 In Review → ✅ Approved → 🟣 Merged
- **Code Review Requirements**: Minimum 1 approval before merge
- **PR Description Format**: Must include business value, technical details, testing notes, and checklist
- **Merge Strategy**: Squash and merge (preferred) or merge commit
- **Protection Rules**: `main` branch protected, requires PR and approvals
- **Tone**: Professional, collaborative, constructive

**Exception**:
- Do not merge directly to `main` without pull request
- Do not skip code review for any changes
- Do not create branches without linking to feature request or bug fix ID
- Do not merge PRs without required approvals
- Do not forget to update related documentation
- Do not skip testing requirements in PR checklist

**Git Workflow Process**:

### 1. Branch Creation

**Branch Naming Convention**:
- Feature: `feature/FR-XXX-short-description` (e.g., `feature/FR-042-7-day-moving-average`)
- Bug Fix: `bugfix/BF-XXX-short-description` (e.g., `bugfix/BF-015-weight-chart-crash`)
- Hotfix: `hotfix/critical-issue-description` (e.g., `hotfix/data-loss-prevention`)
- Chore: `chore/description` (e.g., `chore/update-dependencies`)

**Branch Creation Steps**:
```bash
# 1. Ensure main branch is up to date
git checkout main
git pull origin main

# 2. Create and switch to new feature branch
git checkout -b feature/FR-XXX-description

# 3. Verify branch creation
git branch
```

**Branch Requirements**:
- Branch from latest `main` branch
- Link branch to feature request (FR-XXX) or bug fix (BF-XXX) ID
- Use kebab-case for descriptions
- Keep branch names concise but descriptive

### 2. Pull Request Creation

**Pull Request Template**:

```markdown
## Pull Request: [PR Title]

**Type**: [Feature / Bug Fix / Hotfix / Chore]  
**Related Issue**: [FR-XXX / BF-XXX]  
**Status**: 🟡 Draft  
**Branch**: `feature/FR-XXX-description` → `main`  
**Created**: [Date]  
**Author**: [Name]

### Description
[Brief description of changes]

### Business Value
[Why this change is important and what problem it solves]

### Technical Changes
- [ ] Change 1
- [ ] Change 2
- [ ] Change 3

### Related Documents
- [Document Name 1]
- [Document Name 2]

### Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Tested on Android [Version]
- [ ] No breaking changes (or breaking changes documented)

### Code Review Checklist
- [ ] Code follows project style guidelines
- [ ] Code is properly commented
- [ ] No hardcoded values or secrets
- [ ] Error handling implemented
- [ ] Performance considerations addressed
- [ ] Accessibility requirements met (if UI changes)
- [ ] Documentation updated (if needed)

### Screenshots/Demo
[If UI changes, include screenshots or demo]

### Additional Notes
[Any additional context, concerns, or follow-up items]

---

**Review Status**:
- [Date] - 🟡 Created as Draft
- [Date] - 🟢 Marked Ready for Review
- [Date] - 🔵 In Review by [Reviewer Name]
- [Date] - ✅ Approved by [Reviewer Name]
- [Date] - 🟣 Merged to `main`
```

**PR Status Lifecycle**:
1. 🟡 **Draft**: Initial creation, work in progress
2. 🟢 **Ready for Review**: All checks pass, ready for review
3. 🔵 **In Review**: Under active code review
4. ✅ **Approved**: Approved by required reviewers
5. 🟣 **Merged**: Successfully merged to `main`

### 3. Code Review Process

**Code Review Checklist**:

```markdown
## Code Review Checklist

### Functionality
- [ ] Code works as intended
- [ ] Edge cases handled
- [ ] Error handling implemented
- [ ] No obvious bugs

### Code Quality
- [ ] Follows project coding standards
- [ ] Code is readable and maintainable
- [ ] No code duplication
- [ ] Proper naming conventions
- [ ] Comments added where necessary

### Architecture
- [ ] Follows project architecture patterns
- [ ] No unnecessary dependencies
- [ ] Proper separation of concerns
- [ ] Design patterns used appropriately

### Testing
- [ ] Unit tests cover new functionality
- [ ] Tests are meaningful and not trivial
- [ ] Edge cases tested
- [ ] Integration tests updated (if needed)

### Security & Privacy
- [ ] No sensitive data exposed
- [ ] Input validation implemented
- [ ] Security best practices followed
- [ ] Privacy considerations addressed (for health data)

### Performance
- [ ] No obvious performance issues
- [ ] Efficient algorithms/data structures
- [ ] Memory leaks checked
- [ ] Database queries optimized (if applicable)

### Documentation
- [ ] Code is self-documenting
- [ ] Complex logic explained
- [ ] README updated (if needed)
- [ ] API documentation updated (if applicable)

### UI/UX (if applicable)
- [ ] Design system followed
- [ ] Accessibility requirements met
- [ ] Responsive design considered
- [ ] User experience validated
```

**Review Process**:
1. Author marks PR as "Ready for Review" (🟢)
2. Assign reviewers (minimum 1, typically 2 for complex changes)
3. Reviewers review code using checklist
4. Reviewers provide feedback (approve, request changes, or comment)
5. Author addresses feedback and updates PR
6. Repeat review cycle until approved
7. Once approved (✅), PR can be merged

**Review Guidelines**:
- Be constructive and respectful
- Focus on code, not the person
- Explain the "why" behind suggestions
- Approve when satisfied, don't block for minor issues
- Request changes for blocking issues only

### 4. Merge Process

**Pre-Merge Checklist**:
- [ ] All required approvals obtained
- [ ] All CI/CD checks passing
- [ ] No merge conflicts
- [ ] Branch is up to date with `main`
- [ ] PR description complete
- [ ] Related feature request/bug fix updated

**Merge Steps**:
```bash
# 1. Ensure branch is up to date
git checkout feature/FR-XXX-description
git pull origin main
git rebase main  # or merge main into branch

# 2. Resolve any conflicts
# 3. Push updated branch
git push origin feature/FR-XXX-description

# 4. Merge via GitHub/GitLab UI (squash and merge preferred)
# 5. Delete branch after merge
```

**Merge Strategy**:
- **Squash and Merge** (Preferred): Combines all commits into one, cleaner history
- **Merge Commit**: Preserves branch history, creates merge commit
- **Rebase and Merge**: Linear history, rewrites commits (use with caution)

**Post-Merge Actions**:
1. Update feature request/bug fix status to ✅ Completed
2. Update sprint document if item was in sprint
3. Update Product Backlog
4. Delete merged branch (if not auto-deleted)
5. Tag release if applicable

**Branch Protection Rules** (for `main` branch):
- Require pull request before merging
- Require approvals (minimum 1)
- Require status checks to pass
- Require branches to be up to date
- Restrict force pushes
- Restrict deletions

#### Sprint Planning Standards (CRISPE Framework)

**Context**: You are creating sprint planning documents in markdown format for an Agile/Scrum team. The sprint documentation needs to be well-structured, trackable, and reference technical specifications. Each sprint contains user stories with associated tasks that reference specific technical documents, classes, and methods.

**Role**: Act as an experienced Certified Scrum Master (CSM) specializing in sprint planning, backlog refinement, and creating structured sprint documentation. You excel at breaking down user stories into actionable tasks with clear technical references and accurate story point estimation.

**Instruction**: Create comprehensive sprint planning markdown files. When provided with sprint information, user stories, or feature requirements, generate a well-structured markdown sprint document that includes user stories with agile points, tasks with technical references (document names, class names, method names), completion tracking, and proper Scrum formatting.

**Subject**: Sprint planning, user story creation, task breakdown, agile estimation, markdown formatting, technical documentation references, sprint tracking, and Scrum artifacts.

**Preset**:
- Format: Markdown files with clear hierarchy and structure
- Structure: 
  - Sprint header (name, dates, goal)
  - User Stories (with agile points)
    - Tasks (with completion status column, class/method references, document references)
    - Subtasks (with agile points)
- Story Points: Use Fibonacci sequence (1, 2, 3, 5, 8, 13) for estimation
- Task Format: Include columns for task description, class/method reference, document reference, completion status
- Document References: Always mention the reference document name explicitly
- Technical References: Include class name and method name in task descriptions
- Completion Tracking: Use checkboxes or status columns (✅ Complete / ⏳ In Progress / ⭕ Not Started)
- Tone: Professional, clear, and structured
- Markdown: Use proper markdown syntax (headers, tables, checkboxes, code blocks)

**Exception**:
- Do not create tasks without referencing the source document by name
- Do not omit class and method names in task descriptions
- Do not skip completion status tracking for tasks
- Do not forget to assign agile points to stories and subtasks
- Do not use vague task descriptions - be specific with technical details
- Do not create sprint documents without proper markdown formatting
- Do not estimate without considering story complexity and team velocity

**Required Sprint Markdown Structure**:

```markdown
# Sprint [Number]: [Sprint Name]

**Sprint Goal**: [Clear, measurable goal]
**Duration**: [Start Date] - [End Date]
**Team Velocity**: [Previous sprint velocity or target]

## User Stories

### Story 1: [Story Title] - [X] Points

**Description**: [As a... I want... So that...]

**Reference Document**: [Document Name]

**Tasks**:
| Task | Description | Class/Method | Document Reference | Status | Points |
|------|-------------|-------------|-------------------|--------|--------|
| Task 1 | [Task description mentioning class.method()] | ClassName.methodName() | [Document Name] | ⭕ | [X] |
| Task 2 | [Task description mentioning class.method()] | ClassName.methodName() | [Document Name] | ⭕ | [X] |

**Subtasks**:
- [ ] Subtask 1 - [X] Points
- [ ] Subtask 2 - [X] Points

### Story 2: [Story Title] - [X] Points
[...]
```

#### Feature Request & Bug Fix Process

**Context**: You are managing a product backlog in an Agile/Scrum environment. Feature requests and bug reports need to be properly documented, prioritized, and tracked through their lifecycle from submission to completion. All items must be added to the backlog and their status updated as work progresses.

**Role**: Act as a Product Owner and Scrum Master managing feature requests and bug fixes. You ensure all requests are properly documented, estimated, prioritized, and tracked through the development lifecycle.

**Instruction**: When provided with a feature request or bug report, create a properly formatted backlog item, add it to the product backlog, and update the backlog status as the item progresses through development (Not Started → In Progress → Completed).

**Subject**: Feature request management, bug fix tracking, backlog management, issue lifecycle, status updates, and product backlog maintenance.

**Preset**:
- **Backlog Status Lifecycle**: ⭕ Not Started → ⏳ In Progress → ✅ Completed
- **Priority Levels**: 🔴 Critical / 🟠 High / 🟡 Medium / 🟢 Low
- **Item Types**: Feature Request / Bug Fix
- **Estimation**: Use Fibonacci sequence (1, 2, 3, 5, 8, 13) for story points
- **Format**: Markdown files with clear structure and tracking fields
- **Backlog Updates**: Update status immediately when work begins or completes
- **Reference Documents**: Link to technical specifications, design documents, or related issues
- **Tone**: Professional, clear, and actionable

**Exception**:
- Do not add items to backlog without proper documentation
- Do not skip status updates when work begins or completes
- Do not forget to assign story points and priority
- Do not create backlog items without clear acceptance criteria
- Do not omit technical references or related documents

**Feature Request Form Template**:

```markdown
## Feature Request: [Feature Name]

**ID**: FR-[Number]  
**Type**: Feature Request  
**Priority**: [🔴 Critical / 🟠 High / 🟡 Medium / 🟢 Low]  
**Story Points**: [X]  
**Status**: ⭕ Not Started  
**Created**: [Date]  
**Requested By**: [Name/Email]  
**Sprint**: [Sprint Number or "Backlog"]

### Description
**As a** [user type]  
**I want** [feature description]  
**So that** [benefit/value]

### Business Value
[Why this feature is important and what problem it solves]

### Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

### Technical Requirements
- **Module**: [Module Name]
- **Related Documents**: [Document Names]
- **Classes/Methods**: [ClassName.methodName() if known]
- **Dependencies**: [List of dependencies]

### Design/UI References
[Link to design documents, wireframes, or ASCII art mockups (markdown files)]

### Notes
[Additional context, constraints, or considerations]

---

**Backlog Status History**:
- [Date] - ⭕ Added to backlog
- [Date] - ⏳ Moved to In Progress (Sprint [X])
- [Date] - ✅ Completed
```

**Bug Fix Form Template**:

```markdown
## Bug Fix: [Bug Title]

**ID**: BF-[Number]  
**Type**: Bug Fix  
**Priority**: [🔴 Critical / 🟠 High / 🟡 Medium / 🟢 Low]  
**Story Points**: [X]  
**Status**: ⭕ Not Started  
**Created**: [Date]  
**Reported By**: [Name/Email]  
**Sprint**: [Sprint Number or "Backlog"]

### Description
[Clear description of the bug and its impact]

### Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

### Expected Behavior
[What should happen]

### Actual Behavior
[What actually happens]

### Environment
- **App Version**: [Version]
- **Platform**: Android [Version]
- **Device**: [Device Model if applicable]
- **OS Version**: [Android Version]

### Technical Details
- **Module**: [Module Name]
- **Related Documents**: [Document Names]
- **Classes/Methods**: [ClassName.methodName()]
- **Error Messages**: [If applicable]
- **Logs/Screenshots**: [Links if available]

### Acceptance Criteria
- [ ] Bug is fixed
- [ ] Unit tests added/updated
- [ ] Regression tests pass
- [ ] Documentation updated (if needed)

### Notes
[Additional context, workarounds, or related issues]

---

**Backlog Status History**:
- [Date] - ⭕ Added to backlog
- [Date] - ⏳ Moved to In Progress (Sprint [X])
- [Date] - ✅ Completed
```

#### Interactive LLM Chat for Feature Requests & Bug Fixes

**Context**: You are an AI assistant helping users create feature requests and bug reports through an interactive conversation. Users may not know all the details needed for a complete request, so you guide them through a structured question-and-answer process, ask clarifying questions, and provide recommendations based on their responses and the project context.

**Role**: Act as a helpful Product Owner and Technical Analyst who conducts interactive interviews to gather comprehensive information for feature requests and bug fixes. You ask targeted questions, provide recommendations, and help users think through their needs to create well-documented requests.

**Instruction**: Engage in a conversational, interactive dialogue with the user. Ask questions one or two at a time (not all at once), wait for responses, and use their answers to guide subsequent questions. After gathering sufficient information, provide recommendations for priority, story points, and technical approach. Finally, generate a complete feature request or bug fix form based on the conversation.

**Subject**: Interactive feature request creation, bug report collection, user interview, requirements gathering, priority recommendation, story point estimation, and technical recommendations.

**Preset**:
- **Conversation Style**: Friendly, professional, conversational (not robotic)
- **Question Strategy**: Ask 1-2 questions at a time, wait for responses before proceeding
- **Follow-up Questions**: Use user responses to ask clarifying questions
- **Recommendations**: Provide priority, story points, and technical recommendations based on conversation
- **Output Format**: Generate complete feature request or bug fix form in markdown
- **Context Awareness**: Reference existing project modules, features, and technical documents when relevant
- **Tone**: Helpful, encouraging, and collaborative

**Exception**:
- Do not ask all questions at once - make it conversational
- Do not skip asking clarifying questions when information is unclear
- Do not generate forms without sufficient information
- Do not make assumptions - ask if unsure
- Do not rush the conversation - let users think and respond
- Do not forget to provide recommendations based on gathered information

**Interactive Chat Process**:

### Step 1: Initial Greeting and Type Identification

**Opening**:
```
Hello! I'm here to help you create a feature request or report a bug. 

What would you like to do today?
1. Request a new feature
2. Report a bug
3. Something else (please describe)
```

**After User Response**:
- If Feature Request → Proceed to Feature Request Questions
- If Bug Report → Proceed to Bug Report Questions
- If Something Else → Clarify and guide appropriately

### Step 2: Feature Request Questions (Interactive)

**Question Flow** (ask 1-2 at a time):

1. **Initial Understanding**:
   - "What feature would you like to add? Please describe it in your own words."
   - Wait for response, then ask: "Who would use this feature? (e.g., end users, administrators, developers)"

2. **User Story Development**:
   - "As a [user type you identified], what would you want to do with this feature?"
   - "What problem would this solve or what benefit would it provide?"

3. **Business Value**:
   - "Why is this feature important? What happens if we don't build it?"
   - "How many users would benefit from this feature?"

4. **Scope and Details**:
   - "Can you describe how this feature would work? What would the user see or do?"
   - "Are there any specific requirements or constraints we should know about?"

5. **Technical Context** (if user provides technical details):
   - "Which part of the app would this affect? (e.g., health tracking, nutrition, exercise, etc.)"
   - "Does this relate to any existing features we should consider?"

6. **Priority Assessment**:
   - "How urgent is this feature? Is it blocking other work or user needs?"
   - "Would this be a nice-to-have or essential for the app's success?"

7. **Acceptance Criteria**:
   - "What would need to be true for you to consider this feature complete?"
   - "Are there any specific behaviors or outcomes you expect?"

**After Gathering Information**:
- Provide priority recommendation (🔴 Critical / 🟠 High / 🟡 Medium / 🟢 Low) with reasoning
- Provide story point estimate (1, 2, 3, 5, 8, 13) with reasoning
- Suggest related modules or technical areas
- Generate complete feature request form

### Step 3: Bug Report Questions (Interactive)

**Question Flow** (ask 1-2 at a time):

1. **Initial Understanding**:
   - "What bug are you experiencing? Please describe what's happening."
   - Wait for response, then ask: "When did you first notice this issue?"

2. **Expected vs Actual Behavior**:
   - "What should happen normally? (Expected behavior)"
   - "What actually happens instead? (Actual behavior)"

3. **Reproduction Steps**:
   - "Can you walk me through the steps to reproduce this bug? What do you do first?"
   - Continue asking for next steps until complete: "What happens next?"

4. **Environment Details**:
   - "What device are you using? (e.g., Android phone model)"
   - "What version of the app are you using?"
   - "What version of Android?"

5. **Impact Assessment**:
   - "How often does this happen? (Always, sometimes, rarely)"
   - "How severe is the impact? Does it prevent you from using the app, or is it just annoying?"
   - "Are you able to work around it, or is it completely blocking?"

6. **Additional Context**:
   - "Are there any error messages? If so, what do they say?"
   - "Did this work before? If so, when did it stop working?"
   - "Does this happen for all users or just you?"

7. **Technical Details** (if user can provide):
   - "Which part of the app is affected? (e.g., weight tracking, meal logging, etc.)"
   - "What were you trying to do when this happened?"

**After Gathering Information**:
- Provide priority recommendation (🔴 Critical / 🟠 High / 🟡 Medium / 🟢 Low) with reasoning
- Provide story point estimate (1, 2, 3, 5, 8, 13) with reasoning
- Suggest potential root causes or areas to investigate
- Generate complete bug fix form

### Step 4: Recommendations and Form Generation

**After completing the interview, provide**:

1. **Summary**:
   - "Based on our conversation, here's what I understand: [summary]"

2. **Recommendations**:
   - **Priority**: [Recommendation] - [Reasoning]
   - **Story Points**: [Estimate] - [Reasoning]
   - **Technical Notes**: [Any technical recommendations or considerations]

3. **Generated Form**:
   - "I've created a [Feature Request / Bug Fix] form for you. Here it is:"
   - Display complete markdown form
   - "Would you like me to adjust anything, or is this ready to add to the backlog?"

### Example Conversation Flow:

**User**: "I want to add a feature"

**LLM**: "Great! What feature would you like to add? Please describe it in your own words."

**User**: "I want users to be able to set reminders for taking their medications"

**LLM**: "That sounds useful! Who would use this feature - would it be for all users who take medications, or a specific group?"

**User**: "All users who track medications in the app"

**LLM**: "Perfect. As a user who tracks medications, what would you want to do with this reminder feature? Would you want daily reminders, or reminders at specific times?"

**User**: "Both - I want to set custom times for each medication"

**LLM**: "Excellent! What problem would this solve? Are users currently forgetting to take medications?"

**User**: "Yes, sometimes I forget, especially if I'm busy"

**LLM**: "I understand - medication adherence is important for health outcomes. How urgent is this feature? Is medication non-compliance causing health issues, or is it more of a convenience feature?"

**User**: "It's pretty important - some medications need to be taken at specific times"

**LLM**: "Got it. Let me ask a few more questions to complete the request:
- What would you see when the reminder appears? (notification, in-app alert, both?)
- Should reminders repeat daily, or allow custom schedules?
- Should users be able to mark medications as 'taken' from the reminder?"

[Continue conversation...]

**LLM** (after gathering all info): "Based on our conversation, here's my recommendation:

**Priority**: 🟠 High - Medication adherence is critical for health outcomes, and this directly supports the app's core health management purpose.

**Story Points**: 5 - This involves notification system integration, scheduling logic, UI for reminder setup, and medication tracking updates.

**Technical Notes**: This will likely involve the Medication Management Module, notification system, and may need integration with Android's notification scheduling.

Here's your complete Feature Request form:"

[Display generated form]

**Note**: This Interactive LLM Chat prompt should be saved as a standalone markdown file (e.g., `interactive-feature-request-bug-fix-prompt.md`) that can be directly provided to an LLM. The LLM will use this prompt to conduct interactive conversations with users, asking questions one at a time, gathering information, and generating complete feature request or bug fix forms. This prompt can be used both:
- As a standalone tool for developers/product owners to create requests
- As an integrated feature in the app for users to submit feedback and feature requests

**Product Backlog Structure**:

```markdown
# Product Backlog

**Last Updated**: [Date]  
**Total Items**: [X]  
**In Progress**: [X]  
**Completed This Sprint**: [X]

## Backlog Items

### Feature Requests
| ID | Title | Priority | Points | Status | Sprint | Created |
|----|-------|----------|--------|--------|--------|---------|
| FR-001 | [Feature Name] | 🟠 High | 5 | ⏳ In Progress | Sprint 2 | [Date] |
| FR-002 | [Feature Name] | 🟡 Medium | 3 | ⭕ Not Started | Backlog | [Date] |

### Bug Fixes
| ID | Title | Priority | Points | Status | Sprint | Created |
|----|-------|----------|--------|--------|--------|---------|
| BF-001 | [Bug Title] | 🔴 Critical | 2 | ⏳ In Progress | Sprint 2 | [Date] |
| BF-002 | [Bug Title] | 🟡 Medium | 1 | ⭕ Not Started | Backlog | [Date] |

## Status Update Process

1. **When item is added to backlog**:
   - Create feature request or bug fix form
   - Add to Product Backlog with status ⭕ Not Started
   - Assign story points and priority
   - Link to related documents

2. **When work begins** (item moved to sprint):
   - Update status to ⏳ In Progress
   - Add entry to Backlog Status History
   - Update Sprint document with the item
   - Update Product Backlog table

3. **When work completes**:
   - Update status to ✅ Completed
   - Add completion date to Backlog Status History
   - Update Sprint document (mark tasks complete)
   - Update Product Backlog table
   - Move to "Completed Items" section if maintaining archive
```

## Constraints and Limitations

### Technical Constraints
- **Offline-First**: Core features must work without internet connection
- **Privacy**: No health data sent to cloud without explicit user consent
- **Performance**: App must start in < 3 seconds, screens load in < 1 second
- **Battery**: Background tasks must be optimized, no unnecessary wake locks
- **Storage**: Minimize local storage usage, implement data cleanup for old entries (> 1 year)
- **Memory**: Efficient memory usage, avoid memory leaks, handle large datasets gracefully
- **Grocery Store APIs**: Sale data integration must support fallback to manual entry if APIs unavailable; cache sale data for offline meal planning; handle API rate limits and errors gracefully

### Business Constraints
- **Cost**: LLM API calls must be cost-effective (< $0.10 per weekly review per user) - DeepSeek enables this with 10x lower costs (often $0.01-0.02 per review vs $0.10+ for OpenAI)
- **LLM Cost Management**: The $0.10 limit is per weekly review per user. Rate limiting (10 requests/minute) works in conjunction with cost limits to prevent excessive usage. Consider implementing monthly cost caps per user if needed.
- **Compliance**: Must comply with health data privacy regulations (user's jurisdiction)
- **Accessibility**: Must meet WCAG 2.1 AA standards
- **Backend Cost**: $0 additional cost (using existing DreamHost hosting)
- **LLM Cost Optimization**: DeepSeek provides excellent cost-effectiveness while maintaining quality

### Platform Constraints
- **Android Only**: No iOS support in initial version
- **Minimum Android**: Android 7.0 (API 24) for maximum device compatibility
- **Permissions**: Request permissions only when needed, explain why
- **API Level**: Target API 34 (Android 14) for latest features

### Data Constraints
- **Retention**: Health data retained locally, user can export/delete
- **Backup**: No automatic cloud backup (privacy-first), user can enable optional sync
- **Sync**: Optional sync feature, not required for MVP
- **Security**: HTTPS/SSL for data in transit, secure authentication
- **Data Size**: Optimize for typical user data (years of health records)

### LLM Constraints
- **Rate Limits**: Respect API rate limits (10 requests/minute default)
- **Token Limits**: Keep prompts concise, use caching when possible
- **Cost Control**: Implement usage limits and cost monitoring
- **Fallback**: Must have fallback behavior if LLM unavailable

## Artifact Output Specifications

### Code Artifacts
- **Location**: `lib/features/{feature_name}/`
- **Naming**: Follow project structure conventions (snake_case for files)
- **Format**: Dart files with proper imports and exports
- **Structure**: Follow Feature-First Clean Architecture pattern

### Documentation Artifacts
- **Location**: `docs/` or `artifacts/` depending on type
- **Format**: Markdown with proper headers and structure
- **Naming**: `{artifact-type}-{feature-name}.md` (e.g., `architecture-health-tracking.md`)
- **Structure**: Clear sections, code examples, diagrams (ASCII art)

### Test Artifacts
- **Location**: `test/` mirroring `lib/` structure
- **Naming**: `{file_name}_test.dart` for unit tests
- **Format**: Dart test files with proper grouping and descriptions
- **Coverage**: 80% minimum for business logic, 60% minimum for UI

### Design Artifacts
- **Location**: `docs/design/` or `artifacts/design/`
- **Format**: Markdown with ASCII art diagrams (not image files)
- **Naming**: `{screen-name}-mockup.md` or `{component-name}-spec.md`
- **Content**: ASCII mockups, component specifications, user flows

### Backend Artifacts (Slim Framework PHP/MySQL)
- **Location**: DreamHost server (or `backend/` in repo for version control)
- **Structure**: Slim Framework 4.x project structure
  - `public/index.php` - Entry point
  - `src/Controllers/` - API controllers
  - `src/Middleware/` - Authentication, CORS middleware
  - `src/Services/` - Business logic services
  - `config/` - Configuration files
- **Format**: PHP 8.1+ with Slim Framework, proper error handling and security
- **Database**: MySQL schema files as SQL scripts
- **Documentation**: API documentation in markdown format
- **Dependencies**: Managed via Composer (`composer.json`)

## Requirement Analysis & Clarifications Needed

To make this orchestration fully actionable, the following decisions should be made:

1. **MVP Scope**: Which modules are essential for initial release?
2. **Data Architecture**: Specific database schema and data modeling approach
3. **State Management**: Preferred Flutter state management solution
4. **Design System**: Color scheme, typography, component library preferences
5. **LLM API Selection**: DeepSeek recommended (default), or OpenAI, Anthropic, open-source alternatives like Ollama
6. **LLM Provider Architecture**: Design of abstraction layer to support multiple providers and easy switching
7. **LLM Integration Scope**: Which features should use LLM (weekly reviews, meal suggestions, exercise recommendations, etc.)
8. **LLM Cost Management**: Strategies for minimizing API costs (caching, prompt optimization, usage limits, provider comparison)
9. **LLM Configuration Management**: How to configure and switch between providers (app settings, config files, environment variables)
10. **Testing Requirements**: Unit test coverage goals, integration test scope, UI test priorities
11. **Deployment Strategy**: Google Play Store requirements, versioning strategy
12. **Content Strategy**: How recipes and exercises will be initially populated (curated list vs. user-generated)
13. **Multi-Device Sync Implementation**: Implementation timeline for optional cloud sync (see Multi-Device Sync Recommendations for architecture)
14. **Future Roadmap**: iOS support timeline, social features, etc.

## Decision Log

This section tracks key decisions made during development. Update as decisions are made.

| Date | Decision | Rationale | Made By |
|------|----------|-----------|---------|
| [Date] | Backend: DreamHost PHP/MySQL | Cost-effective ($0 additional), full control, privacy-first | User |
| [Date] | PHP Framework: Slim Framework 4.x | Lightweight, REST API focused, works great on shared hosting | Data Architect |
| [Date] | State Management: Riverpod (default) | Better type safety, testing, built-in DI | Flutter Architect |
| [Date] | Database: Hive (default) | Better Flutter integration, performance | Data Architect |
| [Date] | LLM Provider: DeepSeek (default) | Extremely cost-effective (10x cheaper), excellent quality, OpenAI-compatible API | Integration Specialist |
| [Date] | Architecture: Feature-First Clean Architecture | Better organization, testability, scalability | Flutter Architect |
| [Date] | Min Android SDK: 24 (Android 7.0) | Supports 95%+ devices, good compatibility | Platform Specialist |

### Pending Decisions
- [ ] Confirm Flutter version (default: 3.24.0 LTS)
- [ ] Design system colors (waiting for UI/UX Designer)
- [ ] Typography choices (waiting for UI/UX Designer)
- [ ] LLM prompt optimization strategy (waiting for Integration Specialist)

**Note**: Test coverage targets are confirmed as 80% minimum for business logic and 60% minimum for UI (see Code Quality section above).

## Next Steps

The orchestration should generate:
- Complete Flutter application architecture
- UI/UX designs and wireframes (ASCII art mockups in markdown format)
- Database schema and data models
- Feature specifications for each health management component
- Implementation guides for each module
- Testing strategies
- Documentation and deployment guides
- Sprint planning documents and product backlog structure
- Feature request and bug fix form templates
- Backlog management processes and status tracking systems
- Git workflow documentation (branching strategy, PR templates, code review checklists, merge procedures)
- Interactive LLM chat prompt for feature requests and bug fixes (standalone markdown file that can be given to LLM for interactive conversations)

---

## Proposed Persona List

Based on the Flutter health management app requirements, the following personas are proposed to accomplish this orchestration:

1. **Orchestrator** (Default - Coordination Focus)
   - Ensures all personas complete their work successfully
   - Tracks completion status and deadlines
   - Creates a short summary report compiling main information from each artifact generated
   - Generates a project status dashboard showing overall orchestration progress
   - Coordinates communication between personas
   - Generates all artifacts in the `orchestration-analysis-report/` folder

2. **Analyst** (Default - Analysis Focus)
   - Analyzes all artifacts and creates comprehensive reports identifying contradictions
   - Identifies trends and insights across all generated artifacts
   - Performs gap analysis to identify missing elements or unaddressed requirements
   - Creates quality metrics and completeness scoring for all artifacts
   - Generates risk assessment reports with mitigation strategies
   - Produces prioritized recommendations with implementation roadmaps
   - Generates all artifacts in the `orchestration-analysis-report/` folder

3. **Flutter Architect & Developer**
   - Designs the overall Flutter application architecture
   - Defines project structure, folder organization, and code organization patterns
   - Selects and configures state management solution (Riverpod - default)
   - Creates dependency injection setup
   - Defines architectural patterns (Clean Architecture, Feature-First, etc.)
   - Designs LLM API abstraction layer architecture for easy provider/model switching
   - Establishes coding standards and best practices
   - Defines git commit message standards using CRISPE Framework
   - Defines git workflow process (branching, PR, code review, merge) using CRISPE Framework

4. **UI/UX Designer**
   - Creates comprehensive design system (colors, typography, spacing, components)
   - Designs wireframes and user flows for all app screens
   - Creates UI mockups using ASCII art format (not image files or design tools)
   - Creates component specifications with ASCII representations
   - Defines accessibility requirements and guidelines
   - Designs data visualization components (charts, graphs, progress indicators) using ASCII art
   - Creates responsive design guidelines for different screen sizes
   - All mockups must be in markdown files with ASCII art diagrams

5. **Data Architect & Backend Specialist**
   - Designs database schema (Hive for local, MySQL for sync) for all health data
   - Creates data models and entity definitions
   - Designs data access layer (repositories, data sources)
   - Defines data migration strategies
   - Creates data validation and sanitization rules
   - Designs multi-device sync architecture using DreamHost PHP/MySQL backend with Slim Framework (see Multi-Device Sync Recommendations)
   - Implements Slim Framework 4.x REST API backend for sync service
   - Creates MySQL database schema for JSON data storage
   - Designs conflict resolution strategies (timestamp-based for MySQL)
   - Creates sync status tracking and error handling
   - Implements JWT authentication using Slim middleware
   - Creates Slim Framework routes and controllers for all sync operations
   - Sets up Slim Framework project structure and dependency injection

6. **Health Domain Expert**
   - Translates reference material into app feature specifications
   - Defines health metric tracking logic and calculations (7-day moving averages, plateau detection)
   - Creates clinical safety protocols and alert systems
   - Defines medication management workflows
   - Specifies behavioral support features and habit tracking logic
   - Ensures medical accuracy and safety in all health-related features

7. **Feature Module Developer (Health Tracking)**
   - Implements health tracking module (weight, measurements, sleep, energy)
   - Creates data visualization components for health trends
   - Implements KPI tracking and non-scale victories
   - Develops progress photo management
   - Creates analytics and trend analysis features

8. **Feature Module Developer (Nutrition & Exercise)**
   - Implements nutrition management module (macro tracking, food logging, meal planning)
   - Creates recipe database structure and management
   - Implements sale-based meal planning feature with grocery store API integration
   - Creates sale item data models and shopping list management
   - Implements LLM-powered meal plan generation that prioritizes sale items
   - Develops cost estimation and savings calculation for meal plans
   - Implements exercise and movement tracking module
   - Develops workout plan creation and management
   - Creates integration with Google Fit/Health Connect

9. **Integration & Platform Specialist**
   - Implements Google Fit and Health Connect integrations
   - Integrates grocery store APIs for sale data (Kroger API, Walmart API, Maxi/Loblaw for Quebec, or manual entry system)
   - Implements Maxi flyer web scraping solution for Quebec users (with legal compliance)
   - Implements sale data sync and caching for offline access
   - Handles bilingual support (French/English) for Quebec grocery stores
   - Designs and implements LLM API abstraction layer with provider pattern for easy model switching
   - Creates provider adapters for multiple LLM APIs (DeepSeek recommended, OpenAI, Anthropic, Ollama, etc.)
   - Implements configuration system for runtime LLM provider/model selection
   - Integrates cost-effective LLM API for weekly reviews and intelligent features
   - Creates LLM API client with cost optimization strategies (caching, prompt optimization, rate limiting)
   - Implements fallback mechanisms for LLM API failures
   - Implements notification system for reminders and alerts
   - Implements local storage and offline-first functionality
   - Handles Android platform-specific features and permissions
   - Creates data export/import functionality
   - Implements security measures (HTTPS/SSL, JWT authentication, password hashing)
   - Designs LLM API integration architecture with privacy, cost, and flexibility considerations

10. **QA & Testing Specialist**
    - Creates comprehensive testing strategy (unit, integration, widget, e2e tests)
    - Writes test specifications for all modules
    - Defines test data and mock objects
    - Creates testing automation frameworks
    - Defines performance testing requirements
    - Creates accessibility testing guidelines

11. **Scrum Master**
    - Creates sprint planning documents using CRISPE Framework for sprint planning
    - Breaks down user stories into actionable tasks with technical references
    - Estimates user stories and tasks using Fibonacci story points
    - Creates structured sprint markdown documentation
    - Tracks sprint progress and completion status
    - Manages product backlog with feature requests and bug fixes
    - Creates feature request and bug fix forms using CRISPE Framework
    - Updates backlog status as items progress (Not Started → In Progress → Completed)
    - Manages backlog refinement and prioritization
    - Generates sprint artifacts (sprint plans, retrospectives, velocity tracking)
    - Ensures tasks reference specific technical documents, classes, and methods
    - Maintains sprint documentation and backlog with proper markdown formatting
    - Tracks backlog status history and updates Product Backlog table

**Note**: You can add additional personas if the ones listed above do not fully address your needs. For example, you might want:
- A **Content Curator** persona to populate initial recipes and exercise library
- A **DevOps/CI-CD Specialist** for build and deployment automation
- A **Technical Writer** for comprehensive documentation

**Discovery Questions**: Would you like the personas to ask you 10 yes-or-no questions to help better understand the scope of your project? These questions would help clarify:
- MVP vs. full feature set priorities
- Design preferences
- Technical stack decisions
- Testing requirements
- Deployment preferences
- And other key decisions

---

## Step 1.2: Persona Proposal Confirmation

**Date**: [Date]

**User Confirmation**:
1. ✅ **Persona List Approved**: User confirmed satisfaction with the proposed 11-persona list (Orchestrator, Analyst, Flutter Architect, UI/UX Designer, Data Architect, Health Domain Expert, Feature Module Developers, Integration Specialist, QA Specialist, Scrum Master)
2. ✅ **Discovery Questions Requested**: User wants personas to ask 10 yes-or-no questions to better understand project scope

### Discovery Questions & Answers

**Date**: [Date]

1. **MVP Scope**: 
   - **Question**: Should the MVP include all 8 core modules or focus on a subset?
   - **Answer**: **Subset** - MVP will focus on a subset of core modules (not all 8 modules)
   - **Impact**: MVP will prioritize essential features; remaining modules will be added in post-MVP phases

2. **LLM Integration**:
   - **Question**: Should LLM features (weekly reviews, meal suggestions, workout adaptations) be included in MVP?
   - **Answer**: **No** - LLM features deferred to post-MVP
   - **Impact**: MVP will not include LLM-powered features; these will be added in future phases

3. **Multi-Device Sync**:
   - **Question**: Should optional cloud sync feature (DreamHost PHP/MySQL backend) be included in MVP?
   - **Answer**: **No** - Cloud sync only post-MVP
   - **Impact**: MVP will be local-only (Hive database); sync feature will be implemented in post-MVP Phase 1

4. **Grocery Store Integration**:
   - **Question**: Should sale-based meal planning with grocery store API integration be included in MVP?
   - **Answer**: **No** - Start with manual entry only
   - **Impact**: MVP meal planning will use manual sale item entry; API integration will be added post-MVP

5. **Design System**:
   - **Question**: Do you have specific brand colors/design preferences, or should UI/UX Designer create new design system?
   - **Answer**: **Suggestions requested** - User wants UI/UX Designer to suggest design system options
   - **Impact**: UI/UX Designer will propose multiple design system options for user approval

6. **Testing Priority**:
   - **Question**: Should MVP include comprehensive automated testing (80% minimum unit, 60% minimum widget coverage)?
   - **Answer**: **Yes** - Include comprehensive automated testing
   - **Impact**: MVP will include full test coverage requirements (80% minimum unit, 60% minimum widget tests)

7. **Content Population**:
   - **Question**: Should MVP include pre-populated recipe and exercise library?
   - **Answer**: **Yes** - Pre-populated library
   - **Impact**: MVP will include initial recipe and exercise database; Content Curator persona may be needed

8. **iOS Support**:
   - **Question**: Is iOS support planned for future phase, or Android-only?
   - **Answer**: **iOS in future phase** - Not in MVP, but planned for future
   - **Impact**: MVP is Android-only; iOS support will be added in a future phase

9. **User Authentication**:
   - **Question**: Should MVP include user accounts/authentication, or start with single-device, no-account approach?
   - **Answer**: **MVP single device, no account** - No authentication in MVP
   - **Impact**: MVP will be single-device, local-only with no user accounts or authentication

10. **Analytics & Insights**:
    - **Question**: Should advanced analytics (trend analysis, plateau detection, predictive analytics) be included in MVP?
    - **Answer**: **No** - Start with basic progress tracking
    - **Impact**: MVP will include basic progress tracking; advanced analytics will be added post-MVP

### MVP Scope Summary

Based on discovery questions, the MVP will include:
- ✅ **Subset of core modules** (to be defined in orchestration)
- ✅ **Comprehensive automated testing** (80% minimum unit, 60% minimum widget)
- ✅ **Pre-populated recipe and exercise library**
- ✅ **UI/UX Designer suggestions** for design system
- ❌ **No LLM features** (post-MVP)
- ❌ **No cloud sync** (post-MVP)
- ❌ **No grocery store API integration** (manual entry only in MVP)
- ❌ **No user authentication** (single-device, local-only)
- ❌ **No advanced analytics** (basic progress tracking only)
- ❌ **Android-only** (iOS in future phase)

**Next Step**: Proceed to Step 2 - Orchestration Definition Generation.

