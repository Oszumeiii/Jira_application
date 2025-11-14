import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/core/app_colors.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/avatar_widget.dart';

import 'create_group_cubit.dart';
import 'create_group_state.dart';

class CreateGroupBottomSheet extends StatefulWidget {
  const CreateGroupBottomSheet({super.key});

  @override
  State<CreateGroupBottomSheet> createState() => _CreateGroupBottomSheetState();
}

class _CreateGroupBottomSheetState extends State<CreateGroupBottomSheet> {
  late TextEditingController _groupNameController;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _groupNameController = TextEditingController();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  void _closeBottomSheet() {
    if (!_isClosing) {
      _isClosing = true;
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: maxHeight,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white, // ensure white background
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              children: [
                // header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Tạo nhóm mới',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _closeBottomSheet,
                        icon: Icon(Icons.close, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),

                // body
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _groupNameController,
                          decoration: InputDecoration(
                            labelText: 'Tên nhóm',
                            hintText: 'Nhập tên nhóm...',
                            prefixIcon: const Icon(Icons.group),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (v) => context
                              .read<CreateGroupCubit>()
                              .onGroupNameChanged(v),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (q) =>
                              context.read<CreateGroupCubit>().searchUsers(q),
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<CreateGroupCubit, CreateGroupState>(
                          builder: (context, state) {
                            if (state.isLoading)
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            if (state.friends.isEmpty) {
                              return Center(
                                child: Text(
                                  state.errorMessage?.isNotEmpty == true
                                      ? state.errorMessage!
                                      : 'Không có kết quả',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              );
                            }
                            return Expanded(
                              child: ListView.separated(
                                itemCount: state.friends.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final friend = state.friends[index];
                                  final isSelected = state.selectedFriendIds
                                      .contains(friend.uid);
                                  return ListTile(
                                    leading: SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: AvatarWidget(
                                        url: friend.photoURL,
                                        initials: friend.name,
                                        radius: 24,
                                      ),
                                    ),
                                    title: Text(
                                      friend.name.isNotEmpty
                                          ? friend.name
                                          : 'Không tên',
                                    ),
                                    subtitle: Text(
                                      friend.email ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Checkbox(
                                      value: isSelected,
                                      onChanged: (_) => context
                                          .read<CreateGroupCubit>()
                                          .toggleFriend(friend.uid),
                                    ),
                                    onTap: () => context
                                        .read<CreateGroupCubit>()
                                        .toggleFriend(friend.uid),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              onPressed: () async {
                                await context
                                    .read<CreateGroupCubit>()
                                    .createGroup();
                                final st = context
                                    .read<CreateGroupCubit>()
                                    .state;
                                if (st.isSuccess)
                                  _closeBottomSheet();
                                else if (st.errorMessage?.isNotEmpty == true)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(st.errorMessage!)),
                                  );
                              },
                              child: const Text(
                                'Tạo nhóm',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
