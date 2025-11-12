import 'package:flutter/material.dart';
import 'package:jira/features/login_signup/presenation/widgets/add_project.dart';
import 'package:jira/features/login_signup/presenation/widgets/add_project.dart';
import 'package:jira/services/project_service.dart';

class AddProjectBottomSheet extends StatefulWidget {
  const AddProjectBottomSheet({super.key});

  @override
  State<AddProjectBottomSheet> createState() => _AddProjectBottomSheetState();
}

class _AddProjectBottomSheetState extends State<AddProjectBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final String _selectedType = "Software";
  // DateTime? _startDate;
  bool _isLoading = false;

  // Future<void> _pickDate() async {
  //   final nxow = DateTime.now();
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: _startDate ?? now,
  //     firstDate: DateTime(now.year - 1),
  //     lastDate: DateTime(now.year + 5),
  //     builder: (context, child) {
  //       return Theme(
  //         data: ThemeData.light().copyWith(
  //           colorScheme: const ColorScheme.light(
  //             primary: Colors.blueAccent,
  //             onPrimary: Colors.white,
  //             surface: Colors.white,
  //           ),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );
  //   if (picked != null) {
  //     setState(() => _startDate = picked);
  //   }
  // }

  Future<void> _addProject() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please enter project name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ProjectService.addProject(
        name: _nameController.text.trim(),
        ownerId: "adGGPKGGy6uPGk3PkWQU",
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ ${result['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }

    print("Project Type: $_selectedType");
    print("Project Name: ${_nameController.text.trim()}");
    print("Summary: ${_summaryController.text.trim()}");
    print("Description: ${_descriptionController.text.trim()}");
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

            // ⚙️ Project Type
            buildDropdown(_selectedType, (fn) => setState(fn)),

            const SizedBox(height: 20),

            // 🧾 Project Name
            buildTextField(
              controller: _nameController,
              label: "Project Name",
              icon: Icons.folder_outlined,
            ),

            const SizedBox(height: 16),

            // 📝 Summary
            buildTextField(
              controller: _summaryController,
              label: "Summary",
              icon: Icons.short_text,
            ),

            const SizedBox(height: 16),

            // 📄 Description
            buildTextField(
              controller: _descriptionController,
              label: "Description",
              icon: Icons.description_outlined,
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            // 📅 Start Date
            // InkWell(
            //   onTap: _pickDate,
            //   borderRadius: BorderRadius.circular(12),
            //   child: InputDecorator(
            //     decoration: InputDecoration(
            //       labelText: "Start Date",
            //       prefixIcon: const Icon(Icons.date_range_outlined, color: Colors.blueAccent),
            //       filled: true,
            //       fillColor: Colors.blue[50]?.withOpacity(0.3),
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //     child: Text(
            //       _startDate == null
            //           ? "Not selected"
            //           : DateFormat('dd/MM/yyyy').format(_startDate!),
            //       style: TextStyle(
            //         color: _startDate == null ? Colors.grey[600] : Colors.black87,
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 28),

            // ✅ Button Create
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
                onPressed: _isLoading ? null : _addProject,
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
