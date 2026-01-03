# Feature Request: FR-001 - Health Tracking UI Redesign (Card-Based Dashboard)

**Status**: ✅ Completed  
**Priority**: 🟠 High  
**Story Points**: 13  
**Created**: 2024-12-20  
**Updated**: 2024-12-20 (Final - All enhancements documented)  
**Assigned Sprint**: Current

## Description

Redesign the Health Tracking screen using a card-based dashboard approach to improve user experience. This redesign addresses user feedback about confusing UX by:
- Separating heart rate tracking from sleep/energy tracking with dedicated entry screens
- Adding blood pressure tracking capability
- Implementing a modern card-based dashboard layout with clear visual hierarchy
- Providing both quick overview and dedicated entry screens for each metric type

## User Story

As a user, I want a clearer, more organized health tracking interface with dedicated screens for each metric type, so that I can easily track and manage all my health data without confusion.

## Acceptance Criteria

### Core Requirements
- [x] Health Tracking main screen redesigned with card-based dashboard layout
- [x] "Today's Overview" summary card displays all current metrics at a glance
- [x] Large metric cards for each metric type (Weight, Heart Rate, Blood Pressure, Sleep & Energy, Body Measurements)
- [x] Each metric card shows current value, trend indicator, and quick action buttons
- [x] Dedicated `HeartRateEntryPage` created (separate from sleep/energy)
- [x] New `BloodPressureEntryPage` created for blood pressure tracking
- [x] `SleepEnergyPage` updated to only handle sleep quality and energy level (no heart rate)
- [x] Blood pressure data model added to HealthMetric entity (systolicBP, diastolicBP)
- [x] Blood pressure validation implemented (systolic: 70-250 mmHg, diastolic: 40-150 mmHg)
- [x] Blood pressure interpretation categories displayed (Normal, Elevated, High Stage 1, High Stage 2)
- [x] Navigation updated to route to correct entry page from each metric card
- [x] All metric cards have "Quick Log" and "View Details" actions
- [x] Visual hierarchy clearly distinguishes different metric types
- [x] All existing functionality preserved

### Enhanced Features (Beyond Original Scope)
- [x] History pages created for all metric types:
  - `HeartRateHistoryPage` - shows all heart rate entries
  - `BloodPressureHistoryPage` - shows all blood pressure entries with interpretation
  - `SleepEnergyHistoryPage` - shows all sleep and energy entries
  - `BodyMeasurementsHistoryPage` - shows all body measurement entries
- [x] Multiple entries per day support - users can log multiple entries for the same day
- [x] Latest entry display - Today's Overview shows the most recent entry for each metric type
- [x] Clickable overview items - all metrics in Today's Overview are tappable and navigate to entry pages
- [x] Sleep hours tracking added - slider with 30-minute increments (1-12 hours)
- [x] Weight chart positioning - moved to top after Today's Overview for better visibility
- [x] Empty state handling - overview items show "--" when empty and are visually dimmed to prompt entry

### Quality & Polish
- [x] All entry pages create new metrics (allow multiple entries per day)
- [x] Forms clear after successful save for quick consecutive entries
- [x] Proper data preservation when updating existing metrics
- [x] Consistent UI patterns across all entry and history pages

## Business Value

This redesign significantly improves user experience by:
- Reducing confusion from mixing unrelated metrics (heart rate with sleep/energy)
- Making the interface more intuitive and easier to navigate
- Adding blood pressure tracking (important cardiovascular health metric)
- Providing a scalable design that can easily accommodate future metrics
- Improving user satisfaction and reducing support requests about confusing UI
- Following modern mobile app design patterns for better usability

## Technical Requirements

### Data Model Changes
- Add `systolicBP` (nullable int) to HealthMetric entity
- Add `diastolicBP` (nullable int) to HealthMetric entity
- Add `sleepHours` (nullable double) to HealthMetric entity (1-12 hours in 0.5 increments)
- Update HealthMetricModel Hive adapter (add new HiveField entries: 11, 12, 13)
- Update validation in SaveHealthMetricUseCase
- Update entity `copyWith`, `hasData`, equality, and hashCode methods

### New Pages
- Create `lib/features/health_tracking/presentation/pages/heart_rate_entry_page.dart`
- Create `lib/features/health_tracking/presentation/pages/blood_pressure_entry_page.dart`
- Create `lib/features/health_tracking/presentation/pages/heart_rate_history_page.dart`
- Create `lib/features/health_tracking/presentation/pages/blood_pressure_history_page.dart`
- Create `lib/features/health_tracking/presentation/pages/sleep_energy_history_page.dart`
- Create `lib/features/health_tracking/presentation/pages/body_measurements_history_page.dart`

