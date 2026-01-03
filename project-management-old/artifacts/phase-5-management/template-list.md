# Template List

This document lists all templates available in the project for creating new documents, features, bug fixes, sprints, and other artifacts.

**Last Updated**: 2025-01-02

---

## 1. Sprint Planning Template

**Location**: `project-management/artifacts/phase-5-management/sprints/sprint-planning-template.md`

**Purpose**: Template for creating new sprint planning documents following the CRISPE Framework.

**Use When**: Creating a new sprint planning document (sprint-XX-*.md).

**Contains**:
- Sprint header format (goal, duration, velocity, dates)
- Sprint overview structure (focus areas, deliverables, dependencies, risks)
- User story format with acceptance criteria
- Tasks table format
- Reference document structure
- Technical reference format

**Reference**: Based on CRISPE Framework standards in `../../requirements.md`.

---

## 2. User Documentation Template

**Location**: `project-management/artifacts/user-documentation-template.md`

**Purpose**: Template for creating user-facing documentation, in-app help, and user guides.

**Use When**: Creating documentation for end users (user guides, help content, getting started guides).

**Contains**:
- Getting started guide structure
- Feature guides format
- Troubleshooting section format
- FAQ structure
- Best practices section
- Glossary format

**Covers Features**:
- Health Tracking
- Nutrition Management
- Exercise Tracking
- Medication Management
- Behavioral Support
- Progress Analytics

---

## 3. Feature Request Template

**Location**: `project-management/artifacts/phase-5-management/backlog/product-backlog-structure.md` (Section: "Feature Request Template")

**File Path Pattern**: `project-management/artifacts/phase-5-management/backlog/feature-requests/FR-XXX-feature-name.md`

**Purpose**: Template for creating new feature request documents in the product backlog.

**Use When**: Adding a new feature request to the backlog.

**Contains**:
- Feature request header (ID, status, priority, story points, dates, assigned sprint)
- Description section
- User story format (As a... I want... So that...)
- Acceptance criteria checklist
- Business value section
- Technical requirements
- Reference documents section
- Technical references (architecture, feature specs, data models)
- Dependencies section
- Notes section
- History/change log

**Required Fields**:
- Status: ⭕ Not Started / ⏳ In Progress / ✅ Completed
- Priority: 🔴 Critical / 🟠 High / 🟡 Medium / 🟢 Low
- Story Points: Fibonacci scale (1, 2, 3, 5, 8, 13)
- Created date
- Updated date
- Assigned Sprint

**ID Format**: `FR-XXX` (e.g., FR-001, FR-042)

---

## 4. Bug Fix Template

**Location**: `project-management/artifacts/phase-5-management/backlog/product-backlog-structure.md` (Section: "Bug Fix Template")

**File Path Pattern**: `project-management/artifacts/phase-5-management/backlog/bug-fixes/BF-XXX-bug-description.md`

**Purpose**: Template for creating new bug fix documents in the product backlog.

**Use When**: Reporting a bug or creating a bug fix item in the backlog.

**Contains**:
- Bug fix header (ID, status, priority, story points, dates, assigned sprint)
- Description section
- Steps to reproduce
- Expected behavior
- Actual behavior
- Environment details (device, Android version, app version, OS)
- Screenshots/logs section
- Technical details
- Root cause analysis
- Solution section
- Reference documents
- Technical references (class/method, file, test)
- Testing checklist
- Notes section
- History/change log

**Required Fields**:
- Status: ⭕ Not Started / ⏳ In Progress / ✅ Completed
- Priority: 🔴 Critical / 🟠 High / 🟡 Medium / 🟢 Low
- Story Points: Fibonacci scale (1, 2, 3, 5, 8, 13)
- Created date
- Updated date
- Assigned Sprint
- Environment details

**ID Format**: `BF-XXX` (e.g., BF-001, BF-015)

---

## 5. Product Backlog Table Template

