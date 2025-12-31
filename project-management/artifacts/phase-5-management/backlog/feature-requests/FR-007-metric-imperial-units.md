# Feature Request: FR-007 - Metric/Imperial Units Support

**Status**: ⭕ Not Started  
**Priority**: 🟠 High  
**Story Points**: 13  
**Created**: 2025-01-02  
**Updated**: 2025-01-03  
**Assigned Sprint**: [Sprint 12](../sprints/sprint-12-metric-imperial-units.md)

## Description

Enable users to choose between metric and imperial units for all measurements throughout the app. Currently, the app stores unit preferences in `UserPreferences`, but there is no UI to change the preference, and the app does not convert or display values according to the user's unit preference. Users should be able to switch between metric (kg, cm, °C) and imperial (lb, ft/in, °F) units, with all displayed values automatically converted and formatted according to their preference.

## User Story

As a user, I want to choose my preferred unit system (metric or imperial) and have all measurements displayed in my preferred units, so that I can use the app comfortably with the units I'm familiar with.

## Acceptance Criteria

### Core Requirements
- [ ] Users can select metric or imperial units in settings
- [ ] Unit preference is saved and persists across app restarts
- [ ] All weight values are displayed in the selected units (kg for metric, lb for imperial)
- [ ] All height/body measurement values are displayed in the selected units (cm for metric, ft/in for imperial)
- [ ] Unit preference applies consistently across all screens (entry, history, charts, home screen)
- [ ] When users change unit preference, all displayed values update immediately
- [ ] Data is stored internally in metric units for consistency (conversion happens at display time)

### Settings UI
- [ ] Settings page has a "Units" section with metric/imperial toggle or dropdown
- [ ] Current unit preference is clearly indicated in settings
- [ ] Changing units preference saves immediately
- [ ] Visual indicator (e.g., "kg" vs "lb") shows which system is selected

### Weight Display
- [ ] Weight entry fields accept input in selected units (kg or lb)
- [ ] Weight values in history display in selected units
- [ ] Weight charts show values in selected units with appropriate labels
- [ ] Weight moving averages display in selected units
- [ ] Weight trends and statistics display in selected units
- [ ] Weight input validation uses appropriate ranges for selected units

### Body Measurements Display
- [ ] Height measurements display in selected units:
  - Metric: cm (e.g., "175 cm")
  - Imperial: ft/in (e.g., "5'9\"")
- [ ] Other body measurements (waist, chest, etc.) display in selected units:
  - Metric: cm
  - Imperial: in
- [ ] Entry forms accept input in selected units
- [ ] History pages show measurements in selected units

