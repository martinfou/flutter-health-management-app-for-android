# Claude Code Project Configuration

This file provides context and conventions for Claude Code when working on this project.

## Project Overview

Flutter health management app for Android that helps users track nutrition, exercise, health metrics, and provides AI-powered insights.

## Key Directories

- `app/` - Main Flutter application code
- `project-management/` - Backlog, sprints, feature requests, bug fixes
- `mock-server/` - Development mock server

## Git Commit Message Format

**Always follow this format for commit messages:**

```
<FR-XXX or BF-XXX>: <Short business description (50-72 characters)>

<Business description paragraph explaining what changed and why from a business/user perspective. 1-3 sentences.>

Technical changes for developers:
- <Specific technical change 1>
- <Specific technical change 2>
- <Specific technical change 3>

Refs <FR-XXX or BF-XXX>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

### Commit Message Guidelines

1. **Title Line**: Start with task number (FR-XXX or BF-XXX), use imperative mood, max 72 chars
2. **Business Description**: Explain the "what" and "why" from user/business perspective
3. **Technical Changes**: List specific code changes in bullet points
4. **References**: Add "Refs FR-XXX" at end

### Example

```
FR-022: Add on-device SLM feature request and sprint planning

Created feature request for on-device small language model integration enabling offline AI capabilities on Pixel 10 and compatible Android devices. Added Sprint 22 planning with detailed task breakdown for platform channel, adapter, prompts, and UI work.

Technical changes for developers:
- Added FR-022-on-device-slm-integration.md feature request
- Created sprint-22-on-device-slm-integration.md sprint plan
- Updated product-backlog.md with FR-022 entry

Refs FR-022

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

## Project Management Templates

- Feature Request: `project-management/docs/templates/feature-request-template.md`
- Bug Fix: `project-management/docs/templates/bug-fix-template.md`
- Sprint Planning: `project-management/docs/templates/sprint-planning-template.md`
- Git Commit: `project-management/docs/templates/git-commit-template.md`

## Backlog Management

- Product Backlog: `project-management/backlog/product-backlog.md`
- Feature Requests: `project-management/backlog/features/FR-XXX-*.md`
- Bug Fixes: `project-management/backlog/bug-fixes/BF-XXX-*.md`
- Sprints: `project-management/sprints/sprint-XX-*.md`

## Technical Standards

- **Authentication**: Google OAuth (see backlog-management-process.md)
- **LLM Integration**: Provider pattern with adapters (see lib/core/llm/)
- **State Management**: Riverpod
- **Architecture**: Clean Architecture with feature-based organization

## Status Indicators

- ⭕ Not Started
- ⏳ In Progress
- ✅ Completed

## Priority Levels

- 🔴 Critical
- 🟠 High
- 🟡 Medium
- 🟢 Low
