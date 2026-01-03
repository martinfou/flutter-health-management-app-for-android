# Testing with Ollama

This guide explains how to test the Flutter Health Management App with Ollama, a local LLM that runs on your machine.

## Prerequisites

1. **Install Ollama**: Download and install Ollama from [https://ollama.com/](https://ollama.com/)
2. **Start Ollama Service**: The Ollama service must be running on your machine

## Quick Start

### 1. Start Ollama Service

You can use the provided script to start Ollama:

```bash
./scripts/start_ollama.sh
```

Or manually:

```bash
# Check if Ollama is already running
ollama serve

# If not running, start it (on macOS, the Ollama app may already be running)
# Pull the default model (llama3)
ollama pull llama3
```

### 2. Verify Ollama is Running

Test that Ollama is accessible:

```bash
# Check if port 11434 is listening
lsof -Pi :11434 -sTCP:LISTEN

# Or test with curl
curl http://localhost:11434/api/tags
```

### 3. Configure the App

#### Option A: Using the Settings UI

1. Open the app
2. Navigate to **Settings** → **AI Personal Assistant Settings**
3. Select **OLLAMA** as the provider
4. Set the model to `llama3` (or another model you have installed)
5. **Important**: For local Ollama, you can leave the API Key field empty (Ollama doesn't require an API key)
6. The Base URL should be `http://localhost:11434/v1` (default for Ollama)
7. Save the settings

#### Option B: Testing on a Physical Device

If testing on a physical Android device, you need to:

1. **Find your Mac's IP address**:
   ```bash
   # Use the provided script
   ./mock-server/get-ip.sh
   
   # Or manually
   ifconfig | grep "inet " | grep -v 127.0.0.1
   ```

2. **Update Ollama Base URL** in the app settings:
   - Instead of `http://localhost:11434/v1`
   - Use `http://YOUR_MAC_IP:11434/v1`
   - Example: `http://192.168.1.100:11434/v1`

3. **Configure Ollama to accept external connections**:
   
   By default, Ollama only listens on `localhost` (127.0.0.1), which means it can't be accessed from other devices. To make it accessible from your phone:
   
   **Option A: Set environment variable (temporary)**
   ```bash
   # Stop Ollama if it's running
   # Then start it with OLLAMA_HOST set to listen on all interfaces
   export OLLAMA_HOST=0.0.0.0:11434
   ollama serve
   ```
   
   **Option B: Set environment variable permanently (macOS)**
   ```bash
   # Add to your ~/.zshrc (or ~/.bash_profile if using bash)
   echo 'export OLLAMA_HOST=0.0.0.0:11434' >> ~/.zshrc
   source ~/.zshrc
   
   # Then restart Ollama
   ollama serve
   ```
   
   **Option C: Create a launch script**
   Create a file `start_ollama_network.sh`:
   ```bash
   #!/bin/bash
   export OLLAMA_HOST=0.0.0.0:11434
   ollama serve
   ```
   Then run: `chmod +x start_ollama_network.sh && ./start_ollama_network.sh`
   
   **Verify it's listening on all interfaces:**
   ```bash
   lsof -Pi :11434 -sTCP:LISTEN
   # Should show: *:11434 (LISTEN) instead of 127.0.0.1:11434
   ```
   
   **Security Note**: This makes Ollama accessible to any device on your local network. Only use this on trusted networks (e.g., your home WiFi).

## Testing LLM Features

The app uses Ollama in several features:

### 1. Meal Suggestions

Navigate to **Nutrition** → The app will use Ollama to suggest meals based on your preferences and goals.

### 2. Workout Adaptations

Navigate to **Exercise** → The app can adapt workout plans using Ollama based on your progress and preferences.

### 3. Weekly Review

Navigate to **Analytics** → The app generates personalized weekly reviews using Ollama.

## Programmatic Testing

You can test the LLM service directly in code:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/llm/providers/llm_providers.dart';
import 'package:health_app/core/llm/llm_provider.dart';

// In a widget or test
final llmService = ref.read(llmServiceProvider);

// Simple prompt
final result = await llmService.ask('What are some healthy breakfast options?');

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (response) => print('Response: $response'),
);

// Advanced request with system prompt
final request = LlmRequest(
  prompt: 'Suggest a workout for weight loss',
  systemPrompt: 'You are a fitness expert helping with weight loss.',
  temperature: 0.7,
  maxTokens: 500,
);

final response = await llmService.generateCompletion(request);
response.fold(
  (failure) => print('Error: ${failure.message}'),
  (llmResponse) {
    print('Content: ${llmResponse.content}');
    print('Tokens used: ${llmResponse.totalTokens}');
  },
);
```

## Troubleshooting

### Issue: "API Key is required" Error

**Problem**: Getting an error about API key being required.

**Solution**: 
- The `OllamaAdapter` has been updated to skip API key validation
- You can leave the API Key field completely empty when using Ollama
- If you still see this error, ensure you've selected **OLLAMA** as the provider type

### Issue: Connection Refused

**Problem**: Cannot connect to Ollama service.

**Solutions**:
1. Verify Ollama is running: `lsof -Pi :11434 -sTCP:LISTEN`
2. Check the Base URL is correct: `http://localhost:11434/v1`
3. For physical devices, ensure you're using your Mac's IP address, not `localhost`
4. Check firewall settings if testing on a physical device

### Issue: Works with localhost but not with network IP

**Problem**: Ollama works with `127.0.0.1` but not with `http://192.168.x.x:11434/` from your phone.

**Solution**: Ollama is only listening on localhost. Configure it to listen on all network interfaces:

```bash
# Quick fix (temporary - until you restart Ollama)
export OLLAMA_HOST=0.0.0.0:11434
# Stop current Ollama process, then restart it
ollama serve

# Or make it permanent
echo 'export OLLAMA_HOST=0.0.0.0:11434' >> ~/.zshrc
source ~/.zshrc
ollama serve
```

Verify it's working:
```bash
# Should show *:11434 (LISTEN) not 127.0.0.1:11434
lsof -Pi :11434 -sTCP:LISTEN

# Test from your phone's browser
# http://YOUR_MAC_IP:11434/api/tags
```

### Issue: Model Not Found

**Problem**: Ollama returns an error about the model not being available.

**Solution**:
```bash
# List available models
ollama list

# Pull the model you need
ollama pull llama3
# or
ollama pull llama3.2
# or
ollama pull mistral
```

### Issue: Slow Responses

**Problem**: Ollama responses are slow.

**Solutions**:
1. Use a smaller/faster model (e.g., `llama3.2:1b` instead of `llama3`)
2. Reduce `maxTokens` in the request
3. Ensure your Mac has sufficient resources (CPU/RAM)

## Available Models

Common Ollama models you can use:

- `llama3` - Default, good balance
- `llama3.2` - Newer version
- `llama3.2:1b` - Smaller, faster
- `mistral` - Alternative model
- `phi3` - Microsoft's small model

To see all available models:
```bash
ollama list
```

## Testing Different Models

1. Pull a model: `ollama pull mistral`
2. Update the model name in app settings to `mistral`
3. Save and test

## Integration with App Features

The LLM is integrated into these use cases:

1. **`SuggestMealsUseCase`** - Generates meal suggestions based on user preferences
2. **`AdaptWorkoutUseCase`** - Adapts workout plans based on progress
3. **`GenerateWeeklyReviewUseCase`** - Creates personalized weekly health reviews

All these use cases automatically use the configured LLM provider (Ollama when selected).

## Next Steps

- Test meal suggestions with different dietary preferences
- Test workout adaptations with various fitness goals
- Test weekly reviews with different health data
- Experiment with different models to find the best balance of speed and quality

