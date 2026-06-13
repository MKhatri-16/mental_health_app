import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/security/api_key_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // SECURITY CHECK: Validate API keys before app starts
  try {
    final apiKeyService = ApiKeyService();
    if (!apiKeyService.hasRequiredKeys) {
      // Show warning (but don't crash - user can configure later)
      debugPrint('⚠️ API keys missing. App will show configuration dialog on launch.');
    }
  } catch (e) {
    debugPrint('⚠️ Error checking API keys: $e');
  }

  runApp(
    const ProviderScope(
      child: MindGuardApp(),
    ),
  );
}
