// features/dash_board/presentation/tab/chat_tab/add_friend/add_friend_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/avatar_widget.dart';
import 'add_friend_cubit.dart';
import 'add_friend_state.dart';

class AddFriendBottomSheet extends StatelessWidget {
  const AddFriendBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: BlocProvider(
        create: (_) => AddFriendCubit(),
        child: const _AddFriendContent(),
      ),
    );
  }
}

class _AddFriendContent extends StatefulWidget {
  const _AddFriendContent();

  @override
  State<_AddFriendContent> createState() => _AddFriendContentState();
}

class _AddFriendContentState extends State<_AddFriendContent> {
  bool _isFocused = false;
  final Set<String> _addedFriends = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Text(
              "Add Friends",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 22,
                color: Color(0xFF6C5CE7),
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF6C5CE7),
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isFocused
                      ? const Color(0xFF6C5CE7)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: TextField(
                onTap: () => setState(() => _isFocused = true),
                onTapOutside: (_) => setState(() => _isFocused = false),
                onChanged: context.read<AddFriendCubit>().onQueryChanged,
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                  suffixIcon:
                      BlocSelector<AddFriendCubit, AddFriendState, String>(
                        selector: (state) => state.query,
                        builder: (context, query) => query.isNotEmpty
                            ? IconButton(
                                onPressed: () => context
                                    .read<AddFriendCubit>()
                                    .onQueryChanged(''),
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<AddFriendCubit, AddFriendState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6C5CE7),
                      ),
                    );
                  }

                  if (state.suggestions.isEmpty && state.query.length >= 2) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_search_rounded,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No users found",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.suggestions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Search for friends",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: state.suggestions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final user = state.suggestions[i];
                      final isAdded = _addedFriends.contains(user.uid);

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  AvatarWidget(
                                    url: user.photoURL,
                                    initials: user.name,
                                    radius: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Color(0xFF2D3748),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          user.email,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: isAdded
                                          ? null
                                          : () {
                                              context
                                                  .read<AddFriendCubit>()
                                                  .sendFriendRequest(user.uid);
                                              setState(() {
                                                _addedFriends.add(user.uid);
                                              });
                                            },
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isAdded
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFF6C5CE7),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          isAdded
                                              ? Icons.check_rounded
                                              : Icons.person_add_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            BlocSelector<AddFriendCubit, AddFriendState, String?>(
              selector: (state) => state.message,
              builder: (context, message) {
                if (message == null) return const SizedBox.shrink();
                final isSuccess = message.contains('success');
                return Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? const Color(0xFF6C5CE7)
                        : const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSuccess
                            ? Icons.check_circle_rounded
                            : Icons.info_outline_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.white,
                          ),
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
