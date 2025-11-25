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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: widget.showFriendsList ? "Tìm bạn bè..." : "Tìm kiếm",
          prefixIcon: const Icon(
            Icons.search,
            color: Color.fromARGB(255, 66, 39, 214),
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    if (widget.showFriendsList) {
                      context.read<ChatTabCubit>().searchFriends('');
                    } else {
                      context.read<ChatTabCubit>().searchUsers('');
                    }
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
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
