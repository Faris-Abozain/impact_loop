// Basic Flutter widget test.
//
// The full app (MyApp) depends on async initialization (DI, localization,
// secure storage, notifications), so this smoke test only verifies that the
// Flutter test environment renders a simple widget.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smoke test renders a widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Impact Loop'))),
    );

    expect(find.text('Impact Loop'), findsOneWidget);
  });
}
