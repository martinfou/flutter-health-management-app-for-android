# Health Tracking Module Specification

## Overview

The Health Tracking Module provides comprehensive health metric tracking including weight, body measurements, sleep quality, energy levels, and resting heart rate. The module includes data visualization, KPI tracking, progress photos, and basic progress tracking analytics for the MVP.

**Reference**: 
- Architecture: `artifacts/phase-1-foundations/architecture-documentation.md`
- Data Models: `artifacts/phase-1-foundations/data-models.md`
- Health Domain: `artifacts/phase-1-foundations/health-domain-specifications.md`
- Clinical Safety: `artifacts/phase-1-foundations/clinical-safety-protocols.md`

## Module Structure

### Feature Organization

```
lib/features/health_tracking/
├── data/
│   ├── models/
│   │   ├── health_metric_model.dart
│   │   ├── progress_photo_model.dart
│   │   └── non_scale_victory_model.dart
│   ├── repositories/
│   │   └── health_tracking_repository_impl.dart
│   └── datasources/
│       └── local/
│           └── health_tracking_local_datasource.dart
├── domain/
│   ├── entities/
│   │   ├── health_metric.dart
│   │   ├── progress_photo.dart
│   │   └── non_scale_victory.dart
│   ├── repositories/
│   │   └── health_tracking_repository.dart
│   └── usecases/
│       ├── calculate_moving_average.dart
│       ├── detect_plateau.dart
│       ├── get_weight_trend.dart
│       ├── save_health_metric.dart
│       └── calculate_baseline_heart_rate.dart
└── presentation/
    ├── pages/
    │   ├── health_tracking_page.dart
    │   ├── weight_entry_page.dart
    │   ├── measurements_page.dart
    │   ├── sleep_energy_page.dart
    │   └── progress_photos_page.dart
    ├── widgets/
    │   ├── weight_chart_widget.dart
    │   ├── metric_card_widget.dart
    │   ├── measurement_form_widget.dart
    │   └── progress_photo_grid_widget.dart
    └── providers/
        ├── health_metrics_provider.dart
        ├── weight_trend_provider.dart
        └── moving_average_provider.dart
```

## Weight Tracking

### Features

- Daily weight entry with date picker
- 7-day moving average calculation and display
- Weight trend visualization (line chart)
- Weight history view
- Validation: 20-500 kg range

### UI Components

**Weight Entry Screen**:
- Large numeric input field (24sp font, centered)
- Unit display (kg/lbs based on user preference)
- Date picker button (defaults to today, can select past dates)
- Information card showing:
  - 7-day moving average
  - Trend indicator (↑ increasing, ↓ decreasing, → stable)
  - Change from last week
- Recent weights list (last 5 entries)
- Primary action button: "Save Weight"

**Weight Display Card**:
- Current weight (large, bold)
- 7-day average (secondary text)
- Trend indicator with change amount
- Tap to navigate to weight entry screen

### Business Logic

**7-Day Moving Average Calculation**:
- Use `MovingAverageCalculator.calculate7DayAverage()` from health domain specs
- Display "Insufficient data" if less than 7 days of entries
- Update automatically when new weight entry is added
- Round to 1 decimal place

**Trend Calculation**:
- Compare current 7-day average to previous 7-day average
- Determine trend: increasing (> 0.1 kg), decreasing (< -0.1 kg), stable (within ±0.1 kg)
- Display trend indicator with change amount

**Validation**:
- Weight must be between 20-500 kg
- Date cannot be in future
- Show validation error messages inline

### Data Flow

```
User Input → Validation → Save to Repository → Update UI
                                    ↓
                            Calculate Moving Average
                                    ↓
                            Update Trend Display
                                    ↓
                            Check Safety Alerts
```

### Use Cases

**SaveWeightUseCase**:
```dart
class SaveWeightUseCase {
  final HealthTrackingRepository repository;
  
  Future<Either<Failure, HealthMetric>> call({
    required double weight,
    required DateTime date,
  }) async {
    // Validate weight
    if (weight < 20 || weight > 500) {
      return Left(ValidationFailure('Weight must be between 20 and 500 kg'));
    }
    
    // Create health metric
    final metric = HealthMetric(
      id: UUID().v4(),
      userId: currentUserId,
      date: date,
      weight: weight,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Save to repository
    return await repository.saveHealthMetric(metric);
  }
}
```

## Body Measurements Tracking

### Features

- Weekly body measurements entry
- Measurements: waist, hips, neck, chest, thigh
- Measurement history view
- Trend visualization
- Comparison to last measurement

### UI Components

**Measurements Entry Screen**:
- Date picker (defaults to today)
- Input fields for each measurement:
  - Waist (cm/inches)
  - Hips (cm/inches)
  - Neck (cm/inches)
  - Chest (cm/inches)
  - Thigh (cm/inches)
- Last measurements card showing:
  - Previous measurements
  - Change indicators (↑, ↓, →)
  - Change amounts
