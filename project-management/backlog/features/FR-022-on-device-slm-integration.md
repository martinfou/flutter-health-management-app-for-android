# Feature Request: FR-022 - On-Device Small Language Model Integration

**Status**: ⭕ Not Started
**Priority**: 🟠 High
**Story Points**: 13
**Created**: 2026-01-03
**Updated**: 2026-01-03
**Assigned Sprint**: [Sprint 22](../../sprints/sprint-22-on-device-slm-integration.md)

## Description

Enable the app to run AI-powered features using on-device small language models (SLMs) available on modern mobile devices like Google Pixel 10 and other compatible Android phones. This provides offline AI capabilities for weekly reviews, food/recipe suggestions based on macros, and other LLM-powered features without requiring internet connectivity or external API costs.

The feature leverages Google's Gemini Nano (available on Pixel 8 Pro and later devices) and similar on-device AI capabilities, providing a privacy-focused, cost-free alternative to cloud-based LLM providers.

## User Story

As a mobile app user with a Pixel 10 or compatible Android device,
I want to use on-device AI for weekly reviews, food suggestions, and recipe recommendations based on my macros,
so that I can get personalized health insights without internet connectivity, API costs, or sending my health data to external servers.

## Acceptance Criteria

- [ ] Detect if device supports on-device SLM (Gemini Nano or compatible models)
- [ ] Add "On-Device AI" as a new LLM provider option in settings
- [ ] Weekly review insights work with on-device SLM
- [ ] Food suggestions based on remaining macros work with on-device SLM
- [ ] Recipe recommendations based on macros work with on-device SLM
- [ ] Graceful fallback to cloud LLM if on-device AI is unavailable
- [ ] Show indicator when using on-device vs cloud AI
- [ ] On-device AI works completely offline
- [ ] Response quality is acceptable for health coaching use cases
- [ ] Performance is acceptable (responses within reasonable time)
- [ ] Battery impact is documented and reasonable
- [ ] User can choose to prefer on-device AI for all features when available

## Business Value

- **Privacy First**: User health data never leaves the device when using on-device AI
- **Zero API Costs**: No recurring costs for AI features after implementation
- **Offline Capability**: Users can get AI insights anywhere, without internet
- **Faster Responses**: No network latency for AI queries
- **Competitive Advantage**: Differentiates from apps requiring cloud AI
- **User Trust**: Privacy-conscious users prefer local processing
- **Battery Efficiency**: Modern on-device models are optimized for mobile hardware

## Technical Requirements

### Device Compatibility
- **Google Pixel 8 Pro, Pixel 9, Pixel 10**: Gemini Nano via AI Core
- **Samsung Galaxy S24+**: On-device Galaxy AI models
- **Other Android devices**: Potential support via MediaPipe LLM or similar

### Android AI Core Integration
- Use Android AICore APIs for Gemini Nano access
- Detect AICore availability at runtime
- Handle model download/initialization
- Manage model lifecycle (load/unload for memory)

### Implementation Approach
1. **Create OnDeviceLlmAdapter**:
   - Implement `LlmProvider` interface (existing abstraction from FR-010)
   - Use Android AI Core APIs via platform channels
   - Handle Gemini Nano text generation
   - Implement capability detection

2. **Platform Channel Bridge**:
   - Create Flutter-to-Native bridge for AI Core
   - Handle async model loading
   - Stream responses for better UX
   - Proper error handling for unsupported devices

3. **Prompt Optimization for SLM**:
   - Optimize prompts for smaller model context windows
   - Keep prompts concise while maintaining quality
   - Test and tune for Gemini Nano capabilities
   - May need different prompts than cloud models

4. **Feature-Specific Integration**:
   - Weekly Review: Summarize week's data, provide insights
   - Food Suggestions: Recommend foods to meet remaining macros
   - Recipe Suggestions: Generate or suggest recipes for macro targets
   - All features should work interchangeably with cloud or on-device AI

### Fallback Strategy
- Primary: On-device SLM (if available and user preference)
- Fallback: Cloud LLM provider (Ollama, DeepSeek, etc.)
- Graceful degradation with user notification
- Allow user to set preference hierarchy

### Performance Requirements
- Model initialization: < 5 seconds
- Response generation: < 10 seconds for typical queries
- Memory usage: Minimal background footprint
- Battery: Comparable to other AI apps using on-device models

## Reference Documents

- FR-010 - LLM Integration (existing provider abstraction)
- Android AI Core documentation
- Gemini Nano on-device capabilities
- MediaPipe LLM Inference API documentation

## Technical References

- LLM Provider Interface: `lib/core/llm/llm_provider.dart`
- Existing Adapters: `lib/core/llm/adapters/`
- LLM Settings: `lib/features/llm_integration/presentation/pages/llm_settings_page.dart`
- Weekly Review Use Case: (existing in FR-010 implementation)
- Food Suggestion Use Case: (existing in FR-004 implementation)

## Dependencies

- FR-010 - LLM Integration (✅ Completed - provides abstraction layer)
- FR-004 - Food Suggestion Based on Remaining Macros (✅ Completed)
- Android AI Core availability (Pixel 8 Pro+, Android 14+)
- Flutter platform channel implementation for native AI APIs

## Notes

### Supported Devices (as of 2026)
- **Full Support (Gemini Nano)**:
  - Google Pixel 8 Pro, Pixel 9, Pixel 9 Pro, Pixel 9 Pro XL, Pixel 10
  - Requires Android 14+ with AI Core
- **Potential Future Support**:
  - Samsung Galaxy S24+ (Galaxy AI)
  - Other flagship devices with NPU/AI accelerators

### Model Capabilities
- Gemini Nano is optimized for on-device use
- Smaller context window than cloud models
- Best for summarization, simple Q&A, short-form generation
- May need prompt engineering for complex health insights

### Privacy Considerations
- All processing happens on-device
- No data sent to external servers
- Perfect for users with strict privacy requirements
- Consider making this the default for privacy-conscious users

### Future Enhancements
- Custom fine-tuned health coaching model (if supported)
- Multi-modal support (food photo analysis with on-device vision)
- Voice interaction for hands-free health queries
- Widget support for quick on-device insights

### Testing Strategy
- Requires physical Pixel 8 Pro+ device for testing
- Consider Android emulator with AI Core simulation
- Test degradation on unsupported devices
- Benchmark response quality vs cloud models

## History

- 2026-01-03 - Created based on user request for on-device AI using Pixel 10/compatible mobile devices for weekly reviews, food/recipe suggestions
- 2026-01-03 - Assigned to Sprint 22, sprint planning document created

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
- [x] File is saved with correct naming convention
- [x] Entry is added to product backlog table
