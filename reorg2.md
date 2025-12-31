# Project Reorganization: TCREI Framework Prompt

## Current Status (Updated)

**✅ REORGANIZATION MOSTLY COMPLETE** (as of review)

The reorganization has been successfully executed:
- ✅ All application files moved to `app/` directory
- ✅ All project management files moved to `project-management/` directory  
- ✅ All personas moved to `project-management/personas/`
- ✅ Files moved using `git mv` (history preserved - shown as "R" in git status)
- ✅ Documentation paths in `app/docs/` already updated correctly

**Cleanup Tasks Completed** (latest update):
- ✅ Updated `README.md` to reflect new structure (all paths updated)
- ✅ Removed leftover `android/.gradle` directory at root (Gradle cache)
- ✅ Verified Flutter functionality from `app/` directory (Flutter 3.29.0 working)
- ✅ Verified all old path references removed from README.md

**Optional Future Tasks** (not critical):
- ⚠️ Create `app/README.md` for application-specific documentation (optional)
- ⚠️ Create `project-management/README.md` for project management overview (optional)

## Task

Reorganize the Flutter Health Management App project by splitting the codebase into three distinct sections:

1. **Android Application Code and Documentation** → Move to dedicated folder structure
2. **Project Management Artifacts** → Move to dedicated folder structure
3. **Persona Definitions** → Move to dedicated folder structure

The goal is to create clear separation between application code/documentation and project management/persona materials, improving navigation and maintainability for both developers and project managers.

## Quick Reference Command Summary

**Essential Commands (Execute in Order)**:

```bash
# 1. Backup current state
git checkout -b backup/pre-reorganization
git add . && git commit -m "chore: backup before reorganization"
git checkout -  # Return to previous branch
git checkout -b chore/reorganize-project-structure

# 2. Create directories
mkdir -p app project-management

# 3. Move application files
git mv lib test android docs coverage app/ 2>/dev/null || true
git mv pubspec.yaml pubspec.lock analysis_options.yaml app/
git mv health_app.iml app/ 2>/dev/null || true

# 4. Move project management files
git mv artifacts orchestration-guide.md personas project-management/

# 5. Update paths in documentation (see Path Update Reference Guide section)

# 6. Verify Flutter functionality
cd app && flutter pub get && flutter analyze && flutter test && cd ..

# 7. Commit changes
git add . && git status  # Verify moves
git commit -m "chore: reorganize project into app/ and project-management/ directories..."
```

