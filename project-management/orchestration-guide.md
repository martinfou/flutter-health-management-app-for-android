# Orchestration Guide: Flutter Health Management App for Android

This guide provides step-by-step instructions for an LLM to execute the complete orchestration and generate all required artifacts for the Flutter Health Management App for Android.

## Overview

This orchestration generates comprehensive documentation for a Flutter mobile application targeting Android that helps users manage their global health with a primary focus on weight loss. The orchestration produces architecture documentation, UI/UX designs, data models, feature specifications, testing strategies, and implementation guides for an MVP that includes a subset of core health management modules.

## Execution Instructions for LLM

You are executing a multi-persona orchestration. Follow these steps sequentially, executing each persona in order. Each persona will read input artifacts and generate output artifacts according to the orchestration definition.

### Prerequisites

Before starting, verify:
- [ ] You have access to `artifacts/orchestration-definition.md`
- [ ] You have access to `artifacts/requirements.md`
- [ ] You have access to `artifacts/organization-schema.md`
- [ ] All phase folders exist in `artifacts/` directory
- [ ] `artifacts/orchestration-analysis-report/` folder exists
- [ ] `artifacts/final-product/` folder exists

### Execution Sequence

Execute personas in the exact order specified below. Each persona must complete before the next begins.

#### Step 1: Flutter Architect & Developer

**Persona File**: `personas/01-flutter-architect-developer.md`

**Action**: Read the persona file and execute it. This persona will:
- Read `artifacts/requirements.md` and `artifacts/orchestration-definition.md`
- Design Feature-First Clean Architecture structure
- Define project structure and folder organization
- Configure Riverpod state management
- Design LLM API abstraction layer (post-MVP)
- Define git commit message standards and git workflow process

**Expected Outputs**:
- `artifacts/phase-1-foundations/architecture-documentation.md`
- `artifacts/phase-1-foundations/project-structure-specification.md`

**Verification**: Check that both files are created in `artifacts/phase-1-foundations/` folder.

#### Step 2: UI/UX Designer

**Persona File**: `personas/02-ui-ux-designer.md`

**Action**: Read the persona file and execute it. This persona will:
- Read `artifacts/requirements.md` and `artifacts/phase-1-foundations/architecture-documentation.md`
- Create 3-4 design system options for user selection
- Design wireframes and user flows for all app screens
- Create component specifications with ASCII art representations
- Define accessibility requirements (WCAG 2.1 AA)

**Expected Outputs**:
- `artifacts/phase-1-foundations/design-system-options.md`
- `artifacts/phase-1-foundations/wireframes.md`
- `artifacts/phase-1-foundations/component-specifications.md`

**Verification**: Check that all three files are created in `artifacts/phase-1-foundations/` folder. All mockups must use ASCII art format.

#### Step 3: Data Architect & Backend Specialist

**Persona File**: `personas/03-data-architect-backend-specialist.md`

**Action**: Read the persona file and execute it. This persona will:
- Read `artifacts/requirements.md`, `artifacts/phase-1-foundations/architecture-documentation.md`, and `artifacts/phase-1-foundations/health-domain-specifications.md` (if available)
- Design Hive database schema for local storage
- Create data models and entity definitions
- Design data access layer following Clean Architecture
- Define data validation and sanitization rules
- Design post-MVP sync architecture (DreamHost PHP/MySQL, Slim Framework)

**Expected Outputs**:
- `artifacts/phase-1-foundations/database-schema.md`
- `artifacts/phase-1-foundations/data-models.md`
- `artifacts/phase-3-integration/sync-architecture-design.md`

**Verification**: Check that database-schema.md and data-models.md are in `artifacts/phase-1-foundations/`, and sync-architecture-design.md is in `artifacts/phase-3-integration/`.

#### Step 4: Health Domain Expert

**Persona File**: `personas/04-health-domain-expert.md`

**Action**: Read the persona file and execute it. This persona will:
- Read `artifacts/requirements.md` and reference material from `reference-material/artifacts/`
- Translate reference material into app feature specifications
- Define health metric tracking logic (7-day moving averages, plateau detection)
- Create clinical safety protocols and alert systems with specific thresholds
- Define medication management workflows

