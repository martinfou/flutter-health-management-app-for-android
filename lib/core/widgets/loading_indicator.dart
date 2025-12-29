import 'package:flutter/material.dart';
import 'package:health_app/core/constants/ui_constants.dart';

/// Reusable loading indicator widget
/// 
/// Displays a circular progress indicator with optional message.
/// Meets WCAG 2.1 AA accessibility requirements.
class LoadingIndicator extends StatelessWidget {
  /// Optional message to display below the spinner
  final String? message;

  /// Size of the spinner (default: 48dp)
  final double size;

  /// Creates a loading indicator
  const LoadingIndicator({
    super.key,
    this.message,
    this.size = UIConstants.iconSizeXl,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: UIConstants.spacingMd),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Full-screen loading indicator
/// 
/// Displays a loading indicator that takes up the full screen.
class FullScreenLoadingIndicator extends StatelessWidget {
  /// Optional message to display
  final String? message;

  /// Creates a full-screen loading indicator
  const FullScreenLoadingIndicator({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Semantics(
        label: message ?? 'Loading',
        child: LoadingIndicator(message: message),
      ),
    );
  }
}

