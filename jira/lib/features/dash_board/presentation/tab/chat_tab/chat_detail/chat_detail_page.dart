import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/core/app_colors.dart';
import 'package:jira/core/firebase_config.dart';
import 'chat_detail_cubit.dart';
import 'chat_detail_state.dart';
import 'message_mubble.dart';
import 'typing_indicator.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;
  final String chatName;
  final bool isGroup;
  final List<String> members;

  const ChatDetailPage({
    super.key,
    required this.chatId,
    required this.chatName,
    required this.isGroup,
    required this.members,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    // NOTE: Do NOT create ChatDetailCubit here.
    // ChatDetailCubit must be provided by the caller via BlocProvider.
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Expect a BlocProvider<ChatDetailCubit> above this widget.
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.chatName,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (widget.isGroup)
              Text(
                '${widget.members.length} thành viên',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatDetailCubit, ChatDetailState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.messages.isEmpty && !state.isTyping) {
                  return const Center(
                    child: Text(
                      'Chưa có tin nhắn nào',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: state.messages.length + (state.isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (state.isTyping && index == 0)
                      return const TypingIndicator();
                    final messageIndex = state.isTyping ? index - 1 : index;
                    if (messageIndex >= state.messages.length)
                      return const SizedBox.shrink();
                    final message = state.messages[messageIndex];
                    return MessageBubble(
                      message: message,
                      isCurrentUser:
                          message.from == FirebaseConfig.auth.currentUser?.uid,
                    );
                  },
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: (text) {
                      // safe to call; provider should exist
                      final cubit = context.read<ChatDetailCubit?>();
                      if (cubit != null) cubit.setTyping(text.isNotEmpty);
                    },
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: AppColors.primary,
                  onPressed: () async {
                    final text = _messageController.text.trim();
                    if (text.isEmpty) return;
                    final cubit = context.read<ChatDetailCubit?>();
                    if (cubit == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lỗi: Chat chưa sẵn sàng'),
                        ),
                      );
                      return;
                    }
                    await cubit.sendMessage(text);
                    _messageController.clear();
                    cubit.setTyping(false);
                  },
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