- Primary action button: "Save Measurements"

**Measurement Display**:
- Grid layout showing all measurements
- Current values with change from last measurement
- Trend indicators

### Business Logic

**Validation Rules**:
- Waist: 50-200 cm
- Hips: 60-250 cm
- Neck: 25-60 cm
- Chest: 70-200 cm
- Thigh: 30-100 cm
- All measurements must be positive numbers

**Change Calculation**:
- Compare current measurement to most recent previous measurement
- Calculate difference and percentage change
- Display with trend indicator

### Data Flow

```
User Input → Validation → Save to Repository → Update UI
                                    ↓
                            Calculate Changes
                                    ↓
                            Update Trend Display
```

## Sleep and Energy Tracking

### Features

- Daily sleep quality entry (1-10 scale)
- Daily energy level entry (1-10 scale)
- Combined entry screen
- Trend visualization
- Optional notes field

### UI Components

**Sleep & Energy Entry Screen**:
- Sleep Quality slider (1-10 scale)
  - Visual slider with labels
  - Selected value display
  - Interpretation text (Excellent 8-10, Good 6-7, Fair 4-5, Poor 1-3)
- Energy Level slider (1-10 scale)
  - Same format as sleep quality
- Notes field (optional, multiline text)
- Primary action button: "Save Entry"

**Sleep/Energy Display Cards**:
- Current value (large number)
- Trend indicator
- 7-day average
- Tap to navigate to entry screen

### Business Logic

**Validation**:
- Sleep quality: 1-10 (integer)
- Energy level: 1-10 (integer)
- Both optional (user can log one or both)

**Trend Analysis**:
- Calculate 7-day average for sleep and energy
- Display trend over time
- Show interpretation based on value ranges

## Resting Heart Rate Tracking

### Features

- Daily resting heart rate entry
- Baseline calculation (first 7 days average)
- Monthly baseline recalculation
- Integration with clinical safety alerts
- Trend visualization

### UI Components

**Heart Rate Entry Screen**:
- Numeric input field for BPM
- Date picker
- Baseline display card:
  - Current baseline value
  - Date baseline was calculated
  - Note about monthly recalculation
- Primary action button: "Save Heart Rate"

**Heart Rate Display**:
- Current value
- Baseline comparison
- Trend chart
- Alert indicator (if elevated)

### Business Logic

**Baseline Calculation**:
- Initial: Average of first 7 days of heart rate data
- Monthly: Recalculate using previous month's data
- Store baseline in user preferences or separate table
- Use most recent baseline for alert calculations

**Alert Integration**:
- Check elevated heart rate alert (> 20 BPM from baseline for 3 days)
- Check resting heart rate alert (> 100 BPM for 3 days)
- Display alerts prominently on heart rate screen

**Validation**:
- Heart rate: 40-200 BPM (reasonable human range)

## Data Visualization Components

### Weight Trend Chart

**Specifications**:
- Type: Line chart
- X-axis: Date (last 30 days default, user can select range)
- Y-axis: Weight (kg/lbs)
- Data points: Daily weight entries
- Overlay: 7-day moving average line (different color)
- Interaction: Tap point to see exact value and date
- Zoom: Pinch to zoom, drag to pan

**Implementation**:
- Use `fl_chart` package for Flutter
- Display both raw data points and moving average
- Show trend line (linear regression optional, post-MVP)

### Measurement Trend Chart

**Specifications**:
- Type: Multi-line chart
- X-axis: Date (weekly intervals)
- Y-axis: Measurement value (cm/inches)
- Lines: One line per measurement type (waist, hips, etc.)
- Colors: Different color for each measurement
- Legend: Show measurement types with colors

### Sleep/Energy Trend Chart

**Specifications**:
- Type: Dual-axis line chart
- X-axis: Date (daily)
- Y-axis: Sleep quality (1-10, left) and Energy level (1-10, right)
- Lines: Two lines, one for sleep, one for energy
- Colors: Different colors for sleep vs energy
- Interpretation zones: Color-coded zones (Excellent, Good, Fair, Poor)

## KPI Tracking

### Non-Scale Victories (NSVs)

**Features**:
- Track NSVs by category
- Add custom NSV entries
- View NSV history
- Celebrate NSV achievements

**Categories**:
- Clothing Fit
- Energy Levels
- Sleep Quality
- Strength/Stamina
- Appetite Suppression
- Mood
- Joint Health
- Blood Pressure
- Other (custom)

**UI Components**:
- NSV entry form:
  - Category dropdown
  - Description text field
  - Date picker
  - Save button
- NSV list view:
  - Grouped by category
  - Sorted by date (newest first)
  - Display description and date

### Clothing Fit Tracking

**Features**:
- Track when clothes fit better
- Categorize by clothing type (pants, shirts, etc.)
- Notes field for details

### Strength/Stamina Metrics

