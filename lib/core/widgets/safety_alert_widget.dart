// Dart SDK
import 'package:flutter/material.dart';

// Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/safety/safety_alert.dart';
import 'package:health_app/core/safety/alert_type.dart';
import 'package:health_app/core/providers/safety_alerts_provider.dart';

/// Widget to display safety alerts
/// 
/// Shows active safety alerts that have not been acknowledged.
/// Alerts are non-dismissible (cannot be permanently dismissed).
class SafetyAlertWidget extends ConsumerWidget {
  const SafetyAlertWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(activeSafetyAlertsProvider);
    final acknowledgedAlerts = ref.watch(acknowledgedAlertsProvider);

    return alertsAsync.when(
      data: (alerts) {
        // Filter out acknowledged alerts
        final unacknowledgedAlerts = alerts
            .where((alert) => !acknowledgedAlerts.contains(alert.title))
            .toList();

        if (unacknowledgedAlerts.isEmpty) {
          return const SizedBox.shrink();
        }

        // Show the first unacknowledged alert
        // In a production app, you might want to show all or prioritize by severity
        return _buildAlertCard(context, ref, unacknowledgedAlerts.first);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    WidgetRef ref,
    SafetyAlert alert,
  ) {
    final theme = Theme.of(context);
    
    // Determine colors based on severity
    Color backgroundColor;
    Color foregroundColor;
    IconData iconData;
    
    switch (alert.severity) {
      case AlertSeverity.high:
        backgroundColor = theme.colorScheme.errorContainer;
        foregroundColor = theme.colorScheme.onErrorContainer;
        iconData = Icons.warning;
        break;
      case AlertSeverity.medium:
        backgroundColor = theme.colorScheme.tertiaryContainer;
        foregroundColor = theme.colorScheme.onTertiaryContainer;
        iconData = Icons.info;
        break;
      case AlertSeverity.low:
        backgroundColor = theme.colorScheme.primaryContainer;
        foregroundColor = theme.colorScheme.onPrimaryContainer;
        iconData = Icons.info_outline;
        break;
    }

    return Container(
      margin: const EdgeInsets.all(UIConstants.spacingMd),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
        border: Border.all(
          color: foregroundColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  iconData,
                  color: foregroundColor,
                  size: UIConstants.iconSizeLg,
                ),
                const SizedBox(width: UIConstants.spacingMd),
                Expanded(
                  child: Text(
                    alert.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingMd),
            
            // Message
            Text(
              alert.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: foregroundColor,
              ),
            ),
            const SizedBox(height: UIConstants.spacingMd),
            
            // Acknowledge button
            if (alert.requiresAcknowledgment)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Mark alert as acknowledged
                    ref.read(acknowledgedAlertsProvider.notifier).state =
                        {...ref.read(acknowledgedAlertsProvider), alert.title};
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: foregroundColor,
                    side: BorderSide(color: foregroundColor),
                  ),
                  child: const Text('Acknowledge'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

