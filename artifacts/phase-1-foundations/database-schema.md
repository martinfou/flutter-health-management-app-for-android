# Database Schema

## Overview

This document defines the Hive database schema for local storage in the Flutter Health Management App for Android. Hive is a lightweight, fast NoSQL database that provides excellent performance for Flutter applications and supports offline-first architecture.

**Reference**: Based on requirements in `artifacts/requirements.md` and architecture in `artifacts/phase-1-foundations/architecture-documentation.md`.

## Hive Overview

Hive is a NoSQL key-value database written in Dart. It stores data in "boxes" (similar to tables in SQL databases) and provides:
- Fast read/write performance
- Type-safe data access
- Offline-first support
- Simple API
- Code generation for type adapters

## Database Structure

### Box Organization

Each entity type has its own Hive box for efficient querying and organization:

```
Hive Boxes:
├── userProfileBox          # Single user profile (1 record)
├── healthMetricsBox        # Health metrics (many records)
├── medicationsBox          # Medications (many records)
├── medicationLogsBox       # Medication logs (many records)
├── mealsBox                # Meals (many records)
├── exercisesBox            # Exercises (many records)
├── recipesBox              # Recipes (pre-populated library)
├── mealPlansBox            # Meal plans (many records)
├── shoppingListItemsBox    # Shopping list items (many records)
├── saleItemsBox            # Sale items (cached, many records)
├── progressPhotosBox       # Progress photos (many records)
├── sideEffectsBox          # Side effects (many records)
├── habitsBox               # Habits (many records)
├── goalsBox                # Goals (many records)
└── userPreferencesBox      # User preferences (1 record)
```

### Box Naming Convention

- Use camelCase: `userProfileBox`, `healthMetricsBox`
- Plural for collections: `healthMetricsBox`, `medicationsBox`
- Singular for single records: `userProfileBox`, `userPreferencesBox`

## Box Definitions

### 1. User Profile Box

**Box Name**: `userProfileBox`  
**Type**: `UserProfile`  
**Cardinality**: 1 record (single user)  
**Key**: `'user_profile'` (constant string key)

**Storage Strategy**:
- Single record stored with constant key
- No indexing needed (single record)
- Auto-initialize with default profile on first launch

**Data Structure**:
```dart
@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  String id; // UUID
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String email;
  
  @HiveField(3)
  DateTime dateOfBirth;
  
  @HiveField(4)
  String gender; // 'male', 'female', 'other'
  
  @HiveField(5)
  double height; // cm
  
  @HiveField(6)
  double targetWeight; // kg
  
  @HiveField(7)
  bool syncEnabled; // false for MVP
  
  @HiveField(8)
  DateTime createdAt;
  
  @HiveField(9)
  DateTime updatedAt;
}
```

### 2. Health Metrics Box

**Box Name**: `healthMetricsBox`  
**Type**: `HealthMetric`  
**Cardinality**: Many records (one per day, multiple entries possible)  
**Key**: `id` (UUID string)

**Indexes**:
- Primary: `id` (unique)
- Secondary: `userId` (for filtering)
- Secondary: `date` (for date range queries)
- Composite: `userId_date` (for user-specific date queries)

**Storage Strategy**:
- Store all health metrics in single box
- Index by userId and date for efficient queries
- Support multiple entries per day (user can log multiple times)

**Data Structure**:
```dart
@HiveType(typeId: 1)
class HealthMetric extends HiveObject {
  @HiveField(0)
  String id; // UUID, primary key
  
  @HiveField(1)
  String userId; // FK to UserProfile
  
  @HiveField(2)
  DateTime date;
  
  @HiveField(3)
  double? weight; // kg, nullable
  
  @HiveField(4)
  int? sleepQuality; // 1-10, nullable
  
  @HiveField(5)
  int? energyLevel; // 1-10, nullable
  
  @HiveField(6)
  int? restingHeartRate; // bpm, nullable
  
  @HiveField(7)
  Map<String, double>? bodyMeasurements; // waist, hips, neck, chest, thigh
  
  @HiveField(8)
  String? notes;
  
  @HiveField(9)
  DateTime createdAt;
  
  @HiveField(10)
  DateTime updatedAt;
}
```

**Query Patterns**:
- Get all metrics for user: Filter by `userId`
- Get metrics for date range: Filter by `userId` and `date` range
- Get latest weight: Filter by `userId`, sort by `date` desc, get first with `weight != null`

