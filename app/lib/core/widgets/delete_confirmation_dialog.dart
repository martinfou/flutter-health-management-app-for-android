// Dart SDK
import 'package:flutter/material.dart';

// Project
import 'package:health_app/core/constants/ui_constants.dart';

/// Delete confirmation dialog
/// 
/// A reusable dialog for confirming deletion of items.
/// Shows a warning message and provides Cancel and Delete buttons.
class DeleteConfirmationDialog extends StatelessWidget {
  /// Title of the dialog
  final String title;

  /// Message to display in the dialog body
  final String message;

  /// Optional additional details to display
  final String? details;

  /// Creates a DeleteConfirmationDialog
  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.details,
  });

  /// Show the delete confirmation dialog
  /// 
  /// Returns true if user confirmed deletion, false otherwise.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String? details,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: title,
        message: message,
        details: details,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: UIConstants.spacingSm),
          Expanded(
            child: Text(title),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (details != null) ...[
            const SizedBox(height: UIConstants.spacingMd),
            Text(
              details!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

