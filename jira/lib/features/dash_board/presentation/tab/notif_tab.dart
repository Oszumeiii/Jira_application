import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jira/core/firebase_config.dart';
import 'package:jira/core/app_colors.dart';

class NotifTab extends StatefulWidget {
  const NotifTab({super.key});

  @override
  State<NotifTab> createState() => _NotifTabState();
}

class _NotifTabState extends State<NotifTab> {
  String _selectedFilter = 'All'; // 'All' or 'Unread'

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseConfig.auth.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Thông báo'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text(
            'Chưa đăng nhập',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final col = FirebaseConfig.firestore
        .collection('users')
               .doc(uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Thông báo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _FilterTab(
                    label: 'Tất cả',
                    isSelected: _selectedFilter == 'All',
                    onTap: () => setState(() => _selectedFilter = 'All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FilterTab(
                    label: 'Chưa đọc',
                    isSelected: _selectedFilter == 'Unread',
                    onTap: () => setState(() => _selectedFilter = 'Unread'),
                    badge: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: col.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${snapshot.error}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          final allDocs = snapshot.data!.docs;
          
          // Filter based on selected tab
          final filteredDocs = _selectedFilter == 'Unread'
              ? allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final isRead = data['isRead'] as bool? ?? false;
                  return !isRead;
                }).toList()
              : allDocs;

          if (filteredDocs.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh logic if needed
            },
            color: AppColors.primary,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredDocs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final d = filteredDocs[index];
                final data = d.data() as Map<String, dynamic>;
                final type = data['type'] as String? ?? '';
                final timestamp = data['timestamp'] as Timestamp?;
                final isRead = data['isRead'] as bool? ?? false;

                if (type == 'friend_request') {
                  final status = data['status'] as String? ?? 'pending';
                  final fromName = data['fromName'] as String? ?? 'Người dùng';
                  final fromPhoto = data['fromPhoto'] as String?;
                  final fromUid = data['fromUid'] as String?;

                  return _FriendRequestCard(
                    notificationDoc: d,
                    fromName: fromName,
                    fromPhoto: fromPhoto,
                    fromUid: fromUid,
                    status: status,
                    currentUid: uid,
                    timestamp: timestamp,
                    isRead: isRead,
                    onTap: () => _markAsRead(d),
                  );
                }

                // Other notification types
                return _GeneralNotificationCard(
                  notificationDoc: d,
                  title: data['title'] ?? 'Thông báo',
                  body: data['body'] ?? '',
                  timestamp: timestamp,
                  isRead: isRead,
                  onTap: () => _markAsRead(d),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _markAsRead(QueryDocumentSnapshot doc) async {
    try {
      await doc.reference.update({'isRead': true});
    } catch (e) {
      print('[NotifTab] Error marking as read: $e');
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _selectedFilter == 'Unread'
                  ? Icons.mark_email_read_outlined
                  : Icons.notifications_none_rounded,
              size: 64,
              color: AppColors.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedFilter == 'Unread'
                ? 'Không có thông báo chưa đọc'
                : 'Không có thông báo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'Unread'
                ? 'Tất cả thông báo đã được đọc'
                : 'Bạn sẽ nhận được thông báo ở đây',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool badge;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
              if (badge && !isSelected) ...[
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FriendRequestCard extends StatefulWidget {
  final QueryDocumentSnapshot notificationDoc;
  final String fromName;
  final String? fromPhoto;
  final String? fromUid;
  final String status;
  final String currentUid;
  final Timestamp? timestamp;
  final bool isRead;
  final VoidCallback onTap;

  const _FriendRequestCard({
    required this.notificationDoc,
    required this.fromName,
    this.fromPhoto,
    this.fromUid,
    required this.status,
    required this.currentUid,
    this.timestamp,
    required this.isRead,
    required this.onTap,
  });

  @override
  State<_FriendRequestCard> createState() => _FriendRequestCardState();
}

class _FriendRequestCardState extends State<_FriendRequestCard>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _acceptFriendRequest() async {
    if (widget.fromUid == null || _isProcessing) return;

    setState(() => _isProcessing = true);
    _animationController.forward();
    widget.onTap(); // Mark as read

    try {
      final currentUserDoc = await FirebaseConfig.firestore
          .collection('users')
          .doc(widget.currentUid)
          .get();
      final currentFriends =
          List<String>.from(currentUserDoc.data()?['friends'] ?? []);

      if (currentFriends.contains(widget.fromUid)) {
        await widget.notificationDoc.reference.update({
          'status': 'accepted',
          'isRead': true,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Đã là bạn bè rồi'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        setState(() => _isProcessing = false);
        return;
      }

      await FirebaseConfig.firestore
          .collection('users')
          .doc(widget.currentUid)
          .update({
        'friends': FieldValue.arrayUnion([widget.fromUid]),
      });

      await FirebaseConfig.firestore
          .collection('users')
          .doc(widget.fromUid)
          .update({
        'friends': FieldValue.arrayUnion([widget.currentUid]),
      });

      await widget.notificationDoc.reference.update({
        'status': 'accepted',
        'isRead': true,
      });

      final existingChats = await FirebaseConfig.firestore
          .collection('chats')
          .where('isGroup', isEqualTo: false)
          .where('members', arrayContains: widget.currentUid)
          .get();

      bool chatExists = false;
      for (var chatDoc in existingChats.docs) {
        final members = List<String>.from(chatDoc.data()['members'] ?? []);
        if (members.length == 2 &&
            members.contains(widget.currentUid) &&
            members.contains(widget.fromUid)) {
          chatExists = true;
          break;
        }
      }

      if (!chatExists) {
        String? otherUserName;
        String? otherUserPhoto;
        try {
          final otherUserDoc = await FirebaseConfig.firestore
              .collection('users')
              .doc(widget.fromUid)
              .get();
          if (otherUserDoc.exists) {
            final otherUserData = otherUserDoc.data()!;
            otherUserName = otherUserData['userName'] ??
                otherUserData['firstName'] ??
                '';
            otherUserPhoto = otherUserData['photoURL'];
          }
        } catch (e) {
          print('[NotifTab] Error fetching other user: $e');
        }

        await FirebaseConfig.firestore.collection('chats').add({
          'name': otherUserName ?? '',
          'isGroup': false,
          'members': [widget.currentUid, widget.fromUid],
          'admin': widget.currentUid,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'lastMessageFrom': widget.currentUid,
          'photoURL': otherUserPhoto,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Đã chấp nhận lời mời kết bạn'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print('[NotifTab] Error accepting friend request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Lỗi chấp nhận: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        _animationController.reverse();
      }
    }
  }

  Future<void> _declineFriendRequest() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    widget.onTap(); // Mark as read

    try {
      await widget.notificationDoc.reference.update({
        'status': 'declined',
        'isRead': true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.cancel, color: Colors.white),
                SizedBox(width: 8),
                Text('Đã từ chối lời mời kết bạn'),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print('[NotifTab] Error declining friend request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Lỗi từ chối: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = widget.status == 'pending';
    final isAccepted = widget.status == 'accepted';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: widget.isRead
            ? null
            : Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1.5,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar with badge
                    Stack(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.2),
                                AppColors.primary.withOpacity(0.05),
                              ],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundImage: widget.fromPhoto != null
                                ? NetworkImage(widget.fromPhoto!)
                                : null,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: widget.fromPhoto == null
                                ? Text(
                                    widget.fromName.isNotEmpty
                                        ? widget.fromName[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        if (isPending)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        if (!widget.isRead)
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.fromName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: widget.isRead
                                        ? FontWeight.w600
                                        : FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              if (widget.timestamp != null)
                                Text(
                                  _formatTimestamp(widget.timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.person_add_rounded,
                                size: 14,
                                color: isPending
                                    ? AppColors.primary
                                    : isAccepted
                                        ? Colors.green
                                        : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isPending
                                    ? 'Lời mời kết bạn'
                                    : isAccepted
                                        ? 'Đã chấp nhận'
                                        : 'Đã từ chối',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isPending
                                      ? Colors.grey[600]
                                      : isAccepted
                                          ? Colors.green
                                          : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isPending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          onPressed: _isProcessing ? null : _acceptFriendRequest,
                          label: 'Chấp nhận',
                          icon: Icons.check_circle_outline,
                          color: AppColors.primary,
                          isLoading: _isProcessing,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          onPressed: _isProcessing ? null : _declineFriendRequest,
                          label: 'Từ chối',
                          icon: Icons.cancel_outlined,
                          color: Colors.red,
                          isOutlined: true,
                          isLoading: _isProcessing,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isAccepted
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAccepted ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: isAccepted ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAccepted ? 'Đã chấp nhận' : 'Đã từ chối',
                          style: TextStyle(
                            color: isAccepted ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  final Color color;
  final bool isOutlined;
  final bool isLoading;

  const _ActionButton({
    required this.onPressed,
    required this.label,
    required this.icon,
    required this.color,
    this.isOutlined = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            : Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _GeneralNotificationCard extends StatelessWidget {
  final QueryDocumentSnapshot notificationDoc;
  final String title;
  final String body;
  final Timestamp? timestamp;
  final bool isRead;
  final VoidCallback onTap;

  const _GeneralNotificationCard({
    required this.notificationDoc,
    required this.title,
    required this.body,
    this.timestamp,
    required this.isRead,
    required this.onTap,
  });

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isRead
            ? null
            : Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1.5,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    if (!isRead)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          body,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (timestamp != null)
                  Text(
                    _formatTimestamp(timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[400],
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
