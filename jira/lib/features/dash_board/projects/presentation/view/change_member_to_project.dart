import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jira/core/api_client.dart';
import 'package:jira/features/Users/model/user_model.dart';

class ChangeMemberToProject extends StatefulWidget {
  final List<UserModel> currentMembers;

  const ChangeMemberToProject({super.key, required this.currentMembers});

  @override
  State<ChangeMemberToProject> createState() => _ChangeMemberToProjectState();
}

class _ChangeMemberToProjectState extends State<ChangeMemberToProject> {
  List<Map<String, dynamic>> users = [];
  List<String> selectedIds = [];
  bool loading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    selectedIds = widget.currentMembers.map((m) => m.uid).toList();
    fetchUsers();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> fetchUsers({String query = ""}) async {
    setState(() => loading = true);

    try {
      final response = await ApiClient.dio.get(
        '/users/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        users = (response.data['data']['users'] ?? []).cast<Map<String, dynamic>>();
      }
    } catch (_) {
      users = [];
    }

    setState(() => loading = false);
  }

  void onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      fetchUsers(query: text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 56,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// drag handle
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

          /// title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Add Members",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, size: 26),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// search
          TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: "Search user...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (_, i) {
                      final u = users[i];
                      final id = u["uid"];

                      final isSelected = selectedIds.contains(id);

                      return InkWell(
                        onTap: () {
                          setState(() {
                            isSelected
                                ? selectedIds.remove(id)
                                : selectedIds.add(id);
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey.shade300,
                              width: 1.3,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Text(
                                  u['firstName']?[0] ?? "?",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "${u['firstName']} ${u['lastName']}",
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Icon(
                                isSelected ? Icons.check_circle : Icons.circle_outlined,
                                color: isSelected ? Colors.blue : Colors.grey,
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 16),

          /// button Add
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                final result = [
                  ...users.where((u) => selectedIds.contains(u['uid'])).map(UserModel.fromJson),
                  ...widget.currentMembers.where((m) => selectedIds.contains(m.uid)),
                ];
                Navigator.pop(context, result);
              },
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text("Add Members"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003289),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
