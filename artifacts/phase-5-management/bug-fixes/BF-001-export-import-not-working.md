# Bug Fix: BF-001 - Export/Import Functionality Not Working Properly

**Status**: ⏳ In Progress  
**Priority**: 🔴 Critical  
**Story Points**: 5  
**Created**: 2025-12-30  
**Updated**: 2025-01-02  
**Assigned Sprint**: Sprint 10

## Description

The export and import functionality for user data backup is not working correctly. Users are unable to successfully import exported files, particularly when files are saved to cloud storage services like Dropbox or Google Drive. Additionally, files saved to the Downloads directory may not be accessible for import.

## Steps to Reproduce

1. Export data using the Export feature in Settings
2. Share the exported file to Dropbox or Google Drive
3. Attempt to import the file using the Import feature
4. Observe that:
   - Files in Dropbox are visible but cannot be selected/clicked
   - Files in Google Drive are not visible in the file picker
   - Files in Downloads directory may not be accessible

## Expected Behavior

- Export should save files to a location that is easily accessible for import
- Import should allow users to select and import files from:
  - Cloud storage services (Dropbox, Google Drive)
  - Downloads folder
  - Any accessible file location on the device
- File picker should display all exported JSON files and allow selection
- Import should successfully read and restore data from exported files

## Actual Behavior

- Files exported to cloud storage cannot be imported
- Dropbox files appear in file picker but are not selectable/clickable
- Google Drive files do not appear in file picker at all
- Files may not be saved to a user-accessible location (Downloads folder)
- Import functionality fails when attempting to access files from cloud storage

## Environment

- **Device**: Android device (Pixel 10 reported)
- **Android Version**: Android API 24-34 (targeting API 34)
- **App Version**: Current development version
- **OS**: Android

## Screenshots/Logs

No error messages are displayed, but files cannot be selected during import process.

## Technical Details

- **Module**: Core - Data Export/Import
- **Related Documents**: 
  - `artifacts/phase-1-foundations/database-schema.md` - Backup and Restore section
  - `artifacts/phase-3-integration/platform-specifications.md` - File storage
- **Classes/Methods**: 
  - `ExportService.exportAllData()` - `lib/core/utils/export_utils.dart`
  - `ExportService.importAllData()` - `lib/core/utils/export_utils.dart`
  - `ExportService._saveExportFile()` - `lib/core/utils/export_utils.dart`
  - `_pickFile()` - `lib/core/pages/import_page.dart`
- **Error Messages**: None displayed, but functionality fails silently

## Root Cause

1. **Cloud Storage Access**: The file picker may not properly handle files from cloud storage providers when they don't have direct file paths. Files shared to cloud storage may only be accessible via content URIs or require special handling.

2. **File Location**: Files are currently saved to the app's documents directory, which may not be easily accessible through the standard file picker, especially for cloud storage services.

3. **File Picker Configuration**: The file picker may not be properly configured to access files from cloud storage services or may require additional permissions/configuration.

4. **Downloads Directory Access**: Attempts to save to Downloads directory may fail due to Android scoped storage restrictions or permission issues.

## Solution

1. **Save to Downloads Directory**: ✅ Improved export to attempt saving to Downloads directory, with fallback to app's external storage directory (accessible via file picker).

2. **Handle Cloud Storage Files**: ✅ Implemented proper handling for files accessed from cloud storage:
   - Read file bytes when direct file path is not available
   - Save file contents to temporary location for import processing
   - Enhanced file picker configuration with `withData: true` to read file contents directly

3. **File Picker Configuration**: ✅ Configured file picker to properly access files from:
   - Local storage (Downloads, Documents)
   - Cloud storage providers (Dropbox, Google Drive, etc.)
   - Using `withData: true` to read file contents directly from cloud storage

4. **Error Handling**: ✅ Added proper error messages when files cannot be accessed or imported, with helpful user guidance.

5. **Testing**: ⏳ Pending - Test export/import flow with:
   - Files in Downloads directory
   - Files shared to Dropbox
   - Files shared to Google Drive
   - Files accessed via file manager

## Reference Documents

- `artifacts/phase-1-foundations/database-schema.md` - Export Strategy, Import Strategy sections
- `artifacts/phase-3-integration/platform-specifications.md` - File storage section
- `artifacts/phase-5-management/sprint/sprint-08-integration-polish.md` - Story 8.4: Data Export/Import UI

## Technical References

- Class/Method: `ExportService.exportAllData()` - `lib/core/utils/export_utils.dart`
- Class/Method: `ExportService.importAllData()` - `lib/core/utils/export_utils.dart`
- Class/Method: `ExportService._saveExportFile()` - `lib/core/utils/export_utils.dart`
- File: `lib/core/pages/export_page.dart`
- File: `lib/core/pages/import_page.dart`
- Test: `test/unit/core/utils/export_utils_test.dart` (to be created)

## Testing

- [ ] Unit test added/updated for export/import functionality
- [ ] Widget test added/updated for export/import pages
- [ ] Integration test added/updated for full export/import flow
- [ ] Manual testing completed:
  - [ ] Export to Downloads directory
  - [ ] Import from Downloads directory
  - [ ] Export and share to Dropbox, then import
  - [ ] Export and share to Google Drive, then import
  - [ ] Verify data integrity after import

## Notes

- This is a critical bug as it prevents users from backing up and restoring their health data, which is a core requirement for data safety.
- The issue affects data export/import functionality that was implemented in Sprint 8 (Story 8.4).
- Related to file storage and Android scoped storage permissions.
- May require additional permissions or Android manifest configuration.

## History

- 2025-12-30 - Created
- 2025-01-02 - Status changed to ⏳ In Progress, Assigned to Sprint 10
- 2025-01-02 - Implemented fixes:
  - Improved export file saving to attempt Downloads directory with proper fallback
  - Enhanced import file picker to handle cloud storage files (Dropbox, Google Drive)
  - Added better error handling and user feedback
  - Updated UI messages to guide users on file access

