// features/dash_board/presentation/tab/chat_tab/components/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jira/core/app_colors.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrentUser ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isCurrentUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                color: isCurrentUser ? Colors.white70 : Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