**Features**:
- Track exercise performance improvements
- Link to exercise module
- Track: weight lifted, reps, duration, distance

### Appetite Suppression Levels

**Features**:
- Track appetite suppression (1-10 scale)
- Link to medication tracking
- Track correlation with medication timing

## Progress Photo Management

### Features

- Monthly progress photos (front, side, back)
- Photo capture interface
- Photo storage and organization
- Photo viewing interface
- Photo comparison view

### UI Components

**Photo Capture Screen**:
- Instructions: "Take photos in consistent lighting and clothing"
- Photo type selector: Front, Side, Back
- Camera preview
- Capture button
- Retake button
- Save button

**Photo Grid View**:
- Grid layout (3 columns: Front, Side, Back)
- Monthly grouping
- Thumbnail images
- Tap to view full screen

**Photo View Screen**:
- Full-screen image
- Date display
- Photo type indicator
- Navigation: Swipe to next/previous photo
- Comparison mode: Side-by-side view of different months

### Business Logic

**Storage**:
- Store photos in app's file system (not in Hive)
- Store photo metadata in Hive (path, date, type)
- Organize by month/year folders
- Compress images for storage efficiency

**Monthly Schedule**:
- Remind user to take photos monthly
- Allow taking photos at any time (not restricted to monthly)
- Group photos by month for display

## Basic Progress Tracking Analytics

### Trend Analysis

**7-Day Moving Averages**:
- Weight: 7-day moving average
- Sleep: 7-day moving average
- Energy: 7-day moving average
- Heart Rate: 7-day moving average (optional)

**Display**:
- Show moving averages on main tracking screen
- Display trend indicators (↑, ↓, →)
- Show change amounts

### Plateau Detection (Basic)

**Features**:
- Detect weight plateaus (3 weeks unchanged)
- Display plateau alert
- Provide basic guidance

**Implementation**:
- Use `PlateauDetector` from health domain specs
- Check weekly (not real-time)
- Display alert when detected
- Note: Advanced plateau analysis deferred to post-MVP

### Progress Summary

**Features**:
- Weekly progress summary
- Monthly progress summary
- Key metrics display:
  - Total weight loss
  - Average weekly loss
  - Measurement changes
  - Days tracked

**UI Components**:
- Summary card on main screen
- Detailed summary screen
- Export summary (post-MVP)

## Integration Points

### Clinical Safety Alerts

- Integrate with clinical safety protocols
- Display alerts on relevant screens
- Link to safety protocol details

### Medication Module

- Link heart rate tracking to medication side effects
- Track medication impact on sleep and energy
- Display medication context in health metrics

### Nutrition Module

- Link weight trends to nutrition data
- Display correlation between macros and weight
- Show nutrition impact on energy levels

### Exercise Module

- Link exercise to energy levels
- Track exercise impact on sleep quality
- Display exercise correlation with weight trends

## User Flows

### Weight Entry Flow

```
Home Screen → Health Tracking → Weight Entry
    ↓
Enter Weight → Select Date → Save
    ↓
Calculate Moving Average → Update Trend → Check Alerts
    ↓
Return to Health Tracking Screen
```

### Measurements Entry Flow

```
Health Tracking → Measurements → Entry Screen
    ↓
Select Date → Enter Measurements → Save
    ↓
Calculate Changes → Update Display
    ↓
Return to Measurements View
```

### Progress Photo Flow

```
Health Tracking → Progress Photos → Capture Screen
    ↓
Select Photo Type → Take Photo → Review
    ↓
Save Photo → Store Metadata → Update Grid
    ↓
Return to Photo Grid
```

## Testing Requirements

### Unit Tests

- Moving average calculation
- Plateau detection algorithm
- Baseline calculation
- Trend calculation
- Validation logic

### Widget Tests

- Weight entry form
- Measurement entry form
- Chart widgets
- Metric cards

### Integration Tests

- Complete weight entry flow
- Complete measurement entry flow
- Photo capture and storage
- Alert triggering

## Performance Considerations

- Efficient date range queries
- Lazy loading for chart data
- Image compression for photos
- Cached calculations (moving averages, trends)

## Accessibility

- Screen reader labels for all inputs
- Keyboard navigation support
- High contrast mode support
- Text scaling support (up to 200%)

## References

- **Architecture**: `artifacts/phase-1-foundations/architecture-documentation.md`
- **Data Models**: `artifacts/phase-1-foundations/data-models.md`
- **Health Domain**: `artifacts/phase-1-foundations/health-domain-specifications.md`
- **Clinical Safety**: `artifacts/phase-1-foundations/clinical-safety-protocols.md`
- **Design System**: `artifacts/phase-1-foundations/design-system-options.md`
- **Wireframes**: `artifacts/phase-1-foundations/wireframes.md`

---

**Last Updated**: [Date]  
**Version**: 1.0  
**Status**: Health Tracking Module Specification Complete

