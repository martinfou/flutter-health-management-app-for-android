import 'package:flutter/material.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';

/// Large dashboard metric card widget for the card-based health tracking layout
class DashboardMetricCardWidget extends StatelessWidget {
  final String title;
  final String? value;
  final IconData icon;
  final Color? iconColor;
  final String? subtitle;
  final String? additionalInfo;
  final VoidCallback? onQuickLog;
  final VoidCallback? onViewDetails;
  final Widget? customContent;

  const DashboardMetricCardWidget({
    super.key,
    required this.title,
    this.value,
    required this.icon,
    this.iconColor,
    this.subtitle,
    this.additionalInfo,
    this.onQuickLog,
    this.onViewDetails,
    this.customContent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: UIConstants.spacingSm),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingMd),
            
            // Divider
            Divider(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
            const SizedBox(height: UIConstants.spacingMd),

            // Custom content or default value display
            if (customContent != null)
              customContent!
            else if (value != null) ...[
              Text(
                value!,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: UIConstants.spacingXs),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
              if (additionalInfo != null) ...[
                const SizedBox(height: UIConstants.spacingSm),
                Text(
                  additionalInfo!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ] else ...[
              Text(
                'No data',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],

            const SizedBox(height: UIConstants.spacingLg),

            // Action buttons
            Row(
              children: [
                if (onViewDetails != null)
                  Expanded(
                    child: CustomButton(
                      label: 'View Details',
                      onPressed: onViewDetails,
                      variant: ButtonVariant.secondary,
                      icon: Icons.info_outline,
                    ),
                  ),
                if (onViewDetails != null && onQuickLog != null)
                  const SizedBox(width: UIConstants.spacingSm),
                if (onQuickLog != null)
                  Expanded(
                    child: CustomButton(
                      label: 'Quick Log',
                      onPressed: onQuickLog,
                      icon: Icons.add,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

