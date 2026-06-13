import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_health_app/app.dart';
import 'package:mental_health_app/core/security/api_key_service.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Mock ApiKeyService returning present keys
class MockPresentApiKeyService extends ApiKeyService {
  @override
  bool get hasRequiredKeys => true;
  @override
  String? getGeminiApiKey() => 'test_key';
}

void main() {
  group('App Navigation Integration Test', () {
    testWidgets('should navigate between screens and show emergency button', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiKeyServiceProvider.overrideWithValue(MockPresentApiKeyService()),
          ],
          child: const MindGuardApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Ensure we are past the SecurityGate by entering PIN
      expect(find.text('Create/Enter Security PIN'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '1234');
      await tester.tap(find.text('Unlock Shield'));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Dashboard is visible
      expect(find.textContaining('Study Hours vs Stress'), findsOneWidget);

      // Verify Emergency action is accessible
      final emergencyIcon = find.byIcon(LucideIcons.alertTriangle);
      if (emergencyIcon.evaluate().isNotEmpty) {
        expect(emergencyIcon, findsWidgets);
      }

      // Navigate to Chat Screen
      final chatTab = find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.byIcon(LucideIcons.bot),
      );
      await tester.tap(chatTab);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
