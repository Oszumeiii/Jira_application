import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/avatar_widget.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_detail/chat_detail_cubit.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_detail/chat_detail_page.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_tab/chat_tab_cubit.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_tab/chat_tab_state.dart';

import 'chat_item_model.dart';

class SearchResultView extends StatelessWidget {
  const SearchResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatTabCubit, ChatTabState>(
      builder: (context, state) {
        final results = state.searchResults;
        if (state.searchQuery.isEmpty) {
          return const Center(child: Text('Gõ để tìm người hoặc chat'));
        }
        if (results.isEmpty) {
          return const Center(child: Text('Không tìm thấy'));
        }
        return ListView.separated(
          itemCount: results.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
          itemBuilder: (context, index) {
            final user = results[index];
            final currentUid = FirebaseAuth.instance.currentUser?.uid;
            return ListTile(
              leading: SizedBox(
                width: 48,
                height: 48,
                child: AvatarWidget(
                  url: user.photoURL,
                  initials: user.name,
                  radius: 24,
                ),
              ),
              title: Text(user.name.isNotEmpty ? user.name : 'Không tên'),
              subtitle: Text(
                user.email ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: user.isOnline
                  ? const Text(
                      'Online',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    )
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => ChatDetailCubit(user.id, false),
                      child: ChatDetailPage(
                        chatId: user.id,
                        chatName: user.name,
                        isGroup: false,
                        members:
                            user.members ??
                            [if (currentUid != null) currentUid, user.id],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
