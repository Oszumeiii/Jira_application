import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/core/app_colors.dart';
import 'add_friend/add_friend_bottom_sheet.dart';
import 'create_group/create_group_bottom_sheet.dart';
import 'create_group/create_group_cubit.dart';

class ChatHeader extends StatefulWidget {
  final String selectedTab;
  final bool showFriendsList;
  final Function(String) onTabChanged;
  final Function(bool) onToggleFriendsList;

  const ChatHeader({
    super.key,
    required this.selectedTab,
    required this.showFriendsList,
    required this.onTabChanged,
    required this.onToggleFriendsList,
  });

  @override
  State<ChatHeader> createState() => _ChatHeaderState();
}

class _ChatHeaderState extends State<ChatHeader> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildTab("All"),
            const SizedBox(width: 8),
            _buildTab("Groups"),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.person_add_alt_1, color: Colors.blue),
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const AddFriendBottomSheet(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.group_add),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (sheetContext) {
                    return BlocProvider(
                      create: (_) => CreateGroupCubit(),
                      child: const CreateGroupBottomSheet(),
                    );
                  },
                );
              },
            ),
            IconButton(
              icon: Icon(
                widget.showFriendsList ? Icons.unfold_less : Icons.people,
                color: widget.showFriendsList
                    ? AppColors.primary
                    : Colors.black54,
              ),
              onPressed: () =>
                  widget.onToggleFriendsList(!widget.showFriendsList),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTab(String label) {
    final selected = label == widget.selectedTab;
    return GestureDetector(
      onTap: () => widget.onTabChanged(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade400,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : Colors.black87,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
