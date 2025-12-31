// Dart SDK
import 'package:flutter/material.dart';

// Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/navigation/app_router.dart';
import 'package:health_app/core/providers/user_preferences_provider.dart';
import 'package:health_app/features/behavioral_support/presentation/pages/habit_tracking_page.dart';
import 'package:health_app/features/behavioral_support/presentation/pages/behavioral_support_page.dart';

/// Settings page for app configuration
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
        children: [
          // Behavioral Support Section
          _buildSectionHeader(context, 'Behavioral Support'),
          _buildSettingsTile(
            context,
            title: 'Habit Tracking',
            subtitle: 'Track and manage your habits',
            icon: Icons.check_circle,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HabitTrackingPage(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            context,
            title: 'Behavioral Support',
            subtitle: 'Habits and goals overview',
            icon: Icons.psychology,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BehavioralSupportPage(),
                ),
              );
            },
          ),
          const Divider(),

          // Units Section
          _buildSectionHeader(context, 'Units'),
          _buildUnitsSelection(context, ref),
          const Divider(),

          // Data Management Section
          _buildSectionHeader(context, 'Data Management'),
          _buildSettingsTile(
            context,
            title: 'Export Data',
            subtitle: 'Backup your health data',
            icon: Icons.download,
            onTap: () {
              AppRouter.navigateTo(context, AppRoutes.export);
            },
          ),
          _buildSettingsTile(
            context,
            title: 'Import Data',
            subtitle: 'Restore from backup',
            icon: Icons.upload,
            onTap: () {
              AppRouter.navigateTo(context, AppRoutes.import);
            },
          ),
          const Divider(),

          // About Section
          _buildSectionHeader(context, 'About'),
          _buildSettingsTile(
            context,
            title: 'Version',
            subtitle: '1.0.0',
            icon: Icons.info,
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        top: UIConstants.spacingLg,
        bottom: UIConstants.spacingMd,
      ),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  Widget _buildUnitsSelection(BuildContext context, WidgetRef ref) {
    final unitPreferenceAsync = ref.watch(userPreferencesProvider);

    return unitPreferenceAsync.when(
      data: (preferences) {
        return Column(
          children: [
            RadioListTile<String>(
              title: const Text('Metric'),
              subtitle: const Text('kg, cm'),
              value: 'metric',
              groupValue: preferences.units,
              onChanged: (String? value) async {
                if (value != null) {
                  final updateFn = ref.read(updateUnitPreferenceProvider);
                  await updateFn(value);
                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unit preference saved'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Imperial'),
              subtitle: const Text('lb, ft/in'),
              value: 'imperial',
              groupValue: preferences.units,
              onChanged: (String? value) async {
                if (value != null) {
                  final updateFn = ref.read(updateUnitPreferenceProvider);
                  await updateFn(value);
                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unit preference saved'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(UIConstants.spacingMd),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.all(UIConstants.spacingMd),
        child: Text(
          'Error loading preferences: $error',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
      ),
    );
  }
}

