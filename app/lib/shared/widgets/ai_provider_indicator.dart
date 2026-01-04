import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/llm/llm_provider.dart';
import '../../../core/llm/providers/llm_providers.dart';

/// Widget that displays the current AI provider being used
class AiProviderIndicator extends ConsumerWidget {
  final bool showLabel;
  final double iconSize;
  final TextStyle? textStyle;

  const AiProviderIndicator({
    super.key,
    this.showLabel = true,
    this.iconSize = 16,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(llmConfigProvider);
    final onDeviceAvailable = ref.watch(onDeviceAiAvailableProvider);

    // Determine which provider is actually being used based on preference and availability
    LlmProviderType actualProvider = config.providerType;
    bool isOnDevice = false;

    if (config.aiPreference == AiPreference.preferOnDevice ||
        config.aiPreference == AiPreference.onDeviceOnly) {
      if (onDeviceAvailable.valueOrNull == true) {
        actualProvider = LlmProviderType.onDevice;
        isOnDevice = true;
      }
    } else if (config.aiPreference == AiPreference.preferCloud ||
        config.aiPreference == AiPreference.cloudOnly) {
      // Cloud provider is already set
      isOnDevice = false;
    } else if (config.providerType == LlmProviderType.onDevice) {
      isOnDevice = true;
    }

    final displayName = _getProviderDisplayName(actualProvider);
    final icon = _getProviderIcon(actualProvider);
    final color = _getProviderColor(actualProvider, context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: color,
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            displayName,
            style: textStyle ??
                TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
        if (isOnDevice) ...[
          const SizedBox(width: 2),
          Icon(
            Icons.offline_bolt,
            size: 10,
            color: Colors.green,
          ),
        ],
      ],
    );
  }

  String _getProviderDisplayName(LlmProviderType type) {
    switch (type) {
      case LlmProviderType.onDevice:
        return 'On-Device';
      case LlmProviderType.opencodeZen:
        return 'OpenCode Zen';
      case LlmProviderType.deepseek:
        return 'DeepSeek';
      case LlmProviderType.openai:
        return 'OpenAI';
      case LlmProviderType.anthropic:
        return 'Claude';
      case LlmProviderType.ollama:
        return 'Ollama';
    }
  }

  IconData _getProviderIcon(LlmProviderType type) {
    switch (type) {
      case LlmProviderType.onDevice:
        return Icons.smartphone;
      case LlmProviderType.opencodeZen:
      case LlmProviderType.deepseek:
      case LlmProviderType.openai:
      case LlmProviderType.anthropic:
        return Icons.cloud;
      case LlmProviderType.ollama:
        return Icons.computer;
    }
  }

  Color _getProviderColor(LlmProviderType type, BuildContext context) {
    switch (type) {
      case LlmProviderType.onDevice:
        return Colors.green;
      case LlmProviderType.opencodeZen:
        return Colors.purple;
      case LlmProviderType.deepseek:
        return Colors.blue;
      case LlmProviderType.openai:
        return Colors.green.shade700;
      case LlmProviderType.anthropic:
        return Colors.orange;
      case LlmProviderType.ollama:
        return Colors.teal;
    }
  }
}

/// Compact version for use in app bars or small spaces
class CompactAiProviderIndicator extends ConsumerWidget {
  final double size;

  const CompactAiProviderIndicator({
    super.key,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(llmConfigProvider);
    final onDeviceAvailable = ref.watch(onDeviceAiAvailableProvider);

    // Determine which provider is actually being used
    LlmProviderType actualProvider = config.providerType;
    bool isOnDevice = false;

    if (config.aiPreference == AiPreference.preferOnDevice ||
        config.aiPreference == AiPreference.onDeviceOnly) {
      if (onDeviceAvailable.valueOrNull == true) {
        actualProvider = LlmProviderType.onDevice;
        isOnDevice = true;
      }
    } else if (config.providerType == LlmProviderType.onDevice) {
      isOnDevice = true;
    }

    final icon = _getProviderIcon(actualProvider);
    final color = _getProviderColor(actualProvider, context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            icon,
            size: size * 0.6,
            color: color,
          ),
          if (isOnDevice)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.offline_bolt,
                  size: size * 0.2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getProviderIcon(LlmProviderType type) {
    switch (type) {
      case LlmProviderType.onDevice:
        return Icons.smartphone;
      case LlmProviderType.opencodeZen:
      case LlmProviderType.deepseek:
      case LlmProviderType.openai:
      case LlmProviderType.anthropic:
        return Icons.cloud;
      case LlmProviderType.ollama:
        return Icons.computer;
    }
  }

  Color _getProviderColor(LlmProviderType type, BuildContext context) {
    switch (type) {
      case LlmProviderType.onDevice:
        return Colors.green;
      case LlmProviderType.opencodeZen:
        return Colors.purple;
      case LlmProviderType.openai:
        return Colors.green.shade700;
      case LlmProviderType.anthropic:
        return Colors.orange;
      case LlmProviderType.deepseek:
        return Colors.blue;
      case LlmProviderType.ollama:
        return Colors.teal;
    }
  }
}