**Expected Outputs**:
- `artifacts/phase-1-foundations/health-domain-specifications.md`
- `artifacts/phase-1-foundations/clinical-safety-protocols.md`

**Verification**: Check that both files are created in `artifacts/phase-1-foundations/` folder.

#### Step 5: Feature Module Developer (Health Tracking)

**Persona File**: `personas/05-feature-module-developer-health-tracking.md`

**Action**: Read the persona file and execute it. This persona will:
- Read `artifacts/requirements.md`, `artifacts/phase-1-foundations/architecture-documentation.md`, `artifacts/phase-1-foundations/data-models.md`, and `artifacts/phase-1-foundations/health-domain-specifications.md`
- Create detailed health tracking module specifications
- Specify weight tracking, body measurements, sleep, energy, heart rate features
- Create data visualization component specifications
- Implement KPI tracking and progress photo management specifications

**Expected Outputs**:
- `artifacts/phase-2-features/health-tracking-module-specification.md`

**Verification**: Check that the file is created in `artifacts/phase-2-features/` folder.

#### Step 6: Feature Module Developer (Nutrition & Exercise)

**Persona File**: `personas/06-feature-module-developer-nutrition-exercise.md`

**Action**: Read the persona file and execute it. This persona will:
- Read `artifacts/requirements.md`, `artifacts/phase-1-foundations/architecture-documentation.md`, `artifacts/phase-1-foundations/data-models.md`, and `artifacts/phase-1-foundations/health-domain-specifications.md`
- Create detailed nutrition module specifications (macro tracking, meal planning, recipe database)
- Create detailed exercise module specifications (workout plans, activity tracking)
- Specify Google Fit/Health Connect integration requirements

**Expected Outputs**:
- `artifacts/phase-2-features/nutrition-module-specification.md`
- `artifacts/phase-2-features/exercise-module-specification.md`

**Verification**: Check that both files are created in `artifacts/phase-2-features/` folder.

#### Step 7: Integration & Platform Specialist

**Persona File**: `personas/07-integration-platform-specialist.md`

**Action**: Read the persona file and execute it. This persona will:
- Read `artifacts/requirements.md`, `artifacts/phase-1-foundations/architecture-documentation.md`, and feature specifications from `artifacts/phase-2-features/`
- Create integration specifications (Google Fit, Health Connect, manual sale entry)
- Create platform specifications (Android features, permissions)
- Design LLM API abstraction layer architecture (post-MVP)
- Implement notification system specifications

**Expected Outputs**:
- `artifacts/phase-3-integration/integration-specifications.md`
- `artifacts/phase-3-integration/platform-specifications.md`

**Verification**: Check that both files are created in `artifacts/phase-3-integration/` folder.

#### Step 8: QA & Testing Specialist

**Persona File**: `personas/08-qa-testing-specialist.md`

**Action**: Read the persona file and execute it. This persona will:
- Read `artifacts/requirements.md`, `artifacts/phase-1-foundations/architecture-documentation.md`, all feature specifications, and integration specifications
- Create comprehensive testing strategy (80% unit, 60% widget coverage)
- Write test specifications for all modules
- Define test data and mock objects
- Create testing automation frameworks specifications

**Expected Outputs**:
- `artifacts/phase-4-testing/testing-strategy.md`
- `artifacts/phase-4-testing/test-specifications.md`

**Verification**: Check that both files are created in `artifacts/phase-4-testing/` folder.

#### Step 9: Scrum Master

**Persona File**: `personas/09-scrum-master.md`

**Action**: Read the persona file and execute it. This persona will:
- Read `artifacts/requirements.md` and all specifications from previous phases
- Create sprint planning template using CRISPE Framework
- Create product backlog structure with feature request and bug fix templates
- Define backlog management process

**Expected Outputs**:
- `artifacts/phase-5-management/sprint-planning-template.md`
- `artifacts/phase-5-management/product-backlog-structure.md`
- `artifacts/phase-5-management/backlog-management-process.md`

**Verification**: Check that all three files are created in `artifacts/phase-5-management/` folder.

#### Step 10: Orchestrator

**Persona File**: `personas/10-orchestrator.md`

