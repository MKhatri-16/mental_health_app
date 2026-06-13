import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPlaying = false;

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
        title: const Text('Mindful Space'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                'Box Breathing',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Calm your central nervous system & focus.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
              const Spacer(),

              // Animated Breathing Circle
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = _controller.value;
                  double scale = 1.0;
                  String phaseText = "Breathe";
                  int count = 4;

                  if (!_isPlaying) {
                    scale = 1.0;
                    phaseText = "Ready";
                    count = 4;
                  } else {
                    if (t < 0.333) {
                      // Inhale: 0s to 4s
                      final p = t / 0.333;
                      scale = 1.0 + p * 1.0; // scales from 1.0 to 2.0
                      phaseText = "Inhale";
                      count = (4 - (p * 4)).ceil();
                    } else if (t < 0.666) {
                      // Hold: 4s to 8s
                      final p = (t - 0.333) / 0.333;
                      scale = 2.0;
                      phaseText = "Hold";
                      count = (4 - (p * 4)).ceil();
                    } else {
                      // Exhale: 8s to 12s
                      final p = (t - 0.666) / 0.334;
                      scale = 2.0 - p * 1.0; // scales from 2.0 to 1.0
                      phaseText = "Exhale";
                      count = (4 - (p * 4)).ceil();
                    }
                  }

                  if (count < 1) count = 1;
                  if (count > 4) count = 4;

                  return Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glowing ripple (animated scale & opacity)
                        if (_isPlaying)
                          Transform.scale(
                            scale: scale * 1.25,
                            child: Opacity(
                              opacity: 0.15,
                              child: Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Main Breathing Circle
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
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
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

                        // Floating phase label below the circle
                        Transform.translate(
                          offset: const Offset(0, 140),
                          child: Text(
                            phaseText.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Spacer(),

              // Controls Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
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
                          _isPlaying ? LucideIcons.square : LucideIcons.play,
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
                              _isPlaying ? 'Cycle Active' : 'Start Session',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _isPlaying
                                  ? 'Match your breath to the expanding circle.'
                                  : 'Press play to begin a 1-minute box session.',
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