**Key Files to Move**:
- To `app/`: `lib/`, `test/`, `android/`, `docs/`, `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `coverage/`
- To `project-management/`: `artifacts/`, `personas/`, `orchestration-guide.md`

## Context

### Current Project Structure

The project currently has all files at the root level, creating organizational challenges:

**Application Code (should be grouped)**:
- `lib/` - Flutter application source code
- `test/` - Test files (unit, widget, integration)
- `android/` - Android platform-specific code
- `docs/` - Application documentation (user guide, release notes, API docs, etc.)
- `pubspec.yaml`, `pubspec.lock` - Flutter dependencies
- `analysis_options.yaml` - Dart analysis configuration
- `build/` - Build artifacts (generated, typically ignored)
- `coverage/` - Test coverage reports
- IDE configuration files (`.iml` files)

**Project Management (should be grouped)**:
- `artifacts/` - All project management artifacts organized by phase
  - `phase-1-foundations/` - Foundation specifications
  - `phase-2-features/` - Feature specifications
  - `phase-3-integration/` - Integration specifications
  - `phase-4-testing/` - Testing specifications
  - `phase-5-management/` - Management documentation
  - `orchestration-analysis-report/` - Analysis reports
  - `final-product/` - Final deliverables
  - Root-level artifact files (requirements.md, orchestration-definition.md, etc.)
- `orchestration-guide.md` - Orchestration execution guide

**Personas (should be grouped)**:
- `personas/` - All persona prompt files (13 persona files numbered 01-13)

### Issues with Current Structure

1. **Mixed Concerns**: Application code and project management materials are intermingled at root level
2. **Navigation Difficulty**: Developers must sift through project management files to find code
3. **Unclear Boundaries**: It's not immediately obvious what belongs to the app vs. project management
4. **Maintenance Overhead**: Updates to project structure require navigating through mixed concerns

### Flutter Project Constraints

- Flutter projects require `pubspec.yaml` at the root of the Flutter project directory
- Developers typically run Flutter commands (`flutter pub get`, `flutter run`, etc.) from the project root
- Build artifacts are generated relative to the project root
- IDE configurations reference paths relative to the project root

## Requirements

### Structural Requirements

1. **Create `app/` Directory**
   - Contains all Android/Flutter application code
   - Contains all application-specific documentation
   - Must be a valid Flutter project (can run Flutter commands from within `app/`)

2. **Create `project-management/` Directory**
   - Contains all `artifacts/` directory and its contents
   - Contains `orchestration-guide.md`
   - Contains project management README

3. **Create `personas/` Directory** (or keep at root if preferred, but user specified separate folder)
   - Actually, personas should likely go in `project-management/personas/` since they're orchestration tools
   - **Decision**: Move `personas/` to `project-management/personas/`

### Functional Requirements

1. **Preserve Git History**
   - Use `git mv` for all file moves (never use regular `mv` or copy operations)
   - Maintain file history and blame information

2. **Update All Internal References**
   - Update paths in documentation files
   - Update paths in artifact files
   - Update paths in persona files
   - Update paths in orchestration guide
   - Update paths in README files

3. **Maintain Flutter Functionality**
   - Flutter commands must work from `app/` directory
   - Build system must function correctly
   - Tests must run successfully
   - IDE must be able to open and work with the project

4. **Update Documentation**
   - Root README.md must reflect new structure
   - Create/update `app/README.md` with application-focused content
   - Create `project-management/README.md` with project management overview
   - All cross-references in markdown files must be updated

5. **Handle Build Artifacts**
   - `build/` directory can be regenerated (typically in .gitignore)
   - Consider whether to move or regenerate
   - Coverage reports may need path updates if referenced

### Quality Requirements

1. **No Broken Links**: All markdown internal links must be valid after reorganization
2. **No Orphaned Files**: All files must be in appropriate locations
3. **Consistent Paths**: All path references must use consistent relative path conventions
4. **Clear Structure**: The new structure should be intuitive and self-documenting

## Execution

### Execution Strategy

1. **Plan Before Action**
   - Map all files to target locations
   - Identify all files with internal path references
   - Create backup branch for safety

2. **Move Files Systematically**
   - Move application files first (to `app/`)
   - Move project management files second (to `project-management/`)
   - Verify moves with `git status`

3. **Update References in Batches**
   - Update application documentation first
   - Update project management artifacts second
   - Update root-level documentation last

4. **Verify Functionality**
   - Test Flutter commands from `app/` directory
   - Verify all paths are correct
   - Check for broken links

### Detailed Execution Steps

#### Phase 1: Preparation

1. Create a backup branch: `git checkout -b backup/pre-reorganization`
2. Commit current state: `git add . && git commit -m "chore: backup before reorganization"`
3. Return to working branch (or create feature branch)
4. Document current file locations and cross-references

#### Phase 2: Create New Directory Structure

1. Create `app/` directory
2. Create `project-management/` directory
3. Verify directories are created correctly

#### Phase 3: Move Application Files

Move the following to `app/` using `git mv`:
- `lib/` → `app/lib/`
- `test/` → `app/test/`
- `android/` → `app/android/`
- `docs/` → `app/docs/`
- `pubspec.yaml` → `app/pubspec.yaml`
- `pubspec.lock` → `app/pubspec.lock`
- `analysis_options.yaml` → `app/analysis_options.yaml`
- `health_app.iml` → `app/health_app.iml` (if exists and should be tracked)
- `coverage/` → `app/coverage/` (if tracking coverage)

**Note**: `build/` directory is typically in `.gitignore` and can be regenerated. Do not move it unless necessary.

#### Phase 4: Move Project Management Files

Move the following to `project-management/` using `git mv`:
- `artifacts/` → `project-management/artifacts/`
- `orchestration-guide.md` → `project-management/orchestration-guide.md`
- `personas/` → `project-management/personas/`

#### Phase 5: Update Documentation Files

1. **Update Root README.md**
   - Add navigation section pointing to `app/` and `project-management/`
   - Update any path references
   - Keep high-level project overview

2. **Create/Update `app/README.md`**
   - Focus on application development setup
   - Include Flutter setup instructions
   - Include build and run instructions
   - Update all paths to reflect `app/` location
   - Remove project management references (move to project-management README)

3. **Create `project-management/README.md`**
   - Explain purpose of project management folder
   - Document artifact organization
   - Document persona usage
   - Reference orchestration guide
   - Update all paths

#### Phase 6: Update Internal Path References

Search and update paths in the following file categories:

**Application Documentation** (`app/docs/`):
- Update references to `artifacts/` → `../project-management/artifacts/`
- Update references to `personas/` → `../project-management/personas/`
- Update references to root-level files

**Project Management Artifacts** (`project-management/artifacts/`):
- Update references to `docs/` → `../../app/docs/`
- Update references to `lib/` → `../../app/lib/`
- Update references to `test/` → `../../app/test/`
- Update cross-references within artifacts

**Personas** (`project-management/personas/`):
- Update references to `artifacts/` → `../artifacts/`
- Update references to application code → `../../app/`

**Orchestration Guide** (`project-management/orchestration-guide.md`):
- Update all path references to reflect new structure

#### Phase 7: Verify and Test

1. **Flutter Functionality**

   ```bash
   cd app/
   flutter pub get
   ```
   **Expected Output**: Should show "Running 'flutter pub get' in app..." and complete with exit code 0. No errors about missing `pubspec.yaml`.

   ```bash
   flutter analyze
   ```
   **Expected Output**: Should analyze Dart files and show analysis results. May have pre-existing warnings, but should not error about missing files or path issues.

   ```bash
   flutter test
   ```
   **Expected Output**: Should run all tests successfully. Test count should match pre-reorganization count. No "file not found" errors.

   ```bash
   cd ..
   ```
   - Verify IDE can open project from `app/` directory (manual verification)

2. **Path Verification**

   ```bash
   # Find any remaining old path references
   grep -r "artifacts/" app/docs/ 2>/dev/null | grep -v "project-management/artifacts/" || echo "No old artifact references found"
   grep -r "personas/" app/docs/ 2>/dev/null | grep -v "project-management/personas/" || echo "No old persona references found"
   grep -r "\"docs/\"" project-management/ 2>/dev/null | grep -v "app/docs" || echo "No old docs references found"
   grep -r "\"lib/\"" project-management/ 2>/dev/null | grep -v "app/lib" || echo "No old lib references found"
   ```
   **Expected Output**: Should show "No old X references found" for each check, or list only legitimate references that were correctly updated.

   ```bash
   # Verify markdown links (if link checker available)
   # Manual check: Open key markdown files and verify links work
   ```
   - Verify all markdown links are valid (check key files manually)
   - Check for broken relative paths

3. **Git Status**

   ```bash
   git status
   ```
   **Expected Output**: Should show:
   - All moved files as "renamed" (not "deleted" and "new file")
   - Modified files (README updates, path reference updates)
   - No unexpected deleted files
   - No untracked files that should have been moved

   ```bash
   # Verify git history preservation
   git log --follow --oneline app/lib/main.dart | head -5
   ```
   **Expected Output**: Should show commit history for the file, demonstrating history is preserved.

   ```bash
   # Check for any files left in root that should have been moved
   ls -la | grep -E "^(lib|test|android|docs|artifacts|personas|pubspec)" || echo "No unexpected root files"
   ```
   **Expected Output**: Should show only expected root files (README.md, reorg.md, reorg2.md, .gitignore, etc.). No `lib/`, `test/`, `artifacts/`, etc.

## Implementation

### Target Directory Structure

```
flutter-health-management-app-for-android/
├── app/                                    # Android application code and docs
│   ├── lib/                                # Flutter application source code
│   │   ├── core/                          # Core functionality
│   │   ├── features/                      # Feature modules
│   │   └── main.dart                      # Application entry point
│   ├── test/                              # Test files
│   │   ├── unit/                          # Unit tests
│   │   ├── widget/                        # Widget tests
│   │   ├── integration/                   # Integration tests
│   │   └── fixtures/                      # Test fixtures
│   ├── android/                           # Android platform-specific code
│   │   ├── app/                           # Android app configuration
│   │   ├── gradle/                        # Gradle configuration
│   │   └── build.gradle.kts               # Root build file
│   ├── docs/                              # Application documentation
│   │   ├── api/                           # API documentation
│   │   ├── architecture/                  # Architecture docs
│   │   ├── deployment/                    # Deployment docs
│   │   ├── development/                   # Development guides
│   │   ├── user-guide.md                  # User documentation
│   │   ├── release-notes.md               # Release notes
│   │   └── post-mvp-features.md           # Post-MVP feature docs
│   ├── coverage/                          # Test coverage reports
│   ├── pubspec.yaml                       # Flutter dependencies
│   ├── pubspec.lock                       # Locked dependencies
│   ├── analysis_options.yaml              # Dart analysis options
│   ├── health_app.iml                     # IDE configuration
│   └── README.md                          # Application README
│
├── project-management/                    # Project management and orchestration
│   ├── artifacts/                         # All project artifacts
│   │   ├── requirements.md                # Project requirements
│   │   ├── orchestration-definition.md    # Orchestration structure
│   │   ├── organization-schema.md         # Artifact organization
│   │   ├── deployment-guide.md            # Deployment guide
│   │   ├── document-review-report.md      # Document review
│   │   ├── implementation-order.md        # Implementation order
│   │   ├── phase-1-foundations/           # Foundation artifacts
│   │   ├── phase-2-features/              # Feature specifications
│   │   ├── phase-3-integration/           # Integration specifications
│   │   ├── phase-4-testing/               # Testing specifications
│   │   ├── phase-5-management/            # Management documentation
│   │   ├── orchestration-analysis-report/ # Analysis reports
│   │   └── final-product/                 # Final deliverables
│   ├── personas/                          # Persona prompt files
│   │   ├── 01-flutter-architect-developer.md
│   │   ├── 02-ui-ux-designer.md
│   │   ├── 03-data-architect-backend-specialist.md
│   │   ├── 04-health-domain-expert.md
│   │   ├── 05-feature-module-developer-health-tracking.md
│   │   ├── 06-feature-module-developer-nutrition-exercise.md
│   │   ├── 07-integration-platform-specialist.md
│   │   ├── 08-qa-testing-specialist.md
│   │   ├── 09-scrum-master.md
│   │   ├── 10-orchestrator.md
│   │   ├── 11-analyst.md
│   │   ├── 12-compiler.md
│   │   └── 13-ios-migration-specialist.md
│   ├── orchestration-guide.md             # Orchestration execution guide
│   └── README.md                          # Project management README
│
├── README.md                              # Root README (navigation and overview)
├── reorg.md                               # Previous reorganization notes
└── reorg2.md                              # This file (TCREI reorganization prompt)
```

### Specific Implementation Commands

#### Step 1: Create Backup Branch
```bash
git checkout -b backup/pre-reorganization
git add .
git commit -m "chore: backup before reorganization"
git checkout -  # Return to previous branch or create feature branch
```

#### Step 2: Create Feature Branch for Reorganization
```bash
git checkout -b chore/reorganize-project-structure
```

#### Step 3: Create New Directories
```bash
mkdir -p app
mkdir -p project-management
```

#### Step 4: Move Application Files
```bash
# Move core application directories
git mv lib app/
git mv test app/
git mv android app/
git mv docs app/
git mv coverage app/  # If tracking coverage

