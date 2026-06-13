import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';

class MindfulnessScreen extends StatefulWidget {
  const MindfulnessScreen({super.key});

  @override
  State<MindfulnessScreen> createState() => _MindfulnessScreenState();
}

class _MindfulnessScreenState extends State<MindfulnessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPlaying = false;
  int _sessionDurationMinutes = 1; // Default session duration

  @override
  void initState() {
    super.initState();
    // 12-second total cycle (4s Inhale, 4s Hold, 4s Exhale)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindfulness Corner'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                'JEE/NEET Focus Break',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Relieve eye strain & exam overload with 4-4-4 deep breathing.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
              const Spacer(),

              // Timer selectors
              if (!_isPlaying)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [1, 3, 5].map((min) {
                    final isSel = _sessionDurationMinutes == min;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _sessionDurationMinutes = min;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel
                              ? (isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary)
                              : (isDark ? AppTheme.darkCard : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel
                                ? Colors.transparent
                                : (isDark ? AppTheme.darkPrimary.withValues(alpha: 0.1) : Colors.grey.shade200),
                          ),
                        ),
                        child: Text(
                          '$min Min',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            color: isSel
                                ? (isDark ? AppTheme.darkBg : Colors.white)
                                : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const Spacer(),

              // Pulsing Animated Circle
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = _controller.value;
                  double scale = 1.0;
                  String phaseText = "Prepare";
                  int count = 4;

                  if (!_isPlaying) {
                    scale = 1.0;
                    phaseText = "Ready";
                    count = 4;
                  } else {
                    if (t < 0.333) {
                      // Inhale: 4s
                      final p = t / 0.333;
                      scale = 1.0 + p * 1.0; // 1.0 to 2.0
                      phaseText = "Inhale (Focus)";
                      count = (4 - (p * 4)).ceil();
                    } else if (t < 0.666) {
                      // Hold: 4s
                      final p = (t - 0.333) / 0.333;
                      scale = 2.0;
                      phaseText = "Hold (Steady)";
                      count = (4 - (p * 4)).ceil();
                    } else {
                      // Exhale: 4s
                      final p = (t - 0.666) / 0.334;
                      scale = 2.0 - p * 1.0; // 2.0 to 1.0
                      phaseText = "Exhale (Release)";
                      count = (4 - (p * 4)).ceil();
                    }
                  }

                  if (count < 1) count = 1;
                  if (count > 4) count = 4;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isPlaying)
                        Transform.scale(
                          scale: scale * 1.3,
                          child: Opacity(
                            opacity: 0.12,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                                    blurRadius: 35,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [AppTheme.darkPrimary, AppTheme.darkAccent]
                                  : [AppTheme.lightPrimary, AppTheme.lightAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _isPlaying ? '$count' : 'Go',
                              style: GoogleFonts.outfit(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkBg : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, 150),
                        child: Text(
                          phaseText.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.5,
                            color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const Spacer(),
              const Spacer(),

              // Play/Pause Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _togglePlay,
                        style: IconButton.styleFrom(
                          backgroundColor: isDark
                              ? AppTheme.darkPrimary.withValues(alpha: 0.1)
                              : AppTheme.lightPrimary.withValues(alpha: 0.08),
                          padding: const EdgeInsets.all(16),
                        ),
                        icon: Icon(
                          _isPlaying ? LucideIcons.pause : LucideIcons.play,
                          color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isPlaying ? 'Breathing Activated' : 'Start Focus session',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _isPlaying
                                  ? 'Match your breathing to the glowing animation.'
                                  : 'Press play to begin a $_sessionDurationMinutes-minute cooldown.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
