import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/features/Users/model/user_model.dart';
import 'package:jira/features/Users/service/user_repo.dart';
import 'package:jira/features/dash_board/projects/data/models/project_model.dart';
import 'package:jira/features/dash_board/projects/domain/entities/project_entity.dart';
import 'package:jira/features/dash_board/projects/presentation/cubit/project_cubit.dart';
import 'package:jira/features/dash_board/projects/presentation/view/change_member_to_project.dart';

class ProjectInfoPage extends StatefulWidget {
  final ProjectEntity project;

  const ProjectInfoPage({super.key, required this.project});

  @override
  State<ProjectInfoPage> createState() => _ProjectInfoPageState();
}

class _ProjectInfoPageState extends State<ProjectInfoPage> {
  late ProjectEntity _currentProject;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _statusCtrl;
  late final TextEditingController _membersCtrl;
  late final TextEditingController _sumaryCtrl;

  late Future<List<UserModel>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _currentProject = widget.project;
    _nameCtrl = TextEditingController(text: _currentProject.name);
    _descCtrl = TextEditingController(text: _currentProject.description);
    _statusCtrl = TextEditingController(text: _currentProject.status);
    _sumaryCtrl = TextEditingController(text: _currentProject.sumary);
    _membersCtrl = TextEditingController(text: _currentProject.members?.join(', ') ?? "");
    _membersFuture = UserService.getUsersInProject(widget.project.id!);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _statusCtrl.dispose();
    _membersCtrl.dispose();
    _sumaryCtrl.dispose();
    super.dispose();
  }

  // ----------------------- UPDATE PROJECT -----------------------
  Future<void> _applyUpdate(ProjectModel updated) async {
    await context.read<ProjectCubit>().updateProject(updated.toEntity());

    setState(() {
      _currentProject = updated.toEntity();
      _membersCtrl.text = updated.members?.join(', ') ?? "";
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text("Update successfully!"),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade600,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

Future<void> _updateField({
  String? name,
  String? sumary,
  String? description,
  String? status,
  List<String>? members,
}) async {
  final updated = ProjectModel.fromEntity(_currentProject).copyWith(
    name: name,
    sumary: sumary,
    description: description,
    status: status,
    members: members,
    updatedAt: DateTime.now(),
  );
  await _applyUpdate(updated);
}


  //----------------------- CHANGE MEMBERS -----------------------
  Future<void> _changeMember(List<UserModel> selected) async {
    final ids = selected.map((u) => u.uid).toList();
    final updated = ProjectModel.fromEntity(_currentProject).copyWith(
      members: ids,
      updatedAt: DateTime.now(),
    );
    await _applyUpdate(updated);
    setState(() {
      _membersFuture = UserService.getUsersInProject(widget.project.id!);
    });
  }

  Future<void> _updateMembers() async {
    final members = await _membersFuture;
    final result = await showModalBottomSheet<List<UserModel>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeMemberToProject(currentMembers: members),
    );

    if (result != null && result.isNotEmpty) {
      await _changeMember(result);
    }
  }

  // ---------------------- EDIT FIELD MODAL ---------------------
Future<void> _edit({
  required String label,
  required TextEditingController controller,
  required Function(String text) onSave,
  int maxLines = 1,
  List<String>? options,
}) async {
  final text = await showModalBottomSheet<String>(
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
          builder: (_, scrollCtrl) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(20),
                children: [
                  // Title
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (options != null && options.isNotEmpty) ...[
                    ListView.separated(
                      controller: null,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: options.length,
                      separatorBuilder: (_, __) => const Divider(height: 0),
                      itemBuilder: (_, index) {
                        final option = options[index];
                        final isSelected = controller.text == option;
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor:
                              isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
                          title: Text(
                            option,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.blue.shade700 : Colors.black87,
                            ),
                          ),
                          onTap: () => Navigator.pop(context, option),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    TextField(
                      controller: controller,
                      maxLines: maxLines,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Enter $label",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, controller.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                        ),
                        child: const Text("Save"),
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

  if (text != null && text.trim().isNotEmpty) onSave(text.trim());
}


  // ------------------------------ UI ------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Project Infomation",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: CustomScrollView(
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),

          // Content Section
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
              _buildInfoCard(
                  title: "Summary",
                  icon: Icons.description_rounded,
                  content: _currentProject.sumary!,
                  onEdit: () => _edit(
                    label: "Summary",
                    controller: _sumaryCtrl,
                    maxLines: 3,
                    onSave: (t) => _updateField(sumary: t),
                  ),
                ),


                const SizedBox(height: 16),
                // Description Card
                _buildInfoCard(
                  title: "Description",
                  icon: Icons.description_rounded,
                  content: _currentProject.description,
                  onEdit: () => _edit(
                    label: "Description",
                    controller: _descCtrl,
                    maxLines: 3,
                    onSave: (t) => _updateField(description: t),
                  ),
                ),

                const SizedBox(height: 12),

                // Status Card
                _buildInfoCard(
                  title: "Status",
                  icon: Icons.flag_rounded,
                  content: _currentProject.status,
                  onEdit: () => _edit(
                  label: "Status",
                  controller: _statusCtrl,
                  onSave: (t) => _updateField(status: t),
                  //options: ["Active", "Review", "Done", "Blocked"],
                  options: ["Active", "Review", "Done"],
                ),
                  customContent: _buildStatusBadge(_currentProject.status),
                ),

                const SizedBox(height: 12),

                // Members Card
                _buildMembersCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ HEADER --------------------
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2196F3),
            const Color(0xFF1976D2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentProject.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              Material(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => _edit(
                    label: "Project Name",
                    controller: _nameCtrl,
                    onSave: (t) => _updateField(name: t),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------ INFO CARD --------------------
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String content,
    required VoidCallback onEdit,
    Widget? customContent,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                child: Icon(icon, size: 18, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          customContent ??
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey.shade700,
                ),
              ),
        ],
      ),
    );
  }

  // ------------------ STATUS BADGE --------------------
  Widget _buildStatusBadge(String status) {
      Color bgColor;
    Color textColor;
    IconData icon;

  switch (status.toLowerCase()) {
    case 'active':
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      icon = Icons.play_circle_rounded;
      break;
    case 'review':
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade700;
      icon = Icons.rate_review_rounded;
      break;
    case 'done':
      bgColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
      icon = Icons.check_circle_rounded;
      break;
    case 'blocked':
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      icon = Icons.block_rounded;
      break;
    default:
      bgColor = Colors.grey.shade100;
      textColor = Colors.grey.shade700;
      icon = Icons.info_rounded;
  }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ MEMBERS CARD --------------------
  Widget _buildMembersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                child: Icon(Icons.group_rounded, size: 18, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Members",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Material(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: _updateMembers,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.person_add_alt_rounded,
                      size: 18,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<UserModel>>(
            future: _membersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.people_outline, size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          "No members",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Column(
                  children: snapshot.data!
                      .map((user) => _buildUserCard(user))
                      .toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // ------------------ USER CARD --------------------
  Widget _buildUserCard(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : "?",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${user.firstName} ${user.lastName}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}