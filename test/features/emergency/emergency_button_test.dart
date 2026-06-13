import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_health_app/features/emergency/emergency_screen.dart';

void main() {
  group('Emergency Screen TDD', () {
    testWidgets('should display SOS button and helpline numbers', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: EmergencyScreen()),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('SOS PANIC'), findsOneWidget);
      
      // Tap the panic button
      await tester.tap(find.textContaining('SOS PANIC'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Kiran'), findsWidgets);
    });
  });
}
