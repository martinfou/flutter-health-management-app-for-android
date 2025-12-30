import 'package:flutter/material.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';
import 'package:health_app/features/health_tracking/presentation/pages/health_tracking_page.dart';
import 'package:health_app/features/health_tracking/presentation/pages/weight_entry_page.dart';
import 'package:health_app/features/health_tracking/presentation/pages/measurements_page.dart';
import 'package:health_app/features/health_tracking/presentation/pages/sleep_energy_page.dart';

/// Demo page for Sprint 4: Health Tracking UI
class Sprint4DemoPage extends StatelessWidget {
  const Sprint4DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprint 4: Health Tracking UI Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sprint 4 Demo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.spacingMd),
            const Text(
              'All health tracking UI features are now available. Use the buttons below to navigate to each feature.',
            ),
            const SizedBox(height: UIConstants.spacingLg),
            CustomButton(
              label: 'Health Tracking Main Page',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HealthTrackingPage(),
                  ),
                );
              },
              icon: Icons.dashboard,
              width: double.infinity,
            ),
            const SizedBox(height: UIConstants.spacingSm),
            CustomButton(
              label: 'Weight Entry Page',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const WeightEntryPage(),
                  ),
                );
              },
              icon: Icons.scale,
              variant: ButtonVariant.secondary,
              width: double.infinity,
            ),
            const SizedBox(height: UIConstants.spacingSm),
            CustomButton(
              label: 'Body Measurements Page',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MeasurementsPage(),
                  ),
                );
              },
              icon: Icons.straighten,
              variant: ButtonVariant.secondary,
              width: double.infinity,
            ),
            const SizedBox(height: UIConstants.spacingSm),
            CustomButton(
              label: 'Sleep & Energy Page',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SleepEnergyPage(),
                  ),
                );
              },
              icon: Icons.bedtime,
              variant: ButtonVariant.secondary,
              width: double.infinity,
            ),
            const SizedBox(height: UIConstants.spacingLg),
            const Divider(),
            const SizedBox(height: UIConstants.spacingMd),
            const Text(
              'Features Implemented:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.spacingSm),
            _buildFeatureItem('✅ Health Tracking Providers (Story 4.1)'),
            _buildFeatureItem('✅ Weight Entry Page (Story 4.2)'),
            _buildFeatureItem('✅ Weight Trend Chart Widget (Story 4.3)'),
            _buildFeatureItem('✅ Body Measurements Page (Story 4.4)'),
            _buildFeatureItem('✅ Sleep and Energy Tracking Page (Story 4.5)'),
            _buildFeatureItem('✅ Health Tracking Main Page (Story 4.6)'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingXs),
      child: Row(
        children: [
          const SizedBox(width: UIConstants.spacingMd),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

