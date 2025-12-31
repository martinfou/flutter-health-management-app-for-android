# Sprint 12: Metric/Imperial Units Support

**Sprint Goal**: Complete critical export/import bug fix and enable users to choose between metric and imperial units for all measurements throughout the app, with automatic conversion and consistent display across all screens.

**Duration**: [Start Date] - [End Date] (2 weeks)  
**Team Velocity**: Target 18 points  
**Sprint Planning Date**: [Date]  
**Sprint Review Date**: [Date]  
**Sprint Retrospective Date**: [Date]

## Related Feature Requests and Bug Fixes

This sprint implements the following items from the product backlog:

### Bug Fixes
- [BF-001: Export/Import Functionality Not Working Properly](../backlog/bug-fixes/BF-001-export-import-not-working.md) - 5 points

### Feature Requests
- [FR-007: Metric/Imperial Units Support](../backlog/feature-requests/FR-007-metric-imperial-units.md) - 13 points

**Total**: 18 points

## Sprint Overview

**Focus Areas**:
- Complete export/import bug fix (critical)
- Unit conversion utilities and formatting
- Settings UI for unit preference selection
- Weight and measurement display updates across all screens
- Data entry conversion (user input → metric storage)

**Key Deliverables**:
- Export/import functionality working correctly (bug fix)
- Unit conversion utility class (`UnitConverter`)
- Settings page unit selection UI
- Updated weight entry/display pages with unit conversion
- Updated body measurements pages with unit conversion
- Format utilities for consistent unit display
- Unit preference provider for state management

**Dependencies**:
- Sprint 11: Post-MVP Improvements must be complete
- Settings page must exist (already exists)
- Weight entry and measurement pages must exist (already exist)
- UserPreferences entity and model must support units field (already implemented)

**Risks & Blockers**:
- Need to update all weight/measurement display locations consistently
- Chart libraries (fl_chart) need axis label updates
- Clinical safety alerts may need threshold conversion
- Height input format (ft/in) requires special handling

**Documentation Workflow**:
- After completion of each task, the LLM must update this sprint document (`sprint-12-metric-imperial-units.md`) with task status updates
- Related documents referenced in tasks (e.g., FR-007) should also be updated to reflect implementation details, progress, and any deviations from the original specification
- Documentation updates should include:
  - Task status changes (⭕ Not Started → ⏳ In Progress → ✅ Complete)
  - Implementation notes or decisions made during development
  - Any technical changes or improvements discovered during implementation
  - Links to related code changes or new files created

## User Stories

### Story 12.1: Export/Import Functionality Fix - 5 Points

**User Story**: As a user, I want to successfully export and import my health data backup files from cloud storage services and local storage, so that I can backup and restore my data safely across devices and storage locations.

