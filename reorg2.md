# Project Reorganization: TCREI Framework Prompt

## Task

Reorganize the Flutter Health Management App project by splitting the codebase into three distinct sections:

1. **Android Application Code and Documentation** → Move to dedicated folder structure
2. **Project Management Artifacts** → Move to dedicated folder structure
3. **Persona Definitions** → Move to dedicated folder structure

The goal is to create clear separation between application code/documentation and project management/persona materials, improving navigation and maintainability for both developers and project managers.

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
   - `cd app/ && flutter pub get` (should succeed)
   - `cd app/ && flutter analyze` (should work)
   - `cd app/ && flutter test` (should work)
   - Verify IDE can open project from `app/` directory

2. **Path Verification**
   - Use grep to find any remaining old path references
   - Verify all markdown links are valid
   - Check for broken relative paths

3. **Git Status**
   - Verify all moves are tracked correctly
   - Check for any untracked files that should be moved
   - Ensure no files were accidentally deleted

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
flutter pub get
flutter analyze
flutter test
cd ..
```

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

