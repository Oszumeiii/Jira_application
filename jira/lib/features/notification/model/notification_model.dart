import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  friendRequest,
  projectAssigned,
  comment,
  general,
}

class NotificationModel {
  final String id;
  final String type; // để Firestore dễ filter
  final String fromUid;
  final String fromName;
  final String? fromPhoto;
  final String status; // ví dụ: pending, accepted, declined
  final bool isRead;
  final Timestamp timestamp;
  final String content;

  NotificationModel({
    required this.id,
    required this.type,
    required this.fromUid,
    required this.fromName,
    this.fromPhoto,
    this.status = 'pending',
    this.isRead = false,
    required this.timestamp,
    required this.content,
  });

  /// Tạo notification mới từ type và dữ liệu
  factory NotificationModel.create({
    required String type,
    required String fromUid,
    required String fromName,
    String? fromPhoto,
    String status = 'pending',
  }) {
    final now = Timestamp.now();
    String content;

    switch (type) {
      case 'friend_request':
        content = '$fromName sent you a friend request';
        break;
      case 'project_assigned':
        content = '$fromName assigned you to a project';
        break;
      case 'comment':
        content = '$fromName commented on your task';
        break;
      default:
        content = 'You have a new notification';
    }

    return NotificationModel(
      id: '', // Firestore sẽ tự tạo
      type: type,
      fromUid: fromUid,
      fromName: fromName,
      fromPhoto: fromPhoto,
      status: status,
      isRead: false,
      timestamp: now,
      content: content,
    );
  }

  /// Chuyển thành Map để lưu Firestore
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'fromUid': fromUid,
      'fromName': fromName,
      'fromPhoto': fromPhoto,
      'status': status,
      'isRead': isRead,
      'timestamp': timestamp,
      'content': content,
    };
  }

  /// Tạo từ Firestore doc
  factory NotificationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      type: data['type'] ?? 'general',
      fromUid: data['fromUid'] ?? '',
      fromName: data['fromName'] ?? '',
      fromPhoto: data['fromPhoto'],
      status: data['status'] ?? 'pending',
      isRead: data['isRead'] ?? false,
      timestamp: data['timestamp'] ?? Timestamp.now(),
      content: data['content'] ?? '',
    );
  }
}