### 3. Medications Box

**Box Name**: `medicationsBox`  
**Type**: `Medication`  
**Cardinality**: Many records (multiple medications per user)  
**Key**: `id` (UUID string)

**Indexes**:
- Primary: `id` (unique)
- Secondary: `userId` (for filtering)
- Secondary: `isActive` (for active medications query)

**Storage Strategy**:
- Store all medications in single box
- Index by userId for efficient filtering
- Support soft delete (endDate field) rather than hard delete

**Data Structure**:
```dart
@HiveType(typeId: 2)
class Medication extends HiveObject {
  @HiveField(0)
  String id; // UUID, primary key
  
  @HiveField(1)
  String userId; // FK to UserProfile
  
  @HiveField(2)
  String name;
  
  @HiveField(3)
  String dosage;
  
  @HiveField(4)
  String frequency; // 'daily', 'twiceDaily', etc.
  
  @HiveField(5)
  List<String> times; // List of time strings (e.g., ['08:00', '20:00'])
  
  @HiveField(6)
  DateTime startDate;
  
  @HiveField(7)
  DateTime? endDate; // null if active
  
  @HiveField(8)
  bool reminderEnabled;
  
  @HiveField(9)
  DateTime createdAt;
  
  @HiveField(10)
  DateTime updatedAt;
}
```

### 4. Medication Logs Box

**Box Name**: `medicationLogsBox`  
**Type**: `MedicationLog`  
**Cardinality**: Many records (one per medication dose taken)  
**Key**: `id` (UUID string)

**Indexes**:
- Primary: `id` (unique)
- Secondary: `medicationId` (for filtering by medication)
- Secondary: `takenAt` (for date range queries)
- Composite: `medicationId_takenAt` (for medication-specific date queries)

**Storage Strategy**:
- Store all medication logs in single box
- Index by medicationId and takenAt for efficient queries
- Support querying logs for specific medication and date range

**Data Structure**:
```dart
@HiveType(typeId: 3)
class MedicationLog extends HiveObject {
  @HiveField(0)
  String id; // UUID, primary key
  
  @HiveField(1)
  String medicationId; // FK to Medication
  
  @HiveField(2)
  DateTime takenAt;
  
  @HiveField(3)
  String dosage;
  
  @HiveField(4)
  String? notes;
  
  @HiveField(5)
  DateTime createdAt;
}
```

### 5. Meals Box

**Box Name**: `mealsBox`  
**Type**: `Meal`  
**Cardinality**: Many records (multiple meals per day)  
**Key**: `id` (UUID string)

**Indexes**:
- Primary: `id` (unique)
- Secondary: `userId` (for filtering)
- Secondary: `date` (for date range queries)
- Secondary: `mealType` (for filtering by meal type)
- Composite: `userId_date` (for user-specific date queries)

**Storage Strategy**:
- Store all meals in single box
- Index by userId, date, and mealType for efficient queries
- Support querying meals for specific date and meal type

**Data Structure**:
```dart
@HiveType(typeId: 4)
class Meal extends HiveObject {
  @HiveField(0)
  String id; // UUID, primary key
  
  @HiveField(1)
  String userId; // FK to UserProfile
  
  @HiveField(2)
  DateTime date;
  
  @HiveField(3)
  String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  
  @HiveField(4)
  String name;
  
  @HiveField(5)
  double protein; // grams
  
  @HiveField(6)
  double fats; // grams
  
  @HiveField(7)
  double netCarbs; // grams
  
  @HiveField(8)
  double calories;
  
  @HiveField(9)
  List<String> ingredients;
  
  @HiveField(10)
  String? recipeId; // FK to Recipe, nullable
  
  @HiveField(11)
  DateTime createdAt;
}
```

### 6. Exercises Box

**Box Name**: `exercisesBox`  
**Type**: `Exercise`  
**Cardinality**: Many records (multiple exercises per day)  
**Key**: `id` (UUID string)

**Indexes**:
- Primary: `id` (unique)
- Secondary: `userId` (for filtering)
- Secondary: `date` (for date range queries)
- Secondary: `type` (for filtering by exercise type)

**Storage Strategy**:
- Store all exercises in single box
- Index by userId, date, and type for efficient queries
- Support querying exercises for specific date and type

