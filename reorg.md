# Project Reorganization: CRISPE Framework Prompt

## Context

The Flutter Health Management App project currently has all files in a flat structure at the root level. To improve organization and maintainability, we need to separate the Android application code and its documentation from project management artifacts and persona definitions.

**Current Structure Issues**:
- Android/Flutter code (`lib/`, `test/`, `android/`, `pubspec.yaml`, etc.) is mixed with project management files (`artifacts/`, `personas/`, `orchestration-guide.md`)
- Documentation (`docs/`) is at root level but should be with the application code
- Project management artifacts and personas are at root level, making it unclear what belongs to the app vs. project management

**Desired Outcome**:
- Clear separation between application code/documentation and project management
- Easier navigation for developers working on the app
- Easier navigation for project managers and orchestrators
- Maintained functionality of all existing paths and references

## Role

You are a **Project Structure Specialist** with expertise in:
- Flutter/Dart project organization
- Documentation management
- Project management artifact organization
- File system restructuring with dependency tracking
- Git repository structure best practices

## Instructions

### Task Overview

Reorganize the project into two main directories:
1. **`app/`** - Contains all Android/Flutter application code and its documentation
2. **`project-management/`** - Contains all project management artifacts, personas, and orchestration materials

### Detailed Reorganization Steps

#### Step 1: Create New Directory Structure

Create the following directory structure:
```
flutter-health-management-app-for-android/
├── app/                          # Android application code and documentation
│   ├── lib/                      # Flutter application source code
│   ├── test/                     # Test files
│   ├── android/                  # Android platform-specific code
│   ├── docs/                     # Application documentation
│   ├── build/                    # Build artifacts (if needed)
│   ├── coverage/                 # Test coverage reports
│   ├── pubspec.yaml              # Flutter dependencies
│   ├── pubspec.lock              # Locked dependencies
│   ├── analysis_options.yaml     # Dart analysis options
│   ├── health_app.iml            # IDE configuration
│   └── README.md                 # Application README (update paths)
│
└── project-management/           # Project management and orchestration
    ├── artifacts/                # All generated artifacts
    ├── personas/                 # Persona prompt files
    ├── orchestration-guide.md    # Orchestration execution guide
    └── README.md                 # Project management README
```

#### Step 2: Move Application Code and Documentation

Move the following files and directories to `app/`:
- `lib/` → `app/lib/`
- `test/` → `app/test/`
- `android/` → `app/android/`
- `docs/` → `app/docs/`
- `build/` → `app/build/` (if it exists and should be tracked)
- `coverage/` → `app/coverage/`
- `pubspec.yaml` → `app/pubspec.yaml`
- `pubspec.lock` → `app/pubspec.lock`
- `analysis_options.yaml` → `app/analysis_options.yaml`
- `health_app.iml` → `app/health_app.iml`
- `health_app_android.iml` → `app/health_app_android.iml` (if exists)

**Note**: The `build/` directory is typically in `.gitignore` and may be regenerated. Only move if it contains important artifacts.

#### Step 3: Move Project Management Files

Move the following files and directories to `project-management/`:
- `artifacts/` → `project-management/artifacts/`
- `personas/` → `project-management/personas/`
- `orchestration-guide.md` → `project-management/orchestration-guide.md`

#### Step 4: Update Root README.md

Update the root `README.md` to:
- Reflect the new structure
- Provide navigation to both `app/` and `project-management/` directories
- Update all file paths referenced in the README
- Maintain all existing content but adjust paths

#### Step 5: Create/Update Application README

Create or update `app/README.md` to:
- Focus on application development, setup, and usage
- Include all content from the current README that relates to the application
- Update all paths to reflect the new `app/` location
- Remove references to project management/orchestration (move those to project-management README)

#### Step 6: Create Project Management README

Create `project-management/README.md` to:
- Explain the purpose of project management artifacts
- Document the orchestration process
- Reference persona files and their execution order
- Include instructions for using artifacts
- Update all paths to reflect the new `project-management/` location

#### Step 7: Update Internal References

Search and update all internal file references in:
- **Application code**: Update any hardcoded paths in `app/lib/` (if any)
- **Documentation**: Update paths in `app/docs/` files
- **Artifacts**: Update paths in `project-management/artifacts/` files
- **Personas**: Update paths in `project-management/personas/` files
- **Orchestration guide**: Update paths in `project-management/orchestration-guide.md`

