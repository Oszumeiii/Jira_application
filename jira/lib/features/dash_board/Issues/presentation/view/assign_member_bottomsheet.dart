import 'package:flutter/material.dart';
import 'package:jira/features/Users/model/user_model.dart';

class AssignMemberBottomSheet extends StatefulWidget {
  final List<UserModel> members;

  const AssignMemberBottomSheet({super.key, required this.members});

  @override
  State<AssignMemberBottomSheet> createState() => _AssignMemberBottomSheetState();
}

class _AssignMemberBottomSheetState extends State<AssignMemberBottomSheet> {
  List<UserModel> displayedMembers = [];
  List<String> selectedIds = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState(); 
    displayedMembers = widget.members;
  }

  void onSearchChanged(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      displayedMembers = widget.members
          .where((user) =>
              user.firstName.toLowerCase().contains(searchQuery) ||
              user.lastName.toLowerCase().contains(searchQuery) ||
              user.email.toLowerCase().contains(searchQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 56,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -3)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.person_add_alt_1, color: Colors.blueAccent, size: 28),
                  SizedBox(width: 8),
                  Text(
                    "Assign Members",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, color: Colors.grey, size: 28),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Search bar
          TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: "Search member...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            ),
          ),

          const SizedBox(height: 12),

          // Members list
          Expanded(
            child: displayedMembers.isEmpty
                ? const Center(child: Text("No members found"))
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: displayedMembers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final user = displayedMembers[i];
                      final isSelected = selectedIds.contains(user.uid);

                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedIds.remove(user.uid);
                            } else {
                              selectedIds.add(user.uid);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Text(
                                  user.firstName.isNotEmpty
                                      ? user.firstName.substring(0, 1)
                                      : "?",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${user.firstName} ${user.lastName}",
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      user.email,
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isSelected ? Icons.check_circle : Icons.circle_outlined,
                                color: isSelected ? Colors.blue : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 16),

          // Add button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                final selectedUsers = widget.members
                    .where((u) => selectedIds.contains(u.uid)).toList();
                    
                Navigator.pop(context, selectedUsers);
              },
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text("Assign Selected" ,  style:  TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 0, 154),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
