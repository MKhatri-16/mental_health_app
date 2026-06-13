import 'package:flutter/material.dart';

class MoodEntry {
  final String id;
  final int score; // 1 (Very Bad) to 5 (Excellent)
  final String note;
  final DateTime timestamp;

  MoodEntry({
    required this.id,
    required this.score,
    required this.note,
    required this.timestamp,
  });

  String get emoji {
    switch (score) {
      case 1:
        return '😢';
      case 2:
        return '😔';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😊';
      default:
        return '😐';
    }
  }

  String get label {
    switch (score) {
      case 1:
        return 'Down';
      case 2:
        return 'Unwell';
      case 3:
        return 'Neutral';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return 'Neutral';
    }
  }

  Color get color {
    switch (score) {
      case 1:
        return const Color(0xFFEF4444); // Red
      case 2:
        return const Color(0xFFF97316); // Orange
      case 3:
        return const Color(0xFFEAB308); // Yellow
      case 4:
        return const Color(0xFF10B981); // Green
      case 5:
        return const Color(0xFF6366F1); // Indigo
      default:
        return Colors.grey;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': score,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      score: json['score'] as int,
      note: json['note'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
