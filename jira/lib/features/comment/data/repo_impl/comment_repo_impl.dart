import 'package:injectable/injectable.dart';
import 'package:jira/features/comment/data/model/comment_model.dart';
import 'package:jira/features/comment/data/remote_data_sorce/comment_remote_data_rource.dart';
import 'package:jira/features/comment/domain/comment_entity.dart';
import 'package:jira/features/comment/domain/repo/comment_repo.dart';


@Injectable(as: CommentRepository)

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remoteDataSource;

  CommentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CommentEntity>> getCommentsByTask(String taskId) async {
    try {
      final commentModels = await remoteDataSource.getCommentsByTask(taskId);
      // Chuyển về entity
      return commentModels.map((e) => e.toEntity()).toList();
    } catch (e) {
      throw Exception('Error fetching comments: $e');
    }
  }

  @override
  Future<CommentEntity> createComment(CommentEntity comment) async {
    try {
      final commentModel = CommentModel(
        taskId: comment.taskId,
        userId: comment.userId ,
        content: comment.content,
        username: comment.username,
        email: comment.email,
        createdAt: comment.createdAt,
      );

      final createdModel = await remoteDataSource.createComment(commentModel);
      return createdModel.toEntity();
    } catch (e) {
      throw Exception('Error creating comment: $e');
    }
  }

  @override
  Future<void> deleteComment(String idTask , String commentId) async {
    try {
      await remoteDataSource.deleteComment(idTask , commentId);
    } catch (e) {
      throw Exception('Error deleting comment: $e');
    }
  }
}
