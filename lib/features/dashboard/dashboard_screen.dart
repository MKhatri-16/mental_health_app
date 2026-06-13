import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme.dart';
import '../mood_selector/mood_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final Function(int) onTabChange;

  const DashboardScreen({super.key, required this.onTabChange});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late String _randomQuote;

  final List<String> _quotes = [
    "JEE/NEET syllabus is a marathon, not a sprint. Pace yourself.",
    "A mock test ranking is a feedback mechanism, not your identity.",
    "Mistakes are proof that you are revision-building, not failing.",
    "One physics formula at a time. Slow progress is still progress.",
    "Breathe. No single exam decides your entire worth as a human.",
    "Take 10 minutes off. Your brain needs recovery to store information.",
  ];

  @override
  void initState() {
    super.initState();
    _randomQuote = _quotes[Random().nextInt(_quotes.length)];
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning Study Check';
    } else if (hour < 17) {
      return 'Afternoon Study Check';
    } else {
      return 'Evening Study Check';
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(studentMoodProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter and sort for weekly analytics (past 7 logs)
    final sortedList = List<StudentMoodEntry>.from(entries);
    sortedList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final recent = sortedList.length > 7 ? sortedList.sublist(sortedList.length - 7) : sortedList;

    // Build chart spots
    List<FlSpot> stressSpots = [];
    List<FlSpot> studySpots = [];
    for (int i = 0; i < recent.length; i++) {
      stressSpots.add(FlSpot(i.toDouble(), recent[i].stressScore.toDouble()));
      studySpots.add(FlSpot(i.toDouble(), recent[i].studyHours));
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome row with logo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.shieldCheck,
                            color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'MindGuard AI',
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'JEE/NEET Student Support Framework',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      isDark ? LucideIcons.sun : LucideIcons.moon,
                      color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                    ),
                    onPressed: () {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Study-Anxiety Quote
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppTheme.darkPrimary.withValues(alpha: 0.1), AppTheme.darkAccent.withValues(alpha: 0.05)]
                        : [AppTheme.lightPrimary.withValues(alpha: 0.05), AppTheme.lightAccent.withValues(alpha: 0.02)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppTheme.darkPrimary.withValues(alpha: 0.08) : AppTheme.lightPrimary.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.lightbulb, size: 36, color: Colors.amber),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting().toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _randomQuote,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Study Hours vs Stress level Graph
              Text(
                'Study Hours vs Stress correlation',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 24, 24, 16),
                  child: SizedBox(
                    height: 200,
                    child: recent.isEmpty
                        ? const Center(child: Text('Log entries to populate the tracker.'))
                        : LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (val) => FlLine(
                                  color: isDark
                                      ? AppTheme.darkPrimary.withValues(alpha: 0.04)
                                      : AppTheme.lightPrimary.withValues(alpha: 0.04),
                                ),
                              ),
                              titlesData: FlTitlesData(
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (val, meta) {
                                      return Text(
                                        '${val.toInt()}',
                                        style: GoogleFonts.inter(fontSize: 10),
                                      );
                                    },
                                    reservedSize: 22,
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (val, meta) {
                                      final idx = val.toInt();
                                      if (idx >= 0 && idx < recent.length) {
                                        final date = recent[idx].timestamp;
                                        return Text('${date.day}/${date.month}', style: const TextStyle(fontSize: 9));
                                      }
                                      return const Text('');
                                    },
                                    reservedSize: 18,
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              minY: 0,
                              maxY: 12, // study hours up to 12
                              lineBarsData: [
                                // Stress Level line
                                LineChartBarData(
                                  spots: stressSpots,
                                  isCurved: true,
                                  barWidth: 3,
                                  color: Colors.redAccent,
                                  dotData: const FlDotData(show: true),
                                ),
                                // Study Hours line
                                LineChartBarData(
                                  spots: studySpots,
                                  isCurved: true,
                                  barWidth: 3,
                                  color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                                  dotData: const FlDotData(show: true),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 12, height: 12, color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary),
                  const SizedBox(width: 6),
                  const Text('Study Hours (0-12)', style: TextStyle(fontSize: 11)),
                  const SizedBox(width: 24),
                  Container(width: 12, height: 12, color: Colors.redAccent),
                  const SizedBox(width: 6),
                  const Text('Anxiety/Stress (1-5)', style: TextStyle(fontSize: 11)),
                ],
              ),
              const SizedBox(height: 28),

              // Interactive copy features
              Text(
                'MindGuard Coping Utilities',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  _buildQuickAction(
                    title: 'Mood Selector',
                    desc: 'Log study anxiety & backlinks.',
                    icon: LucideIcons.smile,
                    color: Colors.green,
                    onTap: () => widget.onTabChange(1),
                  ),
                  _buildQuickAction(
                    title: 'AI Therapist',
                    desc: 'Vent or get coping advice.',
                    icon: LucideIcons.bot,
                    color: Colors.indigo,
                    onTap: () => widget.onTabChange(2),
                  ),
                  _buildQuickAction(
                    title: 'Mindful Break',
                    desc: 'Box breathing guide.',
                    icon: LucideIcons.wind,
                    color: Colors.teal,
                    onTap: () => widget.onTabChange(3),
                  ),
                  _buildQuickAction(
                    title: 'SOS Emergency',
                    desc: 'Helpline & panic grounding.',
                    icon: LucideIcons.alertOctagon,
                    color: Colors.red,
                    onTap: () => widget.onTabChange(4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppTheme.darkPrimary.withValues(alpha: 0.05) : Colors.grey.shade100,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
