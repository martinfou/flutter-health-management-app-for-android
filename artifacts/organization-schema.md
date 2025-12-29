# Artifact Organization Schema

**Orchestration**: Flutter Health Management App for Android  
**Organization Method**: By Phase  
**Selected Option**: Option 3

## Overview

Artifacts are organized by development phase to reflect the natural workflow and progression of the project. This structure groups artifacts according to when they are created in the development lifecycle, making it easy to understand the project's evolution and find artifacts based on development stage.

## Folder Structure

```
artifacts/
├── requirements.md
├── orchestration-definition.md
├── organization-schema.md
├── phase-1-foundations/
│   ├── architecture-documentation.md
│   ├── project-structure-specification.md
│   ├── design-system-options.md
│   ├── wireframes.md
│   ├── component-specifications.md
│   ├── database-schema.md
│   ├── data-models.md
│   ├── health-domain-specifications.md
│   └── clinical-safety-protocols.md
├── phase-2-features/
│   ├── health-tracking-module-specification.md
│   ├── nutrition-module-specification.md
│   └── exercise-module-specification.md
├── phase-3-integration/
│   ├── integration-specifications.md
│   ├── platform-specifications.md
│   └── sync-architecture-design.md
├── phase-4-testing/
│   ├── testing-strategy.md
│   └── test-specifications.md
├── phase-5-management/
│   ├── sprint-planning-template.md
│   ├── product-backlog-structure.md
│   └── backlog-management-process.md
├── orchestration-analysis-report/
│   ├── project-summary.md
│   ├── status-dashboard.md
│   ├── gap-analysis.md
│   ├── quality-metrics.md
│   ├── risk-assessment.md
│   └── recommendations.md
└── final-product/
    ├── README.md
    ├── executive-summary.md
    └── complete-report.md
```

## Phase Definitions

### Phase 1: Foundations
**Purpose**: Core architectural and design foundations that all other work builds upon.

**Contains**:
- Architecture documentation and project structure
- Design system, wireframes, and component specifications
- Database schema and data models
- Health domain specifications and clinical safety protocols

**Personas**:
- Flutter Architect & Developer
- UI/UX Designer
- Data Architect & Backend Specialist
- Health Domain Expert

### Phase 2: Features
**Purpose**: Feature module specifications for core app functionality.

**Contains**:
- Health tracking module specification
- Nutrition module specification
- Exercise module specification

**Personas**:
- Feature Module Developer (Health Tracking)
- Feature Module Developer (Nutrition & Exercise)

### Phase 3: Integration
**Purpose**: Integration and platform-specific specifications.

**Contains**:
- Integration specifications (Google Fit, Health Connect, etc.)
- Platform specifications (Android-specific features, permissions)
- Sync architecture design (post-MVP)

**Personas**:
- Integration & Platform Specialist

### Phase 4: Testing
**Purpose**: Testing strategy and specifications.

**Contains**:
- Testing strategy documentation
- Test specifications for all modules

**Personas**:
- QA & Testing Specialist

### Phase 5: Management
**Purpose**: Project management and process documentation.

**Contains**:
- Sprint planning templates
- Product backlog structure
- Backlog management process

**Personas**:
- Scrum Master

### Orchestration Analysis Report
**Purpose**: Analysis and coordination artifacts from Orchestrator and Analyst personas.

**Contains**:
- Project summary
- Status dashboard
- Gap analysis
- Quality metrics
- Risk assessment
- Recommendations

**Personas**:
- Orchestrator
- Analyst

### Final Product
**Purpose**: Compiled final deliverables from Compiler persona.

**Contains**:
- README with navigation
- Executive summary
- Complete compiled report

**Personas**:
- Compiler

## Artifact Mapping Rules

### Core Documents (Root of artifacts/)
- `requirements.md` - User requirements and discovery answers
- `orchestration-definition.md` - Orchestration structure and sequence
- `organization-schema.md` - This document

### Phase 1: Foundations
- **Flutter Architect & Developer** → `phase-1-foundations/architecture-documentation.md`, `phase-1-foundations/project-structure-specification.md`
- **UI/UX Designer** → `phase-1-foundations/design-system-options.md`, `phase-1-foundations/wireframes.md`, `phase-1-foundations/component-specifications.md`
- **Data Architect & Backend Specialist** → `phase-1-foundations/database-schema.md`, `phase-1-foundations/data-models.md`
- **Health Domain Expert** → `phase-1-foundations/health-domain-specifications.md`, `phase-1-foundations/clinical-safety-protocols.md`

