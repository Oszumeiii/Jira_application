import 'package:injectable/injectable.dart';
import 'package:jira/features/comment/domain/comment_entity.dart';
import 'package:jira/features/comment/domain/repo/comment_repo.dart';


@injectable
class CreateCommentUseCase {
  final CommentRepository repository;

  CreateCommentUseCase({required this.repository});

  Future<CommentEntity> call(CommentEntity comment) async {
    return await repository.createComment(comment);
  }
}
