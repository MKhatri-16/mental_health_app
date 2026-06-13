import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/envied.dart';

final apiKeyServiceProvider = Provider((ref) => ApiKeyService());

class ApiKeyService {
  // Read API keys from ENVied (obfuscated in release builds)
  
  bool get hasRequiredKeys {
    return getGeminiApiKey() != null;
  }
  
  String? getGeminiApiKey() {
    try {
      final key = Env.geminiApiKey;
      if (_isInvalidKey(key)) {
        _logWarning('Gemini API key');
        return null;
      }
      return key;
    } catch (_) {
      _logWarning('Gemini API key');
      return null;
    }
  }

  String? getHuggingFaceToken() {
    try {
      final token = Env.hfToken;
      if (_isInvalidKey(token)) {
        _logWarning('HuggingFace Token');
        return null;
      }
      return token;
    } catch (_) {
      _logWarning('HuggingFace Token');
      return null;
    }
  }

  String? getGroqApiKey() {
    try {
      final key = Env.groqApiKey;
      if (_isInvalidKey(key)) {
        _logWarning('Groq API key');
        return null;
      }
      return key;
    } catch (_) {
      _logWarning('Groq API key');
      return null;
    }
  }

  bool _isInvalidKey(String? key) {
    if (key == null || key.isEmpty) return true;
    final normalized = key.toLowerCase().trim();
    return normalized.contains('your_') || normalized == 'placeholder' || normalized.contains('mock');
  }

  void _logWarning(String keyName) {
    // Print user-friendly instructions without leaking raw key names or values
    // ignore: avoid_print
    print('MindGuard Secure Shield: [WARNING] $keyName is missing. Please add your API key in .env file');
  }
}
