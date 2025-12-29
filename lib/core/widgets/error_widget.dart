import 'package:flutter/material.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';

/// Reusable error widget with retry option
/// 
/// Displays an error message with an optional retry button.
/// Meets WCAG 2.1 AA accessibility requirements.
class ErrorWidget extends StatelessWidget {
  /// Error message to display
  final String message;

  /// Optional retry callback
  final VoidCallback? onRetry;

  /// Optional icon to display (default: error icon)
  final IconData? icon;

  /// Creates an error widget
  const ErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: UIConstants.iconSizeXl,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: UIConstants.spacingMd),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: UIConstants.spacingLg),
              CustomButton(
                label: 'Retry',
                onPressed: onRetry!,
                variant: ButtonVariant.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Full-screen error widget
/// 
/// Displays an error widget that takes up the full screen.
class FullScreenErrorWidget extends StatelessWidget {
  /// Error message to display
  final String message;

  /// Optional retry callback
  final VoidCallback? onRetry;

  /// Optional icon to display
  final IconData? icon;

  /// Creates a full-screen error widget
  const FullScreenErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Semantics(
        label: 'Error: $message',
        child: ErrorWidget(
          message: message,
          onRetry: onRetry,
          icon: icon,
        ),
      ),
    );
  }
}

