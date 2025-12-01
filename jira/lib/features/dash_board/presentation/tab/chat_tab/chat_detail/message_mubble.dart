import 'package:flutter/material.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/avatar_widget.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat/message_model.dart';

class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final bool isCurrentUser;
  final String? opponentAvatarUrl;
  final String? opponentName;
  final bool isGroup;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.opponentAvatarUrl,
    this.opponentName,
    required this.isGroup,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isCurrentUser) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () => setState(() => _isTapped = !_isTapped),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A4CE0), Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A4CE0).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.message.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (_isTapped)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, right: 4),
                      child: Text(
                        _formatTime(widget.message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AvatarWidget(
            url: widget.opponentAvatarUrl,
            initials: widget.opponentName ?? '',
            radius: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isTapped = !_isTapped),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isGroup)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4, left: 4),
                      child: Text(
                        widget.opponentName ?? 'User',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Text(
                      widget.message.text,
                      style: TextStyle(
                        color: Colors.grey[900],
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (_isTapped)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        _formatTime(widget.message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(time.year, time.month, time.day);

    if (date == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
