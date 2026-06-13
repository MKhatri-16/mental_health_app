import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'core/security/auth_provider.dart';
import 'core/theme.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/mood_selector/mood_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/mindfulness/mindfulness_screen.dart';
import 'features/emergency/emergency_screen.dart';

import 'core/security/api_key_service.dart';

class MindGuardApp extends ConsumerWidget {
  const MindGuardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'MindGuard AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SecurityGate(),
    );
  }
}

class SecurityGate extends ConsumerStatefulWidget {
  const SecurityGate({super.key});

  @override
  ConsumerState<SecurityGate> createState() => _SecurityGateState();
}

class _SecurityGateState extends ConsumerState<SecurityGate> {
  final TextEditingController _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final apiKeyService = ref.read(apiKeyServiceProvider);
      if (!apiKeyService.hasRequiredKeys) {
        _showApiKeyConfigurationDialog(context);
      }
    });
  }

  void _showApiKeyConfigurationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🔐 API Keys Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MindGuard AI needs API keys to provide AI-powered mental wellness support.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Get FREE API keys (no credit card required):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildApiKeyInfo(
              'Gemini AI',
              '1M tokens/day FREE',
              'https://aistudio.google.com/',
            ),
            _buildApiKeyInfo(
              'Hugging Face',
              '30K requests/month FREE',
              'https://huggingface.co/',
            ),
            _buildApiKeyInfo(
              'Groq',
              'Unlimited FREE',
              'https://console.groq.com/',
            ),
            const SizedBox(height: 16),
            const Text(
              'Steps:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('1. Create .env file in project root'),
            const Text('2. Add your keys:'),
            const Text('   GEMINI_API_KEY=your_key_here'),
            const Text('   HUGGINGFACE_TOKEN=your_token_here'),
            const Text('   GROQ_API_KEY=your_key_here'),
            const Text('3. Run: flutter pub run build_runner build'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // User can use app without AI (limited features)
            },
            child: const Text('Use App Without AI'),
          ),
          ElevatedButton(
            onPressed: () {
              // User will configure and restart app
              Navigator.pop(context);
            },
            child: const Text('I\'ll Configure Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyInfo(String name, String limit, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.key, size: 16, color: Color(0xFF4A90E8)),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text('($limit)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Link opening logic would go here
                },
                child: const Text('Get Key', style: TextStyle(fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _authenticate() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(userPasscodeProvider.notifier).state = _pinController.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (isAuthenticated) {
      return const MainNavigationLayout();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
              border: Border.all(
                color: isDark
                    ? AppTheme.darkPrimary.withValues(alpha: 0.08)
                    : Colors.grey.shade100,
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Emblem
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.shieldAlert,
                      color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'MindGuard AI',
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'JEE/NEET Mental Health Shield',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // PIN Input Field
                  TextFormField(
                    controller: _pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.outfit(fontSize: 18, letterSpacing: 6, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '••••',
                      hintStyle: const TextStyle(letterSpacing: 6),
                      labelText: 'Create/Enter Security PIN',
                      labelStyle: GoogleFonts.inter(
                        fontSize: 12,
                        letterSpacing: 0,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                      ),
                      filled: true,
                      fillColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.length < 4) {
                        return 'PIN must be at least 4 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'This PIN is hashed to derive an AES-256 key. Your study/anxiety records are encrypted locally and never sent to a cloud database.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _authenticate,
                      child: Text(
                        'Unlock Shield',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainNavigationLayout extends StatefulWidget {
  const MainNavigationLayout({super.key});

  @override
  State<MainNavigationLayout> createState() => _MainNavigationLayoutState();
}

class _MainNavigationLayoutState extends State<MainNavigationLayout> {
  int _currentIndex = 0;

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(onTabChange: _onTabChanged),
      const MoodScreen(),
      const ChatScreen(),
      const MindfulnessScreen(),
      const EmergencyScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabChanged,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.home),
              activeIcon: Icon(LucideIcons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.smile),
              activeIcon: Icon(LucideIcons.smile),
              label: 'Stress Log',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.bot),
              activeIcon: Icon(LucideIcons.bot),
              label: 'Therapist',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.wind),
              activeIcon: Icon(LucideIcons.wind),
              label: 'Breathe',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.alertOctagon),
              activeIcon: Icon(LucideIcons.alertOctagon),
              label: 'SOS',
            ),
          ],
          selectedLabelStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.normal,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
