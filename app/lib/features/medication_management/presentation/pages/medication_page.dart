import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/features/medication_management/presentation/providers/medication_providers.dart';
import 'package:health_app/features/medication_management/presentation/widgets/medication_card_widget.dart';
import 'package:health_app/features/medication_management/presentation/pages/add_medication_dialog.dart';
import 'package:health_app/features/medication_management/presentation/pages/medication_logging_page.dart';
import 'package:health_app/core/widgets/safety_alert_widget.dart';

/// Main medication management page showing list of medications
class MedicationPage extends ConsumerWidget {
  const MedicationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final medicationsAsync = ref.watch(medicationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
      ),
      body: medicationsAsync.when(
        data: (medications) {
          if (medications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medication_liquid,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  Text(
                    'No medications yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingSm),
                  Text(
                    'Tap the + button to add a medication',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          final activeMedications = medications.where((m) => m.isActive).toList();
          final inactiveMedications = medications.where((m) => !m.isActive).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Safety alerts
                const SafetyAlertWidget(),
                
                if (activeMedications.isNotEmpty) ...[
                  Text(
                    'Active Medications',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  ...activeMedications.map((medication) => MedicationCardWidget(
                        medication: medication,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MedicationLoggingPage(
                                medication: medication,
                              ),
                            ),
                          );
                        },
                      )),
                  const SizedBox(height: UIConstants.spacingLg),
                ],
                if (inactiveMedications.isNotEmpty) ...[
                  Text(
                    'Inactive Medications',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  ...inactiveMedications.map((medication) => MedicationCardWidget(
                        medication: medication,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MedicationLoggingPage(
                                medication: medication,
                              ),
                            ),
                          );
                        },
                      )),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading medications: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMedicationDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMedicationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const AddMedicationDialog(),
    );
  }
}

