import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:jira/features/comment/domain/comment_entity.dart';
import 'package:jira/features/comment/domain/usecase/create_comment_usecase.dart';
import 'package:jira/features/comment/domain/usecase/get_comment_usecase.dart';
import 'package:jira/features/comment/domain/usecase/remove_comment_usecase.dart';
import 'package:jira/features/comment/presentation/cubit/comment_state.dart';


@injectable
class CommentCubit extends Cubit<CommentState> {
  final GetCommentsByTaskUseCase getCommentsByTaskUsecase;
  final CreateCommentUseCase createCommentUsecase;
  final DeleteCommentUseCase deleteCommentUsecase;

  CommentCubit(
    this.getCommentsByTaskUsecase,
    this.createCommentUsecase,
    this.deleteCommentUsecase,
  ) : super(CommentState());


  Future<void> loadComments(String taskId) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final comments = await getCommentsByTaskUsecase(taskId);
      emit(state.copyWith(isLoading: false, comments: comments));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }


  Future<void> addComment(String taskId, String content, {String? userId, String? username, String? email}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final newComment = CommentEntity(
        taskId: taskId,
        userId: userId,
        content: content,
        username: username,
        email: email,
        createdAt: DateTime.now(),
      );
      final createdComment = await createCommentUsecase(newComment);
      print('Created Comment: ${createdComment.id}');
      final updatedComments = List<CommentEntity>.from(state.comments)..add(createdComment);
      emit(state.copyWith(isLoading: false, comments: updatedComments));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }


  Future<void> deleteComment(String idTask , String commentId) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final success = await deleteCommentUsecase(idTask , commentId);
      if (success) {
        final updatedComments = List<CommentEntity>.from(state.comments)
          ..removeWhere((c) => c.id == commentId);
        emit(state.copyWith(isLoading: false, comments: updatedComments));
      } else {
        emit(state.copyWith(isLoading: false, error: "Failed to delete comment"));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
