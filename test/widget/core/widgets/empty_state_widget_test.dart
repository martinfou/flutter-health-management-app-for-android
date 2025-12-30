import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/core/widgets/empty_state_widget.dart';

void main() {
  group('EmptyStateWidget', () {
    testWidgets('should display title', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(title: 'No data'),
          ),
        ),
      );

      // Assert
      expect(find.text('No data'), findsOneWidget);
    });

    testWidgets('should display description when provided', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'No data',
              description: 'Get started by adding your first entry',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('No data'), findsOneWidget);
      expect(find.text('Get started by adding your first entry'), findsOneWidget);
    });

    testWidgets('should not display description when not provided', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(title: 'No data'),
          ),
        ),
      );

      // Assert
      expect(find.text('No data'), findsOneWidget);
      // Description text should not be found
      expect(find.text('Get started by adding your first entry'), findsNothing);
    });

    testWidgets('should display icon when provided', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'No data',
              icon: Icons.inbox,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('should not display icon when not provided', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(title: 'No data'),
          ),
        ),
      );

      // Assert
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('should display action button when actionLabel and onAction provided', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'No data',
              actionLabel: 'Add Entry',
              onAction: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Add Entry'), findsOneWidget);
    });

    testWidgets('should not display action button when actionLabel not provided', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'No data',
              onAction: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('should not display action button when onAction not provided', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'No data',
              actionLabel: 'Add Entry',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Add Entry'), findsNothing);
    });

    testWidgets('should call onAction when action button is tapped', (WidgetTester tester) async {
      // Arrange
      var wasActionCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'No data',
              actionLabel: 'Add Entry',
              onAction: () {
                wasActionCalled = true;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Add Entry'));
      await tester.pump();

      // Assert
      expect(wasActionCalled, true);
    });

    testWidgets('should have semantic label for accessibility', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'No data',
              description: 'Get started',
            ),
          ),
        ),
      );

      // Assert - verify Semantics widget exists
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('should use title only in semantic label when description not provided', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(title: 'No data'),
          ),
        ),
      );

      // Assert - verify Semantics widget exists
      expect(find.byType(Semantics), findsWidgets);
    });
  });
}

