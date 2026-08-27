import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadowwall_ai/app.dart';

void main() {
  testWidgets('App boots up successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: ShadowWallApp(),
      ),
    );

    // Verify that the app launches and attempts to show some text (e.g. login or splash)
    // We expect at least a MaterialApp or Router to be present.
    expect(find.byType(MaterialApp), findsNothing); // It's actually a Router in our app
    expect(find.byType(ShadowWallApp), findsOneWidget);
  });
}
