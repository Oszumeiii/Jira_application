import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_detail/chat_detail_cubit.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_detail/chat_detail_page.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_title.dart';

class ChatListView extends StatelessWidget {
  final String searchQuery;
  final String selectedTab;

  const ChatListView({
    super.key,
    this.searchQuery = '',
    this.selectedTab = 'All',
  });

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return const Center(child: Text('Chưa đăng nhập'));

    final chatsCol = FirebaseFirestore.instance
        .collection('chats')
        .orderBy('lastMessageTime', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: chatsCol.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final rawDocs = snapshot.data!.docs;

        // Lọc theo user
        final filteredDocs = rawDocs.where((d) {
          final data = d.data() as Map<String, dynamic>? ?? {};
          final members = List<String>.from(data['members'] ?? []);
          final isGroup = data['isGroup'] == true;

          if (!members.contains(currentUid)) return false;

          if (selectedTab == 'Groups' && !isGroup) return false;
          if (selectedTab == 'All') return true;

          // Search
          if (searchQuery.trim().isNotEmpty) {
            final name = (data['name'] ?? '').toString().toLowerCase();
            return name.contains(searchQuery.toLowerCase());
          }

          return true;
        }).toList();

        if (filteredDocs.isEmpty) {
          return Center(
            child: Text(
              selectedTab == 'Groups'
                  ? 'Không có nhóm'
                  : 'Không có cuộc trò chuyện',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          itemCount: filteredDocs.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final chat = doc.data() as Map<String, dynamic>? ?? {};
            final chatId = doc.id;
            final avatar = chat['photoURL'] as String?;
            final isGroup = chat['isGroup'] == true;
            final lastMessage = (chat['lastMessage'] ?? '').toString();
            final lastTs = chat['lastMessageTime'] as Timestamp?;
            final lastMessageTime = lastTs?.toDate();

            final members = List<String>.from(chat['members'] ?? []);

            // ------------ CHAT 1-1, NAME RỖNG: TÌM TÊN USER KHÁC ------------
            if (!isGroup &&
                (chat['name'] == null || chat['name'].toString().isEmpty)) {
              if (members.length == 2) {
                final otherUserId = members.firstWhere(
                  (id) => id != currentUid,
                  orElse: () => '',
                );

                if (otherUserId.isNotEmpty) {
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(otherUserId)
                        .snapshots(),
                    builder: (context, userSnap) {
                      String displayName = 'Người dùng';
                      String? otherAvatar;

                      if (userSnap.hasData && userSnap.data!.exists) {
                        final userData =
                            userSnap.data!.data() as Map<String, dynamic>? ??
                            {};
                        displayName =
                            userData['userName'] ??
                            userData['firstName'] ??
                            'Người dùng';
                        otherAvatar = userData['photoURL'] as String?;
                      }

                      return _buildChatTile(
                        context,
                        chatId,
                        otherUserId,
                        displayName,
                        lastMessage,
                        otherAvatar ?? avatar,
                        false,
                        lastMessageTime,
                        members,
                      );
                    },
                  );
                }
              }
            }

            // ------------ NHÓM HOẶC CHAT 1-1 CÓ NAME SẴN ------------
            final displayName = (chat['name'] ?? '').toString();

            return _buildChatTile(
              context,
              chatId,
              chatId,
              displayName.isNotEmpty
                  ? displayName
                  : (isGroup ? 'Nhóm' : 'Người dùng'),
              lastMessage,
              avatar,
              isGroup,
              lastMessageTime,
              members,
            );
          },
        );
      },
    );
  }

  Widget _buildChatTile(
    BuildContext context,
    String chatId,
    String otherUserIdOrChatId,
    String name,
    String lastMessage,
    String? avatar,
    bool isGroup,
    DateTime? lastMessageTime,
    List<String> members,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => ChatDetailCubit(
                otherUserIdOrChatId,
                isGroup,
                initialIsChatId: true,
              ),
              child: ChatDetailPage(
                chatId: otherUserIdOrChatId,
                chatName: name,
                isGroup: isGroup,
                members: members,
              ),
            ),
          ),
        );
      },
      child: ChatTile(
        chatId: otherUserIdOrChatId,
        name: name,
        lastMessage: lastMessage.isNotEmpty ? lastMessage : 'Không có tin nhắn',
        avatar: avatar,
        isGroup: isGroup,
        lastMessageTime: lastMessageTime,
      ),
    );
  }
}
