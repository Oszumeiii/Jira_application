import 'package:injectable/injectable.dart';
import 'package:jira/features/comment/domain/repo/comment_repo.dart';


@injectable
class DeleteCommentUseCase {
  final CommentRepository repository;

  DeleteCommentUseCase({required this.repository});
  Future<bool> call(String idTask , String commentId) async {
    try {
      await repository.deleteComment(idTask , commentId);
      return true; 
    } catch (_) {
      return false; 
    }
  }
}
