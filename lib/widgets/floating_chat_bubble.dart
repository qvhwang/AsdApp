import 'package:flutter/material.dart';

import '../models/child_model.dart';
import '../models/user_model.dart';
import '../screens/ai_chat/ai_chat_screen.dart';

class FloatingChatBubble extends StatefulWidget {
  final ChildModel child;
  final UserModel user;
  final VoidCallback? onClose;

  const FloatingChatBubble({
    Key? key,
    required this.child,
    required this.user,
    this.onClose,
  }) : super(key: key);

  @override
  State<FloatingChatBubble> createState() => _FloatingChatBubbleState();
}

class _FloatingChatBubbleState extends State<FloatingChatBubble> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // CHAT BUBBLE
        if (!isExpanded)
          Positioned(
            right: 16,
            bottom: 80,
            child: GestureDetector(
              onTap: () {
                setState(() => isExpanded = true);
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00897B), Color(0xFF26A69A)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),

        // EXPANDED CHAT
        if (isExpanded)
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: AIChatScreen(child: widget.child, user: widget.user),
            ),
          ),

        // CLOSE BUTTON
        if (isExpanded)
          Positioned(
            right: 16,
            bottom: 80,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.red,
              onPressed: () {
                setState(() => isExpanded = false);
                widget.onClose?.call();
              },
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
