import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import 'mood_provider.dart';

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  int _stressScore = 3;
  double _studyHours = 8.0;
  String _selectedCategory = 'Mock Exam stress';
  final TextEditingController _noteController = TextEditingController();

  final List<String> _categories = [
    'Mock Exam stress',
    'Revision Backlog',
    'Physics Anxiety',
    'Organic Chem panic',
    'Peer Pressure',
    'Parental Expectations',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitLog() {
    final note = _noteController.text.trim();
    ref.read(studentMoodProvider.notifier).addEntry(
          stressScore: _stressScore,
          category: _selectedCategory,
          note: note,
          studyHours: _studyHours,
        );

    _noteController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.check, color: Colors.white),
            const SizedBox(width: 8),
            Text('Stress log saved securely using AES.', style: GoogleFonts.inter()),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(studentMoodProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Student Stress'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Stress Level Assessment',
                      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Slider
                    Slider(
                      value: _stressScore.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: Colors.redAccent,
                      label: 'Stress: $_stressScore',
                      onChanged: (val) {
                        setState(() {
                          _stressScore = val.toInt();
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1 - Focused/Calm', style: GoogleFonts.inter(fontSize: 11)),
                        Text('5 - Panicked/Burnout', style: GoogleFonts.inter(fontSize: 11, color: Colors.redAccent)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Study Hours Slider
                    Text(
                      'Study Hours Logged Today: ${_studyHours.toStringAsFixed(1)} hrs',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Slider(
                      value: _studyHours,
                      min: 0,
                      max: 16,
                      divisions: 32,
                      activeColor: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                      onChanged: (val) {
                        setState(() {
                          _studyHours = val;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Category wrap selector
                    Text(
                      'Stress Source Category',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final isSel = _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                          child: Chip(
                            label: Text(cat),
                            backgroundColor: isSel
                                ? (isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary)
                                : (isDark ? AppTheme.darkCard : Colors.white),
                            labelStyle: GoogleFonts.inter(
                              fontSize: 12,
                              color: isSel
                                  ? (isDark ? AppTheme.darkBg : Colors.white)
                                  : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Notes field
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Describe the stress scenario (Venting help)',
                              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _noteController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'E.g., Unable to solve HC Verma physics problems, revisions pending...',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Save log button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitLog,
                        child: Text(
                          'Save Encrypted Log',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'Previous Encrypted Logs',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              logs.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text('No stress logs recorded yet.'),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final log = logs[index];
                          final date = '${log.timestamp.day}/${log.timestamp.month}/${log.timestamp.year}';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Chip(
                                        label: Text(log.category),
                                        backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
                                        labelStyle: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '$date • Study: ${log.studyHours}h • Stress: ${log.stressScore}/5',
                                        style: GoogleFonts.inter(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  if (log.note.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      log.note,
                                      style: GoogleFonts.inter(fontSize: 13, height: 1.3),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: logs.length,
                      ),
                    ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }
}
