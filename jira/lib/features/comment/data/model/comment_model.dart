import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jira/features/comment/domain/comment_entity.dart';

class CommentModel extends CommentEntity {
  CommentModel({
    super.id,
    required super.taskId,
    super.userId,
    required super.content,
    super.username,
    super.email,
    required super.createdAt,
  });

  // factory CommentModel.fromJson(Map<String, dynamic> json) {
  //   return CommentModel(
  //     id: json['id'],
  //     taskId: json['taskId'] ?? '',
  //     userId: json['userId'] ?? '',
  //     content: json['content'] ?? '',
  //     username: json['username'],
  //     email: json['email'],
  //     createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
  //   );
  // }


factory CommentModel.fromJson(Map<String, dynamic> json) {
  final createdAt = json['createdAt'];

  DateTime parsedDate;

  if (createdAt is String) {
    parsedDate = DateTime.parse(createdAt);
  } else if (createdAt is Map<String, dynamic>) {
    parsedDate = DateTime.fromMillisecondsSinceEpoch(
      (createdAt['_seconds'] * 1000) +
      (createdAt['_nanoseconds'] ~/ 1000000),
    );
  } else {
    parsedDate = DateTime.now();
  }

  return CommentModel(
    id: json['id'],
    taskId: json['taskId'] ?? '',
    userId: json['userId'],
    content: json['content'],
    username: json['username'],
    email: json['email'],
    createdAt: parsedDate,
  );
}






  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      taskId: data['taskId'] ?? '',
      userId: data['userId'],
      content: data['content'] ?? '',
      username: data['username'],
      email: data['email'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'userId': userId,
      'content': content,
      'username': username,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }


  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      taskId: taskId,
      userId: userId,
      content: content,
      username: username,
      email: email,
      createdAt: createdAt,
    );
  }
}
