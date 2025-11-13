// features/dash_board/presentation/tab/chat_tab/add_friend/add_friend_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_friend_cubit.dart';
import 'add_friend_state.dart';

class AddFriendPage extends StatelessWidget {
  const AddFriendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddFriendCubit(),
      child: const _AddFriendView(),
    );
  }
}

class _AddFriendView extends StatelessWidget {
  const _AddFriendView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Thêm bạn bè",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Email
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
                                icon: const Icon(Icons.clear, size: 18),
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

            // Suggestions List
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: BlocBuilder<AddFriendCubit, AddFriendState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.suggestions.isEmpty && state.query.length >= 2) {
                      return const Center(
                        child: Text("Không tìm thấy người dùng"),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: state.suggestions.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 72),
                      itemBuilder: (context, i) {
                        final user = state.suggestions[i];
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFFDFE1E6),
                            backgroundImage: user.photoURL != null
                                ? NetworkImage(user.photoURL!)
                                : null,
                            child: user.photoURL == null
                                ? Text(
                                    user.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(
                            user.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            user.email,
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: Color(0xFF6554C0),
                              size: 26,
                            ),
                            onPressed: () => context
                                .read<AddFriendCubit>()
                                .addFriend(user.uid),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Message
            BlocSelector<AddFriendCubit, AddFriendState, String?>(
              selector: (state) => state.message,
              builder: (context, message) {
                if (message == null) return const SizedBox.shrink();
                final isSuccess = message.contains('thành công');
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isSuccess
                        ? const LinearGradient(
                            colors: [Color(0xFFE3FCEF), Color(0xFFB8E6D2)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFFFFEBE6), Color(0xFFFFD4CC)],
                          ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSuccess
                          ? const Color(0xFF36B37E)
                          : const Color(0xFFFFAB00),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSuccess ? Icons.check_circle : Icons.info,
                        color: isSuccess
                            ? const Color(0xFF36B37E)
                            : const Color(0xFFFFAB00),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
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
