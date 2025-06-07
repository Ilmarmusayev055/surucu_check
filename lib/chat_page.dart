import 'package:flutter/material.dart';
import 'package:surucu_check/l10n/app_localizations.dart';
import 'package:surucu_check/gemini_service.dart'; // ✅ Gemini servisini əlavə etdik
import 'dart:ui';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // ✅ Həm istifadəçi, həm də AI mesajları üçün

  final GeminiService _geminiService = GeminiService(); // ✅ Gemini servisini yarat

  void _sendMessage() async {
    final userText = _messageController.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      _messages.add({'text': userText, 'isUser': true}); // İstifadəçi mesajı
      _messageController.clear();
    });

    final aiReply = await _geminiService.getGeminiResponse(userText); // ✅ Gemini API cavabı
    setState(() {
      _messages.add({'text': aiReply, 'isUser': false}); // AI cavabı
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.chatTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            shadows: [Shadow(blurRadius: 5.0, color: Colors.black38, offset: Offset(1.0, 1.0))],
          ),
        ),
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8A2BE2), Color(0xFFDA70D6), Color(0xFFFF69B4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[_messages.length - 1 - index];
                    final isUser = message['isUser'] as bool;
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.greenAccent.withOpacity(0.2)
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          message['text'],
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: loc.typeMessage,
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                          ),
                          onSubmitted: (value) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
