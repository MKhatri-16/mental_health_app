import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:shared_preferences/shared_preferences.dart';

class SecureDatabaseService {
  final String _passcode;
  late enc.Encrypter _encrypter;
  late enc.IV _iv;

  SecureDatabaseService(this._passcode) {
    // Derive a 32-byte key from student's passcode using SHA-256
    final keyBytes = sha256.convert(utf8.encode(_passcode)).bytes;
    final key = enc.Key(Uint8List.fromList(keyBytes));
    
    _encrypter = enc.Encrypter(enc.AES(key));
    // Fixed initialization vector for local storage keys (or derived)
    _iv = enc.IV.fromLength(16);
  }

  // Encrypt and save a string key-value pair to local web storage
  Future<void> put(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = _encrypter.encrypt(value, iv: _iv);
    await prefs.setString('mindguard_secure_$key', encrypted.base64);
  }

  // Retrieve and decrypt a string key-value pair
  Future<String?> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final rawBase64 = prefs.getString('mindguard_secure_$key');
    if (rawBase64 == null) return null;
    
    try {
      final decrypted = _encrypter.decrypt64(rawBase64, iv: _iv);
      return decrypted;
    } catch (_) {
      // In case decryption fails (e.g. wrong passcode/corrupted data)
      return null;
    }
  }

  // Helper to store encrypted JSON objects (e.g., student mood history or chats)
  Future<void> putJson(String key, Map<String, dynamic> jsonMap) async {
    final jsonStr = jsonEncode(jsonMap);
    await put(key, jsonStr);
  }

  // Helper to fetch encrypted JSON objects
  Future<Map<String, dynamic>?> getJson(String key) async {
    final rawStr = await get(key);
    if (rawStr == null) return null;
    try {
      return jsonDecode(rawStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