# Move configuration files
git mv pubspec.yaml app/
git mv pubspec.lock app/
git mv analysis_options.yaml app/

# Move IDE files (if tracked)
git mv health_app.iml app/ 2>/dev/null || true
```

#### Step 5: Move Project Management Files
```bash
git mv artifacts project-management/
git mv orchestration-guide.md project-management/
git mv personas project-management/
```

#### Step 6: Update Path References (Example grep and replace pattern)
```bash
# Find files with old path references
# Then update them systematically using search_replace tool or sed

# Common patterns to update:
# - `artifacts/` → `project-management/artifacts/` (in app/docs/)
# - `personas/` → `project-management/personas/` (in app/docs/)
# - `docs/` → `app/docs/` (in project-management/)
# - `lib/` → `app/lib/` (in project-management/)
# - `test/` → `app/test/` (in project-management/)
```

#### Step 7: Update README Files
- Update root `README.md` with navigation
- Create/update `app/README.md`
- Create `project-management/README.md`

#### Step 8: Verify Flutter Functionality
```bash
cd app
flutter pub get      # Expected: Successful dependency resolution, exit code 0
flutter analyze      # Expected: Analysis completes, may show warnings but no path errors
flutter test         # Expected: All tests pass, no file not found errors
cd ..
```

**Troubleshooting Verification**:
- If `flutter pub get` fails: Check that `pubspec.yaml` is in `app/` directory
- If `flutter analyze` shows path errors: Check import statements haven't broken
- If `flutter test` fails: Verify test files were moved correctly and paths are updated

#### Step 9: Commit Changes
```bash
git add .
git status  # Verify all moves are staged correctly
git commit -m "chore: reorganize project into app/ and project-management/ directories

