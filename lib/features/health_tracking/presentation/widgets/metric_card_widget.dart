import 'package:flutter/material.dart';
import 'package:health_app/core/constants/ui_constants.dart';

/// Widget for displaying a health metric card
class MetricCardWidget extends StatelessWidget {
  final String title;
  final String? value;
  final IconData icon;
  final Color? iconColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const MetricCardWidget({
    super.key,
    required this.title,
    this.value,
    required this.icon,
    this.iconColor,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: iconColor ?? theme.colorScheme.primary,
                    size: UIConstants.iconSizeLg,
                  ),
                  const SizedBox(width: UIConstants.spacingSm),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
              if (value != null) ...[
                const SizedBox(height: UIConstants.spacingSm),
                Text(
                  value!,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              if (subtitle != null) ...[
                const SizedBox(height: UIConstants.spacingXs),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

