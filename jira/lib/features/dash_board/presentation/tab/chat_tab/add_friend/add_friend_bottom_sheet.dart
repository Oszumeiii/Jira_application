// features/dash_board/presentation/tab/chat_tab/add_friend/add_friend_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/core/app_colors.dart';
import 'add_friend_cubit.dart';
import 'add_friend_state.dart';

class AddFriendBottomSheet extends StatelessWidget {
  const AddFriendBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFFF4F5F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: BlocProvider(
        create: (_) => AddFriendCubit(),
        child: const _AddFriendContent(),
      ),
    );
  }
}

class _AddFriendContent extends StatelessWidget {
  const _AddFriendContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Thêm bạn bè"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                onChanged: context.read<AddFriendCubit>().onQueryChanged,
                decoration: InputDecoration(
                  hintText: "Tìm kiếm theo email",
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF6554C0),
                  ),
                  suffixIcon:
                      BlocSelector<AddFriendCubit, AddFriendState, String>(
                        selector: (state) => state.query,
                        builder: (context, query) => query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => context
                                    .read<AddFriendCubit>()
                                    .onQueryChanged(''),
                              )
                            : const SizedBox.shrink(),
                      ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Results
            Expanded(
              child: BlocBuilder<AddFriendCubit, AddFriendState>(
                builder: (context, state) {
                  if (state.isLoading)
                    return const Center(child: CircularProgressIndicator());
                  if (state.suggestions.isEmpty && state.query.length >= 2) {
                    return const Center(child: Text("Không tìm thấy"));
                  }
                  return ListView.separated(
                    itemCount: state.suggestions.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 72),
                    itemBuilder: (context, i) {
                      final user = state.suggestions[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null,
                          child: user.photoURL == null
                              ? Text(user.name[0])
                              : null,
                        ),
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.person_add,
                            color: AppColors.primary,
                          ),
                          onPressed: () => context
                              .read<AddFriendCubit>()
                              .sendFriendRequest(user.uid),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Message
            BlocSelector<AddFriendCubit, AddFriendState, String?>(
              selector: (state) => state.message,
              builder: (context, message) {
                if (message == null) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: message.contains('thành công')
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: message.contains('thành công')
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
