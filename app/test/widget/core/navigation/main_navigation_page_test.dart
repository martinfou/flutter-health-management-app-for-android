import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/pages/main_navigation_page.dart';

void main() {
  group('MainNavigationPage', () {
    testWidgets('should display bottom navigation bar', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MainNavigationPage(),
          ),
        ),
      );

      // Assert
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('should display all navigation destinations', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MainNavigationPage(),
          ),
        ),
      );

      // Assert - check for navigation destination labels
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Health'), findsOneWidget);
      expect(find.text('Nutrition'), findsOneWidget);
      expect(find.text('Exercise'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('should switch pages when navigation item is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MainNavigationPage(),
          ),
        ),
      );

      // Initially should show Home page (first page)
      expect(find.text('Health Tracker'), findsOneWidget);

      // Act - tap on Health navigation item
      final navigationBar = find.byType(NavigationBar);
      expect(navigationBar, findsOneWidget);
      
      // Find the NavigationBar and tap on index 1 (Health)
      await tester.tap(find.text('Health'));
      await tester.pumpAndSettle();

      // Assert - should show Health Tracking page
      expect(find.text('Health Tracking'), findsOneWidget);
    });
  });
}

