import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'secure_db_service.dart';

// Provider to hold the student's passcode PIN (null if locked)
final userPasscodeProvider = StateProvider<String?>((ref) => null);

// Provider to instantiate the SecureDatabaseService using the passcode
final secureDbProvider = Provider<SecureDatabaseService?>((ref) {
  final passcode = ref.watch(userPasscodeProvider);
  if (passcode == null) return null;
  return SecureDatabaseService(passcode);
});

// Provider to check if the student is authenticated (has entered a PIN)
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(userPasscodeProvider) != null;
});