### Data Conversion
- [ ] Conversion utilities convert metric to imperial accurately
- [ ] Conversion utilities convert imperial to metric accurately
- [ ] All conversions use appropriate precision (e.g., weight rounded to 1 decimal place)
- [ ] Height conversions handle ft/in format correctly (e.g., 5'9" = 5 feet 9 inches)
- [ ] Stored data remains in metric units internally (only display is converted)

### Testing
- [ ] Unit tests for conversion utilities (metric ↔ imperial)
- [ ] Widget tests for settings UI (unit selection)
- [ ] Widget tests for weight/measurement display in both unit systems
- [ ] Manual testing: Switch units and verify all screens update correctly

## Business Value

This feature significantly improves user experience and app accessibility by:
- Allowing users to use the units they're most familiar with
- Expanding app appeal to users in different regions (metric vs imperial countries)
- Reducing user errors from unit confusion
- Improving user satisfaction and retention
- Making the app more professional and polished

## Technical Requirements

### Domain Layer

#### Unit Conversion Utilities
- Create `UnitConverter` utility class in `lib/core/utils/unit_converter.dart`:
  - `double convertWeightMetricToImperial(double kg) -> double` (kg to lb)
  - `double convertWeightImperialToMetric(double lb) -> double` (lb to kg)
  - `String formatWeight(double valueInMetric, bool useImperial) -> String`
  - `double convertHeightMetricToImperial(double cm) -> Map<String, int>` (cm to ft/in)
  - `double convertHeightImperialToMetric(int feet, int inches) -> double` (ft/in to cm)
  - `String formatHeight(double valueInMetric, bool useImperial) -> String`
  - `double convertLengthMetricToImperial(double cm) -> double` (cm to in)
  - `double convertLengthImperialToMetric(double inches) -> double` (in to cm)
  - `String formatLength(double valueInMetric, bool useImperial) -> String`
  - Conversion constants:
    - 1 kg = 2.20462 lb
    - 1 cm = 0.393701 in
    - 1 ft = 12 in

#### User Preferences Repository
- Verify `UserPreferencesRepository` supports updating unit preference
- If not, add `Future<Result<void>> updateUnits(String units)` method

### Data Layer
- `UserPreferences` entity already has `units` field ('metric' or 'imperial')
- `UserPreferencesModel` already supports `units` field
- No database schema changes needed (already implemented)

### Presentation Layer

#### Settings Page
- Add "Units" section to settings page:
  - Radio buttons or dropdown: "Metric (kg, cm)" / "Imperial (lb, ft/in)"
  - Current selection highlighted
  - Save button or auto-save on selection change
- Load current unit preference from `UserPreferences`
- Update `UserPreferences` when user changes selection
- Show success message after saving

#### Weight Entry/Display Pages
- Update `WeightEntryPage`:
  - Input field label shows "Weight (kg)" or "Weight (lb)" based on preference
  - Convert user input from selected units to metric before saving
  - Display current weight in selected units if available
- Update weight history pages:
  - Display all weight values in selected units
  - Format with appropriate unit label (kg or lb)
- Update weight chart widgets:
  - Y-axis labels show appropriate units
  - Tooltip values show values in selected units
- Update weight statistics widgets:
  - All displayed values (average, trend, etc.) in selected units

#### Body Measurements Pages
- Update `MeasurementsPage`:
  - Height input: TextField with ft/in format for imperial, cm for metric
  - Other measurements: Label shows cm or in based on preference
  - Convert user input from selected units to metric before saving
- Update body measurements history:
  - Display all measurements in selected units
  - Format height as "5'9\"" for imperial or "175 cm" for metric
  - Format other measurements as "32 in" or "81 cm"

#### Format Utilities
- Update or create `format_utils.dart`:
  - `String formatWeightValue(double metricValue, bool useImperial)`
  - `String formatHeightValue(double metricValue, bool useImperial)`
  - `String formatLengthValue(double metricValue, bool useImperial)`
  - `String getWeightUnitLabel(bool useImperial) -> "kg" or "lb"`
  - `String getHeightUnitLabel(bool useImperial) -> "cm" or "ft/in"`
  - `String getLengthUnitLabel(bool useImperial) -> "cm" or "in"`

#### Providers
- Update providers that display weight/measurements:
  - Watch `UserPreferencesProvider` to get current unit preference
  - Convert values before returning/displaying
- Create `UnitPreferenceProvider`:
  - `final unitPreferenceProvider = Provider<bool>((ref) { ... })`
  - Returns `true` if imperial, `false` if metric
  - Watches `UserPreferencesProvider` and extracts units field

#### Home Screen Widgets
- Update weight display cards/widgets:
  - Display current weight in selected units
  - Display weight trend in selected units
- Update any measurement summaries:
  - Display in selected units

### Data Storage Strategy

**Important**: Store all data internally in metric units for consistency:
- User enters weight in their preferred units → Convert to kg → Store in database
- Display weight from database → Read kg → Convert to user's preferred units → Display
- This ensures:
  - Data consistency (all stored values in same units)
  - Easy calculations (no mixed units)
  - Easy unit switching (just change display conversion)
  - No data migration needed when switching units

### Validation Updates

- Update weight input validation:
  - Metric: Reasonable range (e.g., 30-300 kg)
  - Imperial: Reasonable range (e.g., 66-660 lb)
- Update height input validation:
  - Metric: Reasonable range (e.g., 100-250 cm)
  - Imperial: Reasonable range (e.g., 3'3" to 8'2")
- Validation happens after conversion to metric (store always in metric)

### Testing Requirements

#### Unit Tests
- `UnitConverter` class tests:
  - Weight conversions (kg ↔ lb) with various values
  - Height conversions (cm ↔ ft/in) with various values
  - Length conversions (cm ↔ in) with various values
  - Edge cases (zero, very large values, precision)
  - Format functions return correct strings
- Validation tests with different units

#### Widget Tests
- Settings page unit selection:
  - Radio buttons/dropdown displays current preference
  - Changing selection updates preference
  - Preference persists after save
- Weight entry page:
  - Input field label shows correct unit
  - Values convert correctly on save
- Weight display widgets:
  - Values display in correct units
  - Unit labels show correctly
- Measurement pages:
  - Input fields show correct units
  - Values convert correctly

#### Integration Tests
- User flow: Change units in settings → Verify all screens update
- User flow: Enter weight in metric → Switch to imperial → Verify display
- User flow: Enter weight in imperial → Switch to metric → Verify display

## Reference Documents

- `artifacts/phase-1-foundations/data-models.md` - UserPreferences data model
- `artifacts/phase-2-features/health-tracking-module-specification.md` - Health tracking specifications
- `artifacts/phase-2-features/nutrition-management-module-specification.md` - Nutrition specifications (if relevant)

## Technical References

- Entity: `UserPreferences` entity with `units` field (`lib/core/entities/user_preferences.dart`)
- Model: `UserPreferencesModel` with `units` field (`lib/core/data/models/user_preferences_model.dart`)
- Settings Page: `lib/core/pages/settings_page.dart`
- Weight Entry: Weight entry pages in `lib/features/health_tracking/presentation/pages/`
- Format Utils: `lib/core/utils/format_utils.dart` (to be updated)
- New Utility: `lib/core/utils/unit_converter.dart` (to be created)

## Dependencies

- `UserPreferences` entity and model already support `units` field (no changes needed)
- Settings page must exist (already exists)
- All weight and measurement entry/display pages must exist (already exist)
- User preferences repository/provider must be implemented (already exists)

## Notes

- **Data Storage**: All data stored in metric units internally. Conversion happens at display time only. This simplifies calculations and ensures data consistency.
- **Conversion Precision**: 
  - Weight: Round to 1 decimal place (e.g., 75.5 kg = 166.4 lb)
  - Height: Round inches to nearest integer (e.g., 175 cm = 5'9")
  - Other measurements: Round to 1 decimal place (e.g., 81.3 cm = 32.0 in)
- **Height Format**: Imperial height should use ft'in" format (e.g., "5'9\"") for better readability
- **Default Units**: App currently defaults to metric. Consider detecting user's locale/system preference in the future (post-MVP enhancement)
- **Clinical Safety Alerts**: Ensure clinical safety alerts use appropriate thresholds for the selected unit system (or convert thresholds appropriately)
- **Charts**: Update chart libraries (fl_chart) axis labels to show correct units
- **Performance**: Conversion functions are lightweight and can be called frequently without performance concerns

## History

- 2025-01-02 - Created

