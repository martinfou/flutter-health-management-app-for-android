import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:health_app/core/pages/main_navigation_page.dart';
import 'package:health_app/core/data/models/user_preferences_model.dart';
import 'package:health_app/core/entities/user_preferences.dart';
import 'package:health_app/core/constants/auth_config.dart';

void main() {
  group('MainNavigationPage', () {
    late Box<UserPreferencesModel> preferencesBox;
    late Directory testDir;

    setUp(() async {
      // Create unique temporary directory for this test file to avoid lock conflicts
      testDir = await Directory.systemTemp.createTemp('main_nav_test_');
      Hive.init(testDir.path);
      
      // Register adapter for user preferences
      if (!Hive.isAdapterRegistered(12)) {
        Hive.registerAdapter(UserPreferencesModelAdapter());
      }
      
      // Close box if already open to avoid conflicts
      try {
        if (Hive.isBoxOpen('userPreferencesBox')) {
          final box = Hive.box('userPreferencesBox');
          await box.clear();
          await box.close();
        }
      } catch (e) {
        // Box might not exist, ignore
      }
      
      // Wait a bit to ensure lock is released
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Open the preferences box and set default preferences
      preferencesBox = await Hive.openBox<UserPreferencesModel>('userPreferencesBox');
      final defaultPrefs = UserPreferences.defaults();
      await preferencesBox.put('preferences', UserPreferencesModel.fromEntity(defaultPrefs));
    });

    tearDown(() async {
      // Clear and close box
      try {
        if (Hive.isBoxOpen('userPreferencesBox')) {
          final box = Hive.box('userPreferencesBox');
          if (box.isOpen) {
            await box.clear();
            await box.close();
          }
        }
      } catch (e) {
        // Box might already be closed, ignore
      }
      
      // Close Hive to release locks
      try {
        await Hive.close();
      } catch (e) {
        // Hive might already be closed, ignore
      }
      
      // Clean up temporary directory
      try {
        if (await testDir.exists()) {
          await testDir.delete(recursive: true);
        }
      } catch (e) {
        // Directory might already be deleted, ignore
      }
    });
    testWidgets('should display bottom navigation bar', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Disable authentication for testing
            authEnabledProvider.overrideWith((ref) => false),
          ],
          child: const MaterialApp(
            home: MainNavigationPage(),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('should display all navigation destinations', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Disable authentication for testing
            authEnabledProvider.overrideWith((ref) => false),
          ],
          child: const MaterialApp(
            home: MainNavigationPage(),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Assert - check for navigation destination labels in NavigationBar
      // Use find.byType to find NavigationBar first, then check for labels within it
      final navigationBar = find.byType(NavigationBar);
      expect(navigationBar, findsOneWidget);
      
      // Check that navigation labels exist (may appear multiple times in different contexts)
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Health'), findsWidgets);
      expect(find.text('Nutrition'), findsWidgets);
      expect(find.text('Exercise'), findsWidgets);
      expect(find.text('Progress'), findsWidgets);
      expect(find.text('More'), findsWidgets);
    });

    testWidgets('should switch pages when navigation item is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Disable authentication for testing
            authEnabledProvider.overrideWith((ref) => false),
          ],
          child: const MaterialApp(
            home: MainNavigationPage(),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Initially should show Home page (first page)
      expect(find.text('Health Tracker'), findsOneWidget);

      // Act - tap on Health navigation item (index 1)
      final navigationBar = find.byType(NavigationBar);
      expect(navigationBar, findsOneWidget);
      
      // Find NavigationDestination widgets - they're children of NavigationBar
      final navDestinations = find.byType(NavigationDestination);
      expect(navDestinations, findsNWidgets(6)); // Should have 6 destinations
      
      // Tap on the second NavigationDestination (Health, index 1)
      await tester.tap(navDestinations.at(1));
      await tester.pumpAndSettle();

      // Assert - should show Health Tracking page
      expect(find.text('Health Tracking'), findsOneWidget);
    });
  });
}

