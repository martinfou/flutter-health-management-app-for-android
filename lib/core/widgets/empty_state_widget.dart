import 'package:flutter/material.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';

/// Reusable empty state widget
/// 
/// Displays an empty state message with optional action button.
/// Meets WCAG 2.1 AA accessibility requirements.
class EmptyStateWidget extends StatelessWidget {
  /// Title text
  final String title;

  /// Optional description text
  final String? description;

  /// Optional icon to display
  final IconData? icon;

  /// Optional action button label
  final String? actionLabel;

  /// Optional action callback
  final VoidCallback? onAction;

  /// Creates an empty state widget
  const EmptyStateWidget({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.actionLabel,
    this.onAction,
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
            if (icon != null) ...[
              Icon(
                icon,
                size: UIConstants.iconSizeXl * 2,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              SizedBox(height: UIConstants.spacingLg),
            ],
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              SizedBox(height: UIConstants.spacingSm),
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: UIConstants.spacingLg),
              CustomButton(
                label: actionLabel!,
                onPressed: onAction!,
                variant: ButtonVariant.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

