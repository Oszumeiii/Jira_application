// data/datasources/comment_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:jira/features/comment/data/model/comment_model.dart';
import 'package:jira/core/api_client.dart';

abstract class CommentRemoteDataSource {
  Future<List<CommentModel>> getCommentsByTask(String taskId);
  Future<CommentModel> createComment(CommentModel comment);
  Future<void> deleteComment(String idTask , String commentId);
}



@Injectable(as: CommentRemoteDataSource) 
class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final Dio _dio;

  CommentRemoteDataSourceImpl() : _dio = ApiClient.dio;

  @override
  Future<List<CommentModel>> getCommentsByTask(String idTask) async {
    try {
      final response = await _dio.get('/comments/$idTask');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data
            .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch comments');
      }
    } catch (e) {
      throw Exception('Error fetching comments: $e');
    }
  }

  @override
  Future<CommentModel> createComment(CommentModel comment) async {
    try {
      final idTask = comment.taskId ;
      final response = await _dio.post(
        '/comments/$idTask',
        data: comment.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        print(data);
        return CommentModel.fromJson(data);
      } else {
        throw Exception('Failed to create comment');
      }
    } catch (e) {
      throw Exception('Error creating comment: $e');
    }
  }

@override
Future<void> deleteComment(String idTask , String idComment) async {
  try {
    final response = await _dio.delete('/issues/$idTask/comments/$idComment');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete comment');
    }
  } catch (e) {
    throw Exception('Error deleting comment: $e');
  }
}

}