**Data Structure**:
```dart
@HiveType(typeId: 5)
class Exercise extends HiveObject {
  @HiveField(0)
  String id; // UUID, primary key
  
  @HiveField(1)
  String userId; // FK to UserProfile
  
  @HiveField(2)
  String name;
  
  @HiveField(3)
  String type; // 'strength', 'cardio', 'flexibility', 'other'
  
  @HiveField(4)
  List<String> muscleGroups;
  
  @HiveField(5)
  List<String> equipment;
  
  @HiveField(6)
  int? duration; // minutes, nullable
  
  @HiveField(7)
  int? sets; // nullable
  
  @HiveField(8)
  int? reps; // nullable
  
  @HiveField(9)
  double? weight; // kg, nullable
  
  @HiveField(10)
  double? distance; // km, nullable
  
  @HiveField(11)
  DateTime date;
  
  @HiveField(12)
  String? notes;
  
  @HiveField(13)
  DateTime createdAt;
  
  @HiveField(14)
  DateTime updatedAt;
}
```

### 7. Recipes Box

**Box Name**: `recipesBox`  
**Type**: `Recipe`  
**Cardinality**: Many records (pre-populated library)  
**Key**: `id` (UUID string)

**Indexes**:
- Primary: `id` (unique)
- Secondary: `tags` (for tag-based search)
- Full-text: `name` and `description` (for search)

**Storage Strategy**:
- Pre-populated library (read-only for MVP)
- Index by tags for filtering
- Support full-text search on name and description
- Recipes are shared (not user-specific)

**Data Structure**:
```dart
@HiveType(typeId: 6)
class Recipe extends HiveObject {
  @HiveField(0)
  String id; // UUID, primary key
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String? description;
  
  @HiveField(3)
  int servings;
  
  @HiveField(4)
  int prepTime; // minutes
  
  @HiveField(5)
  int cookTime; // minutes
  
  @HiveField(6)
  String difficulty; // 'easy', 'medium', 'hard'
  
  @HiveField(7)
  double protein; // grams per serving
  
  @HiveField(8)
  double fats; // grams per serving
  
  @HiveField(9)
  double netCarbs; // grams per serving
  
  @HiveField(10)
  double calories; // per serving
  
  @HiveField(11)
  List<String> ingredients;
  
  @HiveField(12)
  List<String> instructions;
  
  @HiveField(13)
  List<String> tags;
  
  @HiveField(14)
  String? imageUrl;
  
  @HiveField(15)
  DateTime createdAt;
  
  @HiveField(16)
  DateTime updatedAt;
}
```

### 8. Meal Plans Box

**Box Name**: `mealPlansBox`  
**Type**: `MealPlan`  
**Cardinality**: Many records (one per week)  
**Key**: `id` (UUID string)

**Indexes**:
- Primary: `id` (unique)
- Secondary: `userId` (for filtering)
- Secondary: `weekStartDate` (for date range queries)

**Storage Strategy**:
- Store meal plans with embedded daily meals structure
- Index by userId and weekStartDate for efficient queries
- Support querying meal plans for specific week

**Data Structure**:
```dart
@HiveType(typeId: 7)
class MealPlan extends HiveObject {
  @HiveField(0)
  String id; // UUID, primary key
  
  @HiveField(1)
  String userId; // FK to UserProfile
  
  @HiveField(2)
  DateTime weekStartDate;
  
  @HiveField(3)
  DateTime weekEndDate;
  
  @HiveField(4)
  Map<String, List<Map<String, dynamic>>> dailyMeals; // Date string -> List of meal maps
  
  @HiveField(5)
  List<String> shoppingListItemIds; // FK references to ShoppingListItem
  
  @HiveField(6)
  double estimatedWeeklyCost;
  
  @HiveField(7)
  double totalSavings;
  
  @HiveField(8)
  List<String> saleItemIds; // FK references to SaleItem
  
  @HiveField(9)
  List<String> mealPrepSuggestions;
  
  @HiveField(10)
  DateTime createdAt;
  
  @HiveField(11)
  DateTime updatedAt;
}
```

### 9. Shopping List Items Box

**Box Name**: `shoppingListItemsBox`  
**Type**: `ShoppingListItem`  
**Cardinality**: Many records (many items per meal plan)  
**Key**: `id` (UUID string)

**Indexes**:
- Primary: `id` (unique)
- Secondary: `mealPlanId` (for filtering by meal plan)
- Secondary: `purchased` (for filtering purchased/unpurchased items)

