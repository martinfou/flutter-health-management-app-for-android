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

  String _getProviderDisplayName(LlmProviderType type) {
    switch (type) {
      case LlmProviderType.onDevice:
        return 'On-Device AI (Gemini Nano)';
      case LlmProviderType.opencodeZen:
        return 'OpenCode Zen (Free)';
      case LlmProviderType.deepseek:
        return 'DeepSeek';
      case LlmProviderType.openai:
        return 'OpenAI';
      case LlmProviderType.anthropic:
        return 'Anthropic (Claude)';
      case LlmProviderType.ollama:
        return 'Ollama (Local)';
    }
  }

  String _getDefaultModel(LlmProviderType type) {
    switch (type) {
      case LlmProviderType.onDevice:
        return 'gemini-nano';
      case LlmProviderType.opencodeZen:
        return 'big-pickle';
      case LlmProviderType.deepseek:
        return 'deepseek-chat';
      case LlmProviderType.openai:
        return 'gpt-4-turbo-preview';
      case LlmProviderType.anthropic:
        return 'claude-3-opus-20240229';
      case LlmProviderType.ollama:
        return 'llama3';
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(llmConfigProvider);
    final onDeviceAvailable = ref.watch(onDeviceAiAvailableProvider);

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

          // On-Device AI Status Card
          onDeviceAvailable.when(
            data: (isAvailable) => _buildOnDeviceStatusCard(isAvailable),
            loading: () => _buildOnDeviceStatusCard(null),
            error: (_, __) => _buildOnDeviceStatusCard(false),
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
              final isOnDevice = type == LlmProviderType.onDevice;
              final onDeviceIsAvailable = onDeviceAvailable.valueOrNull ?? false;

              return DropdownMenuItem(
                value: type,
                enabled: !isOnDevice || onDeviceIsAvailable,
                child: Row(
                  children: [
                    if (isOnDevice) ...[
                      Icon(
                        onDeviceIsAvailable ? Icons.phone_android : Icons.phone_android_outlined,
                        size: 18,
                        color: onDeviceIsAvailable ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _getProviderDisplayName(type),
                      style: TextStyle(
                        color: isOnDevice && !onDeviceIsAvailable ? Colors.grey : null,
                      ),
                    ),
                    if (isOnDevice && !onDeviceIsAvailable) ...[
                      const SizedBox(width: 8),
                      const Text(
                        '(Not available)',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
            onChanged: (LlmProviderType? newType) {
              if (newType != null) {
                final newModel = _getDefaultModel(newType);
                _modelController.text = newModel;
                ref.read(llmConfigProvider.notifier).state = config.copyWith(
                  providerType: newType,
                  model: newModel,
                );
              }
            },
          ),
          const SizedBox(height: UIConstants.spacingLg),

          // On-Device specific info
          if (config.providerType == LlmProviderType.onDevice) ...[
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.offline_bolt, color: Colors.green.shade700),
                        const SizedBox(width: UIConstants.spacingSm),
                        Text(
                          'On-Device AI Active',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    const Text(
                      'All AI processing happens on your device:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: UIConstants.spacingXs),
                    _buildBenefitRow(Icons.wifi_off, 'Works offline'),
                    _buildBenefitRow(Icons.lock, 'Data never leaves your device'),
                    _buildBenefitRow(Icons.money_off, 'No API costs'),
                    _buildBenefitRow(Icons.speed, 'Fast local processing'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: UIConstants.spacingLg),
          ],

          // API Key (hide for on-device)
          if (config.providerType != LlmProviderType.onDevice) ...[
            const Text(
              'API Key',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: UIConstants.spacingSm),
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Enter your API key',
                helperText: config.providerType == LlmProviderType.opencodeZen
                    ? 'Get your free API key from https://opencode.ai/zen'
                    : config.providerType == LlmProviderType.ollama
                        ? 'Not required for local Ollama'
                        : 'Your key is stored locally on this device.',
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
        ],
      ),
    );
  }

  Widget _buildOnDeviceStatusCard(bool? isAvailable) {
    if (isAvailable == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.spacingMd),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: UIConstants.spacingSm),
              const Text('Checking on-device AI availability...'),
            ],
          ),
        ),
      );
    }

    return Card(
      color: isAvailable ? Colors.green.shade50 : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingMd),
        child: Row(
          children: [
            Icon(
              isAvailable ? Icons.phone_android : Icons.phone_android_outlined,
              color: isAvailable ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: UIConstants.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAvailable
                        ? 'On-Device AI Available'
                        : 'On-Device AI Not Available',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? Colors.green.shade700 : Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    isAvailable
                        ? 'Gemini Nano is ready on this device'
                        : 'Requires Pixel 8 Pro or newer with Android 14+',
                    style: TextStyle(
                      fontSize: 12,
                      color: isAvailable ? Colors.green.shade600 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.green.shade600),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
