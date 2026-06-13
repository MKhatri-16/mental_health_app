import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import 'mood_provider.dart';

class MoodLogScreen extends ConsumerStatefulWidget {
  const MoodLogScreen({super.key});

  @override
  ConsumerState<MoodLogScreen> createState() => _MoodLogScreenState();
}

class _MoodLogScreenState extends ConsumerState<MoodLogScreen> {
  int _selectedScore = 3; // Neutral by default
  final TextEditingController _noteController = TextEditingController();

  final List<Map<String, dynamic>> _moodsConfig = [
    {'score': 1, 'emoji': '😢', 'label': 'Down'},
    {'score': 2, 'emoji': '😔', 'label': 'Unwell'},
    {'score': 3, 'emoji': '😐', 'label': 'Neutral'},
    {'score': 4, 'emoji': '🙂', 'label': 'Good'},
    {'score': 5, 'emoji': '😊', 'label': 'Excellent'},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitMood() {
    final note = _noteController.text.trim();
    ref.read(moodProvider.notifier).addEntry(_selectedScore, note);
    _noteController.clear();
    // Show a premium bottom toast/snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.checkCircle2, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Mood logged successfully. Take care!',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: AppTheme.darkSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final moods = ref.watch(moodProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Sanctuary'),
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
                      'How are you feeling right now?',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Interactive Emoji Selector Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _moodsConfig.map((config) {
                        final score = config['score'] as int;
                        final isSelected = _selectedScore == score;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedScore = score;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutBack,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark
                                      ? AppTheme.darkPrimary.withValues(alpha: 0.12)
                                      : AppTheme.lightPrimary.withValues(alpha: 0.08))
                                  : (isDark ? AppTheme.darkCard : Colors.white),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? (isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary)
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: (isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary)
                                            .withValues(alpha: 0.15),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Column(
                              children: [
                                AnimatedScale(
                                  scale: isSelected ? 1.25 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Text(
                                    config['emoji'] as String,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  config['label'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected
                                        ? (isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary)
                                        : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Journal Notes Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.darkPrimary.withValues(alpha: 0.06)
                              : Colors.grey.shade100,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.bookOpen,
                                size: 20,
                                color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Write down notes (Optional)',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _noteController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'What\'s causing this mood? Reflection brings peace...',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 13,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? AppTheme.darkBg
                                  : AppTheme.lightBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Log Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitMood,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.penTool, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Save Mood Entry',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Mood History Title
                    Text(
                      'Log History',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Slivers for Mood History List
              moods.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'No logs recorded yet. Start by logging your mood above.',
                            style: GoogleFonts.inter(
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final entry = moods[index];
                          final formattedTime =
                              '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}';
                          final formattedDate =
                              '${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year}';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Left side color bar
                                  Container(
                                    width: 6,
                                    decoration: BoxDecoration(
                                      color: entry.color,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(24),
                                        bottomLeft: Radius.circular(24),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    entry.emoji,
                                                    style: const TextStyle(fontSize: 24),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    entry.label,
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w600,
                                                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '$formattedDate • $formattedTime',
                                                style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (entry.note.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              entry.note,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: moods.length,
                      ),
                    ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