### Updated Pages
- Redesign `lib/features/health_tracking/presentation/pages/health_tracking_page.dart` with card-based layout
  - Added "Today's Overview" card with all metrics displayed
  - Implemented DashboardMetricCardWidget for each metric type
  - Weight chart positioned after Today's Overview
  - All overview items are clickable
  - Support for multiple entries per day (shows latest entry)
- Update `lib/features/health_tracking/presentation/pages/sleep_energy_page.dart`
  - Removed heart rate functionality
  - Added sleep hours slider (1-12 hours, 30-minute increments)
  - Always creates new entries (allows multiple entries per day)
  - Form clears after successful save

### New/Updated Widgets
- Create `DashboardMetricCardWidget` - reusable widget for metric cards with title, value, icon, subtitle, additional info, and action buttons
- Update navigation routing for new entry pages and history pages
- Add `_buildOverviewItem` helper method for Today's Overview items with clickable InkWell wrapper

### Validation & Business Logic
- Blood pressure validation: systolic 70-250 mmHg, diastolic 40-150 mmHg, systolic > diastolic
- Blood pressure interpretation logic (Normal, Elevated, High Stage 1, High Stage 2)
- Sleep hours validation: 1.0 to 12.0 hours (in 0.5 hour increments)
- Multiple entries per day: Entry pages always create new metrics (no merging/updating)
- Latest entry selection: Today's Overview shows most recent entry for each metric type (sorted by createdAt)
- Update clinical safety alerts to include blood pressure checks (if applicable)

### Data Visualization
- Blood pressure trend chart (dual-line chart)
- Mini trend lines on metric cards

## Reference Documents

- `artifacts/phase-1-foundations/health-tracking-ui-design-options.md` - Design Option 3 (Card-Based Dashboard)
- `artifacts/phase-2-features/health-tracking-module-specification.md` - Health Tracking Module Specification
- `artifacts/phase-1-foundations/wireframes.md` - Original Health Tracking Wireframes
- `artifacts/phase-1-foundations/data-models.md` - HealthMetric Data Model
- `artifacts/phase-1-foundations/design-system-options.md` - Design System Guidelines

## Technical References

- Entity: `lib/features/health_tracking/domain/entities/health_metric.dart`
- Model: `lib/features/health_tracking/data/models/health_metric_model.dart`
- Use Case: `lib/features/health_tracking/domain/usecases/save_health_metric.dart`
- Page: `lib/features/health_tracking/presentation/pages/health_tracking_page.dart`
- Page: `lib/features/health_tracking/presentation/pages/sleep_energy_page.dart`
- Repository: `lib/features/health_tracking/domain/repositories/health_tracking_repository.dart`
- Chart Library: `fl_chart` package (already in dependencies)

## Dependencies

- Existing HealthMetric entity and data layer
- Existing HealthTrackingRepository implementation
- fl_chart package (already installed)
- UI constants and design system components

## Notes

- This feature addresses direct user feedback about confusing UI
- Design Option 3 was selected from three design options provided by UX/UI Designer persona
- Blood pressure tracking is an important addition for cardiovascular health monitoring
- The card-based approach provides better scalability for future metric additions
- All existing functionality must be preserved during the redesign
- Consider migration path for existing data if data model changes require it

## Design Decisions

- **Selected Design**: Option 3 (Card-Based Dashboard) - provides best separation, scalability, and user experience
- **Heart Rate Separation**: Complete separation from sleep/energy tracking with dedicated entry screen
- **Blood Pressure Format**: Standard format "120/80 mmHg" with separate systolic and diastolic fields
- **Quick Overview**: Summary card at top shows all today's metrics for quick reference
- **Navigation Pattern**: Each card routes to dedicated entry screen for focused data entry
- **Multiple Entries**: All entry pages create new metrics (no merging) to support multiple logs per day
- **History Pages**: "View Details" buttons navigate to dedicated history pages showing all entries
- **Latest Entry Display**: Today's Overview shows the most recent entry for each metric type (sorted by createdAt)
- **Sleep Hours**: Added as slider with 30-minute increments (1-12 hours) for better sleep tracking
- **Layout Order**: Safety alerts → Today's Overview → Weight Chart → Metric Cards
- **Clickable Overview**: All overview items are interactive and navigate to respective entry pages

## History

- 2024-12-20 - Created based on user feedback and design option selection
- 2024-12-20 - Status changed to ⏳ In Progress
- 2024-12-20 - Data model, entry pages, validation, and navigation completed. Main page redesign pending.
- 2024-12-20 - Main page redesign completed with card-based dashboard layout. Core acceptance criteria met.
- 2024-12-20 - Enhanced with history pages for all metric types, multiple entries per day support, and sleep hours tracking
- 2024-12-20 - Additional UX improvements: clickable overview items, weight chart repositioning, empty state handling
- 2024-12-20 - Status changed to ✅ Completed - All features implemented and tested

