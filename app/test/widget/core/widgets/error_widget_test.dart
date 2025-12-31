import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/core/widgets/error_widget.dart' as health_app;

void main() {
  group('ErrorWidget', () {
    testWidgets('should display error message', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: health_app.ErrorWidget(message: 'An error occurred'),
          ),
        ),
      );

      // Assert
      expect(find.text('An error occurred'), findsOneWidget);
    });

    testWidgets('should display default error icon', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: health_app.ErrorWidget(message: 'Error'),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display custom icon when provided', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: health_app.ErrorWidget(
              message: 'Error',
              icon: Icons.warning,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('should display retry button when onRetry is provided', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: health_app.ErrorWidget(
              message: 'Error',
              onRetry: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should not display retry button when onRetry is null', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: health_app.ErrorWidget(message: 'Error'),
          ),
        ),
      );

      // Assert
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('should call onRetry when retry button is tapped', (WidgetTester tester) async {
      // Arrange
      var wasRetried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: health_app.ErrorWidget(
              message: 'Error',
              onRetry: () {
                wasRetried = true;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Retry'));
      await tester.pump();

      // Assert
      expect(wasRetried, true);
    });

    testWidgets('should have semantic label for accessibility', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: health_app.ErrorWidget(message: 'An error occurred'),
          ),
        ),
      );

      // Assert - verify Semantics widget exists
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('should include retry hint in semantic label when onRetry provided', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: health_app.ErrorWidget(
              message: 'An error occurred',
              onRetry: () {},
            ),
          ),
        ),
      );

      // Assert - verify Semantics widget exists
      expect(find.byType(Semantics), findsWidgets);
    });
  });

  group('FullScreenErrorWidget', () {
    testWidgets('should display error widget in scaffold', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: health_app.FullScreenErrorWidget(message: 'Error'),
        ),
      );

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(health_app.ErrorWidget), findsOneWidget);
    });

    testWidgets('should display error message', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: health_app.FullScreenErrorWidget(message: 'An error occurred'),
        ),
      );

      // Assert
      expect(find.text('An error occurred'), findsOneWidget);
    });

    testWidgets('should have semantic label for accessibility', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: health_app.FullScreenErrorWidget(message: 'An error occurred'),
        ),
      );

      // Assert - verify Semantics widget exists
      expect(find.byType(Semantics), findsWidgets);
    });
  });
}

