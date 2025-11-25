import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/avatar_widget.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_detail/chat_detail_cubit.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_detail/chat_detail_page.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_tab/chat_tab_cubit.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_tab/chat_tab_state.dart';
import 'chat_item_model.dart';

class ChatListView extends StatelessWidget {
  final String selectedTab;
  final String searchQuery;

  const ChatListView({
    super.key,
    this.selectedTab = 'All',
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return BlocBuilder<ChatTabCubit, ChatTabState>(
      builder: (context, state) {
        final friends = state.allFriends;
        final friendMap = {for (var f in friends) f.id: f}; // Dễ tra cứu

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .orderBy('lastMessageTime', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Lỗi tải tin nhắn'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final chatDocs = snapshot.data!.docs;
            final List<ChatItemModel> items = [];

            // 1. Thêm bạn bè chưa từng nhắn (xuống cuối)
            for (final friend in friends) {
              final hasChat = chatDocs.any((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final members = List<String>.from(data['members'] ?? []);
                return members.length == 2 &&
                    members.contains(currentUid) &&
                    members.contains(friend.id);
              });

              if (!hasChat) {
                items.add(
                  friend.copyWith(
                    lastMessage: 'Chưa có tin nhắn',
                    lastMessageTime: DateTime(2000),
                  ),
                );
              }
            }

            // 2. Thêm tất cả cuộc trò chuyện
            for (final doc in chatDocs) {
              final data = doc.data() as Map<String, dynamic>;
              final members = List<String>.from(data['members'] ?? []);
              if (!members.contains(currentUid)) continue;

              final isGroup = data['isGroup'] == true;
              if (selectedTab == 'Groups' && !isGroup) continue;

              String name = '';
              String? photoURL;
              bool isOnline = false;

              if (isGroup) {
                // Nhóm: dùng dữ liệu từ document
                name = data['name']?.toString() ?? 'Nhóm chat';
                photoURL = data['groupPhotoURL'];
              } else {
                // Chat 1-1: lấy từ danh sách bạn bè (chuẩn như FriendsListView)
                final otherId = members.firstWhere(
                  (id) => id != currentUid,
                  orElse: () => '',
                );
                final friend = friendMap[otherId];
                if (friend != null) {
                  name = friend.name;
                  photoURL = friend.photoURL;
                  isOnline = friend.isOnline;
                } else {
                  name = 'Người dùng';
                }
              }

              final lastMessage =
                  data['lastMessage']?.toString() ?? 'Không có tin nhắn';
              final lastTime = (data['lastMessageTime'] as Timestamp?)
                  ?.toDate();

              items.add(
                ChatItemModel(
                  id: doc.id,
                  name: name,
                  photoURL: photoURL,
                  isGroup: isGroup,
                  members: members,
                  isOnline: isOnline,
                  lastMessage: lastMessage,
                  lastMessageTime: lastTime,
                ),
              );
            }

            // Lọc tìm kiếm
            final filtered = items.where((item) {
              if (searchQuery.trim().isEmpty) return true;
              return item.name.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );
            }).toList();

            // Sắp xếp theo tin nhắn mới nhất
            filtered.sort((a, b) {
              final timeA = a.lastMessageTime ?? DateTime(2000);
              final timeB = b.lastMessageTime ?? DateTime(2000);
              return timeB.compareTo(timeA);
            });

            if (filtered.isEmpty) {
              return const Center(
                child: Text(
                  'Chưa có tin nhắn nào',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<ChatTabCubit>().refreshFriends(),
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 72),
                itemBuilder: (context, index) {
                  final item = filtered[index];

                  return ListTile(
                    leading: SizedBox(
                      width: 56,
                      height: 56,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: AvatarWidget(
                              url: item.photoURL,
                              initials: item.name,
                              radius: 28,
                            ),
                          ),
                          if (!item.isGroup && item.isOnline)
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    title: Text(
                      item.name.isNotEmpty ? item.name : 'Không tên',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      item.isGroup
                          ? '${item.members.length} thành viên'
                          : (item.lastMessage ?? 'Chưa có tin nhắn'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    trailing: item.isGroup
                        ? null
                        : Text(
                            item.isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                              color: item.isOnline
                                  ? Colors.green
                                  : Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                    onTap: () {
                      final targetChatId = item.isGroup
                          ? item.id
                          : item.members.firstWhere(
                              (id) => id != currentUid,
                              orElse: () => item.id,
                            );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => ChatDetailCubit(
                              targetChatId,
                              item.isGroup,
                              initialIsChatId: item.isGroup,
                            ),
                            child: ChatDetailPage(
                              chatId: targetChatId,
                              chatName: item.name,
                              isGroup: item.isGroup,
                              members: item.members,
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
      },
    );
  }
}

// Extension copyWith
extension on ChatItemModel {
  ChatItemModel copyWith({String? lastMessage, DateTime? lastMessageTime}) {
    return ChatItemModel(
      id: id,
      name: name,
      email: email,
      photoURL: photoURL,
      isGroup: isGroup,
      members: members,
      isOnline: isOnline,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageFrom: lastMessageFrom,
    );
  }
}