**Key files to check for path updates**:
- `app/docs/user-guide.md`
- `app/docs/release-notes.md`
- `app/docs/post-mvp-features.md`
- `app/docs/development/setup-guide.md`
- `app/docs/development/contribution-guide.md`
- `project-management/orchestration-guide.md`
- `project-management/artifacts/organization-schema.md`
- All persona files in `project-management/personas/`

#### Step 8: Update .gitignore (if needed)

Review and update `.gitignore` to ensure:
- Build artifacts in `app/build/` are ignored
- Coverage reports in `app/coverage/` are handled appropriately
- No project management files are accidentally ignored

#### Step 9: Verify Flutter Project Structure

After moving files, verify that:
- `app/pubspec.yaml` is in the correct location (Flutter expects it at the project root)
- Flutter commands will work from the `app/` directory
- Android build configuration paths are correct
- IDE configurations are updated

**Important**: Flutter projects typically require `pubspec.yaml` at the root of the Flutter project. Since we're moving it to `app/`, developers will need to run Flutter commands from the `app/` directory.

#### Step 10: Update Documentation References

Update all markdown files that reference:
- Paths to `artifacts/` → `project-management/artifacts/`
- Paths to `personas/` → `project-management/personas/`
- Paths to `docs/` → `app/docs/`
- Paths to `lib/` → `app/lib/`
- Paths to `test/` → `app/test/`

## Success Criteria

The reorganization is successful when:

1. ✅ All application code is in `app/` directory
2. ✅ All application documentation is in `app/docs/` directory
3. ✅ All project management artifacts are in `project-management/artifacts/` directory
4. ✅ All personas are in `project-management/personas/` directory
5. ✅ Root README.md provides clear navigation to both directories
6. ✅ `app/README.md` contains application-focused documentation
7. ✅ `project-management/README.md` contains project management documentation
8. ✅ All internal file references are updated to reflect new paths
9. ✅ Flutter project can be built and run from `app/` directory
10. ✅ No broken links or references in documentation
11. ✅ Git history is preserved (files are moved, not copied)

## Constraints

- **Preserve Git History**: Use `git mv` for all file moves to preserve history
- **Maintain Functionality**: Ensure Flutter commands work from `app/` directory
- **No Data Loss**: Verify all files are moved, not deleted
- **Path Updates**: All relative paths in documentation must be updated
- **IDE Compatibility**: Update IDE configuration files if needed

## Process

### Execution Steps

1. **Create directories**: Create `app/` and `project-management/` directories
2. **Move application files**: Use `git mv` to move all application code and docs to `app/`
3. **Move project management files**: Use `git mv` to move artifacts and personas to `project-management/`
4. **Update README files**: Update root README, create/update app README, create project-management README
5. **Search and update paths**: Use grep to find all path references and update them
6. **Verify Flutter setup**: Test that `flutter pub get` and `flutter run` work from `app/` directory
7. **Check for broken links**: Verify all documentation links are valid
8. **Update .gitignore**: Ensure build artifacts are properly ignored

### Verification Checklist

- [ ] All files moved successfully (no files left in wrong location)
- [ ] Root README.md updated with new structure
- [ ] `app/README.md` created/updated with application docs
- [ ] `project-management/README.md` created with project management docs
- [ ] All path references updated in documentation
- [ ] Flutter project builds from `app/` directory
- [ ] Tests run successfully from `app/` directory
- [ ] No broken internal links
- [ ] Git history preserved (use `git log --follow` to verify)

## Expected Output

After completion, the project structure should be:

```
flutter-health-management-app-for-android/
├── app/                          # Android application
│   ├── lib/                      # Application source code
│   ├── test/                     # Tests
│   ├── android/                  # Android platform code
│   ├── docs/                     # Application documentation
│   ├── pubspec.yaml              # Flutter dependencies
│   ├── analysis_options.yaml     # Dart analysis
│   └── README.md                 # Application README
│
├── project-management/           # Project management
│   ├── artifacts/                # Generated artifacts
│   │   ├── phase-1-foundations/
│   │   ├── phase-2-features/
│   │   ├── phase-3-integration/
│   │   ├── phase-4-testing/
│   │   ├── phase-5-management/
│   │   └── ...
│   ├── personas/                 # Persona definitions
│   ├── orchestration-guide.md    # Execution guide
│   └── README.md                  # Project management README
│
└── README.md                     # Root README (navigation)
```

## Notes

- **Flutter Project Root**: Developers will need to `cd app/` before running Flutter commands
- **Path Updates**: Pay special attention to relative paths in markdown files
- **Git Commands**: Always use `git mv` instead of regular `mv` to preserve history
- **Backup**: Consider creating a backup branch before starting reorganization
- **Testing**: Test Flutter build and run commands after reorganization

