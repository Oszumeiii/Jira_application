import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tab container
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                _buildTab("All"),
                SizedBox(width: 4.w),
                _buildTab("Groups"),
              ],
            ),
          ),

          // Action buttons
          Row(
            children: [
              _buildIconButton(
                icon: Icons.person_add_alt_1_rounded,
                color: AppColors.primary,
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AddFriendBottomSheet(),
                ),
              ),
              SizedBox(width: 8.w),
              _buildIconButton(
                icon: Icons.group_add_rounded,
                color: AppColors.primary,
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
              SizedBox(width: 8.w),
              _buildIconButton(
                icon: widget.showFriendsList
                    ? Icons.expand_less_rounded
                    : Icons.people_rounded,
                color: widget.showFriendsList
                    ? AppColors.primary
                    : Colors.grey[700]!,
                isActive: widget.showFriendsList,
                onPressed: () =>
                    widget.onToggleFriendsList(!widget.showFriendsList),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label) {
    final selected = label == widget.selectedTab;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ]
            : null,
      ),
      child: GestureDetector(
        onTap: () => widget.onTabChanged(label),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : Colors.grey[600],
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isActive ? color.withOpacity(0.3) : Colors.grey[200]!,
              width: 1.5.w,
            ),
          ),
          child: Icon(icon, size: 20.sp, color: color),
        ),
      ),
    );
  }
}
