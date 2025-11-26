import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_tab/chat_tab_cubit.dart';

class ChatSearchBar extends StatefulWidget {
  final bool showFriendsList;

  const ChatSearchBar({super.key, required this.showFriendsList});

  @override
  State<ChatSearchBar> createState() => _ChatSearchBarState();
}

class _ChatSearchBarState extends State<ChatSearchBar> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isFocused
              ? const Color(0xFF5B4FDB).withOpacity(0.3)
              : Colors.grey[200]!,
          width: 1.5,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFF5B4FDB).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _controller,
        onTap: () => setState(() => _isFocused = true),
        onTapOutside: (_) => setState(() => _isFocused = false),
        decoration: InputDecoration(
          hintText: widget.showFriendsList ? "Tìm bạn bè..." : "Tìm kiếm",
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _isFocused ? const Color(0xFF5B4FDB) : Colors.grey[600],
            size: 22,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      _controller.clear();
                      if (widget.showFriendsList) {
                        context.read<ChatTabCubit>().searchFriends('');
                      } else {
                        context.read<ChatTabCubit>().searchUsers('');
                      }
                      setState(() {});
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
        onChanged: (query) {
          if (widget.showFriendsList) {
            context.read<ChatTabCubit>().searchFriends(query);
          } else {
            context.read<ChatTabCubit>().searchUsers(query);
          }
          setState(() {});
        },
      ),
    );
  }
}
