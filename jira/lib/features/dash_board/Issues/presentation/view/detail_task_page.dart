import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/core/injection.dart';
import 'package:jira/features/Users/model/user_model.dart';
import 'package:jira/features/Users/service/user_repo.dart';
import 'package:jira/features/comment/presentation/cubit/comment_cubit.dart';
import 'package:jira/features/comment/presentation/view/comment_section.dart';
import 'package:jira/features/dash_board/Issues/domain/Entity/issue_entity.dart';
import 'package:jira/features/dash_board/Issues/presentation/view/assign_member_bottomsheet.dart';
import 'package:jira/features/dash_board/Issues/presentation/cubit/issue_cubit.dart';

class DetailTaskPage extends StatefulWidget {
  final IssueEntity issue;

  const DetailTaskPage({super.key, required this.issue});

  @override
  State<DetailTaskPage> createState() => _DetailTaskPageState();
}

class _DetailTaskPageState extends State<DetailTaskPage> {
  Future<UserModel?>? _assigneeFuture;
  Future<UserModel?>? _reporterFuture;
  Future<List<UserModel>>? _projectMembersFuture;
  late IssueEntity _currentIssue;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentIssue = widget.issue;
    _titleController.text = _currentIssue.title;
    _descriptionController.text = _currentIssue.description ?? '';
    _assigneeFuture = _fetchUser(_currentIssue.assigneeId);
    _reporterFuture = _fetchUser(_currentIssue.reporterId);
    _projectMembersFuture = UserService.getUsersInProject(_currentIssue.projectId);

  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  

