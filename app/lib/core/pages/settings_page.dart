// Dart SDK
import 'package:flutter/material.dart';

// Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/constants/auth_config.dart';
import 'package:health_app/core/navigation/app_router.dart';
import 'package:health_app/core/providers/user_preferences_provider.dart';
import 'package:health_app/core/pages/user_profile_page.dart';
import 'package:health_app/core/sync/providers/sync_state_provider.dart';
import 'package:health_app/features/behavioral_support/presentation/pages/habit_tracking_page.dart';
import 'package:health_app/features/behavioral_support/presentation/pages/behavioral_support_page.dart';
import 'package:health_app/features/llm_integration/presentation/pages/llm_settings_page.dart';

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
          // Account Section
          _buildSectionHeader(context, 'Account'),
          _buildSettingsTile(
            context,
            title: 'Profile',
            subtitle: 'View and edit your profile',
            icon: Icons.person,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UserProfilePage(),
                ),
              );
            },
          ),
          // Authentication Toggle (Development/Testing)
          _buildAuthToggle(context, ref),
          const Divider(),

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

          _buildSettingsTile(
            context,
            title: 'Version',
            subtitle: '1.0.0',
            icon: Icons.info,
            onTap: null,
          ),
          const Divider(),

          // Sync Status Section
          _buildSectionHeader(context, 'Sync Status'),
          _buildSyncStatusWidget(context, ref),
          const Divider(),

          // AI Assistant Section
          _buildSectionHeader(context, 'AI Personal Assistant'),
          _buildSettingsTile(
            context,
            title: 'AI Settings',
            subtitle: 'Configure AI provider and insights',
            icon: Icons.auto_awesome,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LlmSettingsPage(),
                ),
              );
            },
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

  Widget _buildAuthToggle(BuildContext context, WidgetRef ref) {
    final isAuthEnabled = ref.watch(authEnabledProvider);

    return SwitchListTile(
      title: const Text('Authentication'),
      subtitle: Text(
        isAuthEnabled
            ? 'Login required to access app'
            : 'Authentication disabled (development mode)',
      ),
      value: isAuthEnabled,
      onChanged: (value) {
        ref.read(authEnabledProvider.notifier).state = value;
        // Show a snackbar to inform user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? 'Authentication enabled. Please restart the app.'
                  : 'Authentication disabled. App will skip login.',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        // Note: User may need to restart app for full effect
        // For immediate effect, we could navigate, but that's disruptive
      },
      secondary: Icon(
        isAuthEnabled ? Icons.lock : Icons.lock_open,
      ),
    );
  }

  Widget _buildSyncStatusWidget(BuildContext context, WidgetRef ref) {
    final syncStateAsync = ref.watch(syncStateProvider);
    final manualSyncTrigger = ref.watch(manualSyncTriggerProvider);

    return syncStateAsync.when(
      data: (syncState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last Sync Time
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Last Synced'),
              subtitle: Text(syncState.lastSyncDisplay ?? 'Never'),
            ),
            // Sync Status
            ListTile(
              leading: syncState.isSyncing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_done),
              title: const Text('Sync Status'),
              subtitle: Text(
                syncState.isSyncing
                    ? 'Syncing...'
                    : syncState.errorMessage ?? 'Up to date',
              ),
            ),
            // Manual Sync Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: syncState.isSyncing ? null : () async {
                  await manualSyncTrigger();
                },
                icon: const Icon(Icons.sync),
                label: const Text('Sync Now'),
              ),
            ),
            // Error Message (if any)
            if (syncState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          syncState.errorMessage!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
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
          'Error loading sync status: $error',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
      ),
    );
  }
}

