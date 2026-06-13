import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_health_app/features/mindfulness/mindfulness_screen.dart';

void main() {
  group('Mindfulness Screen TDD', () {
    testWidgets('should display breathing animation indicator', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: MindfulnessScreen()),
        ),
      );

      // Don't pumpAndSettle because of infinite animation
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('breathing'), findsOneWidget);
    });
  });
}
