import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jira/core/api_client.dart';

class AddMemberBottomSheet extends StatefulWidget {
  const AddMemberBottomSheet({super.key});

  @override
  State<AddMemberBottomSheet> createState() => _AddMemberBottomSheetState();
}

class _AddMemberBottomSheetState extends State<AddMemberBottomSheet> {
  List<Map<String, dynamic>> users = [];
  List<String> selectedIds = [];
  bool loading = true;
  String searchQuery = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  String _getInitial(dynamic name) {
  final s = (name ?? '').toString().trim();
  return s.isEmpty ? "?" : s[0].toUpperCase();
}


  Future<void> fetchUsers({String query = ""}) async {
    setState(() => loading = true);

    try {
      final response = await ApiClient.dio.get(
        '/users/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final List<dynamic> usersData = response.data['data']['users'] ?? [];
        users = usersData.cast<Map<String, dynamic>>();
      } else {
        users = [];
        debugPrint('Error fetching users: ${response.statusCode}');
      }
    } catch (e) {
      users = [];
      debugPrint('Error fetching users: $e');
    }

    setState(() => loading = false);
  }

  void onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchUsers(query: text);
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
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
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
                    "Add Members",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
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
              hintText: "Search user...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            ),
          ),

          const SizedBox(height: 12),

          // User list
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : users.isEmpty
                    ? const Center(child: Text("No users found"))
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: users.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (_, i) {
                          final u = users[i];
                          final id = u['uid'];
                          final isSelected = selectedIds.contains(id);

                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedIds.remove(id);
                                } else {
                                  selectedIds.add(id);
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
                                      _getInitial(u['firstName']),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),

                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${u['firstName']} ${u['lastName']}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          u['email'] ?? "",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
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

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                final selectedUsers = users
                    .where((u) => selectedIds.contains(u['uid']))
                    .map((u) => {
                          'uid': u['uid'].toString(),
                          'email': u['email'].toString(),
                        })
                    .toList();

                Navigator.pop(context, selectedUsers);
              },
              icon: const Icon(Icons.person_add_alt_1 , color: Color.fromARGB(255, 255, 255, 255)),
              label: const Text("Add Members" ,style: TextStyle(
                                            fontSize: 12,
                                            color: Color.fromARGB(255, 255, 255, 255),
                                          ), ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 50, 137),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