**Note**: `sync-architecture-design.md` from Data Architect & Backend Specialist goes to `phase-3-integration/` (it's a post-MVP integration concern).

### Phase 2: Features
- **Feature Module Developer (Health Tracking)** → `phase-2-features/health-tracking-module-specification.md`
- **Feature Module Developer (Nutrition & Exercise)** → `phase-2-features/nutrition-module-specification.md`, `phase-2-features/exercise-module-specification.md`

### Phase 3: Integration
- **Integration & Platform Specialist** → `phase-3-integration/integration-specifications.md`, `phase-3-integration/platform-specifications.md`
- **Data Architect & Backend Specialist** → `phase-3-integration/sync-architecture-design.md` (post-MVP sync architecture)

### Phase 4: Testing
- **QA & Testing Specialist** → `phase-4-testing/testing-strategy.md`, `phase-4-testing/test-specifications.md`

### Phase 5: Management
- **Scrum Master** → `phase-5-management/sprint-planning-template.md`, `phase-5-management/product-backlog-structure.md`, `phase-5-management/backlog-management-process.md`

### Orchestration Analysis Report
- **Orchestrator** → `orchestration-analysis-report/project-summary.md`, `orchestration-analysis-report/status-dashboard.md`
- **Analyst** → `orchestration-analysis-report/gap-analysis.md`, `orchestration-analysis-report/quality-metrics.md`, `orchestration-analysis-report/risk-assessment.md`, `orchestration-analysis-report/recommendations.md`

### Final Product
- **Compiler** → `final-product/README.md`, `final-product/executive-summary.md`, `final-product/complete-report.md`

## Naming Conventions

### File Names
- Use **kebab-case** (lowercase with hyphens): `health-tracking-module-specification.md`
- Be descriptive and specific: `database-schema.md` not `schema.md`
- Include file extension: `.md` for markdown files
- Use consistent terminology matching orchestration definition

### Folder Names
- Use **kebab-case**: `phase-1-foundations/`
- Follow phase naming: `phase-{number}-{name}/`
- Special folders: `orchestration-analysis-report/`, `final-product/`

### Artifact References
- When referencing artifacts in documents, use relative paths: `phase-1-foundations/architecture-documentation.md`
- Cross-phase references are allowed and encouraged when dependencies exist

## Instructions for Personas

### General Guidelines
1. **Read this schema** before creating artifacts to understand where to place outputs
2. **Use exact folder paths** as specified in the Artifact Mapping Rules section
3. **Create folders if they don't exist** when writing artifacts
4. **Follow naming conventions** exactly as specified
5. **Reference input artifacts** using relative paths from the artifacts/ root

### Phase-Specific Instructions

#### Phase 1: Foundations
- Place all foundational architecture, design, data, and domain artifacts in `phase-1-foundations/`
- These artifacts form the base that all other phases build upon
- Ensure cross-references between architecture, design, and data models are clear

#### Phase 2: Features
- Place all feature module specifications in `phase-2-features/`
- Reference Phase 1 artifacts (architecture, data models, domain specs) as inputs
- Each feature module should be self-contained but reference foundational documents

#### Phase 3: Integration
- Place integration and platform specifications in `phase-3-integration/`
- Include post-MVP sync architecture here (it's an integration concern)
- Reference Phase 2 feature specifications as inputs

#### Phase 4: Testing
- Place all testing documentation in `phase-4-testing/`
- Reference artifacts from all previous phases as test targets
- Testing strategy should cover all modules and phases

#### Phase 5: Management
- Place project management artifacts in `phase-5-management/`
- These are process documents that apply to the entire project
- Reference all previous phases when creating sprint plans and backlog structure

### Special Folders

#### orchestration-analysis-report/
- **Orchestrator**: Place project summary and status dashboard here
- **Analyst**: Place gap analysis, quality metrics, risk assessment, and recommendations here
- These artifacts analyze and coordinate the entire orchestration

#### final-product/
- **Compiler**: Place all compiled final deliverables here
- This folder contains the polished, unified final product
- Include navigation and cross-references to all phases

## Rationale

**Why Phase-Based Organization?**

1. **Workflow Alignment**: Matches the natural development progression from foundations → features → integration → testing → management
2. **Dependency Clarity**: Makes it clear which artifacts depend on earlier phases
3. **Progressive Understanding**: Easy to see how the project evolves through phases
4. **Logical Grouping**: Related artifacts are grouped by when they're created in the lifecycle
5. **Scalability**: Easy to add new phases or artifacts within existing phases

**When to Use This Organization**:
- Projects with clear development phases
- When you want to understand project progression
- When dependencies between phases are important
- When organizing by development lifecycle makes sense

## Cross-Phase References

Artifacts in later phases should reference artifacts from earlier phases when dependencies exist. Use relative paths:

- From Phase 2: `../phase-1-foundations/architecture-documentation.md`
- From Phase 3: `../phase-1-foundations/data-models.md`, `../phase-2-features/health-tracking-module-specification.md`
- From Phase 4: Reference all previous phases as test targets
- From Phase 5: Reference all phases when creating sprint plans

## Validation

Before finalizing artifacts, verify:
- [ ] Artifact is placed in the correct phase folder
- [ ] File name follows kebab-case naming convention
- [ ] Folder path matches the Artifact Mapping Rules
- [ ] Cross-references use correct relative paths
- [ ] All required artifacts for the phase are present

---

**Last Updated**: [Date]  
**Orchestration**: Flutter Health Management App for Android  
**Organization Method**: By Phase (Option 3)

