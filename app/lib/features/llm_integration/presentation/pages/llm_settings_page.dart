import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/llm/llm_provider.dart';
import '../../../../core/llm/providers/llm_providers.dart';

/// Page for configuring LLM (AI) settings
class LlmSettingsPage extends ConsumerStatefulWidget {
  const LlmSettingsPage({super.key});

  @override
  ConsumerState<LlmSettingsPage> createState() => _LlmSettingsPageState();
}

class _LlmSettingsPageState extends ConsumerState<LlmSettingsPage> {
  late TextEditingController _apiKeyController;
  late TextEditingController _baseUrlController;
  late TextEditingController _modelController;

  @override
  void initState() {
    super.initState();
    final config = ref.read(llmConfigProvider);
    _apiKeyController = TextEditingController(text: config.apiKey);
    _baseUrlController = TextEditingController(text: config.baseUrl);
    _modelController = TextEditingController(text: config.model);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _saveConfig() {
    final currentConfig = ref.read(llmConfigProvider);
    final newConfig = currentConfig.copyWith(
      apiKey: _apiKeyController.text.trim(),
      baseUrl: _baseUrlController.text.trim().isEmpty ? null : _baseUrlController.text.trim(),
      model: _modelController.text.trim(),
    );

    ref.read(llmConfigProvider.notifier).state = newConfig;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI settings saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(llmConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Personal Assistant Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveConfig,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(UIConstants.spacingMd),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: UIConstants.spacingSm),
                      Expanded(
                        child: Text(
                          'Configure your AI provider to enable personalized health insights, meal suggestions, and workout adaptations.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: UIConstants.spacingLg),

          // Provider Selection
          const Text(
            'Preferred AI Provider',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: UIConstants.spacingSm),
          DropdownButtonFormField<LlmProviderType>(
            value: config.providerType,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: LlmProviderType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (LlmProviderType? newType) {
              if (newType != null) {
                // Update config with default model for the new type if model is changed
                String newModel = _modelController.text;
                if (newType == LlmProviderType.deepseek && config.providerType != LlmProviderType.deepseek) {
                   newModel = 'deepseek-chat';
                } else if (newType == LlmProviderType.openai && config.providerType != LlmProviderType.openai) {
                   newModel = 'gpt-4-turbo-preview';
                } else if (newType == LlmProviderType.anthropic && config.providerType != LlmProviderType.anthropic) {
                   newModel = 'claude-3-opus-20240229';
                } else if (newType == LlmProviderType.ollama && config.providerType != LlmProviderType.ollama) {
                   newModel = 'llama3';
                }
                
                _modelController.text = newModel;
                ref.read(llmConfigProvider.notifier).state = config.copyWith(
                  providerType: newType,
                  model: newModel,
                );
              }
            },
          ),
          const SizedBox(height: UIConstants.spacingLg),

          // API Key
          const Text(
            'API Key',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: UIConstants.spacingSm),
          TextField(
            controller: _apiKeyController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your API key',
              helperText: 'Your key is stored locally on this device.',
            ),
            obscureText: true,
          ),
          const SizedBox(height: UIConstants.spacingLg),

          // Model Selection
          const Text(
            'Model Name',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: UIConstants.spacingSm),
          TextField(
            controller: _modelController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g., deepseek-chat, gpt-4',
            ),
          ),
          const SizedBox(height: UIConstants.spacingLg),

          // Advanced: Base URL
          ExpansionTile(
            title: const Text('Advanced Settings'),
            children: [
              Padding(
                padding: const EdgeInsets.all(UIConstants.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Custom Base URL (Optional)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    TextField(
                      controller: _baseUrlController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'https://api.example.com',
                        helperText: 'Leave empty to use the provider\'s default URL.',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
