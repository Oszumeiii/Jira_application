import 'package:flutter/material.dart';
import 'package:jira/features/dash_board/projects/domain/entities/project_entity.dart';
import 'package:jira/features/dash_board/projects/presentation/view/add_member_bottomsheet.dart';
import 'package:jira/features/login_signup/presenation/widgets/add_project.dart';

class AddProjectBottomSheet extends StatefulWidget {
  const AddProjectBottomSheet({super.key});

  @override
  State<AddProjectBottomSheet> createState() => _AddProjectBottomSheetState();
}

class _AddProjectBottomSheetState extends State<AddProjectBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Lưu member dạng map: {'uid': '...', 'email': '...'}
  List<Map<String, String>> members = [];

  final String _selectedType = "Software";
  final bool _isLoading = false;
  final String _priority = "Low";

  void _submit() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final summary = _summaryController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter project name")),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter project name")),
      );
      return;
    }

    final project = ProjectEntity(
      id: null,
      name: name,
      priority: _priority,
      projectType: _selectedType,
      sumary: summary,
      description: description,
      members: members.isNotEmpty ? members.map((m) => m['uid']!).toList() : [],
      status: "Active",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(project);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _summaryController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
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
                Icon(
                  Icons.auto_awesome_outlined,
                  color: Colors.blueAccent,
                  size: 28,
                ),
                SizedBox(width: 8),
                Text(
                  "Create New Project",
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
                  child: buildDropdown(_selectedType, (fn) => setState(fn)),
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
                      builder: (_) => const AddMemberBottomSheet(),
                    );

                    if (result != null && result.isNotEmpty) {
                      setState(() {
                        List<Map<String, String>> newMembers = List<Map<String, String>>.from(result);
                        final existingUids = members.map((e) => e['uid']).toSet();
                        members = [
                          ...members,
                          ...newMembers.where((e) => !existingUids.contains(e['uid']))
                        ];
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
                        Text(
                          "Assign",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Priority dropdown
            buildDropdownProjecType(_priority, (fn) => setState(fn)),

            const SizedBox(height: 20),

            // Project Name
            buildTextField(
              controller: _nameController,
              label: "Project Name",
              icon: Icons.folder_outlined,
            ),

            const SizedBox(height: 16),

            // Summary
            buildTextField(
              controller: _summaryController,
              label: "Summary",
              icon: Icons.short_text,
            ),

            const SizedBox(height: 16),

            // Description
            buildTextField(
              controller: _descriptionController,
              label: "Description",
              icon: Icons.description_outlined,
              maxLines: 3,
            ),

            const SizedBox(height: 10),

            if (members.isNotEmpty) ...[
                Text(
                  "Create New Project",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: members.map((m) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            m['email']?.substring(0, 1).toUpperCase() ?? '?',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          m['email'] ?? '',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            setState(() {
                              members.remove(m);
                            });
                          },
                          child: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 28),
            // Create button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: _isLoading
                      ? [Colors.blueGrey, Colors.grey]
                      : [Colors.blueAccent, Colors.lightBlueAccent],
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add_circle_outline),
                label: Text(
                  _isLoading ? 'Creating...' : 'Create Project',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
