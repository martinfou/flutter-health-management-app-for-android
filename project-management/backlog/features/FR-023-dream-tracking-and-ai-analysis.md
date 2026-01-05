# Feature Request: FR-023 - Dream Tracking and AI Analysis

**Status**: ⭕ Not Started  
**Priority**: 🟡 Medium  
**Story Points**: 8  
**Created**: 2026-01-03  
**Updated**: 2026-01-03  
**Assigned Sprint**: Backlog  

## Description

Enable users to record their dreams in a personal dream journal and receive AI-powered analysis and insights. This feature helps users track sleep-related experiences, identify patterns, and gain insights into potential connections between dreams, sleep quality, stress levels, and overall health. The AI analysis provides personalized interpretations and highlights potential correlations with tracked health metrics.

## User Story

As a health-conscious user tracking my sleep quality and overall wellness,
I want to record my dreams and receive AI-powered analysis and insights,
so that I can better understand connections between my dreams, sleep patterns, stress levels, and overall health, and identify patterns that may impact my wellness journey.

## Acceptance Criteria

- [ ] Users can create and save dream entries with date/time, title, and description
- [ ] Dream entries are stored locally using Hive database
- [ ] Users can view a list of their dream entries (chronological order, newest first)
- [ ] Users can edit and delete existing dream entries
- [ ] AI analysis is generated for each dream entry using the existing LLM integration
- [ ] AI analysis provides insights including:
  - Themes and patterns identified in the dream
  - Potential connections to sleep quality, stress, or health metrics
  - Suggestions for reflection or action items (if applicable)
- [ ] Users can view AI analysis for individual dreams
- [ ] Users can request re-analysis of a dream entry
- [ ] Dream entries are searchable by keywords
- [ ] Dream entries can be filtered by date range
- [ ] Dream entries are linked to sleep quality data (if available for that date)
- [ ] UI follows Material Design 3 principles and accessibility standards
- [ ] All data is stored locally (no cloud sync required for MVP)

## Business Value

- **Holistic Health Tracking**: Expands the app beyond physical metrics to include mental/emotional wellness indicators
- **Sleep Quality Insights**: Dream patterns can provide additional context for sleep quality tracking
- **User Engagement**: Personalized AI insights increase app engagement and user value
- **Differentiation**: Dream tracking with AI analysis is uncommon in health apps, providing a unique feature
- **Stress Correlation**: Dreams often reflect stress levels, which can correlate with health metrics and weight management
- **User Retention**: Journaling features encourage daily app usage and habit formation

## Technical Requirements

### Data Model
- Create `DreamEntry` entity in domain layer
- Fields:
  - `id` (String/UUID)
  - `dateTime` (DateTime)
  - `title` (String, optional)
  - `description` (String, required)
  - `analysis` (String, nullable - stores AI analysis result)
  - `analysisDate` (DateTime, nullable - when analysis was generated)
  - `sleepQualityId` (String, nullable - link to sleep quality entry if available)

### Database (Hive)
- Create `DreamEntry` Hive model with TypeAdapter
- Store in `dream_entries` box
- Index by date for efficient filtering and sorting

### Architecture
- Follow feature-first clean architecture pattern:
  - `lib/features/dream_tracking/data/` - Data layer (models, repositories, datasources)
  - `lib/features/dream_tracking/domain/` - Domain layer (entities, repositories, usecases)
  - `lib/features/dream_tracking/presentation/` - Presentation layer (pages, widgets, providers)

### AI Analysis Integration
- Leverage existing LLM integration (FR-010 - ✅ Completed)
- Create use case: `AnalyzeDreamUseCase`
- Use existing `LlmProvider` interface
- Prompt engineering for dream analysis:
  - Include dream description
  - Optionally include sleep quality data for that date (if available)
  - Request analysis focusing on themes, patterns, and potential health connections
  - Keep analysis concise and actionable

