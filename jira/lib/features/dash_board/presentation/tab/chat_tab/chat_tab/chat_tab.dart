import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/add_friend/friend_list_view.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat/chat_list_view.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat/chat_search_bar.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat/search_result_view.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_header.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_tab/chat_tab_state.dart';
import 'chat_tab_cubit.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  String selectedTab = "All";
  bool showFriendsList = false;

  @override
  void initState() {
    super.initState();
    _updateOnlineStatus(true);
  }

  @override
  void dispose() {
    _updateOnlineStatus(false);
    super.dispose();
  }

  void _updateOnlineStatus(bool online) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance.collection('users').doc(uid).update({
        'online': online,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatTabCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ChatHeader(
                  selectedTab: selectedTab,
                  showFriendsList: showFriendsList,
                  onTabChanged: (tab) => setState(() => selectedTab = tab),
                  onToggleFriendsList: (show) =>
                      setState(() => showFriendsList = show),
                ),
                const SizedBox(height: 16),
                ChatSearchBar(showFriendsList: showFriendsList),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<ChatTabCubit, ChatTabState>(
                    builder: (context, state) {
                      if (showFriendsList) {
                        return const FriendsListView();
                      }
                      // nếu có searchQuery -> show search results (users)
                      if (state.searchQuery.isNotEmpty) {
                        return const SearchResultView();
                      }
                      // mặc định show chat list
                      return ChatListView(
                        selectedTab: selectedTab,
                        searchQuery: state.searchQuery,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
