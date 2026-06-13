import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_health_app/core/security/api_key_service.dart';
import 'package:mental_health_app/features/chat/chat_screen.dart';

// Mock ApiKeyService returning missing keys
class MockMissingApiKeyService extends ApiKeyService {
  @override
  bool get hasRequiredKeys => false;
}

// Mock ApiKeyService returning present keys
class MockPresentApiKeyService extends ApiKeyService {
  @override
  bool get hasRequiredKeys => true;
  @override
  String? getGeminiApiKey() => 'test_key';
}

void main() {
  group('Chat Screen TDD', () {
    testWidgets('should show API key configuration dialog when keys missing', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiKeyServiceProvider.overrideWithValue(MockMissingApiKeyService()),
          ],
          child: const MaterialApp(home: ChatScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Expectation: Dialog or warning appears asking user to add API keys
      expect(find.textContaining('API key'), findsOneWidget);
    });

    testWidgets('should show chat interface when API keys present', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiKeyServiceProvider.overrideWithValue(MockPresentApiKeyService()),
          ],
          child: const MaterialApp(home: ChatScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Expectation: Chat screen displays with input field
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should NOT display API key in chat input', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiKeyServiceProvider.overrideWithValue(MockPresentApiKeyService()),
          ],
          child: const MaterialApp(home: ChatScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Security test: Verify API key never visible in UI
      expect(find.text('test_key'), findsNothing);
      expect(find.textContaining('test_key'), findsNothing);
    });
  });
}
