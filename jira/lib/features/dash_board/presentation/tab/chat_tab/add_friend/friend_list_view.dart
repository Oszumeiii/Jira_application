import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/avatar_widget.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_detail/chat_detail_cubit.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_detail/chat_detail_page.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_tab/chat_tab_cubit.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_tab/chat_tab_state.dart';

class FriendsListView extends StatelessWidget {
  const FriendsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatTabCubit, ChatTabState>(
      builder: (context, state) {
        if (state.isLoadingFriends) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.filteredFriends.isEmpty) {
          return Center(
            child: Text(
              state.searchQuery.isEmpty ? 'Chưa có bạn bè' : 'Không tìm thấy',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => context.read<ChatTabCubit>().refreshFriends(),
          child: ListView.separated(
            itemCount: state.filteredFriends.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final friend = state.filteredFriends[index];

              return ListTile(
                leading: SizedBox(
                  width: 56,
                  height: 56,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AvatarWidget(
                          url: friend.photoURL,
                          initials: friend.name,
                          radius: 28,
                        ),
                      ),
                      if (friend.isOnline)
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                title: Text(
                  friend.name.isNotEmpty ? friend.name : 'Không tên',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  friend.email ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: friend.isOnline
                    ? const Text(
                        'Online',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : const Text(
                        'Offline',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                onTap: () {
                  final currentUid = FirebaseAuth.instance.currentUser?.uid;
                  final members = <String>[
                    if (currentUid != null) currentUid,
                    friend.id,
                  ];

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => ChatDetailCubit(friend.id, false),
                        child: ChatDetailPage(
                          chatId: friend.id,
                          chatName: friend.name,
                          isGroup: false,
                          members: members,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