**Location**: `project-management/artifacts/phase-5-management/backlog/product-backlog-structure.md` (Section: "Product Backlog Table")

**File**: `project-management/artifacts/phase-5-management/backlog/product-backlog.md`

**Purpose**: Template for the main product backlog tracking table that lists all feature requests and bug fixes.

**Use When**: Updating the main product backlog table with new items.

**Contains**:
- Feature Requests table format
- Bug Fixes table format
- Column definitions:
  - ID (FR-XXX or BF-XXX)
  - Title
  - Priority (🔴 Critical / 🟠 High / 🟡 Medium / 🟢 Low)
  - Points (story points)
  - Status (⭕ Not Started / ⏳ In Progress / ✅ Completed)
  - Sprint (assigned sprint number or "Backlog")
  - Created (date)
  - Updated (date)

**Status Values**:
- ⭕ **Not Started**: Item not yet started
- ⏳ **In Progress**: Item currently being worked on
- ✅ **Completed**: Item finished and verified

**Priority Levels**:
- 🔴 **Critical**: Blocks core functionality, must be fixed immediately
- 🟠 **High**: Important feature, should be addressed soon
- 🟡 **Medium**: Nice to have, can wait
- 🟢 **Low**: Future consideration, low priority

**Notes Section References**:
- Feature request details: `feature-requests/FR-XXX-*.md` files
- Bug fix details: `bug-fixes/BF-XXX-*.md` files
- Sprint assignments: `../sprints/sprint-XX-*.md` files

---

## Template Usage Guidelines

### Creating a New Feature Request

1. Copy the Feature Request Template from `product-backlog-structure.md`
2. Assign unique ID: `FR-XXX` (use next available number)
3. Fill in all required fields
4. Save to: `backlog/feature-requests/FR-XXX-feature-name.md`
5. Add entry to `product-backlog.md` table
6. Update product backlog structure if needed

### Creating a New Bug Fix

1. Copy the Bug Fix Template from `product-backlog-structure.md`
2. Assign unique ID: `BF-XXX` (use next available number)
3. Fill in all required fields, especially:
   - Steps to reproduce
   - Expected vs. actual behavior
   - Environment details
4. Save to: `backlog/bug-fixes/BF-XXX-bug-description.md`
5. Add entry to `product-backlog.md` table
6. Update product backlog structure if needed

### Creating a New Sprint

1. Copy the Sprint Planning Template from `sprint-planning-template.md`
2. Update sprint number: `sprint-XX-*.md`
3. Fill in sprint header (goal, duration, velocity, dates)
4. Add user stories from backlog
5. Break down into tasks
6. Save to: `sprints/sprint-XX-sprint-name.md`

### Creating User Documentation

1. Copy the User Documentation Template from `user-documentation-template.md`
2. Customize sections for the specific feature or topic
3. Update paths and references as needed
4. Save to appropriate location (e.g., `app/docs/user-guide.md`)

---

## Related Documents

- **Backlog Management Process**: `backlog/backlog-management-process.md` - Process for managing backlog items
- **Product Backlog Structure**: `backlog/product-backlog-structure.md` - Complete structure documentation with all templates
- **Sprint Planning Template**: `sprints/sprint-planning-template.md` - Sprint planning template
- **Requirements**: `../../requirements.md` - Project requirements and CRISPE Framework standards

---

## Template Locations Summary

| Template | Location | Type |
|----------|----------|------|
| Sprint Planning | `sprints/sprint-planning-template.md` | Standalone file |
| User Documentation | `../../user-documentation-template.md` | Standalone file |
| Feature Request | `backlog/product-backlog-structure.md` | Embedded template |
| Bug Fix | `backlog/product-backlog-structure.md` | Embedded template |
| Product Backlog Table | `backlog/product-backlog-structure.md` | Embedded template |

---

**Note**: When using embedded templates (Feature Request, Bug Fix, Product Backlog Table), refer to the `product-backlog-structure.md` file for the complete template with examples.


