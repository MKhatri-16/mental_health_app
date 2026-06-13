import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mood_model.dart';

final moodProvider = StateNotifierProvider<MoodNotifier, List<MoodEntry>>((ref) {
  return MoodNotifier();
});

class MoodNotifier extends StateNotifier<List<MoodEntry>> {
  MoodNotifier() : super([]) {
    _loadLogs();
  }

  static const String _storageKey = 'mood_entries_key';

  Future<void> _loadLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_storageKey);
      if (savedData != null) {
        final List<dynamic> jsonList = jsonDecode(savedData);
        final list = jsonList.map((e) => MoodEntry.fromJson(e)).toList();
        // Sort by timestamp descending
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        state = list;
      } else {
        // Prepopulate mock data for a beautiful initial visual experience
        _loadMockData();
      }
    } catch (e) {
      // In case of error, load mock data anyway
      _loadMockData();
    }
  }

  void _loadMockData() {
    final now = DateTime.now();
    final mockEntries = [
      MoodEntry(
        id: 'mock1',
        score: 4,
        note: 'Had a productive coding session today.',
        timestamp: now.subtract(const Duration(days: 4)),
      ),
      MoodEntry(
        id: 'mock2',
        score: 3,
        note: 'Felt a bit tired and lazy in the afternoon.',
        timestamp: now.subtract(const Duration(days: 3)),
      ),
      MoodEntry(
        id: 'mock3',
        score: 2,
        note: 'Stressed about a deadline, but took a walk.',
        timestamp: now.subtract(const Duration(days: 2)),
      ),
      MoodEntry(
        id: 'mock4',
        score: 5,
        note: 'Completed all goals and hung out with friends!',
        timestamp: now.subtract(const Duration(days: 1)),
      ),
    ];
    // Sort by timestamp descending
    mockEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = mockEntries;
  }

  Future<void> addEntry(int score, String note) async {
    final newEntry = MoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      score: score,
      note: note,
      timestamp: DateTime.now(),
    );

    final updatedState = [newEntry, ...state];
    // Keep it sorted
    updatedState.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = updatedState;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = state.map((e) => e.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {
      // Silently ignore write failures in mock mode
    }
  }
}
