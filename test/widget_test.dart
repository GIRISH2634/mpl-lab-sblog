import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blog_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Provide a value for isLoggedIn (e.g., false for testing login screen).
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    // Check that it doesn't display "1" initially.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Check that the counter increased to 1.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
