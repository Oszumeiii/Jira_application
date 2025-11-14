import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/add_friend/add_friend_page.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_detail/chat_detail_page.dart';

import 'package:jira/features/dash_board/presentation/tab/chat_tab/create_group/create_group.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  String selectedTab = "All";
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6554C0);

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildTabButton("All", primaryPurple),
                      const SizedBox(width: 10),
                      _buildTabButton("Groups", primaryPurple),
                    ],
                  ),

                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.person_add_alt_1),
                        tooltip: "Thêm bạn",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddFriendPage(),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.group_add),
                        tooltip: "Tạo nhóm",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateGroupScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: "Tìm kiếm cuộc trò chuyện",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _db.collection('chats').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final chats = snapshot.data!.docs;

                    if (chats.isEmpty) {
                      return const Center(
                        child: Text("Chưa có cuộc trò chuyện nào."),
                      );
                    }

                    return ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat =
                            chats[index].data() as Map<String, dynamic>;
                        final chatId = chats[index].id;

                        if (selectedTab == "Groups" &&
                            (chat["isGroup"] != true)) {
                          return const SizedBox.shrink();
                        }

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              chat["avatar"] ??
                                  "https://i.pravatar.cc/150?img=5",
                            ),
                            radius: 26,
                          ),
                          title: Text(
                            chat["name"] ?? "Không tên",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            chat["lastMessage"] ?? "",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailPage(
                                  chatId: chatId,
                                  chatName: chat["name"],
                                  // avatar: chat["avatar"],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, Color color) {
    final selected = label == selectedTab;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: ShapeDecoration(
          color: selected ? color.withOpacity(0.1) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: selected ? color : Colors.grey.shade400,
              width: 1.0,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : Colors.black87,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
