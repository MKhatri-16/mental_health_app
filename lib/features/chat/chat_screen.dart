import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dio/dio.dart';
import '../../core/security/api_key_service.dart';
import '../../core/theme.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I am your MindGuard AI companion. Competitive exam prep can be exhausting. Feel free to talk to me about backlog stress, mock test anxiety, or ask for quick study break tips. How are you feeling today?",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  final ApiKeyService _apiKeyService = ApiKeyService();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final userText = _messageController.text.trim();
    if (userText.isEmpty) return;

    _messageController.clear();
    setState(() {
      _messages.add(ChatMessage(text: userText, isUser: true, timestamp: DateTime.now()));
      _isLoading = true;
    });
    _scrollToBottom();

    // Check for API key presence
    final apiKey = _apiKeyService.getGeminiApiKey();
    if (apiKey == null) {
      setState(() {
        _messages.add(ChatMessage(
          text: "MindGuard Secure Shield: Gemini API Key is missing. Please add your API key in .env file.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      _scrollToBottom();
      return;
    }

    try {
      final dio = Dio();
      final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey';
      
      final response = await dio.post(
        url,
        data: {
          'contents': [
            {
              'parts': [
                {'text': userText}
              ]
            }
          ],
          'systemInstruction': {
            'parts': [
              {
                'text': "You are MindGuard AI, an empathetic student mental health counselor for NEET and JEE competitive exam aspirants. Offer warm guidance, quick study break exercises, motivation, and positive reinforcement. Keep responses concise (under 4 sentences) and highly encouraging. Encourage short breathing breaks or walks when stress is high."
              }
            ]
          }
        },
      );

      final reply = response.data['candidates'][0]['content']['parts'][0]['text'] as String;

      setState(() {
        _messages.add(ChatMessage(text: reply.trim(), isUser: false, timestamp: DateTime.now()));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "I am having trouble connecting to my cognitive cores. Don't worry, take a slow deep breath, and let's try again in a few seconds.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final apiKeyMissing = _apiKeyService.getGeminiApiKey() == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MindGuard AI Therapist'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Warning Banner for Missing API Keys
            if (apiKeyMissing)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.amber.shade900.withValues(alpha: 0.15),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertTriangle, color: Colors.amber, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please add your API key in .env file (GEMINI_API_KEY) and rerun build_runner to activate the AI Therapist.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Chat Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isAi = !msg.isUser;
                  return Align(
                    alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isAi
                            ? (isDark ? AppTheme.darkCard : Colors.white)
                            : (isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: isAi ? Radius.zero : const Radius.circular(20),
                          bottomRight: isAi ? const Radius.circular(20) : Radius.zero,
                        ),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                        border: isAi
                            ? Border.all(
                                color: isDark
                                    ? AppTheme.darkPrimary.withValues(alpha: 0.05)
                                    : Colors.grey.shade100,
                              )
                            : null,
                      ),
                      child: Text(
                        msg.text,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.4,
                          color: isAi
                              ? (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary)
                              : (isDark ? AppTheme.darkBg : Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              ),

            // Input panel
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppTheme.darkPrimary.withValues(alpha: 0.06)
                        : Colors.grey.shade200,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type your message (e.g. Backlog in organic chem)...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                        ),
                        filled: true,
                        fillColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _sendMessage,
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                      foregroundColor: isDark ? AppTheme.darkBg : Colors.white,
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: const Icon(LucideIcons.send, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
