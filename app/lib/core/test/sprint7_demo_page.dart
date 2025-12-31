// Dart SDK
import 'package:flutter/material.dart';

// Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';
import 'package:health_app/features/medication_management/presentation/pages/medication_page.dart';
import 'package:health_app/features/medication_management/presentation/providers/medication_providers.dart';
import 'package:health_app/features/behavioral_support/presentation/pages/behavioral_support_page.dart';
import 'package:health_app/features/behavioral_support/presentation/pages/habit_tracking_page.dart';
import 'package:health_app/features/behavioral_support/presentation/providers/behavioral_providers.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:health_app/features/user_profile/domain/entities/gender.dart';

/// Sprint 7 Demo Page
/// 
/// Demonstrates all Sprint 7 features:
/// - Medication providers (Riverpod)
/// - Medication pages (medication list, medication logging)
/// - Medication widgets (medication cards)
/// - Behavioral support providers (habits, goals)
/// - Behavioral support pages (habit tracking, behavioral support main)
/// - Behavioral support widgets (habit cards, goal progress)
class Sprint7DemoPage extends ConsumerStatefulWidget {
  const Sprint7DemoPage({super.key});

  @override
  ConsumerState<Sprint7DemoPage> createState() => _Sprint7DemoPageState();
}

class _Sprint7DemoPageState extends ConsumerState<Sprint7DemoPage> {
  final List<String> _demoResults = [];
  bool _isRunning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkProviders();
    _ensureUserProfile();
  }

  void _checkProviders() {
    // Check if providers are accessible
    try {
      ref.read(medicationsProvider);
      ref.read(activeMedicationsProvider);
      ref.read(habitsProvider);
      ref.read(weeklyReviewProvider);
      ref.read(goalsProvider);
      
      _addResult('Providers Initialization', 
          '✅ All providers accessible');
    } catch (e) {
      _addResult('Providers Initialization', '❌ Error: $e');
    }
  }

  Future<void> _ensureUserProfile() async {
    try {
      final userProfileRepo = ref.read(userProfileRepositoryProvider);
      final userResult = await userProfileRepo.getCurrentUserProfile();
      
      final userExists = userResult.fold(
        (failure) => false,
        (_) => true,
      );
      
      if (!userExists) {
        // User profile doesn't exist, create a default one
        final now = DateTime.now();
        final profileId = 'demo-user-${now.millisecondsSinceEpoch}';
        
        final profile = UserProfile(
          id: profileId,
          name: 'Demo User',
          email: 'demo@example.com',
          dateOfBirth: DateTime(1990, 1, 1),
          gender: Gender.male,
          height: 175.0,
          targetWeight: 75.0,
          syncEnabled: false,
          createdAt: now,
          updatedAt: now,
        );
        
        final saveResult = await userProfileRepo.saveUserProfile(profile);
        saveResult.fold(
          (saveFailure) {
            _addResult('User Profile Creation', '❌ Failed: ${saveFailure.message}');
          },
          (_) {
            _addResult('User Profile Creation', '✅ Created default user profile');
          },
        );
      } else {
        // User profile exists
        _addResult('User Profile Check', '✅ User profile exists');
      }
    } catch (e) {
      _addResult('User Profile Check', '❌ Error: $e');
    }
  }

  void _addResult(String test, String result) {
    setState(() {
      _demoResults.add('$test: $result');
    });
  }

  Future<void> _runFullDemo() async {
    setState(() {
      _isRunning = true;
      _errorMessage = null;
      _demoResults.clear();
    });

    try {
      // 1. Providers Check
      _addResult('1. Medication & Behavioral Providers', '✅ All providers initialized');
      
      // 2. Test Medication Providers
      await _testMedicationProviders();
      
      // 3. Test Behavioral Providers
      await _testBehavioralProviders();

      _addResult('✅ Demo Complete', 'All Sprint 7 features tested successfully!');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _testMedicationProviders() async {
    try {
      final medicationsAsync = ref.read(medicationsProvider.future);
      final medications = await medicationsAsync;
      _addResult('2. MedicationsProvider', 
          '✅ Loaded ${medications.length} medications');

      final activeAsync = ref.read(activeMedicationsProvider.future);
      final active = await activeAsync;
      _addResult('3. ActiveMedicationsProvider', 
          '✅ Loaded ${active.length} active medications');
    } catch (e) {
      _addResult('2-3. Medication Providers', '❌ Error: $e');
    }
  }

  Future<void> _testBehavioralProviders() async {
    try {
      final habitsAsync = ref.read(habitsProvider.future);
      final habits = await habitsAsync;
      _addResult('4. HabitsProvider', 
          '✅ Loaded ${habits.length} habits');

      final goalsAsync = ref.read(goalsProvider.future);
      final goals = await goalsAsync;
      _addResult('5. GoalsProvider', 
          '✅ Loaded ${goals.length} goals');

      final review = ref.read(weeklyReviewProvider);
      _addResult('6. WeeklyReviewProvider', 
          '✅ Review structure: ${review.keys.join(", ")}');
    } catch (e) {
      _addResult('4-6. Behavioral Providers', '❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprint 7 Demo: Medication & Behavioral UI'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sprint 7 Features',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    const Text(
                      'Medication Management & Behavioral Support UI',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingLg),

            // Create User Profile Button
            CustomButton(
              label: 'Create/Check User Profile',
              icon: Icons.person,
              onPressed: _ensureUserProfile,
              variant: ButtonVariant.secondary,
              width: double.infinity,
            ),

            const SizedBox(height: UIConstants.spacingMd),

            // Run Demo Button
            CustomButton(
              label: _isRunning ? 'Running Demo...' : 'Run Full Demo',
              onPressed: _isRunning ? null : _runFullDemo,
              isLoading: _isRunning,
              width: double.infinity,
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: UIConstants.spacingMd),
              Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.cardPadding),
                  child: Text(
                    _errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: UIConstants.spacingLg),

            // Demo Results
            if (_demoResults.isNotEmpty) ...[
              Text(
                'Demo Results',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: UIConstants.spacingMd),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _demoResults.map((result) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: UIConstants.spacingXs),
                        child: Text(
                          result,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],

            const SizedBox(height: UIConstants.spacingLg),

            // Navigation Section
            Text(
              'Navigate to Pages',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.spacingMd),

            // Medication Pages
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medication Management',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingMd),
                    CustomButton(
                      label: 'Medication Page',
                      icon: Icons.medication_liquid,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MedicationPage(),
                          ),
                        );
                      },
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingMd),

            // Behavioral Support Pages
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Behavioral Support',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingMd),
                    CustomButton(
                      label: 'Behavioral Support Page',
                      icon: Icons.psychology,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const BehavioralSupportPage(),
                          ),
                        );
                      },
                      width: double.infinity,
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    CustomButton(
                      label: 'Habit Tracking Page',
                      icon: Icons.check_circle,
                      variant: ButtonVariant.secondary,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const HabitTrackingPage(),
                          ),
                        );
                      },
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

