import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_health_app/app.dart';
import 'package:mental_health_app/core/security/api_key_service.dart';

// A mock ApiKeyService that simulates missing keys
class MockMissingApiKeyService extends ApiKeyService {
  @override
  bool get hasRequiredKeys => false;
}

// A mock ApiKeyService that simulates present keys
class MockPresentApiKeyService extends ApiKeyService {
  @override
  bool get hasRequiredKeys => true;
}

void main() {
  group('Security Config Integration Test', () {
    testWidgets('Should display missing API key dialog if keys are invalid', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiKeyServiceProvider.overrideWithValue(MockMissingApiKeyService()),
          ],
          child: const MindGuardApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Expect the API Keys Missing dialog to appear
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('API Keys Missing'), findsOneWidget);
      expect(find.text('Understood'), findsOneWidget);

      // Tap Understood
      await tester.tap(find.text('Understood'));
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Should NOT display missing API key dialog if keys are valid', (WidgetTester tester) async {
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

      // Dialog should not appear
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('API Keys Missing'), findsNothing);
    });
  });
}
