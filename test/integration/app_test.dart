import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mental_health_app/app.dart';
import 'package:mental_health_app/features/dashboard/dashboard_screen.dart';
import 'package:mental_health_app/features/mood_selector/mood_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('MindGuard AI Student Flow Integration Test', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Verify student PIN unlock, dashboard load, stress log submission, and SOS crisis panels', (WidgetTester tester) async {
      // Set desktop web-sized viewport for testing
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // 1. Build MindGuard AI application
      await tester.pumpWidget(
        const ProviderScope(
          child: MindGuardApp(),
        ),
      );
      await tester.pumpAndSettle();

      // 2. Expect to find PIN login gateway
      expect(find.text('MindGuard AI'), findsOneWidget);
      expect(find.text('Create/Enter Security PIN'), findsOneWidget);

      // 3. Input security PIN and tap Unlock
      await tester.enterText(find.byType(TextFormField), '1234');
      await tester.tap(find.text('Unlock Shield'));
      await tester.pump(const Duration(milliseconds: 300));

      // 4. Verify that Dashboard Screen has loaded successfully
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.textContaining('JEE/NEET Student Support'), findsOneWidget);
      expect(find.textContaining('Study Hours vs Stress'), findsOneWidget);

      // 5. Navigate to Stress Log tab (index 1 of bottom navigation)
      final moodTab = find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.byIcon(LucideIcons.smile),
      );
      expect(moodTab, findsOneWidget);
      await tester.tap(moodTab);
      await tester.pump(const Duration(milliseconds: 300));

      // 6. Verify Stress Log Screen loaded
      expect(find.byType(MoodScreen), findsOneWidget);
      expect(find.text('Stress Level Assessment'), findsOneWidget);

      // 7. Write a reflective stress note and save the log
      await tester.enterText(find.byType(TextField), 'Revision backlog in organic chem mechanisms is causing severe stress.');
      await tester.ensureVisible(find.text('Save Encrypted Log'));
      await tester.tap(find.text('Save Encrypted Log'));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify success snackbar appears
      expect(find.textContaining('Stress log saved securely'), findsOneWidget);

      // 8. Go to SOS emergency panic tab (index 4 of bottom navigation)
      final sosTab = find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.byIcon(LucideIcons.alertOctagon),
      );
      expect(sosTab, findsOneWidget);
      await tester.tap(sosTab);
      await tester.pump(const Duration(milliseconds: 300));

      // 9. Verify SOS panel loaded and activate panic button
      expect(find.text('SOS PANIC'), findsOneWidget);
      await tester.tap(find.text('SOS PANIC'));
      await tester.pump(const Duration(milliseconds: 300));

      // 10. Verify crisis helplines and grounding exercises appear
      expect(find.textContaining('Crisis Shield Activated'), findsOneWidget);
      expect(find.textContaining('Grounding: The 5-4-3-2-1 Technique'), findsOneWidget);
      expect(find.textContaining('Kiran Helpline'), findsOneWidget);
    });
  });
}
