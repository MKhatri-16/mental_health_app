import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_health_app/app.dart';

void main() {
  testWidgets('App renders secure login gate successfully test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MindGuardApp(),
      ),
    );

    // Verify security PIN gateway is present
    expect(find.text('MindGuard AI'), findsOneWidget);
    expect(find.text('Create/Enter Security PIN'), findsOneWidget);
    expect(find.text('Unlock Shield'), findsOneWidget);
  });
}
