import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatItemModel {
  final String id;
  final String name;
  final String? email;
  final String? photoURL;
  final bool isGroup;
  final List<String> members;
  final bool isOnline;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageFrom;

  ChatItemModel({
    required this.id,
    required this.name,
    this.email,
    this.photoURL,
    required this.isGroup,
    required this.members,
    this.isOnline = false,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageFrom,
  });

  factory ChatItemModel.fromUserDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return ChatItemModel(
      id: doc.id,
      name:
          data['userName'] ??
          '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
      email: data['email'],
      photoURL: data['photoURL'],
      isGroup: false,
      members: [uid, doc.id],
      isOnline: data['online'] ?? false,
    );
  }

  factory ChatItemModel.fromChatDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatItemModel(
      id: doc.id,
      name: data['name'] ?? 'Nhóm chat',
      email: null,
      photoURL: data['groupPhotoURL'],
      isGroup: true,
      members: List<String>.from(data['members'] ?? []),
      lastMessage: data['lastMessage'],
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      lastMessageFrom: data['lastMessageFrom'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'isGroup': isGroup,
      'members': members,
      'isOnline': isOnline,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'lastMessageFrom': lastMessageFrom,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatItemModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isGroup == other.isGroup;

  @override
  int get hashCode => Object.hash(id, isGroup);
}
