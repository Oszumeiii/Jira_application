import 'package:flutter/material.dart';
import 'package:jira/core/api_client.dart';
import 'package:jira/features/Users/model/user_model.dart';
import 'package:jira/features/dash_board/Issues/domain/Entity/issue_entity.dart';
import 'package:jira/features/dash_board/Issues/presentation/view/assign_member_bottomsheet.dart';
import 'package:jira/features/dash_board/projects/domain/entities/project_entity.dart';
import 'package:jira/features/dash_board/projects/presentation/view/add_member_bottomsheet.dart';
import 'package:jira/features/login_signup/presenation/widgets/add_project.dart';

class AddIssueBottomsheet extends StatefulWidget {
  final ProjectEntity project; 

  const AddIssueBottomsheet({super.key, required this.project});

  @override
  State<AddIssueBottomsheet> createState() => _AddIssueBottomsheetState();
}

class _AddIssueBottomsheetState extends State<AddIssueBottomsheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<UserModel> members = [];

  String _selectedType = "Task";
  String _priority = "Low";
  bool _isLoading = false;
  UserModel? _selectedAssignee;

  void _submit() {
    final title = _titleController.text.trim();
    final summary = _summaryController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar( 
        const SnackBar(content: Text("Please enter issue title")),
      );
      return;
    }
    print(widget.project.id);

    final issue = IssueEntity(
      projectId: widget.project.id!,
      title: title,
      summary: summary,
      description: description,
      type: _selectedType.toLowerCase(), 
      priority: _priority,
      status: "todo",
      assigneeId:_selectedAssignee?.uid,
      reporterId: null,
      parentId: null,
      subTasks: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(issue);
  }


 Future<void> _loadUsers() async {
    try {
      final users = await getUsersInProject(widget.project.id!);
      setState(() {
        members = users;
      });
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  Future<List<UserModel>> getUsersInProject(String projectId) async {
    final response = await ApiClient.dio.get('/projects/$projectId/members');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final usersData = response.data['users'] as List<dynamic>;
      return usersData.map((e) => UserModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }


  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    //get member by project id
    _loadUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -3)),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Title
            Row(
              children: const [
                Icon(Icons.bug_report_outlined, color: Colors.blueAccent, size: 28),
                SizedBox(width: 8),
                Text(
                  "Create New Issue",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Type dropdown + Assign members
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(labelText: "Type"),
                    items: ["Task", "Bug", "Story", "Sub-task"]
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedType = value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    final result = await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (_) =>  AssignMemberBottomSheet(members: members),
                    );

                    if (result != null && result.isNotEmpty) {
                      setState(() {
                        List<Map<String, String>> newMembers = List<Map<String, String>>.from(result);
                        // final existingUids = members.map((e) => e['uid']).toSet();
                        // members = [
                        //   ...members,
                        //   ...newMembers.where((e) => !existingUids.contains(e['uid']))
                        // ];
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400, width: 2),
                      color: const Color.fromARGB(255, 0, 174, 255),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.person_add_alt_1, size: 20, color: Colors.black87),
                        SizedBox(width: 6),
                        Text("Assign", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Priority dropdown
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: const InputDecoration(labelText: "Priority"),
              items: ["Low", "Medium", "High", "Critical"]
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _priority = value);
              },
            ),

            const SizedBox(height: 16),

            // Title
            buildTextField(controller: _titleController, label: "Title", icon: Icons.title),

            const SizedBox(height: 16),

            // Summary
            buildTextField(controller: _summaryController, label: "Summary", icon: Icons.short_text),

            const SizedBox(height: 16),

            // Description
            buildTextField(
                controller: _descriptionController,
                label: "Description",
                icon: Icons.description_outlined,
                maxLines: 3),

            const SizedBox(height: 28),

            // Create button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.add_circle_outline),
                label: Text(
                  _isLoading ? 'Creating...' : 'Create Issue',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
