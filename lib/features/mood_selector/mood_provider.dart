import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/security/auth_provider.dart';

class StudentMoodEntry {
  final String id;
  final int stressScore; // 1 (Relaxed) to 5 (Extremely Panicked)
  final String category; // Revision Backlog, Mock Exam, Physics Anxiety, etc.
  final String note;
  final DateTime timestamp;
  final double studyHours; // Study hours logged that day

  StudentMoodEntry({
    required this.id,
    required this.stressScore,
    required this.category,
    required this.note,
    required this.timestamp,
    required this.studyHours,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stressScore': stressScore,
      'category': category,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
      'studyHours': studyHours,
    };
  }

  factory StudentMoodEntry.fromJson(Map<String, dynamic> json) {
    return StudentMoodEntry(
      id: json['id'] as String,
      stressScore: json['stressScore'] as int,
      category: json['category'] as String,
      note: json['note'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      studyHours: (json['studyHours'] as num).toDouble(),
    );
  }
}

final studentMoodProvider = StateNotifierProvider<StudentMoodNotifier, List<StudentMoodEntry>>((ref) {
  return StudentMoodNotifier(ref);
});

class StudentMoodNotifier extends StateNotifier<List<StudentMoodEntry>> {
  final Ref _ref;

  StudentMoodNotifier(this._ref) : super([]) {
    _loadEntries();
  }

  static const String _dbKey = 'student_stress_logs';

  Future<void> _loadEntries() async {
    final db = _ref.read(secureDbProvider);
    if (db == null) return;

    final jsonMap = await db.getJson(_dbKey);
    if (jsonMap != null && jsonMap['entries'] != null) {
      final List<dynamic> rawList = jsonMap['entries'];
      state = rawList.map((e) => StudentMoodEntry.fromJson(e)).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } else {
      // Prepopulate mock JEE/NEET study logs
      final now = DateTime.now();
      final mock = [
        StudentMoodEntry(
          id: 'mock_1',
          stressScore: 4,
          category: 'Mock Exam stress',
          note: 'Scored low in mock test. Feeling anxious about rankings.',
          timestamp: now.subtract(const Duration(days: 4)),
          studyHours: 8.5,
        ),
        StudentMoodEntry(
          id: 'mock_2',
          stressScore: 3,
          category: 'Revision Backlog',
          note: 'Trying to catch up on Organic Chemistry mechanics.',
          timestamp: now.subtract(const Duration(days: 3)),
          studyHours: 7.0,
        ),
        StudentMoodEntry(
          id: 'mock_3',
          stressScore: 5,
          category: 'Physics Anxiety',
          note: 'Rotational dynamics questions are extremely difficult.',
          timestamp: now.subtract(const Duration(days: 2)),
          studyHours: 9.0,
        ),
        StudentMoodEntry(
          id: 'mock_4',
          stressScore: 2,
          category: 'Peer Pressure',
          note: 'Discussed prep with study group. Felt more relaxed.',
          timestamp: now.subtract(const Duration(days: 1)),
          studyHours: 6.0,
        ),
      ];
      state = mock..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      await _saveEntries();
    }
  }

  Future<void> addEntry({
    required int stressScore,
    required String category,
    required String note,
    required double studyHours,
  }) async {
    final newEntry = StudentMoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      stressScore: stressScore,
      category: category,
      note: note,
      timestamp: DateTime.now(),
      studyHours: studyHours,
    );

    state = [newEntry, ...state]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    await _saveEntries();
  }

  Future<void> _saveEntries() async {
    final db = _ref.read(secureDbProvider);
    if (db == null) return;

    final jsonMap = {
      'entries': state.map((e) => e.toJson()).toList(),
    };
    await db.putJson(_dbKey, jsonMap);
  }
}
