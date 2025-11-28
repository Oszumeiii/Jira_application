import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:jira/features/comment/domain/comment_entity.dart';
import 'package:jira/features/comment/presentation/cubit/comment_cubit.dart';
import 'package:jira/features/comment/presentation/cubit/comment_state.dart';

class CommentSection extends StatelessWidget {
  final String taskId;
  final TextEditingController _controller = TextEditingController();

  CommentSection({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final commentCubit = context.read<CommentCubit>();
    commentCubit.loadComments(taskId);

    return Column(
      children: [
        BlocBuilder<CommentCubit, CommentState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.error != null) {
              return Text("Error: ${state.error}");
            } else if (state.comments.isEmpty) {
              return const Text("No comments yet.");
            } else {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.comments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final comment = state.comments[index];
                  return _buildCommentItem(context, commentCubit, comment);
                },
              );
            }
          },
        ),
        const SizedBox(height: 12),

        /// Input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "Add a comment...",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                final content = _controller.text.trim();
                if (content.isNotEmpty) {
                  commentCubit.addComment(taskId, content);
                  _controller.clear();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

Widget _buildCommentItem(
  BuildContext context,
  CommentCubit cubit,
  CommentEntity comment,
) {
  final formattedDate =
      DateFormat("dd/MM/yyyy HH:mm").format(comment.createdAt);

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.blue.shade300,
          child: Text(
            comment.username?.substring(0, 1).toUpperCase() ?? "U",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      comment.username ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == "delete") {
                        cubit.deleteComment(taskId , comment.id!);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: "delete",
                        child: Text("Delete"),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert, size: 20),
                  ),
                ],
              ),
              Text(
                comment.content,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                formattedDate,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


}