  Future<UserModel?> _fetchUser(String? userId) async {
    if (userId == null) return null;
    try {
      return await UserService.getUserById(userId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _assignUser(String userId) async {
    final updatedIssue = _currentIssue.copyWith(assigneeId: userId);
    await getIt<IssueCubit>().updateIssue(updatedIssue);

    setState(() {
      _currentIssue = updatedIssue;
      _assigneeFuture = _fetchUser(userId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Assigned successfully!"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  Future<void> _changeAssignee() async {
    final members = await _projectMembersFuture;
    if (members == null || members.isEmpty) return;

    final List<UserModel>? result = await showModalBottomSheet<List<UserModel>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: AssignMemberBottomSheet(members: members),
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _assignUser(result[0].uid);
    }
  }

Future<void> _updateTitle() async {
  final newTitle = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.3,
        minChildSize: 0.2,
        maxChildSize: 0.6,
        builder: (_, controller) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Title',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleController,
                  autofocus: true,
                  maxLines: 2,
                  minLines: 1,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Enter title...',
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, _titleController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );

  if (newTitle != null && newTitle.isNotEmpty && newTitle != _currentIssue.title) {
    final updatedIssue = _currentIssue.copyWith(title: newTitle);
    await getIt<IssueCubit>().updateIssue(updatedIssue);

    setState(() {
      _currentIssue = updatedIssue;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Title updated successfully!"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }
}


Future<void> _updateDescription() async {
  final newDescription = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        builder: (_, controller) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    controller: controller,
                    child: TextField(
                      controller: _descriptionController,
                      autofocus: true,
                      maxLines: null,
                      minLines: 4,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Enter description...',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, _descriptionController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );

  if (newDescription != null && newDescription != _currentIssue.description) {
    final updatedIssue = _currentIssue.copyWith(description: newDescription);
    await getIt<IssueCubit>().updateIssue(updatedIssue);

    setState(() {
      _currentIssue = updatedIssue;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Description updated successfully!"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }
}


  Future<void> _deleteIssue() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Issue'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Text('Are you sure you want to delete this issue? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await getIt<IssueCubit>().deleteIssue(_currentIssue.id!);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Issue deleted successfully!"),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to delete issue: $e"),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    if (_currentIssue.status == newStatus) return;

    final updatedIssue = _currentIssue.copyWith(status: newStatus);
    await getIt<IssueCubit>().updateIssue(updatedIssue);

    setState(() {
      _currentIssue = updatedIssue;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Status updated to ${newStatus.capitalize()}"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final issue = _currentIssue;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          issue.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white, // màu nền menu
            elevation: 8,
            onSelected: (value) {
              switch (value) {
                case 'edit_title':
                  _updateTitle();
                  break;
                case 'edit_description':
                  _updateDescription();
                  break;
                case 'change_assignee':
                  _changeAssignee();
                  break;
                case 'delete':
                  _deleteIssue();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit_title',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    const Text('Edit Title', style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit_description',
                child: Row(
                  children: [
                    Icon(Icons.description, size: 20, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    const Text('Edit Description', style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'change_assignee',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 20, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    const Text('Change Assignee', style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    const SizedBox(width: 12),
                    const Text('Delete Issue', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card with Gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade500,
                    Colors.blue.shade700,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildModernBadge(
                          issue.type.toUpperCase(),
                          _getTypeIcon(issue.type),
                          Colors.white,
                          Colors.white24,
                        ),
                        const SizedBox(width: 8),
                        _buildModernBadge(
                          issue.priority.toUpperCase(),
                          Icons.flag,
                          Colors.white,
                          Colors.white24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            issue.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _updateTitle,
                          icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                          tooltip: 'Edit title',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Section
                  _buildSectionCard(
                    title: "Status",
                    icon: Icons.linear_scale_rounded,
                    child: Wrap(
                      spacing: 8,
                      children: ['todo', 'inProgress', 'done'].map((status) {
                        final isSelected = issue.status.toLowerCase() == status.toLowerCase();
                        return _buildStatusChip(status, isSelected);
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // People Section
                  _buildSectionCard(
                    title: "Team",
                    icon: Icons.people_outline_rounded,
                    child: Column(
                      children: [
                        _buildPersonRow(
                          label: "Assignee",
                          future: _assigneeFuture,
                          onAssign: () async {
                            final members = await _projectMembersFuture;
                            if (members == null || members.isEmpty) return;

                            final List<UserModel>? result =
                                await showModalBottomSheet<List<UserModel>>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                child: AssignMemberBottomSheet(members: members),
                              ),
                            );

                            if (result != null && result.isNotEmpty) {
                              await _assignUser(result[0].uid);
                            }
                          },
                        ),
                        const Divider(height: 24),
                        _buildPersonRow(
                          label: "Reporter",
                          future: _reporterFuture,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description Section
                  _buildSectionCard(
                    title: "Description",
                    icon: Icons.description_outlined,
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: _updateDescription,
                      tooltip: 'Edit description',
                    ),
                    child: Text(
                      issue.description ?? 'No description provided.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Timeline Section
                  _buildSectionCard(
                    title: "Timeline",
                    icon: Icons.schedule_outlined,
                    child: Column(
                      children: [
                        _buildTimelineRow(
                          icon: Icons.add_circle_outline,
                          label: "Created",
                          date: issue.createdAt,
                        ),
                        const SizedBox(height: 12),
                        _buildTimelineRow(
                          icon: Icons.update_outlined,
                          label: "Last Updated",
                          date: issue.updatedAt ?? issue.createdAt,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),


            const SizedBox(height: 16),
          _buildSectionCard(
            title: "Comments",
            icon: Icons.comment_outlined,
            child: BlocProvider<CommentCubit>(
              create: (_) => getIt<CommentCubit>(),
              child: CommentSection(taskId: issue.id!),
            ),
          ),


          ],
        ),
      ),
    );
  }

Widget _buildSectionCard({
  required String title,
  required IconData icon,
  required Widget child,
  Widget? trailing,
}) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: Colors.blue.shade600,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),

              if (trailing != null) trailing,
            ],
          ),

          const SizedBox(height: 20),
          child,
        ],
      ),
    ),
  );
}


  Widget _buildPersonRow({
    required String label,
    required Future<UserModel?>? future,
    VoidCallback? onAssign,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: FutureBuilder<UserModel?>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                      height: 20,
                      width: 20,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(seconds: 1),
                        builder: (context, value, child) {
                          return Transform.rotate(
                            angle: value * 6.3, // 2*π rad
                            child: child,
                          );
                        },
                        child: Icon(Icons.autorenew, color: Colors.blue.shade600, size: 20),
                      ),
                    );
              }
              
              final user = snapshot.data;
              if (user != null) {
                return InkWell(
                  onTap: onAssign,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.blue.shade100,
                         //backgroundImage: AssetImage('jira/assets/images/image.png'),
                          child:  Text(
                                  user.lastName[0].toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                )
                          
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            user.userName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onAssign != null)
                          Icon(Icons.edit, size: 16, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                );
              } else if (onAssign != null) {
                return TextButton.icon(
                  onPressed: onAssign,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Assign"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                );
              }
              return const Text("Unassigned");
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status, bool isSelected) {
    final colors = _getStatusColors(status);
    
    return InkWell(
      onTap: () => _updateStatus(status),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors['bg'] : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors['border']! : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.check_circle,
                  size: 16,
                  color: colors['text'],
                ),
              ),
            Text(
              status.capitalize(),
              style: TextStyle(
                color: isSelected ? colors['text'] : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernBadge(String text, IconData icon, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRow({
    required IconData icon,
    required String label,
    required DateTime date,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(date),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Map<String, Color> _getStatusColors(String status) {
    switch (status.toLowerCase()) {
      case 'todo':
        return {
          'bg': Colors.orange.shade50,
          'border': Colors.orange.shade300,
          'text': Colors.orange.shade700,
        };
      case 'inprogress':
        return {
          'bg': Colors.blue.shade50,
          'border': Colors.blue.shade300,
          'text': Colors.blue.shade700,
        };
      case 'done':
        return {
          'bg': Colors.green.shade50,
          'border': Colors.green.shade300,
          'text': Colors.green.shade700,
        };
      default:
        return {
          'bg': Colors.grey.shade50,
          'border': Colors.grey.shade300,
          'text': Colors.grey.shade700,
        };
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'bug':
        return Icons.bug_report;
      case 'task':
        return Icons.check_box_outlined;
      case 'story':
        return Icons.bookmark_outline;
      default:
        return Icons.label_outline;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}