**Action**: Read the persona file and execute it. This persona will:
- Read all artifacts from all phases (phase-1-foundations through phase-5-management)
- Compile executive summary with main information from each artifact
- Generate project status dashboard showing overall orchestration progress

**Expected Outputs**:
- `artifacts/orchestration-analysis-report/project-summary.md`
- `artifacts/orchestration-analysis-report/status-dashboard.md`

**Verification**: Check that both files are created in `artifacts/orchestration-analysis-report/` folder.

#### Step 11: Analyst

**Persona File**: `personas/11-analyst.md`

**Action**: Read the persona file and execute it. This persona will:
- Read all artifacts from all phases and `artifacts/orchestration-analysis-report/project-summary.md`
- Analyze all artifacts for contradictions, gaps, and quality issues
- Perform gap analysis
- Create quality metrics and completeness scoring
- Generate risk assessment with mitigation strategies
- Produce prioritized recommendations with implementation roadmaps

**Expected Outputs**:
- `artifacts/orchestration-analysis-report/gap-analysis.md`
- `artifacts/orchestration-analysis-report/quality-metrics.md`
- `artifacts/orchestration-analysis-report/risk-assessment.md`
- `artifacts/orchestration-analysis-report/recommendations.md`

**Verification**: Check that all four files are created in `artifacts/orchestration-analysis-report/` folder.

#### Step 12: Compiler

**Persona File**: `personas/12-compiler.md`

**Action**: Read the persona file and execute it. This persona will:
- Read all artifacts from all phases and analysis reports
- Compile all artifacts into unified final product
- Ensure consistent tone and language level
- Create polished documentation structure with navigation

**Expected Outputs**:
- `artifacts/final-product/README.md`
- `artifacts/final-product/executive-summary.md`
- `artifacts/final-product/complete-report.md`

**Verification**: Check that all three files are created in `artifacts/final-product/` folder.

## Artifact Organization

All artifacts are organized according to `artifacts/organization-schema.md` using a phase-based structure:

- **Phase 1: Foundations** - Architecture, design, data, domain
- **Phase 2: Features** - Feature module specifications
- **Phase 3: Integration** - Integration and platform specifications
- **Phase 4: Testing** - Testing strategy and specifications
- **Phase 5: Management** - Project management documentation
- **Orchestration Analysis Report** - Analysis and coordination artifacts
- **Final Product** - Compiled final deliverables

## Important Notes

1. **File Paths**: All file references use relative paths from the orchestration directory. Use `artifacts/` not root-relative paths.

2. **Organization Schema**: Check `artifacts/organization-schema.md` for exact artifact locations. Artifacts are organized by phase.

3. **Special Folders**:
   - Orchestrator and Analyst artifacts go to `artifacts/orchestration-analysis-report/`
   - Compiler artifacts go to `artifacts/final-product/`
   - Standard personas follow phase organization

4. **ASCII Art for UI/UX**: All UI/UX mockups must use ASCII art format in markdown files, not image files.

5. **Mermaid.js for Diagrams**: Use Mermaid.js syntax for architecture diagrams, flowcharts, and technical diagrams.

6. **Sequential Execution**: Execute personas in order. Each persona depends on outputs from previous personas.

7. **Definition of Done**: Each persona file includes a "Definition of Done" checklist. Verify all items are complete before proceeding.

## Completion Verification

After executing all personas, verify:

- [ ] All phase-1-foundations artifacts are created (8 files)
- [ ] All phase-2-features artifacts are created (3 files)
- [ ] All phase-3-integration artifacts are created (3 files)
- [ ] All phase-4-testing artifacts are created (2 files)
- [ ] All phase-5-management artifacts are created (3 files)
- [ ] All orchestration-analysis-report artifacts are created (6 files)
- [ ] All final-product artifacts are created (3 files)
- [ ] Total: 28 artifacts (plus requirements.md, orchestration-definition.md, organization-schema.md)

## Getting Help

If you encounter issues:
1. Review the persona file for specific instructions
2. Check `artifacts/orchestration-definition.md` for orchestration structure
3. Check `artifacts/organization-schema.md` for artifact locations
4. Verify all input files exist before executing a persona

---

**Ready to Execute**: Begin with Step 1 (Flutter Architect & Developer) and proceed sequentially through all 12 steps.

