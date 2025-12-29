import 'package:flutter/material.dart';
import 'package:health_app/core/constants/app_constants.dart';
import 'package:health_app/core/constants/health_constants.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/utils/date_utils.dart' as app_date_utils;
import 'package:health_app/core/utils/validation_utils.dart';
import 'package:health_app/core/utils/calculation_utils.dart';
import 'package:health_app/core/utils/format_utils.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/errors/error_handler.dart';
import 'package:health_app/core/pages/export_page.dart';
import 'package:health_app/core/widgets/custom_button.dart';

/// Test page to demonstrate core constants and utilities
class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final _weightController = TextEditingController(text: '75.5');
  final _heightController = TextEditingController(text: '175');
  String _validationResult = '';
  String _calculationResult = '';
  String _formatResult = '';
  String _errorResult = '';

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _testValidation() {
    final weight = double.tryParse(_weightController.text);
    final validationError = ValidationUtils.validateWeightKg(weight);
    setState(() {
      _validationResult = validationError ?? '✓ Valid';
    });
  }

  void _testCalculations() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    
    if (weight != null && height != null) {
      final bmi = CalculationUtils.calculateBMI(weight, height);
      final proteinCal = CalculationUtils.caloriesFromProtein(100);
      final carbsCal = CalculationUtils.caloriesFromCarbs(150);
      final fatCal = CalculationUtils.caloriesFromFat(50);
      final totalCal = CalculationUtils.totalCaloriesFromMacros(
        proteinGrams: 100,
        carbsGrams: 150,
        fatGrams: 50,
      );
      
      setState(() {
        _calculationResult = '''
BMI: ${bmi?.toStringAsFixed(1) ?? 'N/A'}
Protein (100g): ${proteinCal.toStringAsFixed(0)} cal
Carbs (150g): ${carbsCal.toStringAsFixed(0)} cal
Fat (50g): ${fatCal.toStringAsFixed(0)} cal
Total: ${totalCal.toStringAsFixed(0)} cal
''';
      });
    }
  }

  void _testFormatting() {
    final weight = double.tryParse(_weightController.text);
    final now = DateTime.now();
    
    setState(() {
      _formatResult = '''
Weight: ${weight != null ? FormatUtils.formatWeightKg(weight) : 'N/A'}
Date Short: ${FormatUtils.formatDateShort(now)}
Date Long: ${FormatUtils.formatDateLong(now)}
Date Relative: ${FormatUtils.formatDateRelative(now)}
Time: ${FormatUtils.formatTime(now)}
Percentage: ${FormatUtils.formatPercentage(45.67)}
Calories: ${FormatUtils.formatCalories(2150)}
''';
    });
  }

  void _testErrorHandling() {
    // Test different failure types
    final validationFailure = ValidationFailure(
      'Weight is required',
      {'weight': 'Weight must be between 20 and 300 kg'},
    );
    final databaseFailure = DatabaseFailure('Failed to save data');
    final networkFailure = NetworkFailure('Connection timeout', 408);
    
    setState(() {
      _errorResult = '''
Validation Error:
${ErrorHandler.getUserFriendlyMessage(validationFailure)}

Database Error:
${ErrorHandler.getUserFriendlyMessage(databaseFailure)}

Network Error:
${ErrorHandler.getUserFriendlyMessage(networkFailure)}
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Core Infrastructure Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Constants Section
            _buildSection(
              'Constants',
              [
                _buildInfoRow('App Name', AppConstants.appName),
                _buildInfoRow('App Version', AppConstants.appVersion),
                _buildInfoRow('Min Android SDK', AppConstants.minAndroidSdk.toString()),
                _buildInfoRow('Target Android SDK', AppConstants.targetAndroidSdk.toString()),
                _buildInfoRow('Resting HR Alert', '${HealthConstants.restingHeartRateAlertThreshold} BPM'),
                _buildInfoRow('Rapid Weight Loss', '${HealthConstants.rapidWeightLossThresholdKg} kg/week'),
                _buildInfoRow('Moving Average Days', HealthConstants.movingAverageDays.toString()),
                _buildInfoRow('Screen Padding', '${UIConstants.screenPaddingHorizontal}dp'),
                _buildInfoRow('Min Touch Target', '${UIConstants.minTouchTarget}dp'),
              ],
            ),
            
            const SizedBox(height: UIConstants.spacingLg),
            
            // Date Utils Section
            _buildSection(
              'Date Utilities',
              [
                _buildInfoRow('Today', FormatUtils.formatDateShort(DateTime.now())),
                _buildInfoRow('7 Days Ago', FormatUtils.formatDateShort(
                  app_date_utils.DateUtils.daysAgo(DateTime.now(), 7),
                )),
                _buildInfoRow('Is Today?', app_date_utils.DateUtils.isToday(DateTime.now()).toString()),
                _buildInfoRow('Is Yesterday?', app_date_utils.DateUtils.isYesterday(
                  DateTime.now().subtract(const Duration(days: 1)),
                ).toString()),
                _buildInfoRow('Start of Week', FormatUtils.formatDateShort(
                  app_date_utils.DateUtils.startOfWeek(DateTime.now()),
                )),
              ],
            ),
            
            const SizedBox(height: UIConstants.spacingLg),
            
            // Validation Section
            _buildSection(
              'Validation Utilities',
              [
                TextField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: UIConstants.spacingSm),
                ElevatedButton(
                  onPressed: _testValidation,
                  child: const Text('Test Validation'),
                ),
                if (_validationResult.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: UIConstants.spacingSm),
                    child: Text(
                      _validationResult,
                      style: TextStyle(
                        color: _validationResult.startsWith('✓') 
                            ? Colors.green 
                            : Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: UIConstants.spacingLg),
            
            // Calculation Section
            _buildSection(
              'Calculation Utilities',
              [
                TextField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: UIConstants.spacingSm),
                ElevatedButton(
                  onPressed: _testCalculations,
                  child: const Text('Test Calculations'),
                ),
                if (_calculationResult.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: UIConstants.spacingSm),
                    child: Text(
                      _calculationResult,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: UIConstants.spacingLg),
            
            // Formatting Section
            _buildSection(
              'Formatting Utilities',
              [
                ElevatedButton(
                  onPressed: _testFormatting,
                  child: const Text('Test Formatting'),
                ),
                if (_formatResult.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: UIConstants.spacingSm),
                    child: Text(
                      _formatResult,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: UIConstants.spacingLg),
            
            // Error Handling Section
            _buildSection(
              'Error Handling',
              [
                ElevatedButton(
                  onPressed: _testErrorHandling,
                  child: const Text('Test Error Handling'),
                ),
                if (_errorResult.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: UIConstants.spacingSm),
                    child: Text(
                      _errorResult,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: UIConstants.spacingLg),
            
            // Export Page Navigation
            _buildSection(
              'Data Export',
              [
                CustomButton(
                  label: 'Open Export Page',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ExportPage(),
                      ),
                    );
                  },
                  variant: ButtonVariant.primary,
                  icon: Icons.download,
                  width: double.infinity,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: UIConstants.spacingMd),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}

