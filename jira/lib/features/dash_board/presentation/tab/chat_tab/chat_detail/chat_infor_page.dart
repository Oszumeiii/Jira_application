// features/dash_board/presentation/tab/chat_tab/chat_detail/chat_info_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jira/core/app_colors.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/avatar_widget.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_detail/group_mem_page.dart';

class ChatInfoPage extends StatefulWidget {
  final String chatId;
  final String chatName;
  final bool isGroup;
  final List<String> members;
  final String? opponentAvatarUrl;
  final String? opponentName;
  final Map<String, Map<String, dynamic>> memberInfos;

  const ChatInfoPage({
    super.key,
    required this.chatId,
    required this.chatName,
    required this.isGroup,
    required this.members,
    this.opponentAvatarUrl,
    this.opponentName,
    required this.memberInfos,
  });

  @override
  State<ChatInfoPage> createState() => _ChatInfoPageState();
}

class _ChatInfoPageState extends State<ChatInfoPage> {
  late TextEditingController _groupNameController;
  bool _isEditingName = false;
  bool _showInfo = false;
  String _inviteLink = '';
  final primaryColor = const Color.fromARGB(255, 26, 76, 224).withOpacity(0.9);

  @override
  void initState() {
    super.initState();
    _groupNameController = TextEditingController(text: widget.chatName);
    if (widget.isGroup) {
      _generateInviteLink();
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  void _generateInviteLink() {
    _inviteLink = 'https://app.jira.com/join/${widget.chatId}';
  }

  Future<void> _updateGroupName() async {
    final newName = _groupNameController.text.trim();
    if (newName.isEmpty || newName == widget.chatName) {
      setState(() => _isEditingName = false);
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({'name': newName});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group name updated successfully')),
        );
        setState(() => _isEditingName = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _copyInviteLink() {
    Clipboard.setData(ClipboardData(text: _inviteLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite link copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool?> _showCustomConfirmDialog({
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
    required IconData icon,
    required Color iconColor,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: iconColor),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        confirmText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeFriend() async {
    final confirm = await _showCustomConfirmDialog(
      title: 'Remove Friend',
      content:
          'Are you sure you want to remove ${widget.chatName} from your friends list?\nThis action cannot be undone.',
      confirmText: 'Remove',
      confirmColor: Colors.red,
      icon: Icons.person_remove,
      iconColor: Colors.red,
    );

    if (confirm != true) return;

    try {
      final currentUid = FirebaseAuth.instance.currentUser!.uid;
      final opponentId = widget.members.firstWhere((id) => id != currentUid);
      final batch = FirebaseFirestore.instance.batch();

      batch.update(
        FirebaseFirestore.instance.collection('users').doc(currentUid),
        {
          'friends': FieldValue.arrayRemove([opponentId]),
        },
      );

      batch.update(
        FirebaseFirestore.instance.collection('users').doc(opponentId),
        {
          'friends': FieldValue.arrayRemove([currentUid]),
        },
      );

      batch.delete(
        FirebaseFirestore.instance.collection('chats').doc(widget.chatId),
      );

      await batch.commit();

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.chatName} removed from friends list'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _blockUser() async {
    final confirm = await _showCustomConfirmDialog(
      title: 'Block User',
      content:
          'Are you sure you want to block ${widget.chatName}?\nThey will not be able to send you messages.',
      confirmText: 'Block',
      confirmColor: Colors.orange.shade700,
      icon: Icons.block,
      iconColor: Colors.orange.shade700,
    );

    if (confirm == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feature under development')),
      );
    }
  }

  Future<void> _leaveGroup() async {
    final confirm = await _showCustomConfirmDialog(
      title: 'Leave Group',
      content:
          'Are you sure you want to leave this group?\nYou will no longer see new messages.',
      confirmText: 'Leave',
      confirmColor: Colors.red,
      icon: Icons.exit_to_app,
      iconColor: Colors.red,
    );

    if (confirm != true) return;

    try {
      final currentUid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({
            'members': FieldValue.arrayRemove([currentUid]),
          });

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have left the group')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _viewGroupMembers() {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupMemberPage(
          groupName: widget.chatName,
          memberIds: widget.members,
          memberInfos: {
            ...widget.memberInfos,
            currentUid: {
              'name': 'You',
              'photoURL': null,
              'isCurrentUser': true,
            },
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isGroup ? 'Group Info' : 'Info',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with avatar and name
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
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
                children: [
                  AvatarWidget(
                    url: widget.isGroup ? null : widget.opponentAvatarUrl,
                    initials: widget.chatName.isNotEmpty
                        ? widget.chatName[0].toUpperCase()
                        : '?',
                    radius: 50,
                  ),
                  const SizedBox(height: 16),
                  if (widget.isGroup && _isEditingName)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: IntrinsicWidth(
                              child: TextField(
                                controller: _groupNameController,
                                autofocus: true,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 28,
                            ),
                            onPressed: _updateGroupName,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                              size: 28,
                            ),
                            onPressed: () {
                              _groupNameController.text = widget.chatName;
                              setState(() => _isEditingName = false);
                            },
                          ),
                        ],
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.chatName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.isGroup) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => setState(() => _isEditingName = true),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit,
                                color: primaryColor,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  if (widget.isGroup) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${widget.members.length} ${widget.members.length == 1 ? 'member' : 'members'}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Main content
            if (widget.isGroup)
              _buildGroupContent()
            else
              _buildOneOnOneContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupContent() {
    return Column(
      children: [
        // Invite link
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.link, color: primaryColor, size: 24),
            ),
            title: const Text(
              'Invite Link',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: const Text(
              'Tap to copy invite link',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            trailing: Icon(Icons.content_copy, color: primaryColor),
            onTap: _copyInviteLink,
          ),
        ),

        const SizedBox(height: 12),

        // Members list
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.people, color: primaryColor, size: 24),
            ),
            title: const Text(
              'Members',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Text(
              '${widget.members.length} ${widget.members.length == 1 ? 'member' : 'members'}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: _viewGroupMembers,
          ),
        ),

        const SizedBox(height: 24),

        // Leave group button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _leaveGroup,
              icon: const Icon(Icons.exit_to_app, size: 18),
              label: const Text(
                'Leave Group',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildOneOnOneContent() {
    return Column(
      children: [
        // User information
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _showInfo
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              title: const Text(
                'Information',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              subtitle: const Text(
                'Tap to view details',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => setState(() => _showInfo = true),
            ),
          ),
          secondChild: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Detailed Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => setState(() => _showInfo = false),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetailRow(
                  Icons.person_outline,
                  'Name',
                  widget.chatName,
                  Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.email_outlined,
                  'Email',
                  widget.opponentName ?? 'No information',
                  Colors.orange,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Options
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.block,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Block User',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: const Text(
                  'Block messages from this person',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 20,
                ),
                onTap: _blockUser,
              ),
              Divider(
                height: 1,
                indent: 72,
                endIndent: 20,
                color: Colors.grey[200],
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_remove,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Remove Friend',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                subtitle: const Text(
                  'Remove from friends list',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 20,
                ),
                onTap: _removeFriend,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