**Storage Strategy**:
- Store shopping list items separately from meal plans
- Index by mealPlanId for efficient queries
- Support querying items for specific meal plan

**Data Structure**:
```dart
@HiveType(typeId: 8)
class ShoppingListItem extends HiveObject {
  @HiveField(0)
  String id; // UUID, primary key
  
  @HiveField(1)
  String mealPlanId; // FK to MealPlan
  
  @HiveField(2)
  String name;
  
  @HiveField(3)
  String category;
  
  @HiveField(4)
  double quantity;
  
  @HiveField(5)
  String unit;
  
  @HiveField(6)
  double estimatedPrice;
  
  @HiveField(7)
  bool isOnSale;
  
  @HiveField(8)
  String? saleItemId; // FK to SaleItem, nullable
  
  @HiveField(9)
  String? store;
  
  @HiveField(10)
  String? notes;
  
  @HiveField(11)
  bool purchased;
  
  @HiveField(12)
  DateTime? purchasedAt;
}
```

### 10. Sale Items Box

**Box Name**: `saleItemsBox`  
**Type**: `SaleItem`  
**Cardinality**: Many records (cached sale items)  
**Key**: `id` (UUID string)

**Indexes**:
- Primary: `id` (unique)
- Secondary: `store` (for filtering by store)
- Secondary: `category` (for filtering by category)
- Secondary: `validTo` (for filtering active sales)

**Storage Strategy**:
- Cache sale items locally for offline access
- Index by store, category, and validTo for efficient queries
- Support querying active sale items by store and category
- Auto-expire items past validTo date

**Data Structure**:
```dart
@HiveType(typeId: 9)
class SaleItem extends HiveObject {
  @HiveField(0)
  String id; // UUID, primary key
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String category; // 'produce', 'meat', 'dairy', 'pantry'
  
  @HiveField(3)
  String store;
  
  @HiveField(4)
  double regularPrice;
  
  @HiveField(5)
  double salePrice;
  
  @HiveField(6)
  double discountPercent;
  
  @HiveField(7)
  String unit; // 'lb', 'oz', 'each'
  
  @HiveField(8)
  DateTime validFrom;
  
  @HiveField(9)
  DateTime validTo;
  
  @HiveField(10)
  String? description;
  
  @HiveField(11)
  String? imageUrl;
  
  @HiveField(12)
  String source; // 'api', 'manual', 'scraped'
  
  @HiveField(13)
  DateTime createdAt;
  
  @HiveField(14)
  DateTime updatedAt;
}
```

### 11. Progress Photos Box

**Box Name**: `progressPhotosBox`  
**Type**: `ProgressPhoto`  
**Cardinality**: Many records (multiple photos per metric)  
**Key**: `id` (UUID string)

**Indexes**:
- Primary: `id` (unique)
- Secondary: `healthMetricId` (for filtering by health metric)
- Secondary: `date` (for date range queries)
- Secondary: `photoType` (for filtering by photo type)

**Storage Strategy**:
- Store photo metadata in Hive
- Store actual image files in app's file system
- Index by healthMetricId, date, and photoType for efficient queries
- Support querying photos for specific metric and type

**Data Structure**:
```dart
@HiveType(typeId: 10)
class ProgressPhoto extends HiveObject {
  @HiveField(0)
  String id; // UUID, primary key
  
  @HiveField(1)
  String healthMetricId; // FK to HealthMetric
  
  @HiveField(2)
  String photoType; // 'front', 'side', 'back'
  
  @HiveField(3)
  String imagePath; // Path to image file in app storage
  
  @HiveField(4)
  DateTime date;
  
  @HiveField(5)
  DateTime createdAt;
}
```

### 12. Side Effects Box

**Box Name**: `sideEffectsBox`  
**Type**: `SideEffect`  
**Cardinality**: Many records (multiple side effects per medication)  
**Key**: `id` (UUID string)

**Indexes**:
- Primary: `id` (unique)
- Secondary: `medicationId` (for filtering by medication)
- Secondary: `startDate` (for date range queries)

**Storage Strategy**:
- Store all side effects in single box
- Index by medicationId and startDate for efficient queries
- Support querying side effects for specific medication and date range