### UI Components
- **Dream List Page**: Display list of dream entries with date, title preview, analysis status
- **Dream Entry Page**: Full view with description and AI analysis
- **Create/Edit Dream Page**: Form for entering/editing dream details
- **Dream Analysis Widget**: Display AI analysis with proper formatting

### State Management
- Use Riverpod for state management
- Providers for:
  - Dream entries list
  - Individual dream entry
  - AI analysis generation
  - Search and filter state

### Performance Requirements
- List should handle 100+ entries efficiently (use ListView.builder)
- AI analysis generation should show loading state
- Analysis results should be cached (stored with dream entry)
- Re-analysis should be possible but limited (rate limiting consideration)

## Reference Documents

- FR-010 - LLM Integration (provides AI analysis infrastructure)
- Architecture documentation - Feature-first clean architecture pattern
- Hive database documentation - Local storage implementation

## Technical References

- LLM Provider Interface: `lib/core/llm/llm_provider.dart`
- LLM Adapters: `lib/core/llm/adapters/`
- Health Tracking Feature: `lib/features/health_tracking/` (reference for data model and UI patterns)
- Hive Models: `lib/core/database/models/` (reference for Hive TypeAdapter implementation)
- Sleep Quality Tracking: `lib/features/health_tracking/` (reference for sleep quality data structure)

## Dependencies

- FR-010 - LLM Integration (✅ Completed - provides AI analysis infrastructure)
- Hive database setup (already implemented in app)
- Health Tracking feature (for sleep quality data correlation - optional but valuable)

## Notes

### MVP Scope
- Local-only storage (no cloud sync)
- Basic dream entry CRUD operations
- AI analysis using existing LLM providers
- Simple list and detail views
- Basic search and filter functionality

### Future Enhancements (Post-MVP)
- Dream pattern analytics (identify recurring themes over time)
- Correlation analysis with health metrics (automatic pattern detection)
- Dream tags/categories for better organization
- Export functionality (share dreams as text/markdown)
- Dream reminders/notifications (prompt users to record dreams)
- Voice input for dream recording
- Photo attachments (if users want to include dream-related images)
- Integration with sleep tracking devices (if available)
- Cloud sync support (when FR-008 is implemented)

### Privacy Considerations
- Dreams are highly personal and sensitive data
- All data stored locally (MVP)
- No cloud sync without explicit user consent
- Consider encryption at rest for dream entries
- Clear privacy policy regarding AI analysis (data sent to LLM providers)

### AI Analysis Considerations
- Dream interpretation is subjective - AI analysis should be presented as insights, not definitive interpretations
- Consider prompt engineering to avoid overly psychological or clinical interpretations
- Focus on patterns, themes, and potential health connections rather than deep psychoanalysis
- Respect user privacy - dream content is sensitive
- Consider cost implications of AI analysis (may want to limit re-analysis requests)

### Integration with Sleep Tracking
- Link dreams to sleep quality entries when available
- Show sleep quality metrics alongside dream entries
- AI analysis can reference sleep quality in insights
- Consider bidirectional links (sleep quality entry shows "Dream recorded" indicator)

### UX Considerations
- Make dream entry quick and easy (many users record dreams immediately upon waking)
- Consider rich text formatting for dream descriptions (though simple text may be better for MVP)
- Analysis should be clearly separated from user's dream description
- Loading states for AI analysis generation
- Error handling for AI analysis failures (graceful degradation)

## History

- 2026-01-03 - Created based on user request for dream tracking with AI analysis

---

## Template Validation Checklist

- [x] All required fields are filled (Status, Priority, Story Points, Dates)
- [x] User story follows "As a... I want... So that..." format
- [x] At least 3 acceptance criteria are defined
- [x] Acceptance criteria are specific and testable
- [x] Business value is clearly documented
- [x] Technical requirements are specified
- [x] Dependencies are identified
- [x] Story points are estimated using Fibonacci sequence
- [x] Priority is assigned based on business value and urgency
- [x] Technical references are included
- [x] File is saved with correct naming convention: `FR-023-dream-tracking-and-ai-analysis.md`
- [ ] Entry is added to product backlog table

