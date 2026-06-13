import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mental_health_app/core/security/secure_db_service.dart';

void main() {
  group('SecureDatabaseService Unit Tests', () {
    const String correctPasscode = 'neet_jee_pass_2026';
    const String incorrectPasscode = 'wrong_passcode';
    
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Data can be encrypted and successfully decrypted with correct passcode', () async {
      final db = SecureDatabaseService(correctPasscode);
      const testKey = 'stress_note';
      const testValue = 'Backlog in organic chemistry is causing anxiety';

      await db.put(testKey, testValue);
      final retrieved = await db.get(testKey);

      expect(retrieved, equals(testValue));
    });

    test('Decryption fails and returns null when initialized with wrong passcode', () async {
      final dbCorrect = SecureDatabaseService(correctPasscode);
      final dbWrong = SecureDatabaseService(incorrectPasscode);
      
      const testKey = 'secret_log';
      const testValue = 'Scored low in mock test 5';

      await dbCorrect.put(testKey, testValue);
      final retrieved = await dbWrong.get(testKey);

      expect(retrieved, isNull);
    });

    test('JSON serialization/deserialization works securely', () async {
      final db = SecureDatabaseService(correctPasscode);
      const testKey = 'mood_data';
      final testJson = {
        'mood': 'Anxious',
        'stress_level': 4,
        'subject': 'Physics',
      };

      await db.putJson(testKey, testJson);
      final retrieved = await db.getJson(testKey);

      expect(retrieved, isNotNull);
      expect(retrieved!['mood'], equals('Anxious'));
      expect(retrieved['stress_level'], equals(4));
      expect(retrieved['subject'], equals('Physics'));
    });
  });
}
