# Bug Fix: BF-004 - LLM Selection Always Defaults to On-Device Instead of Selected Provider

**Status**: ✅ Completed  
**Priority**: 🟠 High  
**Story Points**: 5  
**Created**: 2026-01-17  
**Updated**: 2026-01-17  
**Assigned Sprint**: Current  

## Description

Mobile application always defaults to on-device LLM (Gemini Nano) when DeepSeek is selected as the default LLM provider.

## Steps to Reproduce

1. Navigate to LLM settings in the app
2. Select DeepSeek as the default LLM provider
3. Save the settings
4. Use any LLM feature (e.g., AI suggestions, chat)
5. Check application logs
6. Observe that Gemini Nano is used instead of DeepSeek

## Expected Behavior

The app should use the selected LLM provider (DeepSeek) when making LLM requests.

## Actual Behavior

Always uses on-device Gemini Nano regardless of the user's LLM provider selection in settings.

## Environment

### For Mobile Applications:
- **Device**: Android device
- **OS**: Android
- **OS Version**: Latest
- **App Version**: Current development version

## Screenshots/Logs

```
[Log output showing Gemini Nano usage despite DeepSeek selection]
```

## Technical Details

The LLM provider selection logic uses the `aiPreference` setting to determine fallback behavior, but this was overriding the explicit `providerType` selection when `aiPreference` was set to "prefer on-device".

## Root Cause

The `generateCompletionWithFallback` method in `LlmService` prioritizes providers based on `aiPreference`:
- `preferOnDevice`: tries on-device first, then selected cloud provider
- `preferCloud`: tries selected cloud provider first, then on-device

Since the default `aiPreference` is `preferOnDevice`, selecting DeepSeek would still try Gemini Nano first, and since Gemini Nano is available, it would use that instead of the selected provider.

## Solution

Modified the LLM settings page dropdown handler to automatically switch `aiPreference` to `preferCloud` when a cloud provider is selected while the current preference is `preferOnDevice`. This ensures the explicitly selected provider gets priority.

## Reference Documents

- LLM Integration feature documentation

## Technical References

[Links to specific code locations, classes, or files. Adapt format to your tech stack.]

## Testing

- [ ] Unit test added/updated
- [ ] Integration test added/updated
- [x] Manual testing completed
- [ ] Tested in multiple browsers/environments (if applicable)
- [ ] Regression testing completed (if applicable)

## Notes

This bug affects the core LLM functionality and prevents users from using their preferred LLM provider.

## History

- 2026-01-17 - Created
- 2026-01-17 - Root cause identified: aiPreference overrides explicit provider selection
- 2026-01-17 - Status changed to ✅ Completed</content>
<parameter name="filePath">project-management/backlog/bugs/BF-004-llm-selection-always-defaults-to-on-device.md