Separate Android application code and documentation from project management artifacts and personas for improved organization and navigation.

Technical changes:
- Move all Flutter/Android code to app/ directory
- Move all project management artifacts to project-management/ directory
- Move personas to project-management/personas/
- Update all internal path references in documentation
- Create separate README files for app/ and project-management/
- Update root README with navigation to new structure"
```

### Path Update Reference Guide

When updating paths in documentation, use these relative path rules:

**From `app/docs/*.md` referencing project-management:**
- `artifacts/` → `../../project-management/artifacts/`
- `personas/` → `../../project-management/personas/`
- `orchestration-guide.md` → `../../project-management/orchestration-guide.md`

**From `project-management/artifacts/**/*.md` referencing app:**
- `docs/` → `../../app/docs/`
- `lib/` → `../../app/lib/`
- `test/` → `../../app/test/`

**From `project-management/personas/*.md` referencing artifacts:**
- `artifacts/` → `../artifacts/`

**From `project-management/orchestration-guide.md` referencing app:**
- `docs/` → `../app/docs/`
- `lib/` → `../app/lib/`
- `test/` → `../app/test/`

**From root `README.md`:**
- `app/` → `app/` (relative to root)
- `project-management/` → `project-management/` (relative to root)

### Verification Checklist

- [ ] All application files moved to `app/`
- [ ] All project management files moved to `project-management/`
- [ ] All personas moved to `project-management/personas/`
- [ ] Root README.md updated with navigation
- [ ] `app/README.md` created/updated
- [ ] `project-management/README.md` created
- [ ] All path references in `app/docs/` updated
- [ ] All path references in `project-management/artifacts/` updated
- [ ] All path references in `project-management/personas/` updated
- [ ] `project-management/orchestration-guide.md` paths updated
- [ ] Flutter commands work from `app/` directory
- [ ] Tests run successfully from `app/` directory
- [ ] No broken markdown links
- [ ] Git history preserved (verified with `git log --follow`)
- [ ] All files committed with appropriate commit message

### Success Criteria

The reorganization is successful when:

1. ✅ **Structure**: All files are in their appropriate directories (`app/` or `project-management/`)
2. ✅ **Functionality**: Flutter project builds and runs from `app/` directory
3. ✅ **Documentation**: All README files are updated and accurate
4. ✅ **References**: All internal path references are correct
5. ✅ **Links**: No broken markdown links exist
6. ✅ **History**: Git history is preserved for all moved files
7. ✅ **Clarity**: The structure is intuitive and self-documenting

### Notes and Considerations

1. **Flutter Project Root**: After reorganization, developers will need to `cd app/` before running Flutter commands. This is acceptable and expected.

2. **Build Directory**: The `build/` directory is typically in `.gitignore` and can be regenerated. It should not be moved.

3. **IDE Configuration**: IDE files (`.iml`) may need to be regenerated or updated after the move. Verify IDE functionality after reorganization.

4. **Relative vs Absolute Paths**: Prefer relative paths in documentation for portability, but ensure they're correct relative to the file's new location.

5. **Git Moves**: Always use `git mv` instead of regular file system moves to preserve history. If a file is moved outside of git, the history may be lost.

6. **Testing**: Thoroughly test Flutter functionality after reorganization to ensure nothing is broken.

7. **Rollback Plan**: The backup branch created in Phase 1 can be used to rollback if issues are discovered.

## Troubleshooting

### Common Issues and Solutions

#### Issue 1: `git mv` fails with "fatal: bad source"

**Symptoms**: `git mv lib app/` returns error about bad source

**Causes**:
- File/directory doesn't exist at specified path
- File is not tracked by git
- Path contains typos

**Solutions**:
```bash
# Verify file exists and is tracked
git ls-files | grep "^lib/"
ls -la lib/  # Verify directory exists

# If file exists but isn't tracked, add it first
git add lib/
git mv lib app/

# Check current directory
pwd  # Should be project root
```

#### Issue 2: Flutter commands fail after move

**Symptoms**: `cd app && flutter pub get` fails with path errors

**Causes**:
- `pubspec.yaml` not moved correctly
- Still in wrong directory when running commands
- Import paths in code need updating

**Solutions**:
```bash
# Verify pubspec.yaml location
ls -la app/pubspec.yaml  # Should exist

# Ensure you're in app directory
cd app
pwd  # Should end with /app

# Clean and retry
flutter clean
flutter pub get

# If import errors persist, check import statements
grep -r "package:" app/lib/ | head -20  # Check for broken imports
```

#### Issue 3: Tests fail with "file not found" errors

**Symptoms**: `flutter test` fails with file not found errors

**Causes**:
- Test files not moved correctly
- Test fixtures or assets not moved
- Test imports reference old paths

**Solutions**:
```bash
# Verify test directory exists
ls -la app/test/

# Check for fixture files
find app/test/ -name "*.json" -o -name "*.txt" -o -name "fixtures"

# Check test imports
grep -r "import.*test/" app/test/ | head -20

# Verify test references correct paths
cd app
flutter test --verbose  # See detailed error messages
```

#### Issue 4: IDE shows errors after reorganization

**Symptoms**: IDE (VS Code, Android Studio) shows red squiggles or can't find files

**Causes**:
- IDE still pointing to old project root
- IDE cache needs refresh
- Workspace file not updated

**Solutions**:
```bash
# Close IDE completely

# If using VS Code, open workspace from app/ directory
cd app
code .  # Opens app/ as workspace root

# If using Android Studio/IntelliJ
# 1. File → Open → Select app/ directory
# 2. File → Invalidate Caches → Invalidate and Restart

# Clean IDE cache manually (if needed)
rm -rf app/.dart_tool/
rm -rf app/.idea/  # For IntelliJ/Android Studio
cd app && flutter pub get  # Regenerate tool files
```

#### Issue 5: Git history appears lost

**Symptoms**: `git log` shows files as new instead of moved

**Causes**:
- Used regular `mv` instead of `git mv`
- Files were copied instead of moved

**Solutions**:
```bash
# Check if history exists
git log --follow -- app/lib/main.dart

# If history exists but git status shows as new files:
# - This is actually fine, git tracks moves correctly
# - History is preserved even if status shows differently

# If history truly lost, restore from backup branch
git checkout backup/pre-reorganization -- lib/
git mv lib app/lib  # Use git mv this time
git commit -m "chore: correctly move lib/ preserving history"
```

#### Issue 6: Path references not updating correctly

**Symptoms**: Documentation links broken, grep shows old paths

**Causes**:
- Paths updated incorrectly
- Relative path calculations wrong
- Some files missed in update

**Solutions**:
```bash
# Find all old path references
grep -r "artifacts/" app/docs/ project-management/
grep -r '"docs/"' project-management/ | grep -v "app/docs"

# Use Path Update Reference Guide section for correct mappings
# Update paths systematically using search_replace tool

# Verify updates
grep -r "../../project-management/artifacts/" app/docs/ | wc -l
# Should match expected number of references
```

#### Issue 7: Build directory issues

**Symptoms**: Build fails or build artifacts in wrong location

**Causes**:
- Build directory moved when it shouldn't be
- `.gitignore` not updated
- Build cache pointing to old paths

**Solutions**:
```bash
# Build directory should NOT be moved (it's in .gitignore)
# If accidentally moved, remove it
rm -rf app/build/

# Clean build cache
cd app
flutter clean
flutter pub get

# Verify .gitignore
grep "build/" .gitignore  # Should ignore build directories

# Regenerate build
flutter build apk --debug  # Test build works
```

#### Issue 8: Coverage reports broken

**Symptoms**: Coverage reports show wrong paths or can't be generated

**Causes**:
- Coverage directory moved but paths in config not updated
- Coverage tool still using old paths

**Solutions**:
```bash
# Verify coverage directory exists
ls -la app/coverage/

# If using coverage package, check configuration
grep -r "coverage" app/pubspec.yaml

# Regenerate coverage from new location
cd app
flutter test --coverage
# Coverage should be in app/coverage/

# Update any CI/CD scripts that reference coverage paths
```

#### Issue 9: Cannot commit - "nothing to commit"

**Symptoms**: `git commit` says nothing to commit after moves

**Causes**:
- Files not staged
- All changes already committed
- Working on wrong branch

**Solutions**:
```bash
# Check git status
git status  # Should show staged moves

# If nothing staged, stage all changes
git add -A
git status  # Verify files are staged

# Check current branch
git branch  # Should be on chore/reorganize-project-structure

# If on wrong branch, switch branches
git checkout chore/reorganize-project-structure
```

#### Issue 10: Merge conflicts or branch issues

**Symptoms**: Can't create branch, merge conflicts when returning

**Causes**:
- Uncommitted changes
- Branch already exists
- Remote branch conflicts

**Solutions**:
```bash
# Check for uncommitted changes
git status

# Stash changes if needed
git stash
git checkout -b chore/reorganize-project-structure
git stash pop

# If branch exists, delete and recreate (if safe)
git branch -D chore/reorganize-project-structure
git checkout -b chore/reorganize-project-structure

# If remote conflicts, pull latest first
git checkout main  # or your base branch
git pull
git checkout -b chore/reorganize-project-structure
```

### Recovery Procedures

#### Complete Rollback

If reorganization fails catastrophically:

```bash
# Return to backup branch
git checkout backup/pre-reorganization

# Or reset current branch to backup
git reset --hard backup/pre-reorganization

# Verify everything is back
ls -la lib/ test/ android/  # Should exist at root
flutter pub get  # Should work from root
```

#### Partial Rollback

If only some steps need to be undone:

```bash
# Undo specific moves (example: undo lib/ move)
git checkout HEAD -- app/lib/
git mv app/lib .  # Move back
git add .
git commit -m "chore: revert lib/ move"

# Or use git restore for uncommitted changes
git restore --staged app/lib/
git restore app/lib/
```

#### Verification After Issues

After fixing any issues:

```bash
# 1. Verify file structure
tree -L 2 app/ project-management/  # or use ls -R

# 2. Verify Flutter works
cd app && flutter doctor && flutter pub get && flutter test

# 3. Verify git status
git status  # Should show clean or only expected changes

# 4. Verify no broken links
grep -r "artifacts/" app/docs/ | grep -v "project-management" || echo "OK"

# 5. Check git log for moves
git log --oneline --name-status -10  # Should show renames
```


