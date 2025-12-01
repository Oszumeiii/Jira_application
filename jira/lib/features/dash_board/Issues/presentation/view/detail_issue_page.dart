import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/features/Users/model/user_model.dart';
import 'package:jira/features/Users/service/user_repo.dart';
import 'package:jira/features/dash_board/Issues/domain/Entity/issue_entity.dart';
import 'package:jira/features/dash_board/Issues/presentation/view/assign_member_bottomsheet.dart';
import 'package:jira/features/dash_board/Issues/presentation/cubit/issue_cubit.dart';

class DetailIssuePage extends StatefulWidget {
  final IssueEntity issue;

  const DetailIssuePage({super.key, required this.issue});

  @override
  State<DetailIssuePage> createState() => _DetailIssuePageState();
}

class _DetailIssuePageState extends State<DetailIssuePage> {
  Future<UserModel?>? _assigneeFuture;
  Future<UserModel?>? _reporterFuture;
  Future<List<UserModel>>? _projectMembersFuture;
  late IssueEntity _currentIssue;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentIssue = widget.issue;
    _titleController.text = _currentIssue.title;
    _summaryController.text = _currentIssue.summary;
    _descriptionController.text = _currentIssue.description ?? '';
    _assigneeFuture = _fetchUser(_currentIssue.assigneeId);
    _reporterFuture = _fetchUser(_currentIssue.reporterId);
    _projectMembersFuture = UserService.getUsersInProject(_currentIssue.projectId);

  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _summaryController.dispose();
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
    await context.read<IssueCubit>().updateIssue(updatedIssue);

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
      final bottomInset = MediaQuery.of(context).viewInsets.bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false, // rất quan trọng để sheet co lại khi keyboard bật
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
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
                  const SizedBox(height: 18),
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
        ),
      );
    },
  );

  if (newTitle != null && newTitle.isNotEmpty && newTitle != _currentIssue.title) {
    final updatedIssue = _currentIssue.copyWith(title: newTitle);
    await context.read<IssueCubit>().updateIssue(updatedIssue);

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
      final bottomInset = MediaQuery.of(context).viewInsets.bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
                  TextField(
                    controller: _descriptionController,
                    autofocus: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 6,
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
        ),
      );
    },
  );

  if (newDescription != null && newDescription != _currentIssue.description) {
    final updatedIssue = _currentIssue.copyWith(description: newDescription);
    await context.read<IssueCubit>().updateIssue(updatedIssue);

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

Future<void> _updateSummary() async {
  final newSummary = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final bottomInset = MediaQuery.of(context).viewInsets.bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Edit Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _summaryController,
                    autofocus: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 3,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter summary...',
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
                        onPressed: () => Navigator.pop(context, _summaryController.text),
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
        ),
      );
    },
  );

  if (newSummary != null && newSummary != _currentIssue.summary) {
    final updatedIssue = _currentIssue.copyWith(summary: newSummary);
    await context.read<IssueCubit>().updateIssue(updatedIssue);

    setState(() {
      _currentIssue = updatedIssue;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Summary updated successfully!"),
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
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    backgroundColor: Colors.white,
    titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
    actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),

    title: Row(
      children: [
        Icon(Icons.warning_amber_rounded,
            color: Colors.red.shade600, size: 28),
        const SizedBox(width: 10),
        const Text(
          'Delete Issue',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ],
    ),

    content: const Text(
      'Are you sure you want to delete this issue? This action cannot be undone.',
      style: TextStyle(
        fontSize: 15,
        color: Colors.black87,
        height: 1.4,
      ),
    ),

    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        style: TextButton.styleFrom(
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(fontSize: 15),
        ),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, true),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('Delete'),
      ),
    ],
  ),
);


    if (confirmed == true) {
      try {
        await context.read<IssueCubit>().deleteIssue(_currentIssue.id!);
        
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
    await context.read<IssueCubit>().updateIssue(updatedIssue);

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
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                    title: "Summary",
                    icon: Icons.description_outlined,
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: _updateSummary,
                      tooltip: 'Edit Summary',
                    ),
                    child: Text(
                      issue.summary ,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.grey.shade700,
                      ),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: Colors.blue.shade600),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 16),
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
                        // backgroundImage: AssetImage('jira/assets/images/image.png'),
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