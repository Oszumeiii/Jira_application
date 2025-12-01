
import 'package:jira/features/comment/domain/comment_entity.dart';

abstract class CommentRepository {
  Future<List<CommentEntity>> getCommentsByTask(String taskId);
  Future<CommentEntity> createComment(CommentEntity comment);
  Future<void> deleteComment(String idTask , String commentId);
}
