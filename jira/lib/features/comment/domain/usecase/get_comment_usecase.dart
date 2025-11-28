import 'package:injectable/injectable.dart';
import 'package:jira/features/comment/domain/comment_entity.dart';
import 'package:jira/features/comment/domain/repo/comment_repo.dart';

@injectable
class GetCommentsByTaskUseCase {
  final CommentRepository repository;

  GetCommentsByTaskUseCase({required this.repository});

  Future<List<CommentEntity>> call(String taskId) async {
    return await repository.getCommentsByTask(taskId);
  }
}
