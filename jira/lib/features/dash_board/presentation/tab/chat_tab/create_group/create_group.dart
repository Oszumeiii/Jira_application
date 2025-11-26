// features/dash_board/presentation/tab/chat_tab/create_group/create_group_content.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'create_group_cubit.dart';
import 'create_group_state.dart';

class CreateGroupContent extends StatelessWidget {
  const CreateGroupContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateGroupCubit, CreateGroupState>(
      builder: (context, state) {
        return Column(
          children: [
            // Group Name
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                onChanged: context.read<CreateGroupCubit>().onGroupNameChanged,
                decoration: const InputDecoration(
                  hintText: "Tên nhóm",
                  prefixIcon: Icon(Icons.group, color: Color(0xFF6554C0)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Members Header
            Row(
              children: [
                const Text(
                  "Thành viên",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  "${state.selectedFriendIds.length} được chọn",
                  style: const TextStyle(color: Color(0xFF6554C0)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Friends List
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.friends.isEmpty
                    ? const Center(child: Text("Chưa có bạn bè"))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: state.friends.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 72),
                        itemBuilder: (context, i) {
                          final friend = state.friends[i];
                          final isSelected = state.selectedFriendIds.contains(
                            friend.uid,
                          );
                          return CheckboxListTile(
                            secondary: CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xFFDFE1E6),
                              backgroundImage: friend.photoURL != null
                                  ? NetworkImage(friend.photoURL!)
                                  : null,
                              child: friend.photoURL == null
                                  ? Text(
                                      friend.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Text(
                              friend.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              friend.email,
                              style: const TextStyle(fontSize: 13),
                            ),
                            value: isSelected,
                            onChanged: (_) => context
                                .read<CreateGroupCubit>()
                                .toggleFriend(friend.uid),
                            activeColor: const Color(0xFF6554C0),
                            controlAffinity: ListTileControlAffinity.trailing,
                          );
                        },
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Error Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFEBE6), Color(0xFFFFD4CC)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFAB00)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Color(0xFFFFAB00)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.errorMessage,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Create Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: state.isLoading
                    ? null
                    : () => context.read<CreateGroupCubit>().createGroup(),
                icon: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add, size: 20),
                label: Text(state.isLoading ? "Đang tạo..." : "Tạo nhóm"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6554C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
