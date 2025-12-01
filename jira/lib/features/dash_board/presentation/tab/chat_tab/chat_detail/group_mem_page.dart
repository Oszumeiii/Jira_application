import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/avatar_widget.dart';

class GroupMemberPage extends StatefulWidget {
  final String groupName;
  final List<String> memberIds;
  final Map<String, Map<String, dynamic>> memberInfos;

  const GroupMemberPage({
    super.key,
    required this.groupName,
    required this.memberIds,
    required this.memberInfos,
  });

  @override
  State<GroupMemberPage> createState() => _GroupMemberPageState();
}

class _GroupMemberPageState extends State<GroupMemberPage> {
  late TextEditingController _searchController;
  List<String> _filteredMemberIds = [];
  Map<String, Map<String, dynamic>> _memberInfos = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredMemberIds = widget.memberIds;
    _memberInfos = Map.from(widget.memberInfos);
    _fetchMissingMemberInfos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMissingMemberInfos() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final missingUids = widget.memberIds
        .where(
          (uid) =>
              uid != currentUid &&
              (!_memberInfos.containsKey(uid) ||
                  _memberInfos[uid]?['name'] == 'Anonymous User'),
        )
        .toList();

    if (missingUids.isEmpty) return;

    final newUserInfos = <String, Map<String, dynamic>>{};

    for (var i = 0; i < missingUids.length; i += 10) {
      final batch = missingUids.sublist(
        i,
        (i + 10 < missingUids.length) ? i + 10 : missingUids.length,
      );

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        newUserInfos[doc.id] = {
          'name': data['userName'] ?? data['firstName'] ?? 'Anonymous user',
          'photoURL': data['photoURL'],
        };
      }
    }

    if (newUserInfos.isNotEmpty) {
      setState(() {
        _memberInfos.addAll(newUserInfos);
      });
    }
  }

  void _filterMembers(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filteredMemberIds = widget.memberIds.where((uid) {
        final info = _memberInfos[uid] ?? {};
        final name = (info['name'] as String? ?? '').toLowerCase();
        return name.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color.fromARGB(
      255,
      26,
      76,
      224,
    ).withOpacity(0.9);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Group Members',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: Column(
        children: [
          // Header with group name and member count
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.group, color: primaryColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.groupName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.memberIds.length} ${widget.memberIds.length == 1 ? 'member' : 'members'}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterMembers,
              decoration: InputDecoration(
                hintText: 'Search members...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: primaryColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[400]),
                        onPressed: () {
                          _searchController.clear();
                          _filterMembers('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Member list
          Expanded(
            child: _filteredMemberIds.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No members found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredMemberIds.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final uid = _filteredMemberIds[index];
                      final info =
                          _memberInfos[uid] ??
                          {'name': 'Anonymous User', 'photoURL': null};

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: AvatarWidget(
                            url: info['photoURL'],
                            initials:
                                (info['name'] as String?)?.isNotEmpty == true
                                ? (info['name'] as String)[0].toUpperCase()
                                : '?',
                            radius: 24,
                          ),
                          title: Text(
                            info['name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: info['isCurrentUser'] == true
                              ? Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'You',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
