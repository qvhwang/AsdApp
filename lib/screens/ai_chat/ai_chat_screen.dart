import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/chat_message_model.dart';
import '../../models/child_model.dart';
import '../../models/user_model.dart';
import '../../services/ai_service.dart';

class AIChatScreen extends StatefulWidget {
  final ChildModel child;
  final UserModel user;

  const AIChatScreen({Key? key, required this.child, required this.user})
    : super(key: key);

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final data = await AIService.getHistory(widget.child.id);

      setState(() {
        messages = data;
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('Load history error: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final question = _messageController.text.trim();
    _messageController.clear();

    final newMessage = ChatMessage(question: question, time: DateTime.now());

    setState(() {
      messages.add(newMessage);
      isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await AIService.askAI(
        userId: widget.user.id,
        childId: widget.child.id,
        question: question,
      );

      setState(() {
        newMessage.answer = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        newMessage.answer = '❌ $e';
        isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00897B),
        title: Text("Tư vấn AI - ${widget.child.fullName}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      "Chưa có tin nhắn\nHãy bắt đầu trò chuyện!",
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];

                      return Column(
                        children: [
                          _buildUserMessage(msg),
                          const SizedBox(height: 12),
                          if (msg.answer != null) _buildAIMessage(msg),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildUserMessage(ChatMessage msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text("${DateFormat('HH:mm').format(msg.time)} - ${msg.question}"),
    );
  }

  Widget _buildAIMessage(ChatMessage msg) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text("${DateFormat('HH:mm').format(msg.time)} - ${msg.answer}"),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Nhập câu hỏi...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: isLoading ? null : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