**Acceptance Criteria**:
- [ ] Export saves files to Downloads directory (with fallback to app's external storage)
- [ ] Import allows users to select files from:
  - Cloud storage services (Dropbox, Google Drive)
  - Downloads folder
  - Any accessible file location on the device
- [ ] File picker displays all exported JSON files and allows selection
- [ ] Files from cloud storage can be selected and imported successfully
- [ ] Import successfully reads and restores data from exported files
- [ ] Error messages are displayed when files cannot be accessed or imported
- [ ] User guidance is provided for file access issues
- [ ] Export/import flow works correctly with:
  - Files in Downloads directory
  - Files shared to Dropbox
  - Files shared to Google Drive
  - Files accessed via file manager
- [ ] Data integrity is verified after import

**Reference Documents**:
- `../backlog/bug-fixes/BF-001-export-import-not-working.md` - Bug fix specification
- `artifacts/phase-1-foundations/database-schema.md` - Export Strategy, Import Strategy sections
- `artifacts/phase-3-integration/platform-specifications.md` - File storage section

**Technical References**:
- Class/Method: `ExportService.exportAllData()` - `lib/core/utils/export_utils.dart`
- Class/Method: `ExportService.importAllData()` - `lib/core/utils/export_utils.dart`
- Class/Method: `ExportService._saveExportFile()` - `lib/core/utils/export_utils.dart`
- File: `lib/core/pages/export_page.dart`
- File: `lib/core/pages/import_page.dart`
- Test: `test/unit/core/utils/export_utils_test.dart` (to be created)

**Story Points**: 5

**Priority**: 🔴 Critical

**Status**: ⏳ In Progress

**Implementation Notes**:
- Some fixes already implemented (export to Downloads, file picker with `withData: true`)
- Testing still pending for cloud storage scenarios
- Need to verify all scenarios work correctly
- Error handling and user guidance need verification

**Documentation Note**: After each task completion, update this sprint document and any related bug fix documents (BF-001) with task status and implementation notes.

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-326 | Test export/import flow with Downloads directory | `ExportService`, `ImportService` | BF-001 - Testing | ⏳ | 2 | Dev2 |
| T-327 | Test export/import flow with Dropbox files | `ImportService._pickFile()` | BF-001 - Testing | ⏳ | 3 | Dev2 |
| T-328 | Test export/import flow with Google Drive files | `ImportService._pickFile()` | BF-001 - Testing | ⏳ | 3 | Dev2 |
| T-329 | Verify error handling and user guidance messages | `ImportPage`, `ExportPage` | BF-001 - Error Handling | ⏳ | 2 | Dev1 |
| T-330 | Verify data integrity after import | `ImportService.importAllData()` | BF-001 - Testing | ⏳ | 3 | Dev2 |
| T-331 | Write unit tests for export/import functionality | `ExportService` tests, `ImportService` tests | BF-001 - Testing | ⭕ | 5 | Dev2 |
| T-332 | Write widget tests for export/import pages | `ExportPage` tests, `ImportPage` tests | BF-001 - Testing | ⭕ | 3 | Dev3 |
| T-333 | Write integration test for full export/import flow | Integration tests | BF-001 - Testing | ⭕ | 5 | Dev2 |

**Total Task Points**: 26

---

### Story 12.2: Metric/Imperial Units Support - 13 Points

**User Story**: As a user, I want to choose my preferred unit system (metric or imperial) and have all measurements displayed in my preferred units, so that I can use the app comfortably with the units I'm familiar with.

**Acceptance Criteria**:

#### Core Requirements
- [ ] Users can select metric or imperial units in settings
- [ ] Unit preference is saved and persists across app restarts
- [ ] All weight values are displayed in the selected units (kg for metric, lb for imperial)
- [ ] All height/body measurement values are displayed in the selected units (cm for metric, ft/in for imperial)
- [ ] Unit preference applies consistently across all screens (entry, history, charts, home screen)
- [ ] When users change unit preference, all displayed values update immediately
- [ ] Data is stored internally in metric units for consistency (conversion happens at display time)

#### Settings UI
- [ ] Settings page has a "Units" section with metric/imperial toggle or dropdown
- [ ] Current unit preference is clearly indicated in settings
- [ ] Changing units preference saves immediately
- [ ] Visual indicator (e.g., "kg" vs "lb") shows which system is selected

#### Weight Display
- [ ] Weight entry fields accept input in selected units (kg or lb)
- [ ] Weight values in history display in selected units
- [ ] Weight charts show values in selected units with appropriate labels
- [ ] Weight moving averages display in selected units
- [ ] Weight trends and statistics display in selected units
- [ ] Weight input validation uses appropriate ranges for selected units

#### Body Measurements Display
- [ ] Height measurements display in selected units:
  - Metric: cm (e.g., "175 cm")
  - Imperial: ft/in (e.g., "5'9\"")
- [ ] Other body measurements (waist, chest, etc.) display in selected units:
  - Metric: cm
  - Imperial: in
- [ ] Entry forms accept input in selected units
- [ ] History pages show measurements in selected units

#### Data Conversion
- [ ] Conversion utilities convert metric to imperial accurately
- [ ] Conversion utilities convert imperial to metric accurately
- [ ] All conversions use appropriate precision (e.g., weight rounded to 1 decimal place)
- [ ] Height conversions handle ft/in format correctly (e.g., 5'9" = 5 feet 9 inches)
- [ ] Stored data remains in metric units internally (only display is converted)

#### Testing
- [ ] Unit tests for conversion utilities (metric ↔ imperial)
- [ ] Widget tests for settings UI (unit selection)
- [ ] Widget tests for weight/measurement display in both unit systems
- [ ] Manual testing: Switch units and verify all screens update correctly

**Reference Documents**:
- `../backlog/feature-requests/FR-007-metric-imperial-units.md` - Feature specification
- `artifacts/phase-1-foundations/data-models.md` - UserPreferences data model
- `artifacts/phase-2-features/health-tracking-module-specification.md` - Health tracking specifications

**Technical References**:
- Entity: `UserPreferences` entity with `units` field (`lib/core/entities/user_preferences.dart`)
- Model: `UserPreferencesModel` with `units` field (`lib/core/data/models/user_preferences_model.dart`)
- Settings Page: `lib/core/pages/settings_page.dart`
- Weight Entry: Weight entry pages in `lib/features/health_tracking/presentation/pages/`
- Format Utils: `lib/core/utils/format_utils.dart` (to be updated)
- New Utility: `lib/core/utils/unit_converter.dart` (to be created)

**Story Points**: 13

**Priority**: 🟠 High

**Status**: ⭕ Not Started

**Implementation Notes**:
- All data stored internally in metric units for consistency
- Conversion happens at display time only
- Height format: Imperial uses ft'in" format (e.g., "5'9\"")
- Conversion precision: Weight (1 decimal), Height (nearest inch), Other measurements (1 decimal)
- Clinical safety alerts need threshold conversion consideration

**Documentation Note**: After each task completion, update this sprint document and any related feature request documents (FR-007) with task status and implementation notes.

**Tasks**:

| Task ID | Task Description | Class/Method Reference | Document Reference | Status | Points | Assignee |
|---------|------------------|------------------------|---------------------|--------|--------|----------|
| T-307 | Create UnitConverter utility class with conversion methods | `UnitConverter` class | FR-007 - Domain Layer | ⭕ | 5 | Dev2 |
| T-308 | Create unit tests for UnitConverter (weight, height, length conversions) | `UnitConverter` tests | FR-007 - Testing Requirements | ⭕ | 5 | Dev2 |
| T-309 | Update format_utils.dart with unit formatting functions | `format_utils.dart` - format functions | FR-007 - Format Utilities | ⭕ | 3 | Dev2 |
| T-310 | Create UnitPreferenceProvider for state management | `UnitPreferenceProvider` | FR-007 - Providers | ⭕ | 3 | Dev3 |
| T-311 | Add "Units" section to Settings page with selection UI | `SettingsPage` - Units section | FR-007 - Settings UI | ⭕ | 5 | Dev1 |
| T-312 | Update WeightEntryPage to accept input in selected units | `WeightEntryPage` - input conversion | FR-007 - Weight Entry/Display | ⭕ | 5 | Dev1 |
| T-313 | Update weight history pages to display in selected units | Weight history pages | FR-007 - Weight Display | ⭕ | 3 | Dev1 |
| T-314 | Update weight chart widgets with unit labels | Weight chart widgets | FR-007 - Weight Charts | ⭕ | 5 | Dev3 |
| T-315 | Update weight statistics widgets with unit conversion | Weight statistics widgets | FR-007 - Weight Statistics | ⭕ | 3 | Dev1 |
| T-316 | Update MeasurementsPage for height/body measurements with unit conversion | `MeasurementsPage` - unit conversion | FR-007 - Body Measurements | ⭕ | 5 | Dev1 |
| T-317 | Update body measurements history pages with unit display | Body measurements history pages | FR-007 - Body Measurements Display | ⭕ | 3 | Dev1 |
| T-318 | Update home screen weight display widgets with unit conversion | Home screen widgets | FR-007 - Home Screen Widgets | ⭕ | 3 | Dev3 |
| T-319 | Update weight input validation for both unit systems | Weight validation | FR-007 - Validation Updates | ⭕ | 3 | Dev2 |
| T-320 | Update height input validation for both unit systems | Height validation | FR-007 - Validation Updates | ⭕ | 3 | Dev2 |
| T-321 | Write widget tests for settings unit selection | Settings page widget tests | FR-007 - Testing Requirements | ⭕ | 3 | Dev3 |
| T-322 | Write widget tests for weight entry/display with units | Weight page widget tests | FR-007 - Testing Requirements | ⭕ | 3 | Dev3 |
| T-323 | Write widget tests for measurement pages with units | Measurement page widget tests | FR-007 - Testing Requirements | ⭕ | 3 | Dev3 |
| T-324 | Integration test: Change units and verify all screens update | Integration tests | FR-007 - Testing Requirements | ⭕ | 5 | Dev2 |
| T-325 | Update clinical safety alerts thresholds for unit conversion | Clinical safety alerts | FR-007 - Notes | ⭕ | 3 | Dev2 |

**Total Task Points**: 70

---

## Sprint Summary

**Total Story Points**: 18 (5 + 13)  
**Total Task Points**: 96 (26 + 70)  
**Estimated Velocity**: 18 points (based on story points)

**Sprint Burndown**:
- Day 1: [X] points completed
- Day 2: [X] points completed
- Day 3: [X] points completed
- Day 4: [X] points completed
- Day 5: [X] points completed
- Day 6: [X] points completed
- Day 7: [X] points completed
- Day 8: [X] points completed
- Day 9: [X] points completed
- Day 10: [X] points completed
- Day 11: [X] points completed
- Day 12: [X] points completed
- Day 13: [X] points completed
- Day 14: [X] points completed

**Sprint Review Notes**:
- [Notes from sprint review]

**Sprint Retrospective Notes**:
- [Notes from retrospective]

---

## Demo to Product Owner

**Purpose**: The product owner will verify that unit selection works correctly across all screens and that data conversion is accurate.

**Demo Checklist**:

**Export/Import (BF-001)**:
- [ ] Export saves files to Downloads directory successfully
- [ ] Import works from Downloads directory
- [ ] Import works from Dropbox files
- [ ] Import works from Google Drive files
- [ ] File picker displays files correctly from all sources
- [ ] Error messages are clear and helpful
- [ ] Data integrity verified after import
- [ ] All export/import acceptance criteria met

**Metric/Imperial Units (FR-007)**:
- [ ] Settings page displays unit selection option
- [ ] Unit preference saves and persists after app restart
- [ ] Weight entry accepts input in selected units
- [ ] Weight values display correctly in selected units across all screens
- [ ] Height measurements display correctly in selected units (cm or ft/in)
- [ ] Body measurements display correctly in selected units
- [ ] Weight charts show correct unit labels on axes
- [ ] Weight statistics display in selected units
- [ ] Home screen weight display uses selected units
- [ ] Changing units updates all displayed values immediately
- [ ] Data is stored in metric units internally (verify database)
- [ ] Input validation works correctly for both unit systems
- [ ] Clinical safety alerts use appropriate thresholds
- [ ] All acceptance criteria from user story are met
- [ ] Unit tests pass for conversion utilities
- [ ] Widget tests pass for UI components
- [ ] Integration tests pass for unit switching flow
- [ ] No critical bugs or blockers identified

**Demo Notes**:
- [Notes from product owner demo]

---

**Cross-Reference**: Bug Fix - BF-001, Feature Request - FR-007

**Last Updated**: 2025-01-03  
**Version**: 1.0  
**Status**: ⭕ Not Started

**Progress Summary**:
- ⏳ Story 12.1: Export/Import Functionality Fix - **IN PROGRESS** (5 points)
- ⭕ Story 12.2: Metric/Imperial Units Support - **NOT STARTED** (13 points)
- **Completed Points**: 0 / 18 story points (0% complete)
- **Sprint ready for planning and task assignment**

