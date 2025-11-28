import 'package:equatable/equatable.dart';
import 'package:jira/features/comment/domain/comment_entity.dart';

class CommentState extends Equatable {
  final bool isLoading;
  final List<CommentEntity> comments;
  final String? error;

  const CommentState({
    this.isLoading = false,
    this.comments = const [],
    this.error,
  });

  CommentState copyWith({
    bool? isLoading,
    List<CommentEntity>? comments,
    String? error,
  }) {
    return CommentState(
      isLoading: isLoading ?? this.isLoading,
      comments: comments ?? this.comments,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, comments, error];
}
