import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_health_app/features/mood_selector/mood_screen.dart';

void main() {
  group('Mood Screen TDD', () {
    testWidgets('should display stress slider and save button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: MoodScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsWidgets);
      expect(find.textContaining('Save'), findsOneWidget);
    });
  });
}