**Data Structure**:
```dart
@HiveType(typeId: 11)
class SideEffect extends HiveObject {
  @HiveField(0)
  String id; // UUID, primary key
  
  @HiveField(1)
  String medicationId; // FK to Medication
  
  @HiveField(2)
  String name;
  
  @HiveField(3)
  String severity; // 'mild', 'moderate', 'severe'
  
  @HiveField(4)
  DateTime startDate;
  
  @HiveField(5)
  DateTime? endDate; // null if ongoing
  
  @HiveField(6)
  String? notes;
  
  @HiveField(7)
  DateTime createdAt;
}
```

### 13. Habits Box

**Box Name**: `habitsBox`  
**Type**: `Habit`  
**Cardinality**: Many records (multiple habits per user)  
**Key**: `id` (UUID string)

**Indexes**:
- Primary: `id` (unique)
- Secondary: `userId` (for filtering)
- Secondary: `category` (for filtering by category)
- Secondary: `startDate` (for date range queries)

**Storage Strategy**:
- Store all habits in single box
- Index by userId and category for efficient queries
- Support querying habits for specific user and category

**Data Structure**:
```dart
@HiveType(typeId: 13)
class Habit extends HiveObject {
  @HiveField(0)
  String id; // UUID, primary key
  
  @HiveField(1)
  String userId; // FK to UserProfile
  
  @HiveField(2)
  String name;
  
  @HiveField(3)
  String category; // 'nutrition', 'exercise', etc.
  
  @HiveField(4)
  String? description;
  
  @HiveField(5)
  List<DateTime> completedDates;
  
  @HiveField(6)
  int currentStreak;
  
  @HiveField(7)
  int longestStreak;
  
  @HiveField(8)
  DateTime startDate;
  
  @HiveField(9)
  DateTime createdAt;
  
  @HiveField(10)
  DateTime updatedAt;
}
```

### 14. Goals Box

**Box Name**: `goalsBox`  
**Type**: `Goal`  
**Cardinality**: Many records (multiple goals per user)  
**Key**: `id` (UUID string)

**Indexes**:
- Primary: `id` (unique)
- Secondary: `userId` (for filtering)
- Secondary: `type` (for filtering by goal type)
- Secondary: `status` (for filtering by status)
- Secondary: `deadline` (for deadline-based queries)

**Storage Strategy**:
- Store all goals in single box
- Index by userId, type, and status for efficient queries
- Support querying goals for specific user, type, and status

**Data Structure**:
```dart
@HiveType(typeId: 14)
class Goal extends HiveObject {
  @HiveField(0)
  String id; // UUID, primary key
  
  @HiveField(1)
  String userId; // FK to UserProfile
  
  @HiveField(2)
  String type; // 'identity', 'behavior', 'outcome'
  
  @HiveField(3)
  String description;
  
  @HiveField(4)
  String? target;
  
  @HiveField(5)
  double? targetValue;
  
  @HiveField(6)
  double currentValue;
  
  @HiveField(7)
  DateTime? deadline;
  
  @HiveField(8)
  String? linkedMetric;
  
  @HiveField(9)
  String status; // 'inProgress', 'completed', etc.
  
  @HiveField(10)
  DateTime? completedAt;
  
  @HiveField(11)
  DateTime createdAt;
  
  @HiveField(12)
  DateTime updatedAt;
}
```

### 15. User Preferences Box

**Box Name**: `userPreferencesBox`  
**Type**: `UserPreferences`  
**Cardinality**: 1 record (single preferences object)  
**Key**: `'user_preferences'` (constant string key)

**Storage Strategy**:
- Single record stored with constant key
- No indexing needed (single record)
- Auto-initialize with default preferences on first launch

**Data Structure**:
```dart
@HiveType(typeId: 12)
class UserPreferences extends HiveObject {
  @HiveField(0)
  String dietaryApproach; // 'low_carb', 'keto', 'balanced', etc.
  
  @HiveField(1)
  List<String> preferredMealTimes; // List of time strings
  
  @HiveField(2)
  List<String> allergies;
  
  @HiveField(3)
  List<String> dislikes;
  
  @HiveField(4)
  List<String> fitnessGoals;
  
  @HiveField(5)
  Map<String, bool> notificationPreferences;
  
  @HiveField(6)
  String units; // 'metric', 'imperial'
  
  @HiveField(7)
  String theme; // 'light', 'dark', 'system'
}
```

## Index Strategy

### Primary Indexes

