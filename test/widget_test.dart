// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rummitimer/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Timer starts, resets, and stops correctly', (
    WidgetTester tester,
  ) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the timer starts at the default value (40).
    expect(find.text('40'), findsOneWidget);

    // Tap the screen to start the timer.
    await tester.tap(find.byType(GestureDetector));
    await tester.pump(); // Trigger a frame.

    // Wait for 1 second and verify that the timer decrements.
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('39'), findsOneWidget);

    // Tap the screen again to reset the timer.
    await tester.tap(find.byType(GestureDetector));
    await tester.pump();
    expect(find.text('40'), findsOneWidget);

    // Long press the screen to stop the timer.
    await tester.longPress(find.byType(GestureDetector));
    await tester.pump();

    // Verify that the timer is stopped and remains at the current value.
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.text('40'),
      findsOneWidget,
    ); // Timer should not decrement further.
  });
}
