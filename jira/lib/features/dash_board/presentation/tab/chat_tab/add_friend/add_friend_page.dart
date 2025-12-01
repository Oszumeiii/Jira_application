// features/dash_board/presentation/tab/chat_tab/add_friend/add_friend_page_content.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/avatar_widget.dart';
import 'add_friend_cubit.dart';
import 'add_friend_state.dart';

class AddFriendPageContent extends StatefulWidget {
  const AddFriendPageContent({super.key});

  @override
  State<AddFriendPageContent> createState() => _AddFriendPageContentState();
}

class _AddFriendPageContentState extends State<AddFriendPageContent> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Email with animation
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isFocused
                  ? const Color(0xFF5B4FDB).withOpacity(0.3)
                  : Colors.grey[200]!,
              width: 1.5,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: const Color(0xFF5B4FDB).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            onTap: () => setState(() => _isFocused = true),
            onTapOutside: (_) => setState(() => _isFocused = false),
            onChanged: context.read<AddFriendCubit>().onQueryChanged,
            decoration: InputDecoration(
              hintText: "Search by email",
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                Icons.email_rounded,
                color: _isFocused ? const Color(0xFF5B4FDB) : Colors.grey[600],
                size: 22,
              ),
              suffixIcon: BlocSelector<AddFriendCubit, AddFriendState, String>(
                selector: (state) => state.query,
                builder: (context, query) => query.isNotEmpty
                    ? Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () =>
                              context.read<AddFriendCubit>().onQueryChanged(''),
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
          ),
        ),
        const SizedBox(height: 16),

        // Suggestions List with nicer card design
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: BlocBuilder<AddFriendCubit, AddFriendState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF5B4FDB),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Searching...",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
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
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Try searching with a different email",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
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
                          Icons.person_add_alt_1_rounded,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Find friends",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Enter an email to search users",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.suggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final user = state.suggestions[i];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(12),
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
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        user.email,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => context
                                        .read<AddFriendCubit>()
                                        .sendFriendRequest(user.uid),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF5B4FDB,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(
                                            0xFF5B4FDB,
                                          ).withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.person_add_rounded,
                                        color: Color(0xFF5B4FDB),
                                        size: 22,
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
        ),

        const SizedBox(height: 16),

        BlocSelector<AddFriendCubit, AddFriendState, String?>(
          selector: (state) => state.message,
          builder: (context, message) {
            if (message == null) return const SizedBox.shrink();
            final isSuccess = message.contains('success');
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSuccess
                    ? const Color(0xFF10B981).withOpacity(0.1)
                    : const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSuccess
                      ? const Color(0xFF10B981).withOpacity(0.3)
                      : const Color(0xFFF59E0B).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSuccess
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSuccess
                          ? Icons.check_rounded
                          : Icons.info_outline_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: isSuccess
                            ? const Color(0xFF047857)
                            : const Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
