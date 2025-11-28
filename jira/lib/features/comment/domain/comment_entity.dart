class CommentEntity {
  final String? id;        
  final String taskId;
  final String? userId;
  final String content;
  final String? username;
  final String? email;
  final DateTime createdAt;

  CommentEntity({
    this.id,
    required this.taskId,
     this.userId,
    required this.content,
    this.username,
    this.email,
    required this.createdAt,
  });
}
