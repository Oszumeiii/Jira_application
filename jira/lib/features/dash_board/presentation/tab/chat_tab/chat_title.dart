// features/dash_board/presentation/tab/chat_tab/components/chat_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/avatar_widget.dart';
import 'chat_detail/chat_detail_cubit.dart';
import 'chat_detail/chat_detail_page.dart';

class ChatTile extends StatelessWidget {
  final String chatId;
  final String name;
  final String lastMessage;
  final String? avatar;
  final bool isGroup;
  final DateTime? lastMessageTime;

  const ChatTile({
    super.key,
    required this.chatId,
    required this.name,
    required this.lastMessage,
    this.avatar,
    this.isGroup = false,
    this.lastMessageTime,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AvatarWidget(url: avatar, initials: name, radius: 24),
      title: Text(
        name.isEmpty ? 'No name' : name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (lastMessageTime != null)
            Text(
              _formatTime(lastMessageTime!),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          if (isGroup)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(Icons.group, size: 14, color: Colors.grey),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => ChatDetailCubit(chatId, isGroup),
              child: ChatDetailPage(
                chatId: chatId,
                chatName: name,
                isGroup: isGroup,
                members: const [],
              ),
            ),
          ),
        );
      },
    );
  }
}
String _formatTime(DateTime time) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(time.year, time.month, time.day);


  if (date == today) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  if (date == today.subtract(const Duration(days: 1))) {
    return 'Yesterday';
  }

  return '${time.day}/${time.month}';
}



