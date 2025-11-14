// features/dash_board/presentation/tab/chat_tab/create_group/create_group.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  List<Map<String, dynamic>> friends = [];
  List<String> selectedFriends = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoading = true);
    try {
      final uid = _auth.currentUser!.uid;
      final userDoc = await _db.collection('users').doc(uid).get();
      final friendIds = List<String>.from(userDoc['friends'] ?? []);

      final List<Map<String, dynamic>> loaded = [];
      for (var id in friendIds) {
        final fDoc = await _db.collection('users').doc(id).get();
        if (fDoc.exists) {
          loaded.add({
            'uid': id,
            'name': fDoc['name'] ?? 'Unknown',
            'email': fDoc['email'] ?? '',
            'avatar': fDoc['photoURL'],
          });
        }
      }
      setState(() => friends = loaded);
    } catch (e) {
      setState(() => _error = "Không thể tải danh sách bạn bè.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createGroup() async {
    final groupName = _nameController.text.trim();
    if (groupName.isEmpty || selectedFriends.isEmpty) {
      setState(
        () => _error = "Vui lòng nhập tên nhóm và chọn ít nhất 1 thành viên.",
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final uid = _auth.currentUser!.uid;
      final members = [uid, ...selectedFriends];

      final groupRef = await _db.collection('chats').add({
        'name': groupName,
        'isGroup': true,
        'members': members,
        'lastMessage': '',
        'createdAt': FieldValue.serverTimestamp(),
        'admin': uid,
      });

      await groupRef.collection('messages').add({
        'text': "$groupName đã được tạo.",
        'from': uid,
        'time': FieldValue.serverTimestamp(),
        'system': true,
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = "Không thể tạo nhóm.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tạo nhóm mới",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Group Name
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: "Tên nhóm",
                  prefixIcon: Icon(Icons.group, color: Color(0xFF6554C0)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Members Header
            Row(
              children: [
                const Text(
                  "Thành viên",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  "${selectedFriends.length} được chọn",
                  style: const TextStyle(color: Color(0xFF6554C0)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Friends List
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : friends.isEmpty
                    ? const Center(child: Text("Chưa có bạn bè"))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: friends.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 72),
                        itemBuilder: (context, i) {
                          final f = friends[i];
                          final selected = selectedFriends.contains(f['uid']);
                          return CheckboxListTile(
                            secondary: CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xFFDFE1E6),
                              backgroundImage: f['avatar'] != null
                                  ? NetworkImage(f['avatar'])
                                  : null,
                              child: f['avatar'] == null
                                  ? Text(
                                      f['name'][0].toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Text(
                              f['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              f['email'],
                              style: const TextStyle(fontSize: 13),
                            ),
                            value: selected,
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  selectedFriends.add(f['uid']);
                                } else {
                                  selectedFriends.remove(f['uid']);
                                }
                              });
                            },
                            activeColor: const Color(0xFF6554C0),
                            controlAffinity: ListTileControlAffinity.trailing,
                          );
                        },
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Error
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFEBE6), Color(0xFFFFD4CC)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFAB00)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Color(0xFFFFAB00)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Create Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _createGroup,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add, size: 20),
                label: Text(_isLoading ? "Đang tạo..." : "Tạo nhóm"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6554C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
