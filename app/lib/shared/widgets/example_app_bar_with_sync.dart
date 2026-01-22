import 'package:flutter/material.dart';
import 'package:health_app/shared/widgets/sync_status_indicator.dart';
import 'package:health_app/shared/widgets/sync_status_details.dart';

/// Example of how to integrate sync UI components into your app bar
///
/// This shows the recommended way to include sync status in your navigation.
///
/// Copy this pattern to your app's main screens (Home, Dashboard, etc.)
class ExampleAppBarWithSync extends StatelessWidget {
  const ExampleAppBarWithSync({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Tracker'),
        elevation: 0,
        actions: [
          // Compact sync status indicator (shows icon with status)
          const SyncStatusIndicator(),

          // Manual sync button (lets user trigger sync manually)
          const ManualSyncButton(),

          // Info button to show detailed sync status
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Sync details',
            onPressed: () => showSyncStatusDetails(context),
          ),

          // App menu
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                // Navigate to settings
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem<String>(
                value: 'about',
                child: Text('About'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Health Tracker Home'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => showSyncStatusDetails(context),
              child: const Text('View Full Sync Status'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example of how to create a custom app bar with more detailed sync info
class CustomAppBarWithSyncInfo extends StatelessWidget {
  const CustomAppBarWithSyncInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Health Tracker'),
          // You can add a subtitle with sync info here
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: GestureDetector(
              onTap: () => showSyncStatusDetails(context),
              child: const Text(
                'Tap for sync details',
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
      actions: [
        const SyncStatusIndicator(),
        const ManualSyncButton(),
      ],
    );
  }
}

/// Example of a screen with sync controls in the body
class ExampleScreenWithSyncControls extends StatelessWidget {
  const ExampleScreenWithSyncControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meals'),
        actions: [
          const SyncStatusIndicator(),
          const ManualSyncButton(),
        ],
      ),
      body: ListView(
        children: [
          // Sync status card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sync Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => showSyncStatusDetails(context),
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('View Details'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Rest of your content
          ListTile(
            title: const Text('Meal 1'),
            subtitle: const Text('Today at 12:30 PM'),
            trailing: const Icon(Icons.check),
          ),
          ListTile(
            title: const Text('Meal 2'),
            subtitle: const Text('Today at 7:00 PM'),
            trailing: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }
}
