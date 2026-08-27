import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadowwall_ai/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End App Test', () {
    testWidgets('Boot app, login, and verify dashboard loads', (tester) async {
      // Launch the app
      app.main();
      
      // Wait for the app to settle (animations finish, etc)
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 1. We expect to land on a Login or Registration screen initially
      // Find the email input field by type or by a known key/hint text.
      // Assuming a generic email field exists on auth screens.
      final emailField = find.byType(TextFormField).first;
      expect(emailField, findsOneWidget);

      // 2. Simulate typing into the field
      await tester.enterText(emailField, 'integration@test.com');
      
      // 3. Find the password field and type
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'Password123!');
      
      // 4. Tap the Login/Register button
      final actionButton = find.byType(ElevatedButton).first;
      await tester.tap(actionButton);
      
      // 5. Wait for the mocked auth delay (1 second) and routing animation
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 6. Verify we have successfully navigated to the Dashboard
      // The Dashboard has a Cyber Health Score wheel, usually a CustomPaint or a known text widget.
      final dashboardText = find.text('Dashboard');
      final healthScoreText = find.text('Cyber Health');
      
      // Depending on actual text on the dashboard, we check if one exists
      expect(dashboardText.or(healthScoreText), findsWidgets);
      
      // 7. Test navigation to URL Scanner
      // Find a button or InkWell that says 'URL Scanner' or similar.
      final urlScannerCard = find.text('URL Scanner');
      if (urlScannerCard.evaluate().isNotEmpty) {
        await tester.tap(urlScannerCard.first);
        await tester.pumpAndSettle();
        
        // Verify we are on URL Scanner screen
        expect(find.text('Scan URL'), findsWidgets);
        
        // Go back
        final backButton = find.byTooltip('Back');
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
      }

      // Test completed successfully!
    });
  });
}
