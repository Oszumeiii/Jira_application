import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/avatar_widget.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_detail/chat_detail_cubit.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_detail/chat_detail_page.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_tab/chat_tab_cubit.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_tab/chat_tab_state.dart';

class SearchResultView extends StatelessWidget {
  const SearchResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatTabCubit, ChatTabState>(
      builder: (context, state) {
        final results = state.searchResults;

        if (state.searchQuery.isEmpty) {
          return const Center(
            child: Text('Type to search for people or groups'),
          );
        }
        if (results.isEmpty) {
          return const Center(child: Text('No results found'));
        }

        return ListView.separated(
          itemCount: results.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
          itemBuilder: (context, index) {
            final item = results[index];
            final currentUid = FirebaseAuth.instance.currentUser!.uid;

            return ListTile(
              leading: AvatarWidget(
                url: item.photoURL,
                initials: item.name,
                radius: 24,
              ),
              title: Text(
                item.name.isNotEmpty ? item.name : 'No name',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: item.isGroup
                  ? Text('${item.members.length} members')
                  : Text(item.email ?? 'No email'),
              trailing: item.isGroup
                  ? const Icon(Icons.group, color: Colors.grey)
                  : (item.isOnline
                        ? const Text(
                            'Online',
                            style: TextStyle(color: Colors.green),
                          )
                        : null),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => ChatDetailCubit(
                        item.id,
                        item.isGroup,
                        initialIsChatId: true,
                      ),
                      child: ChatDetailPage(
                        chatId: item.id,
                        chatName: item.name,
                        isGroup: item.isGroup,
                        members: item.members,
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