All boxes use `id` (UUID string) as primary key for:
- Fast lookups by ID
- Unique constraint enforcement
- Efficient updates and deletes

### Secondary Indexes

Secondary indexes are created for common query patterns:

1. **User Filtering**: `userId` index on all user-specific boxes
   - HealthMetrics, Medications, Meals, Exercises, MealPlans

2. **Date Range Queries**: `date` index on time-series boxes
   - HealthMetrics, Meals, Exercises, MedicationLogs

3. **Type Filtering**: `type` or `mealType` index on categorized boxes
   - Meals (mealType), Exercises (type), ProgressPhotos (photoType)

4. **Status Filtering**: `purchased`, `isActive` indexes for status queries
   - ShoppingListItems (purchased), Medications (isActive via endDate)

5. **Composite Indexes**: Combined indexes for multi-field queries
   - `userId_date` for user-specific date range queries

## Data Migration Strategy

### Version Management

Hive supports box versioning for schema migrations:

```dart
// Initialize boxes with version
await Hive.openBox<UserProfile>('userProfileBox', version: 1);
```

### Migration Process

1. **Version Increment**: Increment version number when schema changes
2. **Migration Handler**: Implement migration logic in adapter
3. **Backward Compatibility**: Support reading old data format
4. **Data Transformation**: Transform old data to new format

### Example Migration

```dart
@HiveType(typeId: 0, adapterName: 'UserProfileAdapter')
class UserProfile extends HiveObject {
  // ... fields ...
}

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  int get typeId => 0;
  
  @override
  UserProfile read(BinaryReader reader) {
    final version = reader.readByte();
    // Handle different versions
    if (version == 0) {
      // Read old format
    } else if (version == 1) {
      // Read new format
    }
    // ... read fields ...
  }
  
  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer.writeByte(1); // Current version
    // ... write fields ...
  }
}
```

## Performance Considerations

### Box Size Limits

- **Small Boxes** (< 1000 records): No special optimization needed
- **Medium Boxes** (1000-10000 records): Use indexes for common queries
- **Large Boxes** (> 10000 records): Consider pagination, lazy loading

### Query Optimization

1. **Use Indexes**: Always use indexed fields for filtering
2. **Limit Results**: Use `.take()` or `.skip()` for pagination
3. **Lazy Loading**: Load data on-demand, not all at once
4. **Batch Operations**: Use batch writes for multiple updates

### Storage Optimization

1. **Nullable Fields**: Use nullable types to save space
2. **String Compression**: Consider compression for large text fields
3. **Image Storage**: Store images in file system, not in Hive
4. **Cleanup**: Periodically remove old/expired data

## Initialization

### Box Initialization Order

```dart
// 1. Initialize Hive
await Hive.initFlutter();

// 2. Register adapters
Hive.registerAdapter(UserProfileAdapter());
Hive.registerAdapter(HealthMetricAdapter());
// ... register all adapters ...

// 3. Open boxes
final userProfileBox = await Hive.openBox<UserProfile>('userProfileBox');
final healthMetricsBox = await Hive.openBox<HealthMetric>('healthMetricsBox');
// ... open all boxes ...

// 4. Initialize default data
if (userProfileBox.isEmpty) {
  await _initializeDefaultUserProfile();
}
if (userPreferencesBox.isEmpty) {
  await _initializeDefaultPreferences();
}
```

### Default Data

- **User Profile**: Create default profile on first launch
- **User Preferences**: Initialize with default preferences
- **Recipes**: Pre-populate with recipe library (if available)

## Backup and Restore

### Export Strategy

1. **Export All Boxes**: Serialize all boxes to JSON
2. **Compress**: Compress export file
3. **Store**: Save to user's device storage or cloud (post-MVP)

### Import Strategy

1. **Validate**: Validate import file format
2. **Backup Current**: Backup current data before import
3. **Clear Boxes**: Clear existing boxes
4. **Import Data**: Import data from file
5. **Verify**: Verify import success

## References

- **Requirements**: `artifacts/requirements.md` - Data model specifications
- **Architecture**: `artifacts/phase-1-foundations/architecture-documentation.md` - Data layer structure
- **Data Models**: `artifacts/phase-1-foundations/data-models.md` - Entity definitions
- **Hive Documentation**: https://docs.hivedb.dev/

---

**Last Updated**: [Date]  
**Version**: 1.0  
**Status**: Database Schema Complete

